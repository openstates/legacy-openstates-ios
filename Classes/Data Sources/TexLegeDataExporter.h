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

- (void)exportObjectsWithEntityName:(NSString *)entityName JSON:(BOOL)doJSON force:(BOOL)force;
- (void)exportAllDataObjects;
- (void)exportAllDataObjectsWithJSON:(BOOL)doJSON force:(BOOL)force;
	
@end
