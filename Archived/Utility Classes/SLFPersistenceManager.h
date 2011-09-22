//
//  SLFPersistenceManager.h
//  Created by Gregory Combs on 7/26/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <Foundation/Foundation.h>

#define kPersistentSelectionKey     @"RestoreSelection"

@interface SLFPersistenceManager : NSObject {

}

@property (nonatomic, retain) NSArray               * savedTabOrder;
@property (nonatomic, retain) NSMutableDictionary	* savedTableSelection;


// Common methods for persistence manager
+ (id) sharedPersistence;
- (void) loadPersistence;
- (void) savePersistence;
- (void) resetPersistence;



// Persistent Order for TabBarController Tabs
- (NSArray *)orderedTabsFromPersistence:(NSArray *)inViewControllers;
- (void)saveOrderedTabsToPersistence:(NSArray *)inViewControllers;



// Persistence Manager
- (id) tableSelectionForKey:(NSString *)vcKey;
- (void) setTableSelection:(id)object forKey:(NSString *)vcKey;

- (NSData *)archivableTableSelection;
- (NSString *)persistentViewControllerKey;

@end
