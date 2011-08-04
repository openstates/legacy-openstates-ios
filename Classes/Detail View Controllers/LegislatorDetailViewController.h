//
//  LegislatorDetailViewController.h
//  Created by Gregory Combs on 6/28/10.
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

@class SLFLegislator;
@class TableCellDataObject;
@class LegislatorDetailDataSource;

@interface LegislatorDetailViewController : GCTableViewController <UISplitViewControllerDelegate, 
													UIPopoverControllerDelegate>
{	
}

@property (nonatomic,assign)   NSString                 *detailObjectID;
@property (nonatomic,readonly) SLFLegislator            *detailObject;
@property (nonatomic,retain) LegislatorDetailDataSource *dataSource;

@property (nonatomic,retain) IBOutlet UIView            *headerView;
@property (nonatomic,retain) IBOutlet UIImageView       *leg_photoView;
@property (nonatomic,retain) IBOutlet UILabel           *leg_partyLab, *leg_districtLab, *leg_nameLab;
@property (nonatomic,retain) IBOutlet UILabel           *leg_reelection;

@property (nonatomic,retain) UIPopoverController        *notesPopover;
@property (nonatomic,retain) UIPopoverController        *masterPopover;

@end
