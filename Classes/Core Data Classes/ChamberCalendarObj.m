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
#import "RegexKitLite.h"

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
	
	if (![UtilityMethods canReachHostWithURL:[self.feedURLS objectAtIndex:0]])		// I think just doing it once is enough?
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
	
	NSInteger index = 1;
	for (NSURL *url in self.feedURLS) {
		[self.feedStore.feedFetcher subscribeToURL:url error:&theError];
		CFeed * theFeed = [self.feedStore feedForURL:url fetch:YES];
		
		for (CFeedEntry *entry in theFeed.entries) {
			NSNumber *entryChamber = self.chamber;
			
			if ([self.chamber integerValue] == BOTH_CHAMBERS) /// this is when we've got mutliple feeds, must be "all", educate it
				entryChamber = [NSNumber numberWithInteger:index];
			
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
				static NSString *regexString = @"Time:\\s+([0-9]+:[0-9]+\\s+[AP]M)(\\s+\\(Cance[l]+ed\\))?,\\s+Location:\\s+(.+)$";
				
				if([searchString isMatchedByRegex:regexString]) {
					NSString *timeString = [searchString stringByMatching:regexString capture:1L];
					if (timeString) {
						[entryDict setObject:[timeFormatter dateFromString:timeString] forKey:@"time"];
						[entryDict setObject:timeString forKey:@"timeString"];
					}
					
					NSString *cancelledStr   = [searchString stringByMatching:regexString capture:2L];
					[entryDict setObject:[NSNumber numberWithBool:(cancelledStr != nil)] forKey:@"cancelled"];
					
					NSString *location   = [searchString stringByMatching:regexString capture:3L];
					if (location)
						[entryDict setObject:location forKey:@"location"];
				}
			}
			
			[entryArray addObject:entryDict];
			[entryDict release];
		}	
		index++;
	}	
	[dateFormatter release];
	[timeFormatter release];
	
	return entryArray;
}

@end
