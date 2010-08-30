//
//  LegislatorDetailDataSource.h
//  TexLege
//
//  Created by Gregory Combs on 8/29/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LegislatorObj.h"

@interface LegislatorDetailDataSource : NSObject <UITableViewDataSource> {

}

- (id)initWithLegislator:(LegislatorObj *)newObject;
- (id) dataObjectForIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForDataObject:(id)dataObject;
	

@property (nonatomic,readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,retain) LegislatorObj *legislator;
@property (nonatomic,retain) NSMutableArray *sectionArray;

@end
