//
//  ChamberCalendarObj.m
//  TexLege
//
//  Created by Gregory Combs on 8/12/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "ChamberCalendarObj.h"
#import "UtilityMethods.h"
#import "CFeedFetcher.h"
#import "CFeedEntry.h"
#import "CFeed.h"

@implementation ChamberCalendarObj

@synthesize title, chamber, feedURLS, feedStore;

- (id)initWithDictionary:(NSDictionary *)calendarDict {
	if (self = [super init]) {
		self.title = [calendarDict valueForKey:@"title"];
		self.chamber = [calendarDict valueForKey:@"chamber"];
		self.feedURLS = [calendarDict valueForKey:@"feedURLS"];
		self.feedStore = [calendarDict valueForKey:@"feedStore"];
	}
	return self;
}

- (void)dealloc {
	
	self.title = nil;
	self.chamber = nil;
	self.feedURLS = nil;
	self.feedStore = nil;
    [super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"title: %@ - chamber: %@ - feedURLS: %@ - feedStore: %@", 
			self.title, self.chamber, self.feedURLS, self.feedStore];
}

- (NSArray *)feedEntries {
	
	if (![TexLegeReachability canReachHostWithURL:[self.feedURLS objectAtIndex:0]])		// I think just doing it once is enough?
		return nil;
	if (!self.feedStore)
		return nil;

	NSMutableArray *entryArray = [NSMutableArray array];	
	
	NSError *theError = NULL;
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLenient:YES];
	[dateFormatter setDateFormat:@"M/d/yyyy"];
	NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
	[timeFormatter setLenient:YES];
	[timeFormatter setDateFormat:@"h:mm a"];
	
	NSMutableArray *noMeetingsList = [NSMutableArray arrayWithCapacity:4];
									  
	NSInteger index = 1;
	for (NSURL *url in self.feedURLS) {
		[self.feedStore.feedFetcher subscribeToURL:url error:&theError];
		CFeed * theFeed = [self.feedStore feedForURL:url fetch:YES];
		
		for (CFeedEntry *entry in theFeed.entries) {
			NSNumber *entryChamber = self.chamber;
			if ([self.chamber integerValue] == BOTH_CHAMBERS) /// this is when we've got mutliple feeds, must be "all", educate it
				entryChamber = [NSNumber numberWithInteger:index];
			
			if ([entry.title isEqualToString:@"No committee meetings scheduled."]) {
				NSString *chamberName = nil;
				switch ([entryChamber integerValue]) {
					case HOUSE:
						chamberName = @"House";
						break;
					case SENATE:
						chamberName = @"Senate";
						break;
					case JOINT:
					default:
						chamberName = @"Joint";
						break;
				}
				
				[noMeetingsList addObject:chamberName];
				
				break;
			}
						
			NSMutableDictionary *entryDict = [[NSMutableDictionary alloc] initWithCapacity:15];
			[entryDict setObject:entryChamber forKey:@"chamber"];
						
			NSArray *components = [entry.title componentsSeparatedByString:@" - "];
			if (components && ([components count] >= 2)) {
				[entryDict setObject:[components objectAtIndex:0] forKey:@"committee"];
				
				NSDate *refDate = [dateFormatter dateFromString:[components objectAtIndex:1]];
				if (refDate)
					[entryDict setObject:refDate forKey:@"date"];
				
				if ([components objectAtIndex:1])
					[entryDict setObject:[components objectAtIndex:1] forKey:@"dateString"];
			}
			
			if (entry.link)
				[entryDict setObject:entry.link forKey:@"url"];
			
			NSString *searchString = entry.content;
			if (searchString) {
				
				// Catches:			"Time: 8:00 AM  (Canceled), Location: North Texas Tollway Authority Headquarters, Plano"
				//   also:			"Time: 9:00 AM, Location: Senate Chamber"				

				
				//static NSRange kRangeNotFound = {NSNotFound, 0};
				
				// Set whether it's cancelled/canceled(!)
				NSRange cancelRange = [searchString rangeOfString:@" (Canceled),"];
				if (cancelRange.length > 0)
					cancelRange = [searchString rangeOfString:@" (Cancelled),"];
				[entryDict setObject:[NSNumber numberWithBool:(cancelRange.length > 0)] forKey:@"cancelled"];
				

				// Time
				NSRange timeRange = [searchString rangeOfString:@"Time: "];
				NSRange placeRange = [searchString rangeOfString:@" Location: "];
				if ( timeRange.length <= 0 )
					debug_NSLog(@"Unexpected content in schedule parsing ... expected 'Time:[...]', got: %@", searchString);
				else {
					NSInteger start = timeRange.location + timeRange.length;
					NSInteger end = 0;
					if (cancelRange.location != NSNotFound && cancelRange.location > 0)
						end = cancelRange.location-1;
					else if (placeRange.location != NSNotFound && placeRange.location > 0)
						end = placeRange.location-1;
					
					if (start < end) {
						timeRange = NSMakeRange(start, end-start);
						NSString *timeString = [searchString substringWithRange:timeRange];
						if (timeString) {
							if ([timeString length] > 8)	// assholes
								timeString = [timeString substringToIndex:8];

							NSDate *tempTime = [timeFormatter dateFromString:timeString];
							if (tempTime)
								[entryDict setObject:tempTime forKey:@"time"];
							[entryDict setObject:timeString forKey:@"timeString"];
						
							// fullDate = (date + time) ... if possible
							NSString *gotDate = [entryDict objectForKey:@"dateString"];
							if (timeString && gotDate) {
								NSDateFormatter *fullFormatter = [[NSDateFormatter alloc] init];
								[fullFormatter setLenient:YES];
								[fullFormatter setDateFormat:@"M/d/yyyy h:mm a"];
								NSString *fullString = [NSString stringWithFormat:@"%@ %@", gotDate, timeString];
								NSDate *fullDate = [fullFormatter dateFromString:fullString];
								if (fullDate) {
									[entryDict setObject:fullDate forKey:@"fullDate"];
									//debug_NSLog(@"String from date %@", [fullFormatter stringFromDate:fullDate]);
								}
								else
									debug_NSLog(@"Trouble parsing full date from %@", fullString);
								
								[fullFormatter release];
							}
						}
					}						
				}

				// Location
				if ( placeRange.length <= 0 )
					debug_NSLog(@"Unexpected content in schedule parsing ... expected 'Location:[...]', got: %@", searchString);
				else {
					NSInteger start = placeRange.location + placeRange.length;
					NSInteger end = [searchString length];
					if (start < end) {
						placeRange = NSMakeRange(start, end-start);
						NSString *placeString = [searchString substringWithRange:placeRange];
						if (placeString)
							[entryDict setObject:placeString forKey:@"location"];
					}					
				}
			}
			
			[entryArray addObject:entryDict];
			[entryDict release];
		}	
		index++;
	}	
									  
	// At least one of our calendar feeds was empty (no meetings)
	if ([noMeetingsList count]) {
		NSString *titleString = nil;
		NSString *messageString = nil;
		
		if ([noMeetingsList count] > 1) {
			NSMutableString *chamberList = [NSMutableString string];
			NSInteger index = 1;
			for (NSString *chamberName in noMeetingsList) {
				if (index > 1) {
					if ([noMeetingsList count] > 2)
						[chamberList appendString:@", "];
					else
						[chamberList appendString:@" "];
				}
				if (index == [noMeetingsList count]) {
					[chamberList appendString:@"or "];
				}
				[chamberList appendString:chamberName];
				index++;
			}
			titleString = [NSString stringWithFormat:@"No meetings scheduled.", chamberList];
			messageString = [NSString stringWithFormat:@"Currently, there are no %@ meetings scheduled. Try again later.", chamberList];
			
		}
		else {
			NSString *chamberName = [noMeetingsList objectAtIndex:0];
			titleString = [NSString stringWithFormat:@"No %@ meetings scheduled.", chamberName];
			messageString = [NSString stringWithFormat:@"Currently, there are no %@ meetings scheduled. Try again later.", chamberName];
		}

		UIAlertView *noMeetingsAlert = [[[ UIAlertView alloc ] 
										 initWithTitle:titleString 
										 message:messageString 
										 delegate:nil // we're static, so don't do "self"
										 cancelButtonTitle: @"Cancel" 
										 otherButtonTitles:nil, nil] autorelease];
		
		[ noMeetingsAlert show ];		
	}
	
	[dateFormatter release];
	[timeFormatter release];
	
	return entryArray;
}

@end
