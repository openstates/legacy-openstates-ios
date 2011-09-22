//
//  ObjMappingsTestCase.m
//  StatesLegeRestTest
//
//  Created by Greg Combs on 9/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <RestKit/CoreData/CoreData.h>

#import "SLFSpecEnvironment.h"
#import "SLFDataModels.h"
#import "SLFMappingsManager.h"

@interface ObjMappingsTestCase : SenTestCase
@end

@implementation ObjMappingsTestCase

- (void)setUp
{    
    [super setUp];
    RKManagedObjectStore* store = SLFSpecNewManagedObjectStore();
    STAssertNotNil(store, @"Failed to create a managed object store.");
    RKObjectManager* manager = SLFSpecNewObjectManager();
    STAssertNotNil(manager, @"Failed to create an object manager.");
    manager.objectStore = store;
    NSManagedObjectContext* context = [store managedObjectContext];
    STAssertNotNil(context, @"Failed to find a shared managed object context.");
    
    SLFMappingsManager *mapper = [[SLFMappingsManager alloc] init];
    [mapper registerMappings];
    [mapper release];
}

- (void)testItShouldFindAStateObjectMapping {
    RKObjectManager *manager = [RKObjectManager sharedManager];
    STAssertNotNil(manager, @"Object manager should exist but it doesn't!");
    NSObject <RKObjectMappingDefinition> *returnedMapping = [manager.mappingProvider objectMappingForClass:[SLFState class]];
    STAssertNotNil(returnedMapping, @"Failed to a previously created object mapping.");
}

/*
 #pragma mark - RKObjectMapper Specs
 
 - (void)itShouldPerformBasicMapping {
 RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKExampleUser class]];
 RKObjectAttributeMapping* idMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"id" toKeyPath:@"userID"];
 [mapping addAttributeMapping:idMapping];
 RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
 [mapping addAttributeMapping:nameMapping];
 
 RKObjectMapper* mapper = [RKObjectMapper new];
 id userInfo = RKSpecParseFixture(@"user.json");
 RKExampleUser* user = [RKExampleUser user];
 BOOL success = [mapper mapFromObject:userInfo toObject:user atKeyPath:@"" usingMapping:mapping];
 [mapper release];
 [expectThat(success) should:be(YES)];
 [expectThat(user.userID) should:be(31337)];
 [expectThat(user.name) should:be(@"Blake Watters")];
 }
 
 - (void)itShouldMapACollectionOfSimpleObjectDictionaries {
 RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKExampleUser class]];
 RKObjectAttributeMapping* idMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"id" toKeyPath:@"userID"];
 [mapping addAttributeMapping:idMapping];
 RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
 [mapping addAttributeMapping:nameMapping];
 
 RKObjectMapper* mapper = [RKObjectMapper new];
 id userInfo = RKSpecParseFixture(@"users.json");
 NSArray* users = [mapper mapCollection:userInfo atKeyPath:@"" usingMapping:mapping];
 [expectThat([users count]) should:be(3)];
 RKExampleUser* blake = [users objectAtIndex:0];
 [expectThat(blake.name) should:be(@"Blake Watters")];
 [mapper release];
 }
 
 - (void)itShouldDetermineTheObjectMappingByConsultingTheMappingProviderWhenThereIsATargetObject {
 RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKExampleUser class]];
 RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
 [provider setMapping:mapping forKeyPath:@""];
 id mockProvider = [OCMockObject partialMockForObject:provider];
 
 id userInfo = RKSpecParseFixture(@"user.json");
 RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:mockProvider];
 mapper.targetObject = [RKExampleUser user];
 [mapper performMapping];
 
 [mockProvider verify];
 }
 
 - (void)itShouldAddAnErrorWhenTheKeyPathMappingAndObjectClassDoNotAgree {
 RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKExampleUser class]];
 RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
 [provider setMapping:mapping forKeyPath:@""];
 id mockProvider = [OCMockObject partialMockForObject:provider];
 
 id userInfo = RKSpecParseFixture(@"user.json");
 RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:mockProvider];
 mapper.targetObject = [NSDictionary new];
 [mapper performMapping];
 [expectThat([mapper errorCount]) should:be(1)];
 }
 
 - (void)itShouldMapToATargetObject {
 RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKExampleUser class]];
 RKObjectAttributeMapping* idMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"id" toKeyPath:@"userID"];
 [mapping addAttributeMapping:idMapping];
 RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
 [mapping addAttributeMapping:nameMapping];
 
 RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
 [provider setMapping:mapping forKeyPath:@""];
 id mockProvider = [OCMockObject partialMockForObject:provider];
 
 id userInfo = RKSpecParseFixture(@"user.json");
 RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:mockProvider];
 RKExampleUser* user = [RKExampleUser user];
 mapper.targetObject = user;
 RKObjectMappingResult* result = [mapper performMapping];
 
 [mockProvider verify];
 [expectThat(result) shouldNot:be(nil)];
 [expectThat([result asObject] == user) should:be(YES)];
 [expectThat(user.name) should:be(@"Blake Watters")];
 }
 
 - (void)itShouldCreateANewInstanceOfTheAppropriateDestinationObjectWhenThereIsNoTargetObject {
 RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKExampleUser class]];
 RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
 [mapping addAttributeMapping:nameMapping];
 
 RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
 [provider setMapping:mapping forKeyPath:@""];
 id mockProvider = [OCMockObject partialMockForObject:provider];
 
 id userInfo = RKSpecParseFixture(@"user.json");
 RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:mockProvider];
 id mappingResult = [[mapper performMapping] asObject];
 [expectThat([mappingResult isKindOfClass:[RKExampleUser class]]) should:be(YES)];
 }
 
 - (void)itShouldDetermineTheMappingClassForAKeyPathByConsultingTheMappingProviderWhenMappingADictionaryWithoutATargetObject {
 RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKExampleUser class]];        
 RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
 [provider setMapping:mapping forKeyPath:@""];
 id mockProvider = [OCMockObject partialMockForObject:provider];
 [[mockProvider expect] mappingsByKeyPath];
 
 id userInfo = RKSpecParseFixture(@"user.json");
 RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:mockProvider];
 [mapper performMapping];
 [mockProvider verify];
 }
 
 - (void)itShouldMapWithoutATargetMapping {
 RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKExampleUser class]];
 RKObjectAttributeMapping* idMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"id" toKeyPath:@"userID"];
 [mapping addAttributeMapping:idMapping];
 RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
 [mapping addAttributeMapping:nameMapping];
 
 RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
 [provider setMapping:mapping forKeyPath:@""];
 id mockProvider = [OCMockObject partialMockForObject:provider];
 
 id userInfo = RKSpecParseFixture(@"user.json");
 RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:mockProvider];
 RKExampleUser* user = [[mapper performMapping] asObject];
 [expectThat([user isKindOfClass:[RKExampleUser class]]) should:be(YES)];
 [expectThat(user.name) should:be(@"Blake Watters")];
 }
 
 - (void)itShouldMapACollectionOfObjects {
 RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKExampleUser class]];
 RKObjectAttributeMapping* idMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"id" toKeyPath:@"userID"];
 [mapping addAttributeMapping:idMapping];
 RKObjectAttributeMapping* nameMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"name" toKeyPath:@"name"];
 [mapping addAttributeMapping:nameMapping];
 RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
 [provider setMapping:mapping forKeyPath:@""];
 
 id userInfo = RKSpecParseFixture(@"users.json");
 RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:provider];
 RKObjectMappingResult* result = [mapper performMapping];
 NSArray* users = [result asCollection];
 [expectThat([users isKindOfClass:[NSArray class]]) should:be(YES)];
 [expectThat([users count]) should:be(3)];
 RKExampleUser* user = [users objectAtIndex:0];
 [expectThat([user isKindOfClass:[RKExampleUser class]]) should:be(YES)];
 [expectThat(user.name) should:be(@"Blake Watters")];
 }
 
 - (void)itShouldMapACollectionOfObjectsWithDynamicKeys {
 RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKExampleUser class]];
 mapping.forceCollectionMapping = YES;
 [mapping mapKeyOfNestedDictionaryToAttribute:@"name"];    
 RKObjectAttributeMapping* idMapping = [RKObjectAttributeMapping mappingFromKeyPath:@"(name).id" toKeyPath:@"userID"];
 [mapping addAttributeMapping:idMapping];
 RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
 [provider setMapping:mapping forKeyPath:@"users"];
 
 id userInfo = RKSpecParseFixture(@"DynamicKeys.json");
 RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:provider];
 RKObjectMappingResult* result = [mapper performMapping];
 NSArray* users = [result asCollection];
 [expectThat([users isKindOfClass:[NSArray class]]) should:be(YES)];
 [expectThat([users count]) should:be(2)];
 RKExampleUser* user = [users objectAtIndex:0];
 [expectThat([user isKindOfClass:[RKExampleUser class]]) should:be(YES)];
 [expectThat(user.name) should:be(@"blake")];
 user = [users objectAtIndex:1];
 [expectThat([user isKindOfClass:[RKExampleUser class]]) should:be(YES)];
 [expectThat(user.name) should:be(@"rachit")];
 }
 
 - (void)itShouldMapACollectionOfObjectsWithDynamicKeysAndRelationships {
 RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKExampleUser class]];
 mapping.forceCollectionMapping = YES;
 [mapping mapKeyOfNestedDictionaryToAttribute:@"name"];
 
 RKObjectMapping* addressMapping = [RKObjectMapping mappingForClass:[RKSpecAddress class]];
 [addressMapping mapAttributes:@"city", @"state", nil];
 [mapping mapKeyPath:@"(name).address" toRelationship:@"address" withMapping:addressMapping];
 RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
 [provider setMapping:mapping forKeyPath:@"users"];
 
 id userInfo = RKSpecParseFixture(@"DynamicKeysWithRelationship.json");
 RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:provider];
 RKObjectMappingResult* result = [mapper performMapping];
 NSArray* users = [result asCollection];
 [expectThat([users isKindOfClass:[NSArray class]]) should:be(YES)];
 [expectThat([users count]) should:be(2)];
 RKExampleUser* user = [users objectAtIndex:0];
 [expectThat([user isKindOfClass:[RKExampleUser class]]) should:be(YES)];
 [expectThat(user.name) should:be(@"blake")];
 user = [users objectAtIndex:1];
 [expectThat([user isKindOfClass:[RKExampleUser class]]) should:be(YES)];
 [expectThat(user.name) should:be(@"rachit")];
 [expectThat(user.address) shouldNot:be(nil)];
 [expectThat(user.address.city) should:be(@"New York")];
 }
 
 - (void)itShouldMapANestedArrayOfObjectsWithDynamicKeysAndArrayRelationships {
 RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKExampleGroupWithUserArray class]];
 [mapping mapAttributes:@"name", nil];
 
 
 RKObjectMapping* userMapping = [RKObjectMapping mappingForClass:[RKExampleUser class]];
 userMapping.forceCollectionMapping = YES;
 [userMapping mapKeyOfNestedDictionaryToAttribute:@"name"];
 [mapping mapKeyPath:@"users" toRelationship:@"users" withMapping:userMapping];
 
 RKObjectMapping* addressMapping = [RKObjectMapping mappingForClass:[RKSpecAddress class]];
 [addressMapping mapAttributes:
 @"city", @"city",
 @"state", @"state",
 @"country", @"country",
 nil
 ];
 [userMapping mapKeyPath:@"(name).address" toRelationship:@"address" withMapping:addressMapping];
 RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
 [provider setMapping:mapping forKeyPath:@"groups"];
 
 id userInfo = RKSpecParseFixture(@"DynamicKeysWithNestedRelationship.json");
 RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:provider];
 RKObjectMappingResult* result = [mapper performMapping];
 
 NSArray* groups = [result asCollection];
 [expectThat([groups isKindOfClass:[NSArray class]]) should:be(YES)];
 [expectThat([groups count]) should:be(2)];
 
 RKExampleGroupWithUserArray* group = [groups objectAtIndex:0];
 [expectThat([group isKindOfClass:[RKExampleGroupWithUserArray class]]) should:be(YES)];
 [expectThat(group.name) should:be(@"restkit")];
 NSArray * users = group.users;
 [expectThat([users count]) should:be(2)];
 RKExampleUser* user = [users objectAtIndex:0];
 [expectThat([user isKindOfClass:[RKExampleUser class]]) should:be(YES)];
 [expectThat(user.name) should:be(@"blake")];
 user = [users objectAtIndex:1];
 [expectThat([user isKindOfClass:[RKExampleUser class]]) should:be(YES)];
 [expectThat(user.name) should:be(@"rachit")];
 [expectThat(user.address) shouldNot:be(nil)];
 [expectThat(user.address.city) should:be(@"New York")];
 
 group = [groups objectAtIndex:1];
 [expectThat([group isKindOfClass:[RKExampleGroupWithUserArray class]]) should:be(YES)];
 [expectThat(group.name) should:be(@"others")];
 users = group.users;
 [expectThat([users count]) should:be(1)];
 user = [users objectAtIndex:0];
 [expectThat([user isKindOfClass:[RKExampleUser class]]) should:be(YES)];
 [expectThat(user.name) should:be(@"bjorn")];
 [expectThat(user.address) shouldNot:be(nil)];
 [expectThat(user.address.city) should:be(@"Gothenburg")];
 [expectThat(user.address.country) should:be(@"Sweden")];
 }
 
 - (void)itShouldMapANestedArrayOfObjectsWithDynamicKeysAndSetRelationships {
 RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[RKExampleGroupWithUserSet class]];
 [mapping mapAttributes:@"name", nil];
 
 
 RKObjectMapping* userMapping = [RKObjectMapping mappingForClass:[RKExampleUser class]];
 userMapping.forceCollectionMapping = YES;
 [userMapping mapKeyOfNestedDictionaryToAttribute:@"name"];
 [mapping mapKeyPath:@"users" toRelationship:@"users" withMapping:userMapping];
 
 RKObjectMapping* addressMapping = [RKObjectMapping mappingForClass:[RKSpecAddress class]];
 [addressMapping mapAttributes:
 @"city", @"city",
 @"state", @"state",
 @"country", @"country",
 nil
 ];
 [userMapping mapKeyPath:@"(name).address" toRelationship:@"address" withMapping:addressMapping];
 RKObjectMappingProvider* provider = [[RKObjectMappingProvider new] autorelease];
 [provider setMapping:mapping forKeyPath:@"groups"];
 
 id userInfo = RKSpecParseFixture(@"DynamicKeysWithNestedRelationship.json");
 RKObjectMapper* mapper = [RKObjectMapper mapperWithObject:userInfo mappingProvider:provider];
 RKObjectMappingResult* result = [mapper performMapping];
 
 NSArray* groups = [result asCollection];
 [expectThat([groups isKindOfClass:[NSArray class]]) should:be(YES)];
 [expectThat([groups count]) should:be(2)];
 
 RKExampleGroupWithUserSet* group = [groups objectAtIndex:0];
 [expectThat([group isKindOfClass:[RKExampleGroupWithUserSet class]]) should:be(YES)];
 [expectThat(group.name) should:be(@"restkit")];
 
 
 NSSortDescriptor * sortByName =[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
 NSArray * descriptors = [NSArray arrayWithObject:sortByName];;
 NSArray * users = [group.users sortedArrayUsingDescriptors:descriptors];
 [expectThat([users count]) should:be(2)];
 RKExampleUser* user = [users objectAtIndex:0];
 [expectThat([user isKindOfClass:[RKExampleUser class]]) should:be(YES)];
 [expectThat(user.name) should:be(@"blake")];
 user = [users objectAtIndex:1];
 [expectThat([user isKindOfClass:[RKExampleUser class]]) should:be(YES)];
 [expectThat(user.name) should:be(@"rachit")];
 [expectThat(user.address) shouldNot:be(nil)];
 [expectThat(user.address.city) should:be(@"New York")];
 
 group = [groups objectAtIndex:1];
 [expectThat([group isKindOfClass:[RKExampleGroupWithUserSet class]]) should:be(YES)];
 [expectThat(group.name) should:be(@"others")];
 users = [group.users sortedArrayUsingDescriptors:descriptors];
 [expectThat([users count]) should:be(1)];
 user = [users objectAtIndex:0];
 [expectThat([user isKindOfClass:[RKExampleUser class]]) should:be(YES)];
 [expectThat(user.name) should:be(@"bjorn")];
 [expectThat(user.address) shouldNot:be(nil)];
 [expectThat(user.address.city) should:be(@"Gothenburg")];
 [expectThat(user.address.country) should:be(@"Sweden")];
 }
*/
@end
