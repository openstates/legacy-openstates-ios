//
//  SLFTableViewController.m
//  Created by Greg Combs on 9/26/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFTableViewController.h"
#import "SLFAppearance.h"
#import "GradientBackgroundView.h"
#import "SVWebViewController.h"
#import "SLFReachable.h"

@implementation SLFTableViewController
@synthesize useGradientBackground;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.stackWidth = 450;
        self.useGradientBackground = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.useGradientBackground) {
        GradientBackgroundView *gradient = [[GradientBackgroundView alloc] initWithFrame:self.tableView.bounds];
        [gradient loadLayerAndGradientColors];
        self.tableView.backgroundView = gradient;
        [gradient release];
    }
}

- (UITableView *) tableViewWithStyle:(UITableViewStyle)style {
    UITableView *aTableView = [super tableViewWithStyle:style];
    aTableView.backgroundColor = [UIColor clearColor];
    if (style == UITableViewStylePlain)
        aTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    return aTableView;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void)tableViewModel:(RKAbstractTableViewModel*)tableViewModel didFailLoadWithError:(NSError*)error {
    self.title = NSLocalizedString(@"Load Error",@"");
    RKLogError(@"Error loading table: %@", error);
    if ([tableViewModel respondsToSelector:@selector(resourcePath)])
        RKLogError(@"-------- from resource path: %@", [tableViewModel performSelector:@selector(resourcePath)]);
}

- (void)stackOrPushViewController:(UIViewController *)viewController {
    if (!PSIsIpad()) {
        [self.navigationController pushViewController:viewController animated:YES];
        return;
    }
    [self.stackController pushViewController:viewController fromViewController:self animated:YES];
}

- (RKTableItem *)webPageItemWithTitle:(NSString *)itemTitle subtitle:(NSString *)itemSubtitle url:(NSString *)url {
    NSParameterAssert(!IsEmpty(url));
    return [RKTableItem tableItemWithBlock:^(RKTableItem *tableItem) {
        tableItem.cellMapping = [SubtitleCellMapping cellMapping];
        tableItem.text = itemTitle;
        tableItem.detailText = itemSubtitle;
        tableItem.URL = url;
        tableItem.cellMapping.onSelectCell = ^(void) {
            if (SLFIsReachableAddress(tableItem.URL)) {
                SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:tableItem.URL];
                webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
                [self presentModalViewController:webViewController animated:YES];	
                [webViewController release];
            }
        };
    }];
}

@end
