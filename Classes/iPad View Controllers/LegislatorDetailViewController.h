//
//  LegislatorDetailViewController.h
//  TexLege
//
//  Created by Gregory Combs on 6/28/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LegislatorObj;
@class StaticGradientSliderView;
@class DirectoryDetailInfo;

@interface LegislatorDetailViewController : UITableViewController <UITableViewDelegate, UIPopoverControllerDelegate, UISplitViewControllerDelegate>
{	
    UIPopoverController *popoverController;
	//IBOutlet UIBarButtonItem *m_popButton;

	IBOutlet StaticGradientSliderView *indivSlider, *partySlider, *allSlider;
	IBOutlet UIView *indivPHolder, *partyPHolder, *allPHolder;
	IBOutlet UIView *indivView, *partyView, *allView;
	
	LegislatorObj *legislator;
	
	IBOutlet UIImageView *leg_photoView;
	IBOutlet UILabel *leg_partyLab, *leg_districtLab, *leg_tenureLab, *leg_nameLab;
	
	NSMutableArray	*sectionArray;

}

@property (nonatomic,retain) IBOutlet UIImageView *leg_photoView;
@property (nonatomic,retain) IBOutlet UILabel *leg_titleLab, *leg_partyLab, *leg_districtLab, *leg_tenureLab, *leg_nameLab;
@property (nonatomic,retain) IBOutlet StaticGradientSliderView *indivSlider, *partySlider, *allSlider;
@property (nonatomic,retain) IBOutlet UIView *indivPHolder, *partyPHolder, *allPHolder;
@property (nonatomic,retain) IBOutlet UIView *indivView, *partyView, *allView;

@property (nonatomic,retain) LegislatorObj *legislator;
@property (nonatomic, retain) UIPopoverController *popoverController;
//@property (nonatomic, retain) IBOutlet UIBarButtonItem *m_popButton;

@property (nonatomic, retain) NSMutableArray *sectionArray;


//- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
//- (void) didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath;
//- (void) setupHeader:(UIView *)aHeader;

//- (void) loadView;
- (void) createSectionList;
- (void) createEntryInSection:(NSInteger)sectionIndex WithKeys:(NSArray *)keys andObjects:(NSArray *)objects;
- (void) standardTextCell:(UITableViewCell *)cell withInfo:(DirectoryDetailInfo *)cellInfo;

//- (IBAction)showMasterInPopover:(id)sender;
@end
