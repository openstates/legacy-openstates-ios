//
//  SLFReachableTests.m
//  Created by Greg Combs on 10/7/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <XCTest/XCTest.h>
#import "SLFReachable.h"

@interface SLFReachableTests : XCTestCase

@end


@implementation SLFReachableTests

- (void)setUp {
    SLFReachable *reachable = [SLFReachable sharedReachable];
        //NSSet *hosts = [NSSet setWithObjects:@"openstates.org", @"www.stateline.org", @"transparencydata.com", @"www.followthemoney.org", @"www.votesmart.org", nil];
        //[reachable watchHostsInSet:hosts];
    [reachable watchHostNamed:@"openstates.org"];
}

- (void)testItShouldObtainASharedReachabilityManager
{
    SLFReachable *reachable = [SLFReachable sharedReachable];
    XCTAssertNotNil(reachable, @"Reachable object did not instantiate.");
}

- (void)testItShouldVerifyNetworkReachability
{
    SLFReachable *reachable = [SLFReachable sharedReachable];
    XCTAssertTrue([reachable isNetworkReachable], @"Network should be reachable");
}

- (void)testItShouldVerifyHostReachabilityForKnownHosts
{
    SLFReachable *reachable = [SLFReachable sharedReachable];
    XCTAssertTrue([reachable isHostReachable:@"openstates.org"], @"Host should be reachable");
}

- (void)testItShouldDetermineUnknownHostReachabilityByAnyNetAccess
{
    SLFReachable *reachable = [SLFReachable sharedReachable];
    NSString *host = @"flimflam.com";
    BOOL isNetworkReachable = [reachable isNetworkReachable];
    BOOL isHostReachable = [reachable isHostReachable:host];
    XCTAssertEqual(isHostReachable,isNetworkReachable, @"Host should be reachable, as far as we know");
}

- (void)testItShouldVerifyURLReachability
{
    SLFReachable *reachable = [SLFReachable sharedReachable];
    NSString *urlString = @"http://openstates.org";
    NSURL *url = [NSURL URLWithString:urlString];
    XCTAssertTrue([reachable isURLStringReachable:urlString], @"Url String should be reachable");
    XCTAssertTrue([reachable isURLReachable:url], @"Url should be reachable");    
}
@end
