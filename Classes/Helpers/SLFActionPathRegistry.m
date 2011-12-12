//
//  SLFActionPathRegistry.m
//  Created by Greg Combs on 12/5/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//  This class is loads of fun ... sorry, I was in a hurry.
//  It basically does all the legwork to build the path patterns and construct the view controller 
//  initialization blocks, so that we don't have to overly pollute tens of classes to do what this does.
//  Granted, using categories to cheat out an intialization block is a stupid idea, but I'll be damned
//  if it doesn't do the job in a pinch.  Fork it and show me how it should be done.  I'll happily merge
//  your changes, bro.

#import "SLFActionPathRegistry.h"

#import "StatesViewController.h"
#import "StackedMenuViewController.h"
#import "StateDetailViewController.h"
#import "LegislatorsViewController.h"
#import "LegislatorDetailViewController.h"
#import "CommitteesViewController.h"
#import "CommitteeDetailViewController.h"
#import "DistrictsViewController.h"
#import "DistrictDetailViewController.h"
#import "EventsViewController.h"
#import "EventDetailViewController.h"
#import "BillsMenuViewController.h"
#import "BillsSearchViewController.h"
#import "BillDetailViewController.h"
#import "BillsWatchedViewController.h"
#import "BillsSubjectsViewController.h"

@interface SLFTableViewController(SLFActionPath)
+ (void)registerActionPathWithPattern:(NSString *)pattern;
@end

@interface SLFActionPathRegistry()
@property (nonatomic,retain) NSMutableDictionary *patternsForClasses;
- (void)registerAllControllers;
- (void)registerPattern:(NSString *)pattern forClass:(Class)controllerClass;
@end

@implementation SLFActionPathRegistry
@synthesize patternsForClasses = _patternsForClasses;

+ (SLFActionPathRegistry *)sharedRegistry
{
    static dispatch_once_t pred;
    static SLFActionPathRegistry *foo = nil;
    dispatch_once(&pred, ^{ foo = [[self alloc] init]; });
    return foo;
}

- (id)init {
    self = [super init];
    if (self) {
        _patternsForClasses = [[NSMutableDictionary alloc] init];
        [self registerAllControllers];
    }
    return self;
}

- (void)dealloc {
    self.patternsForClasses = nil;
    [super dealloc];
}

- (void)registerAllControllers {
    if (SLFIsIpad())
        [self registerPattern:@"slfos://states/detail/:stateID" forClass:[StackedMenuViewController class]];
    else
        [self registerPattern:@"slfos://states/detail/:stateID" forClass:[StateDetailViewController class]];
    [self registerPattern:@"slfos://states" forClass:[StatesViewController class]];
    [self registerPattern:@"slfos://legislators/detail/:legID" forClass:[LegislatorDetailViewController class]];
    [self registerPattern:@"slfos://legislators/:stateID" forClass:[LegislatorsViewController class]];
    [self registerPattern:@"slfos://committees/detail/:committeeID" forClass:[CommitteeDetailViewController class]];
    [self registerPattern:@"slfos://committees/:stateID" forClass:[CommitteesViewController class]];
    [self registerPattern:@"slfos://districts/detail/:boundaryID" forClass:[DistrictDetailViewController class]];
    [self registerPattern:@"slfos://districts/:stateID" forClass:[DistrictsViewController class]];
    [self registerPattern:@"slfos://events/detail/:eventID" forClass:[EventDetailViewController class]];
    [self registerPattern:@"slfos://events/:stateID" forClass:[EventsViewController class]];
    [self registerPattern:@"slfos://bills/detail/:stateID/:session/:billID" forClass:[BillDetailViewController class]];
    [self registerPattern:@"slfos://bills/search/:stateID" forClass:[BillsSearchViewController class]];
    [self registerPattern:@"slfos://bills/subjects/:stateID" forClass:[BillsSubjectsViewController class]];
    [self registerPattern:@"slfos://bills/watch" forClass:[BillsWatchedViewController class]];
    [self registerPattern:@"slfos://bills/:stateID" forClass:[BillsMenuViewController class]];
}

+ (NSString *)patternForClass:(Class)controllerClass {
    if (!controllerClass)
        return nil;
    return [[SLFActionPathRegistry sharedRegistry].patternsForClasses valueForKey:NSStringFromClass(controllerClass)];
}

- (void)registerPattern:(NSString *)pattern forClass:(Class)controllerClass {
    if (!controllerClass || !pattern)
        return;
    [_patternsForClasses setObject:pattern forKey:NSStringFromClass(controllerClass)];
    NSAssert([controllerClass respondsToSelector:@selector(registerActionPathWithPattern:)], @"Class doesn't answer to registration methods");
    [controllerClass registerActionPathWithPattern:pattern];
}
@end

@implementation SLFTableViewController(SLFActionPath)
+ (void)registerActionPathWithPattern:(NSString *)pattern {
    if (!pattern)
        return;
    Class controllerClass = [self class];
    [SLFActionPathNavigator registerPattern:pattern withArgumentHandler:^UIViewController *(NSDictionary *arguments) {
        if (NO == [controllerClass instancesRespondToSelector:@selector(initWithState:)])
            return nil;
        SLFState *state = [SLFState findFirstByAttribute:@"stateID" withValue:[arguments valueForKey:@"stateID"]];
        if (!state)
            return nil;
        return [[controllerClass alloc] initWithState:state];
    }];
}
@end


@implementation StackedMenuViewController(SLFActionPath)
+ (void)registerActionPathWithPattern:(NSString *)pattern {
    if (!pattern)
        return;    
    [SLFActionPathNavigator registerPattern:pattern withArgumentHandler:^UIViewController *(NSDictionary *arguments) {
        SLFState *state = [SLFState findFirstByAttribute:@"stateID" withValue:[arguments valueForKey:@"stateID"]];
        if (!state)
            return nil;
        [SLFAppDelegateStack statePopover:nil didSelectState:state];
        return nil;
    }];
}
@end

@implementation StatesViewController(SLFActionPath)
+ (void)registerActionPathWithPattern:(NSString *)pattern {
    if (!pattern)
        return;
    [SLFActionPathNavigator registerPattern:pattern withArgumentHandler:^UIViewController *(NSDictionary *arguments) {
        if (SLFIsIpad()) {
            [SLFAppDelegateStack changeSelectedState:nil];
            return nil;
        }
        UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [nav popToRootViewControllerAnimated:YES];
        return nil;
    }];
}
@end

@implementation LegislatorDetailViewController(SLFActionPath)
+ (void)registerActionPathWithPattern:(NSString *)pattern {
    if (!pattern)
        return;
    Class controllerClass = [self class];
    [SLFActionPathNavigator registerPattern:pattern withArgumentHandler:^UIViewController *(NSDictionary *arguments) {
        NSString *legID = [arguments valueForKey:@"legID"];
        if (!legID)
            return nil;
        return [[controllerClass alloc] initWithLegislatorID:legID];
    }];
}
@end

@implementation CommitteeDetailViewController(SLFActionPath)
+ (void)registerActionPathWithPattern:(NSString *)pattern {
    if (!pattern)
        return;
    Class controllerClass = [self class];
    [SLFActionPathNavigator registerPattern:pattern withArgumentHandler:^UIViewController *(NSDictionary *arguments) {
        NSString *committeeID = [arguments valueForKey:@"committeeID"];
        if (!committeeID)
            return nil;
        return [[controllerClass alloc] initWithCommitteeID:committeeID];
    }];
}
@end

@implementation DistrictDetailViewController(SLFActionPath)
+ (void)registerActionPathWithPattern:(NSString *)pattern {
    if (!pattern)
        return;
    Class controllerClass = [self class];
    [SLFActionPathNavigator registerPattern:pattern withArgumentHandler:^UIViewController *(NSDictionary *arguments) {
        NSString *boundaryID = [arguments valueForKey:@"boundaryID"];
        if (!boundaryID)
            return nil;
        return [[controllerClass alloc] initWithDistrictMapID:boundaryID];
    }];
}
@end

@implementation EventDetailViewController(SLFActionPath)
+ (void)registerActionPathWithPattern:(NSString *)pattern {
    if (!pattern)
        return;
    Class controllerClass = [self class];
    [SLFActionPathNavigator registerPattern:pattern withArgumentHandler:^UIViewController *(NSDictionary *arguments) {
        NSString *eventID = [arguments valueForKey:@"eventID"];
        if (!eventID)
            return nil;
        return [[controllerClass alloc] initWithEventID:eventID];
    }];
}
@end

@implementation BillDetailViewController(SLFActionPath)
+ (void)registerActionPathWithPattern:(NSString *)pattern {
    if (!pattern)
        return;
    Class controllerClass = [self class];
    [SLFActionPathNavigator registerPattern:pattern withArgumentHandler:^UIViewController *(NSDictionary *arguments) {
        SLFState *state = [SLFState findFirstByAttribute:@"stateID" withValue:[arguments valueForKey:@"stateID"]];
        NSString *session = [arguments valueForKey:@"session"];
        NSString *billID = [arguments valueForKey:@"billID"];
        if (!state || IsEmpty(session) || IsEmpty(billID))
            return nil;
        return [[controllerClass alloc] initWithState:state session:session billID:billID];
    }];
}
@end

@implementation BillsWatchedViewController(SLFActionPath)
+ (void)registerActionPathWithPattern:(NSString *)pattern {
    if (!pattern)
        return;
    Class controllerClass = [self class];
    [SLFActionPathNavigator registerPattern:pattern withArgumentHandler:^UIViewController *(NSDictionary *arguments) {
        return [[controllerClass alloc] init];
    }];
}
@end

