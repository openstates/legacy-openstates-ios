//
//  SLFDetailDataSource.m
//  StatesLege
//
//  Created by Gregory Combs on 8/4/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import "SLFDetailDataSource.h"
#import "SLFDataModels.h"

#warning This class is still under construction and is not ready for deployment yet.

@implementation SLFDetailDataSource
@synthesize detailObject;

- (id)initWithDetailObject:(id)newObject {
    NSAssert( NO, @"Subclasses must override this method."); 
    
    return ([self initWithObjClass:nil groupBy:nil]);
}

- (void)dealloc {
    self.detailObject = nil;
    [super dealloc];
}

- (NSString *)interpolatedResourcePath {
    NSAssert(self.resourcePath != NULL, @"Detail's resourcePath must be a non-empty path pattern, like /person/:age/:gender");
    if (!self.detailObject)
        return self.resourcePath;
    return RKMakePathWithObject(self.resourcePath, self.detailObject);    
}

- (void)setDetailObject:(id)object {
    if (detailObject) {
        [detailObject release];
        detailObject = nil;
    }
    detailObject = [object retain];
    if (detailObject) {
        [self loadDataWithResourcePath:[self interpolatedResourcePath];
    }
}

- (NSFetchedResultsController *)fetchedResultsController {
    return nil;
}
@end
