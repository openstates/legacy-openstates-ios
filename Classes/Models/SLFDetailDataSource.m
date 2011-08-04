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
    
    return ([self initWithResourcePath:nil objClass:nil sortBy:nil groupBy:nil]);
}

- (void)dealloc {
    self.detailObject = nil;
    self.detailObjectID = nil;
    [super dealloc];
}

- (NSString *)buildResourcePathWithObjectID:(NSString *)newID {
    NSCAssert( NO, @"Subclasses must override this method."); 
    return nil;
}

- (void)setDetailObjectID:(NSString *)newID {
    
    [detailObjectID release];
    detailObjectID = [newID retain];
    
    if (!IsEmpty(newID)) {
        self.resourcePath = [self buildResourcePathWithObjectID:newID];
        [self loadData];
    }
}

- (NSString *)primaryKeyProperty {
    return self.detailObjectID;
}

- (NSFetchedResultsController *)fetchedResultsController {
    return nil;
}
@end
