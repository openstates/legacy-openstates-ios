//
//  CalendarDataSource.m
//  TexLege
//
//  Created by Gregory Combs on 7/27/10.
//  Copyright (c) 2010 University of Texas at Dallas. All rights reserved.
//

#import "CalendarDataSource.h"
#import "CFeedStore.h"
#import "CFeedFetcher.h"
#import "CFeedEntry.h"
#import "CFeed.h"
#import "UtilityMethods.h"
#import "RegexKitLite.h"
#import "TexLegeTheme.h"

@implementation CalendarDataSource
@synthesize managedObjectContext;
@synthesize calendarList, senateURL, houseURL, jointURL, feedStore;


- (NSString *)navigationBarName
{ return @"Upcoming Meetings"; }

- (NSString *)name
{ return @"Meetings"; }

- (UIImage *)tabBarImage 
{ return [UIImage imageNamed:@"83-calendar.png"]; }

- (BOOL)showDisclosureIcon
{ return YES; }

- (BOOL)usesCoreData
{ return NO; }

- (BOOL)canEdit
{ return NO; }


// displayed in a plain style tableview
- (UITableViewStyle)tableViewStyle {
	return UITableViewStylePlain;
}

- (id)init {
	self = [super init];
	if (self !=nil) {
		/* Build a list of files */		
		self.calendarList = [NSArray arrayWithObjects:
							 @"All Upcoming Meetings", @"Upcoming House Meetings", 
							 @"Upcoming Senate Meetings", @"Upcoming Joint Meetings", nil];	
		
		static NSString *senateURLString = @"http://www.capitol.state.tx.us/MyTLO/RSS/RSS.aspx?Type=upcomingmeetingssenate";
		static NSString *houseURLString = @"http://www.capitol.state.tx.us/MyTLO/RSS/RSS.aspx?Type=upcomingmeetingshouse";
		static NSString *jointURLString = @"http://www.capitol.state.tx.us/MyTLO/RSS/RSS.aspx?Type=upcomingmeetingsjoint";
		
		self.senateURL = [NSURL URLWithString:senateURLString];
		self.houseURL = [NSURL URLWithString:houseURLString];
		self.jointURL = [NSURL URLWithString:jointURLString];
		

	}
	return self;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)newContext {
	if ([self init]) {
		if (newContext)
			self.managedObjectContext = newContext;
		
		NSArray *feedURLs = [[NSArray alloc] initWithObjects:self.senateURL, self.houseURL, self.jointURL, nil];
		NSError *theError = NULL;

		@try {
			debug_NSLog(@"Beginning feed subscriptions - %@", [NSDate date]);
			
			self.feedStore = [CFeedStore instance];
			for (NSURL *url in feedURLs) {
				[feedStore.feedFetcher subscribeToURL:url error:&theError];
			}			
			debug_NSLog(@"Ended feed subscriptions -- %@", [NSDate date]);
		}
		@catch (NSException * e) {
			debug_NSLog(@"Error when initializing calendar feed subscriptions:\n  %@\n   %@", [theError description], [e description]);
		}
		
		[feedURLs release];

	}
	return self;
}


// Returns an array of the appropriate feed entries (CFeedEntry)...
- (NSArray *)feedEntriesForIndexPath:(NSIndexPath *)indexPath {	
	NSArray *feedURLs = nil;
	
	if (![UtilityMethods isNetworkReachable]) {
		[UtilityMethods noInternetAlert];
		return nil;
	}
	NSMutableArray *entryArray = [NSMutableArray array];
	NSNumber *chamberType = [NSNumber numberWithInteger:indexPath.row];		// save this for later
	
	switch (indexPath.row) {
		case JOINT:
			feedURLs = [[NSArray alloc] initWithObjects:self.jointURL,nil];
			break;
		case HOUSE:
			feedURLs = [[NSArray alloc] initWithObjects:self.houseURL,nil];
			break;
		case SENATE:
			feedURLs = [[NSArray alloc] initWithObjects:self.senateURL,nil];
			break;
		default:	// "BOTH" ... but really this means all (0)
			feedURLs = [[NSArray alloc] initWithObjects:self.houseURL,self.senateURL,self.jointURL,nil];
			break;
	}
	
	if ([UtilityMethods canReachHostWithURL:[feedURLs objectAtIndex:0]]) {		// I think just doing it once is enough?
		NSError *theError = NULL;
		
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setLenient:YES];
		[dateFormatter setDateFormat:@"M/d/yyyy"];
		NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
		[timeFormatter setLenient:YES];
		[timeFormatter setDateFormat:@"h:mm a"];
		
		if (!self.feedStore)
			self.feedStore = [CFeedStore instance];

		NSInteger index = 1;
		for (NSURL *url in feedURLs) {
			[self.feedStore.feedFetcher subscribeToURL:url error:&theError];
			CFeed * theFeed = [self.feedStore feedForURL:url fetch:YES];
			
			for (CFeedEntry *entry in theFeed.entries) {
				if (indexPath.row == BOTH_CHAMBERS) /// this is when we've got mutliple feeds, must be "all", educate it
					chamberType = [NSNumber numberWithInteger:index];
				
				NSMutableDictionary *entryDict = [[NSMutableDictionary alloc] initWithCapacity:15];
				[entryDict setObject:chamberType forKey:@"chamber"];
				
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

	}
	[feedURLs release];

	return entryArray;
}


#pragma mark -
#pragma mark UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{		
	static NSString *CellIdentifier = @"Cell";
	NSInteger row = indexPath.row;
	
	/* Look up cell in the table queue */
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	/* Not found in queue, create a new cell object */
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewStylePlain reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.textColor =	[TexLegeTheme textDark];
		cell.textLabel.textAlignment = UITextAlignmentLeft;
		cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
		
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.textLabel.adjustsFontSizeToFitWidth = YES;
		cell.textLabel.minimumFontSize = 12.0f;
		//cell.accessoryView = [TexLegeTheme disclosureLabel:YES];
		cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure"]] autorelease];
    }
	// configure cell contents

	BOOL useDark = (indexPath.row % 2 == 0);
	cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
	
	//if ([self showDisclosureIcon])
	//	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	cell.textLabel.text = [self.calendarList objectAtIndex:row];
		
	return cell;
}


- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section 
{		
	return [self.calendarList count];
}

- (void)dealloc {
	self.senateURL = self.houseURL = self.jointURL = nil;
	self.feedStore = nil;

	self.calendarList = nil;
	self.managedObjectContext = nil;
	[super dealloc];
}


@end
