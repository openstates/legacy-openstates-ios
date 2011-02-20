//
//  BillsMenuDataSource.h
//  TexLege
//
//  Created by Gregory Combs on 2/16/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import "TableDataSourceProtocol.h"


@interface BillsMenuDataSource : NSObject <TableDataSource> {
	NSArray *_menuItems;
}

@property (nonatomic,retain) IBOutlet NSManagedObjectContext *managedObjectContext;
@property (nonatomic,readonly) NSArray *menuItems;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)newContext;

@end
