//
//  EXContainer.h
//  Entropy
//

#import <Foundation/Foundation.h>
#import "EXFile.h"
#import "EXPredicate.h"

@interface EXContainer : NSObject { }

- (id)initWithFile:(EXFile*)file;
- (int)store:(id)object; // deprecated
- (int)storeObject:(id)object;
- (NSArray*)queryWithClass:(Class)cls;
- (NSArray*)queryWithClass:(Class)cls predicate:(EXPredicate*)predicate;
- (id)queryWithID:(int)_objectID;
- (void)removeObject:(id)object;
- (BOOL)synchronizeWithPort:(int)port host:(NSString*)host;
- (void)allowSynchronizationOnPort:(int)port;

@end
