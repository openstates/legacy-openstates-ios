//
//  SLFActionPathNavigator.m
//  Created by Greg Combs on 12/4/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "SLFActionPathNavigator.h"
#import <SLFRestKit/RestKit.h>
#import "SLFActionPathRegistry.h"
#import "AppDelegate.h"

@interface SLFActionPathNavigator()
+ (void)stackOrPushViewController:(UIViewController *)viewController;
+ (void)stackOrPushViewController:(UIViewController *)viewController fromBase:(UIViewController *)baseController popToRoot:(BOOL)popToRoot;
+ (void)stackViewController:(UIViewController *)viewController fromBase:(UIViewController *)baseController popToRoot:(BOOL)popToRoot;
+ (void)pushViewController:(UIViewController *)viewController fromBase:(UIViewController *)baseController popToRoot:(BOOL)popToRoot;
// we don't use a single NSDictionary for both of these because we need sorted keys, to force an order
@property (nonatomic,retain) NSMutableArray *patternHandlers;
@end


@implementation SLFActionPathNavigator
@synthesize patternHandlers = _patternHandlers;  

+ (SLFActionPathNavigator *)sharedNavigator
{
    static dispatch_once_t pred;
    static SLFActionPathNavigator *foo = nil;
    dispatch_once(&pred, ^{ foo = [[self alloc] init]; });
    return foo;
}

- (id) init {
    self = [super init];
    if (self) {
        _patternHandlers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    self.patternHandlers = nil;
}

+ (void)registerPattern:(NSString *)pattern withArgumentHandler:(SLFActionArgumentHandlerBlock)block {
    NSParameterAssert(pattern != NULL && block != NULL);
    [[SLFActionPathNavigator sharedNavigator].patternHandlers addObject:[SLFActionPathHandler handlerWithPattern:pattern onViewControllerForArgumentsBlock:block]];
}

/*  We should eventually adopt SOCKit's built-in view performSelector" behavior...
 *
 *   pattern: github.com/:username/:repo
 *   > [pattern performSelector:@selector(initWithUsername:repoName:) onObject:[GithubUser class] sourceString:@"github.com/jverkoey/sockit"];
 *   returns: an allocated, initialized, and autoreleased GithubUser object with @"jverkoey" and @"sockit" passed to initWithUsername:repoName:
 */

+ (NSString *)navigationPathForController:(Class)controller withResourceID:(NSString *)resourceID {
    NSString *path = [SLFActionPathRegistry interpolatePathForClass:controller withResourceID:resourceID];
    if (!SLFTypeNonEmptyStringOrNil(path)) {
        RKLogError(@"Attempted to navigate to an invalid action path, controller: %@, resourceID: %@", NSStringFromClass(controller), resourceID);
        return nil;
    }
    return path;
}

+ (NSString *)navigationPathForController:(Class)controller withResource:(id)resource {
    NSParameterAssert([controller respondsToSelector:@selector(actionPathForObject:)]);
    NSString *path = [controller performSelector:@selector(actionPathForObject:) withObject:resource];
    if (!SLFTypeNonEmptyStringOrNil(path)) {
        RKLogError(@"Attempted to navigate to an invalid action path, controller: %@, resource: %@", NSStringFromClass(controller), resource);
        return nil;
    }
    return path;
}

+ (void)navigateToPath:(NSString *)actionPath skipSaving:(BOOL)skipSaving fromBase:(UIViewController *)baseController popToRoot:(BOOL)popToRoot {
    if (!SLFTypeNonEmptyStringOrNil(actionPath))
        return;
    @try {
        UIViewController *vc = nil;
        SLFActionPathNavigator *navigator = [SLFActionPathNavigator sharedNavigator];
        RKPathMatcher *matcher = [RKPathMatcher matcherWithPath:actionPath];
        for (SLFActionPathHandler *handler in navigator.patternHandlers) {
            NSDictionary *args = nil;
            if ([matcher matchesPattern:handler.pattern tokenizeQueryStrings:YES parsedArguments:&args]) {
                vc = handler.onViewControllerForArguments(args, skipSaving);
                break;
            }
        }
        if (vc) {
            [self stackOrPushViewController:vc fromBase:baseController popToRoot:popToRoot];
        }
    }
    @catch (NSException *exception) {
        RKLogError(@"Trouble navigating to path: %@ -- Exception: %@", actionPath, exception);
    }
}

+ (void)pushViewController:(UIViewController *)viewController fromBase:(UIViewController *)baseController popToRoot:(BOOL)popToRoot {
    if (popToRoot)
        [SLFAppDelegateNav popToRootViewControllerAnimated:YES];
    else if (baseController)
        [SLFAppDelegateNav popToViewController:baseController animated:YES];
    [SLFAppDelegateNav pushViewController:viewController animated:YES];
}

+ (void)stackViewController:(UIViewController *)viewController fromBase:(UIViewController *)baseController popToRoot:(BOOL)popToRoot {
    if (baseController && !popToRoot) {
        [SLFAppDelegateStack pushViewController:viewController fromViewController:baseController animated:YES];
        return;
    }
    if (popToRoot)
        [SLFAppDelegateStack popToRootViewControllerAnimated:YES];
    [SLFAppDelegateStack pushViewController:viewController fromViewController:nil animated:YES];
}

+ (void)stackOrPushViewController:(UIViewController *)viewController fromBase:(UIViewController *)baseController popToRoot:(BOOL)popToRoot {
    @try {
        if (SLFIsIpad())
            [self stackViewController:viewController fromBase:baseController popToRoot:popToRoot];
        else
            [self pushViewController:viewController fromBase:baseController popToRoot:popToRoot];
    }
    @catch (NSException *exception) {
        RKLogError(@"Trouble pushing new view controller: %@ -- Exception: %@", viewController, exception);
    }
}

+ (void)stackOrPushViewController:(UIViewController *)viewController {
    [self stackOrPushViewController:viewController fromBase:nil popToRoot:NO];
}
@end

#pragma mark - Action Path Handler

@implementation SLFActionPathHandler
@synthesize pattern = _pattern;
@synthesize onViewControllerForArguments = _onViewControllerForArguments;

+ (SLFActionPathHandler *)handlerWithPattern:(NSString *)pattern onViewControllerForArgumentsBlock:(SLFActionArgumentHandlerBlock)block {
    SLFActionPathHandler *handler = [[SLFActionPathHandler alloc] init];
    handler.pattern = pattern;
    handler.onViewControllerForArguments = block;
    return handler;
}

- (void)setOnViewControllerForArguments:(SLFActionArgumentHandlerBlock)onViewControllerForArguments {
    if (_onViewControllerForArguments) {
        _onViewControllerForArguments = nil;
        return;
    }
    _onViewControllerForArguments = [onViewControllerForArguments copy];
}

@end
