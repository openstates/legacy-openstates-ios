//
//  SLFActionPathNavigator.m
//  Created by Greg Combs on 12/4/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFActionPathNavigator.h"
#import <RestKit/RestKit.h>
#import "SLFActionPathRegistry.h"

@interface SLFActionPathNavigator()
+ (void)stackOrPushViewController:(UIViewController *)viewController;

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
    [super dealloc];
}

+ (void)registerPattern:(NSString *)pattern withArgumentHandler:(SLFActionArgumentHandlerBlock)block {
    NSParameterAssert(pattern != NULL && block != NULL);
    [[SLFActionPathNavigator sharedNavigator].patternHandlers addObject:[SLFActionPathHandler handlerWithPattern:pattern onViewControllerForArgumentsBlock:block]];
}

+ (void)navigateToPath:(NSString *)actionPath {
    if (IsEmpty(actionPath))
        return;
    @try {
        UIViewController *vc = nil;
        SLFActionPathNavigator *navigator = [SLFActionPathNavigator sharedNavigator];
        RKPathMatcher *matcher = [RKPathMatcher matcherWithPath:actionPath];
        for (SLFActionPathHandler *handler in navigator.patternHandlers) {
            NSDictionary *args = nil;
            if ([matcher matchesPattern:handler.pattern tokenizeQueryStrings:YES parsedArguments:&args]) {
                vc = handler.onViewControllerForArguments(args);
                break;
            }
        }
        if (vc) {
            [self stackOrPushViewController:vc];
            [vc release];
        }
    }
    @catch (NSException *exception) {
       RKLogError(@"Trouble navigating to path: %@ -- Exception: %@", actionPath, exception);
    }
}

+ (void)stackOrPushViewController:(UIViewController *)viewController {
    @try {
        if (!SLFIsIpad()) {
            UINavigationController *nav = (UINavigationController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
            [nav pushViewController:viewController animated:YES];
            return;
        }
            //[SLFAppDelegateStack popToRootViewControllerAnimated:YES];
        [SLFAppDelegateStack pushViewController:viewController fromViewController:nil animated:YES];
    }
    @catch (NSException *exception) {
        RKLogError(@"Trouble pushing new view controller: %@ -- Exception: %@", viewController, exception);
    }
}

@end

#pragma mark - Action Path Handler

@implementation SLFActionPathHandler
@synthesize pattern = _pattern;
@synthesize onViewControllerForArguments = _onViewControllerForArguments;

+ (SLFActionPathHandler *)handlerWithPattern:(NSString *)pattern onViewControllerForArgumentsBlock:(SLFActionArgumentHandlerBlock)block {
    SLFActionPathHandler *handler = [[[SLFActionPathHandler alloc] init] autorelease];
    handler.pattern = pattern;
    handler.onViewControllerForArguments = block;
    return handler;
}

- (void)dealloc {
    self.onViewControllerForArguments = nil;
    self.pattern = nil;
    [super dealloc];
}

- (void)setOnViewControllerForArguments:(SLFActionArgumentHandlerBlock)onViewControllerForArguments {
    if (_onViewControllerForArguments) {
        Block_release(_onViewControllerForArguments);
        _onViewControllerForArguments = nil;
    }
    _onViewControllerForArguments = Block_copy(onViewControllerForArguments);
}
@end


