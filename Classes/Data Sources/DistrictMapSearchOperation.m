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
	[managedObjectContext release];
	[searchDistricts release];
	[foundDistricts release];
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
    @try 
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
        // Operation task here
		
		NSManagedObjectContext *threadedMOC = [self managedObjectContext];
		if (!threadedMOC)
			return;
		
		NSPersistentStoreCoordinator *sourceStore = nil;
		sourceStore = [[TexLegeAppDelegate appDelegate] persistentStoreCoordinator];
		NSManagedObjectContext *sourceMOC = [[NSManagedObjectContext alloc] init];
		[sourceMOC setPersistentStoreCoordinator:sourceStore];
		
		if (foundDistricts)
			[foundDistricts release];
		foundDistricts = [[[NSMutableArray alloc] initWithCapacity:[[self searchDistricts] count]] retain];
		
		for (NSManagedObjectID *objectID in [self searchDistricts]) {
			NSManagedObject * object = [sourceMOC objectWithID:objectID];

			if ([object respondsToSelector:@selector(districtContainsCoordinate:)]) {
				DistrictMapObj *map = (DistrictMapObj *)object;
				if ([map districtContainsCoordinate:[self searchCoordinate]])
					[foundDistricts addObject:[map objectID]];
			}
		}
		
        [self informDelegateOfSuccess];
        [pool drain];
    }
    @catch (NSException * e) 
    {
        debug_NSLog(@"Exception: %@", e);
    }
}


@end
