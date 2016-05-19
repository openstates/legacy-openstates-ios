//
//  DataModelsTestCase.m
//  StatesLegeRestTest
//
//  Created by Greg Combs on 9/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <SLFRestKit/SLFRestKit.h>

#import "SLFSpecEnvironment.h"
#import "SLFDataModels.h"

@interface DataModelsTestCase : XCTestCase
@end

@implementation DataModelsTestCase

- (void)setUp
{    
    [super setUp];
    SLFSpecRestKitEnvironment();
}

- (void)testItShouldCreateTwoStates {
    RKManagedObjectStore *store = [[RKObjectManager sharedManager] objectStore];
    XCTAssertNotNil(store, @"Managed object store should exist, but it doesn't!");
    NSManagedObjectContext *context = [store managedObjectContext];
    XCTAssertNotNil(context, @"Managed object context should exist, but it doesn't!");
    
    [SLFState truncateAll];
    UInt16 stateCount = [SLFState count:nil];
    XCTAssertTrue(stateCount == 0, @"We should have an empty list of states in Core Data, but we don't!");
    
    SLFState *state1 = [SLFState createInContext:context];
    XCTAssertNotNil(state1, @"Failed to create a new state");
    state1.stateID = @"tx";
    state1.name = @"Texas";
    state1.upperChamberName = @"Senate";
    state1.lowerChamberName = @"House of Representatives";
    
    SLFState *state2 = [SLFState createInContext:context];
    XCTAssertNotNil(state2, @"Failed to create a new state");
    state2.stateID = @"ca";
    state2.name = @"California";
    state2.upperChamberName = @"Senate";
    state2.lowerChamberName = @"Assembly";
    
    NSError *error = [store save];
    XCTAssertNil(error, @"Failed to save new states to the managed object store.  Error = %@", [error description]);
    stateCount = [SLFState count:nil];
    XCTAssertTrue(stateCount == 2, @"We should have 2 states in our list, but we don't!  State count = %ud", stateCount);
}

@end
