//
//  DistrictMapSearchOperation.m
//  TexLege
//
//  Created by Gregory Combs on 9/1/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "DistrictMapSearchOperation.h"
#import "NSInvocation+CWVariableArguments.h"
#import "TexLegeAppDelegate.h"
#import "DistrictMapObj.h"

@interface DistrictMapSearchOperation()
{
}
- (void)informDelegateOfFailureWithMessage:(NSString *)message failOption:(DistrictMapSearchOperationFailOption)failOption;
- (void)informDelegateOfSuccess;
@end

@implementation DistrictMapSearchOperation
@synthesize delegate, managedObjectContext;
@synthesize searchDistricts, foundDistricts, searchCoordinate;

- (id) initWithDelegate:(id<DistrictMapSearchOperationDelegate>)newDelegate objects:(NSArray*)objectIDArray coordinate:(CLLocationCoordinate2D)aCoordinate {
	if (self = [super init]) {

		if (newDelegate)
			delegate = newDelegate;
		if (objectIDArray)
			searchDistricts = [objectIDArray retain];
		searchCoordinate = aCoordinate;
		if ([delegate respondsToSelector:@selector(managedObjectContext)])
			managedObjectContext = [delegate performSelector:@selector(managedObjectContext)];
	}
	return self;
}

- (void) dealloc {
	self.managedObjectContext = nil;
	self.searchDistricts = nil;
	self.foundDistricts = nil;
	delegate = nil;
	[super dealloc];
}

- (void)informDelegateOfFailureWithMessage:(NSString *)message failOption:(DistrictMapSearchOperationFailOption)failOption;
{
    if ([delegate respondsToSelector:@selector(DistrictMapSearchOperationDidFail:errorMessage:option:)])
    {
        NSInvocation *invocation = [NSInvocation invocationWithTarget:delegate 
                                                             selector:@selector(DistrictMapSearchOperationDidFail:errorMessage:option:) 
                                                      retainArguments:YES, self, message, failOption];
        [invocation invokeOnMainThreadWaitUntilDone:YES];
    } 
}

- (void)informDelegateOfSuccess
{
    if ([delegate respondsToSelector:@selector(DistrictMapSearchOperationDidFinishSuccessfully:)])
    {
        [delegate performSelectorOnMainThread:@selector(DistrictMapSearchOperationDidFinishSuccessfully:) 
                                   withObject:self 
                                waitUntilDone:NO];
    }
}

#pragma mark -
- (void)main 
{
	NSManagedObjectContext *sourceMOC = [[NSManagedObjectContext alloc] init];
	BOOL success = NO;
	
    @try 
    {		
        // Operation task here
		
		NSManagedObjectContext *threadedMOC = [self managedObjectContext];
		if (threadedMOC) {
		
			NSPersistentStoreCoordinator *sourceStore = nil;
			sourceStore = [[TexLegeAppDelegate appDelegate] persistentStoreCoordinator];
			[sourceMOC setPersistentStoreCoordinator:sourceStore];
			
			if (foundDistricts)
				[foundDistricts release];
			foundDistricts = [[NSMutableArray alloc] init];
			
			for (NSManagedObjectID *objectID in [self searchDistricts]) {
				NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

				NSManagedObject * object = [sourceMOC objectWithID:objectID];

				if ([object respondsToSelector:@selector(districtContainsCoordinate:)]) {
					DistrictMapObj *map = (DistrictMapObj *)object;
					if ([map districtContainsCoordinate:[self searchCoordinate]]) {
						[foundDistricts addObject:[map objectID]];
						success = YES;
					}
				}
				[pool drain];
			}
		}
    }
    @catch (NSException * e) 
    {
        debug_NSLog(@"Exception: %@", e);
    }
	if (sourceMOC)
		[sourceMOC release], sourceMOC = nil;
	
	if (success)
		[self informDelegateOfSuccess];
	else
		[self informDelegateOfFailureWithMessage:@"Could not find a district map with those coordinates." failOption:DistrictMapSearchOperationFailOptionLog];
	

}
	

@end
