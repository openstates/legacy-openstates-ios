//
//  SLFTableViewController.h
//  Created by Greg Combs on 9/26/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import <RestKit/UI/UI.h>
#import "GCTableViewController.h"
#import "PSStackedViewDelegate.h"
#import "StackableControllerProtocol.h"
#import "SLFTheme.h"
#import "TitleBarView.h"
#import "PSStackedView.h"

typedef void(^SearchBarConfigurationBlock)(UISearchBar *searchBar);

@class SLFState;

@interface SLFTableViewController : GCTableViewController <PSStackedViewDelegate, RKTableControllerDelegate, StackableController, UISearchBarDelegate, SLFPerstentActionsProtocol>

@property (nonatomic,assign) BOOL useGradientBackground;
@property (nonatomic,assign) BOOL useTitleBar;
@property (nonatomic,retain) TitleBarView *titleBarView;
@property (nonatomic,retain) UISearchBar *searchBar;

- (RKTableItem *)webPageItemWithTitle:(NSString *)itemTitle subtitle:(NSString *)itemSubtitle url:(NSString *)url;
- (void)configureSearchBarWithPlaceholder:(NSString *)placeholder withConfigurationBlock:(SearchBarConfigurationBlock)block;
- (void)configureChamberScopeTitlesForSearchBar:(UISearchBar *)searchBar withState:(SLFState *)state;

@end

