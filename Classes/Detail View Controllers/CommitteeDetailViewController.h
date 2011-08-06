//
//  CommitteeDetailViewController.h
//  Created by Gregory Combs on 6/29/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <UIKit/UIKit.h>
#import "GCTableViewController.h"

@class SLFCommittee;
@class TableCellDataObject;
@class CommitteeDetailDataSource;

@interface CommitteeDetailViewController : GCTableViewController <UISplitViewControllerDelegate, 
                                                                  UIPopoverControllerDelegate>  
{
}

@property (nonatomic,assign)   NSString                 *detailObjectID;
@property (nonatomic,readonly) SLFCommittee             *detailObject;
@property (nonatomic,retain) CommitteeDetailDataSource  *dataSource;

@property (nonatomic,retain) IBOutlet UIView            *headerView;
@property (nonatomic,retain) IBOutlet UILabel           *membershipLab;
@property (nonatomic,retain) IBOutlet UILabel           *nameLab;

@property (nonatomic,retain) UIPopoverController        *masterPopover;
@end
