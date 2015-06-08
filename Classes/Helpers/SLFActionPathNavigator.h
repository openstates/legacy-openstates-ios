//
//  SLFActionPathNavigator.h
//  Created by Greg Combs on 12/4/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "SLFActionPathRegistry.h"

// given parsed arguments from a pattern, return a retained (not autoreleased) view controller to push onto the stack
typedef UIViewController* (^SLFActionArgumentHandlerBlock)(NSDictionary *arguments, BOOL skipSaving);

@interface SLFActionPathNavigator : NSObject
+ (NSString *)navigationPathForController:(Class)controller withResourceID:(NSString *)resourceID;
+ (NSString *)navigationPathForController:(Class)controller withResource:(id)resource;
+ (void)navigateToPath:(NSString *)actionPath skipSaving:(BOOL)skipSaving fromBase:(UIViewController *)baseController popToRoot:(BOOL)popToRoot;

+ (void)registerPattern:(NSString *)pattern withArgumentHandler:(SLFActionArgumentHandlerBlock)block;
+ (SLFActionPathNavigator *)sharedNavigator;
@end

@interface SLFActionPathHandler : NSObject
+ (SLFActionPathHandler *)handlerWithPattern:(NSString *)pattern onViewControllerForArgumentsBlock:(SLFActionArgumentHandlerBlock)block;
@property (nonatomic,copy) NSString *pattern;
@property (nonatomic,copy) SLFActionArgumentHandlerBlock onViewControllerForArguments;
@end

