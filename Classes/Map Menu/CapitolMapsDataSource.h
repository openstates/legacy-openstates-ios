//
//  CapitolMapsDataSource.h
//  TexLege
//
//  Created by Gregory Combs on 7/22/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "Constants.h"
#import "TableDataSourceProtocol.h"
#import "CapitolMap.h"

@interface CapitolMapsDataSource : NSObject <TableDataSource> {
	IBOutlet NSManagedObjectContext *managedObjectContext;
@private
	NSMutableArray *sectionList;
}
@property (nonatomic,retain) IBOutlet NSManagedObjectContext *managedObjectContext;
@property (nonatomic,retain) NSMutableArray *sectionList;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)newContext;

@end
