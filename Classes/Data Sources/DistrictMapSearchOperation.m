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
#import "TexLegeCoreDataUtils.h"

@interface DistrictMapSearchOperation()
{
}
- (void)informDelegateOfFailureWithMessage:(NSString *)message failOption:(DistrictMapSearchOperationFailOption)failOption;
- (void)informDelegateOfSuccess;
@end

@implementation DistrictMapSearchOperation
@synthesize delegate, managedObjectContext;
@synthesize foundDistricts, searchCoordinate;

- (id) initWithDelegate:(id<DistrictMapSearchOperationDelegate>)newDelegate coordinate:(CLLocationCoordinate2D)aCoordinate {
	if (self = [super init]) {

		if (newDelegate)
			delegate = newDelegate;
		searchCoordinate = aCoordinate;
		if ([delegate respondsToSelector:@selector(managedObjectContext)])
			managedObjectContext = [delegate performSelector:@selector(managedObjectContext)];
	}
	return self;
}

- (void) dealloc {
	self.managedObjectContext = nil;
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
    if ([delegate respondsToSelector:@selector(districtMapSearchOperationDidFinishSuccessfully:)])
    {
        [delegate performSelectorOnMainThread:@selector(districtMapSearchOperationDidFinishSuccessfully:) 
                                   withObject:self 
                                waitUntilDone:NO];
    }
}

#pragma mark -
- (void)main 
{
	/*NSManagedObjectContext *threadedMOC = [self managedObjectContext];
	if (!threadedMOC)
		return; */

	NSManagedObjectContext *sourceMOC = [[NSManagedObjectContext alloc] init];
	[sourceMOC setUndoManager:nil];
	
	BOOL success = NO;
	
    @try 
    {		
        // Operation task here
		
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

		NSPersistentStoreCoordinator *sourceStore = nil;
		sourceStore = [[TexLegeAppDelegate appDelegate] persistentStoreCoordinator];
		[sourceMOC setPersistentStoreCoordinator:sourceStore];
		
		if (foundDistricts)
			[foundDistricts release];
		foundDistricts = [[NSMutableArray alloc] init];
		
		NSArray *searchDistricts = [TexLegeCoreDataUtils allDistrictMapIDsWithBoundingBoxesContaining:[self searchCoordinate] withContext:sourceMOC];
			
		for (NSManagedObjectID *objectID in searchDistricts) {

			NSManagedObject * object = [sourceMOC objectWithID:objectID];

			if ([object respondsToSelector:@selector(districtContainsCoordinate:)]) {
				DistrictMapObj *map = (DistrictMapObj *)object;
				if ([map districtContainsCoordinate:[self searchCoordinate]]) {
					[foundDistricts addObject:[map objectID]];
					success = YES;
				}
				else {
					// this frees up memory and re-faults the unneeded objects
					[sourceMOC refreshObject:map mergeChanges:NO];
				}

			}
		}
		[pool drain];
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
	
/*	NSError *error = nil;
	if (![threadedMOC save:&error]) {
        NSLog(@"Error: %@", error);
	}
*/	

}
	

@end
