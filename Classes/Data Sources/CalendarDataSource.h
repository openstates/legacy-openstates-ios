//
//  CalendarDataSource.h
//  TexLege
//
//  Created by Gregory Combs on 7/27/10.
//  Copyright (c) 2010 University of Texas at Dallas. All rights reserved.
//

#import "TableDataSourceProtocol.h"


@interface CalendarDataSource : NSObject <TableDataSource> {

	IBOutlet NSManagedObjectContext *managedObjectContext;
	NSArray *calendarList;
}
@property (nonatomic,retain) IBOutlet NSManagedObjectContext *managedObjectContext;
@property (nonatomic,retain) NSArray *calendarList;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)newContext;


@end
