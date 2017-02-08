//
//  SLToastKitTests.m
//  SLToastKit
//
//  Created by Gregory Combs on 7/10/16.
//  Copyright (C) 2016 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.
//

#import <XCTest/XCTest.h>
#import <SLToastKit/SLToastKit.h>

@interface SLToastKitTests : XCTestCase

@end

@implementation SLToastKitTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInvalidInfoFromDict {
    struct SLToastKeys keys = SLToastKeys;

    NSDictionary *dict = @{
                           keys.identifier: [NSNull null], // Must be a non-null string
                           keys.title: @"Some title",
                           keys.subtitle: [NSNull null],
                           keys.duration: @(-1)
                           };
    SLToast *toastInfo = [[SLToast alloc] initWithDictionary:dict];
    XCTAssertNil(toastInfo, @"Invalid initializer properties should not instantiate");
}

- (void)testInfoRepresentation {
    SLToast *infoItem = [[SLToast alloc] initWithIdentifier:@"Test Item"
                                                               type:SLToastTypeActivity
                                                              title:@"Test title"
                                                           subtitle:@"Test subtitle"
                                                              image:nil
                                                           duration:99];
    XCTAssertNotNil(infoItem, @"Info should instantiate with valid properties");

    NSDictionary *representation = [infoItem dictionaryRepresentation];
    XCTAssertNotNil(representation, @"Info should have a dictionary representation");
}

- (void)testInfoEquality {
    SLToast *infoItem1 = [[SLToast alloc] initWithIdentifier:@"Test Item"
                                                                type:SLToastTypeActivity
                                                               title:@"Test title"
                                                            subtitle:@"Test subtitle"
                                                               image:nil
                                                            duration:99];
    infoItem1.status = SLToastStatusQueued;

    SLToast *infoItem2 = [infoItem1 copy];
    XCTAssertEqualObjects(infoItem1, infoItem2, @"A copy of an info item should be an equal object (until status changes)");

    infoItem2.status = SLToastStatusFinished;
    XCTAssertNotEqualObjects(infoItem1, infoItem2, @"If an info status changes, it won't be equal to its former self");
}

@end
