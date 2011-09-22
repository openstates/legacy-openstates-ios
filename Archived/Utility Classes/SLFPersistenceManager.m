//
//  SLFPersistenceManager.m
//  Created by Gregory Combs on 7/26/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFPersistenceManager.h"
#import "UtilityMethods.h"


// user default dictionary keys
static NSString * const kSavedTabOrderKey       = @"SavedTabOrderVersion2";


@implementation SLFPersistenceManager
@synthesize savedTableSelection;
@synthesize savedTabOrder;

+ (id)sharedPersistence
{
	static dispatch_once_t pred;
	static SLFPersistenceManager *foo = nil;
	
	dispatch_once(&pred, ^{ foo = [[self alloc] init]; });
	return foo;
}


- (id)init {

    if ((self = [super init])) {
        savedTabOrder = nil;
        
        savedTableSelection = [[NSMutableDictionary alloc] init];

    }
    return self;
}


- (void)dealloc {

    self.savedTableSelection = nil;
    self.savedTabOrder = nil;
    [super dealloc];
}



#pragma mark -
#pragma mark Tab Controller Tab Order

- (NSArray *)orderedTabsFromPersistence:(NSArray *)inViewControllers {
    
    NSCParameterAssert( inViewControllers != NULL);
    
    NSArray *outViewControllers = nil;
    
	[[NSUserDefaults standardUserDefaults] synchronize];	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSArray *savedOrder = [defaults arrayForKey:kSavedTabOrderKey];
    
	if (!IsEmpty(savedOrder)) {
        
        NSInteger foundVCs = 0;
        NSMutableArray *orderedTabs = [NSMutableArray arrayWithCapacity:[inViewControllers count]];
                
		for (NSInteger i = 0; i < [savedOrder count]; i++){
			for (UIViewController *aController in inViewControllers) {
                
				if ([aController.tabBarItem.title isEqualToString:[savedOrder objectAtIndex:i]]) {
					[orderedTabs addObject:aController];
					foundVCs++;
				}
                
			}
            
		}
        
        // if we've got more view controllers now than we used to, reset and return nil ... (we won't change tab order)
        
		if (foundVCs < [inViewControllers count])
			[defaults removeObjectForKey:kSavedTabOrderKey];
		else
			outViewControllers = orderedTabs;
	}
    
    return outViewControllers;
}

- (void)saveOrderedTabsToPersistence:(NSArray *)inViewControllers {
    
    NSCParameterAssert( inViewControllers != NULL);
    
    NSMutableArray *savedOrder = [[NSMutableArray alloc] initWithCapacity:[inViewControllers count]];
    
    for (UIViewController *aViewController in inViewControllers) {
        [savedOrder addObject:aViewController.tabBarItem.title];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:savedOrder forKey:kSavedTabOrderKey];
    
    [savedOrder release];
}


#pragma mark Saving

- (void) savePersistence {
    
    if (self.savedTabOrder) {
        [[NSUserDefaults standardUserDefaults] setObject:self.savedTabOrder forKey:kSavedTabOrderKey];
    }
    
 	// save the drill-down hierarchy of selections to preferences
	[[NSUserDefaults standardUserDefaults] setObject:[self archivableTableSelection] forKey:kPersistentSelectionKey];
	[[NSUserDefaults standardUserDefaults] synchronize];	    
}

- (void)loadPersistence {
	@try {
		NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kPersistentSelectionKey];
		if (data) {
			NSMutableDictionary *tempDict = [[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];	
			if (tempDict) {
				self.savedTableSelection = tempDict;
				[tempDict release];
			}	
		}		
	}
	@catch (NSException * e) {
		[self resetPersistence];
	}
    
}

- (void)resetPersistence {
	self.savedTableSelection = [NSMutableDictionary dictionary];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kPersistentSelectionKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}


- (id) tableSelectionForKey:(NSString *)vcKey {
	id object = nil;
	@try {
		id savedVC = [self.savedTableSelection objectForKey:@"viewController"];
		if (vcKey && savedVC && [vcKey isEqualToString:savedVC])
			object = [self.savedTableSelection objectForKey:@"object"];
		
	}
	@catch (NSException * e) {
		[self resetPersistence];
	}
	
	return object;
}



- (void)setTableSelection:(id)object forKey:(NSString *)vcKey {
	if (!vcKey) {
		[self.savedTableSelection removeAllObjects];
		return;
	}
	[self.savedTableSelection setObject:vcKey forKey:@"viewController"];
	if (object)
		[self.savedTableSelection setObject:object forKey:@"object"];
	else
		[self.savedTableSelection removeObjectForKey:@"object"];
}



- (NSData *)archivableTableSelection {
	NSData *data = nil;
	
	@try {
		NSMutableDictionary *tempDict = [self.savedTableSelection mutableCopy];
		data = [NSKeyedArchiver archivedDataWithRootObject:tempDict];
		[tempDict release];		
	}
	@catch (NSException * e) {
		[self resetPersistence];
	}
	return data;
}

- (NSString *)persistentViewControllerKey {
    return [self.savedTableSelection objectForKey:@"viewController"];  
}

@end
