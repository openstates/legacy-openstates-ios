//
//  LinksMasterViewController.h
//  TexLege
//
//  Created by Gregory Combs on 8/13/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

#import "TableDataSourceProtocol.h"
#import "GeneralTableViewController.h"
#import "AboutViewController.h"

@class MiniBrowserController;
@interface LinksMasterViewController : GeneralTableViewController {
}

@property (nonatomic,retain) AboutViewController *aboutControl;
@property (nonatomic,retain) MiniBrowserController *miniBrowser;

@end
