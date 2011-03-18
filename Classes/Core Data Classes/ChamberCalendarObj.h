//
//  ChamberCalendarObj.h
//  TexLege
//
//  Created by Gregory Combs on 8/12/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "Kal.h"

@interface ChamberCalendarObj : NSObject <KalDataSource> {	
	NSMutableArray *rows;
	NSMutableArray *events;
	BOOL hasPostedAlert;
}

@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSNumber *chamber;

- (NSDictionary *)eventForIndexPath:(NSIndexPath*)indexPath;
- (NSArray *)filterEventsByString:(NSString *)filterString;

@end
