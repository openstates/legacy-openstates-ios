//
//  TexLegeDataExporter.h
//  TexLege
//
//  Created by Gregory Combs on 8/31/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TexLegeDataExporter : NSObject {

}
@property (nonatomic,retain) NSManagedObjectContext *managedObjectContext;

- (id) initWithManagedObjectContext:(NSManagedObjectContext*)newContext;
- (void)exportObjectsWithEntityName:(NSString *)entityName;
- (void)exportAllDataObjects;
	
@end
