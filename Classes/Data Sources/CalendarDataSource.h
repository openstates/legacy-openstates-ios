//
//  CalendarDataSource.h
//  TexLege
//
//  Created by Gregory Combs on 7/27/10.
//  Copyright (c) 2010 University of Texas at Dallas. All rights reserved.
//

#import "TableDataSourceProtocol.h"

@class CFeedStore;
@interface CalendarDataSource : NSObject <TableDataSource> {

	IBOutlet NSManagedObjectContext *managedObjectContext;
	NSArray *calendarList;
	
	NSURL *senateURL, *houseURL, *jointURL;
	CFeedStore *feedStore;
}
@property (nonatomic,retain) IBOutlet NSManagedObjectContext *managedObjectContext;
@property (nonatomic,retain) NSArray *calendarList;
@property (nonatomic,retain) NSURL *senateURL, *houseURL, *jointURL;
@property (nonatomic,retain) CFeedStore *feedStore;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)newContext;

@end
