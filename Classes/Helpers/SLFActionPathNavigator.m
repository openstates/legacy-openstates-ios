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
#import "SLFDataModels.h"
#import "BillDetailViewController.h"

@interface SLFActionPathNavigator()
+ (void)stackOrPushViewController:(UIViewController *)viewController;
@end

@implementation SLFActionPathNavigator

+ (void)navigateToPath:(NSString *)actionPath {
    if (IsEmpty(actionPath))
        return;
    @try {
        UIViewController *vc = nil;
        NSDictionary *args = nil;
        RKPathMatcher *matcher = [RKPathMatcher matcherWithPath:actionPath];
        if ([matcher matchesPattern:@"slfos://bills/detail/:stateID/:session/:billID" tokenizeQueryStrings:YES parsedArguments:&args]) {
            SLFState *state = [SLFState findFirstByAttribute:@"stateID" withValue:[args valueForKey:@"stateID"]];
            NSString *session = [args valueForKey:@"session"];
            NSString *billID = [args valueForKey:@"billID"];
            if (!state || IsEmpty(session) || IsEmpty(billID))
                return;
            vc = [[BillDetailViewController alloc] initWithState:state session:[args valueForKey:@"session"] billID:[args valueForKey:@"billID"]];
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
        [SLFAppDelegateStack pushViewController:viewController animated:YES];
    }
    @catch (NSException *exception) {
        RKLogError(@"Trouble pushing new view controller: %@ -- Exception: %@", viewController, exception);
    }
}

@end
