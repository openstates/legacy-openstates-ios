//
//  SLFDetailDataSource.m
//  StatesLege
//
//  Created by Gregory Combs on 8/4/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import "SLFDetailDataSource.h"
#import "SLFDataModels.h"
#import "UtilityMethods.h"

@implementation SLFDetailDataSource
@synthesize detailObject;
@synthesize detailObjectID;

- (id)initWithDetailObjectID:(NSString *)newID {
    NSCAssert( NO, @"Subclasses must override this method."); 
    
    return ([self initWithObjClass:nil sortBy:nil groupBy:nil]);
}

- (void)dealloc {
    self.detailObject = nil;
    self.detailObjectID = nil;
    [super dealloc];
}

    //TODO: Consider using our RKRouter to do this with a real object ???
- (NSString *)buildResourcePathWithObjectID:(NSString *)newID {
    if (newID)
        return [self.resourcePath stringByAppendingFormat:@"%@/", newID]; // default behavior ala @"/legislators/TXL23423/"
    return self.resourcePath;
}

- (void)setDetailObjectID:(NSString *)newID {
    
    [detailObjectID release];
    detailObjectID = [newID retain];
    
    if (!IsEmpty(newID)) {
        [self loadDataWithResourcePath:[self buildResourcePathWithObjectID:newID]];
    }
}

- (NSString *)primaryKeyProperty {
    return self.detailObjectID;
}

- (NSFetchedResultsController *)fetchedResultsController {
    return nil;
}
@end
