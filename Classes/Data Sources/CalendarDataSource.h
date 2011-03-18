//
//  CalendarDataSource.h
//  TexLege
//
//  Created by Gregory Combs on 7/27/10.
//  Copyright (c) 2010 Gregory S. Combs. All rights reserved.
//

#import "TableDataSourceProtocol.h"

@interface CalendarDataSource : NSObject <TableDataSource> {
}
@property (nonatomic,readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,retain) NSMutableArray *calendarList;

@end
