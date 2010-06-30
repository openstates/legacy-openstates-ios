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
@interface LegislatorDetailViewController : UITableViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate>
{
    UIPopoverController *popoverController;

	IBOutlet UIToolbar *toolbar;
	IBOutlet UITableView *legInfoTable;
	
	IBOutlet StaticGradientSliderView *indivSlider, *partySlider, *allSlider;
	IBOutlet UIView *indivPHolder, *partyPHolder, *allPHolder;
	IBOutlet UIView *indivView, *partyView, *allView;
	
	NSString *tempLegislator;
	LegislatorObj *legislator;
	
	IBOutlet UIImageView *leg_photoView;
	IBOutlet UILabel *leg_partyLab, *leg_districtLab, *leg_tenureLab, *leg_nameLab;
}

@property (nonatomic,retain) IBOutlet UIImageView *leg_photoView;
@property (nonatomic,retain) IBOutlet UILabel *leg_titleLab, *leg_partyLab, *leg_districtLab, *leg_tenureLab, *leg_nameLab;
@property (nonatomic,retain) IBOutlet StaticGradientSliderView *indivSlider, *partySlider, *allSlider;

@property (nonatomic,retain) LegislatorObj *legislator;
@property (nonatomic, retain) NSString *tempLegislator;

@end
