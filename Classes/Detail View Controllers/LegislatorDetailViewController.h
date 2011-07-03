//
//  LegislatorDetailViewController.h
//  TexLege
//
//  Created by Gregory Combs on 6/28/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "S7GraphView.h"

@class LegislatorObj;
@class PartisanScaleView;
@class TableCellDataObject;
@class LegislatorDetailDataSource;
@class VotingRecordDataSource;
@interface LegislatorDetailViewController : UITableViewController <UISplitViewControllerDelegate, 
													UIPopoverControllerDelegate>
{	
}
@property (nonatomic,assign) id dataObject;
@property (nonatomic,retain) NSNumber *dataObjectID;

@property (nonatomic,retain) IBOutlet S7GraphView *chartView;
@property (nonatomic,retain) VotingRecordDataSource *votingDataSource;

@property (nonatomic,retain) IBOutlet UIView *miniBackgroundView;
@property (nonatomic,retain) IBOutlet UIView *headerView;
@property (nonatomic,retain) IBOutlet UIImageView *leg_photoView;
@property (nonatomic,retain) IBOutlet UILabel *leg_indexTitleLab, *leg_rankLab, *leg_chamberPartyLab, *leg_chamberLab;
@property (nonatomic,retain) IBOutlet UILabel *leg_partyLab, *leg_districtLab, *leg_tenureLab, *leg_nameLab, *freshmanPlotLab;
@property (nonatomic,retain) IBOutlet UILabel *leg_reelection;
@property (nonatomic,retain) IBOutlet PartisanScaleView *indivSlider, *partySlider, *allSlider;


@property (nonatomic,retain) UIPopoverController *notesPopover;
@property (nonatomic,retain) UIPopoverController *masterPopover;
@property (nonatomic, assign) LegislatorObj *legislator;
@property (nonatomic, retain) LegislatorDetailDataSource *dataSource;

- (IBAction)resetTableData:(id)sender;

@end
