//
//  ChamberCalendarObj.h
//  TexLege
//
//  Created by Gregory Combs on 8/12/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "CFeedStore.h"
#import "Kal.h"

@interface ChamberCalendarObj : NSObject <KalDataSource> {	
	NSMutableArray *rows;
	NSMutableArray *events;
	BOOL hasPostedAlert;
}

@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSNumber *chamber;
@property (nonatomic,retain) NSArray *feedURLS;
@property (nonatomic,retain) CFeedStore *feedStore;


/* Each event dictionary looks like this:
 @"chamber": NSNumber of BOTH_CHAMBERS/HOUSE/SENATE/JOINT 
 @"committee": NSString of the committee name 
 @"date": NSDate
 @"dateString": NSString of NSDate
 @"url": NSString of the url string
 @"cancelled": NSNumber of a BOOL, whether or not the event is cancelled
 @"time": NSDate of the time
 @"timeString": NSString of the time
 @"fullDate": NSDate of the date & time
 @"location": NSString of the event location
 @"rawDateTime" : Failsafe NSString of the entire date/time string
 */

- (NSDictionary *)eventForIndexPath:(NSIndexPath*)indexPath;
- (NSArray *)filterEventsByString:(NSString *)filterString;

@end
