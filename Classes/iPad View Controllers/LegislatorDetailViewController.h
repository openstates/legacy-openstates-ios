//
//  LegislatorDetailViewController.h
//  TexLege
//
//  Created by Gregory Combs on 6/28/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@class LegislatorObj;
@class StaticGradientSliderView;
@class DirectoryDetailInfo;
@class CPLTColor;

@interface LegislatorDetailViewController : UITableViewController <UISplitViewControllerDelegate, CPLTPlotDataSource, CPLTPieChartDataSource,
																		UIPopoverControllerDelegate>
{	
}

@property (nonatomic, retain) NSMutableArray *sectionArray;

// For Core Plot
@property (nonatomic,retain) NSMutableArray *dataForPlot;
@property (nonatomic,retain) CPLTXYGraph *graph;
@property (nonatomic,retain) CPLTColor *texasRed, *texasBlue, *texasOrange;
@property (nonatomic,retain) IBOutlet CPLTLayerHostingView *scatterPlotView;

@property (nonatomic,retain) IBOutlet UIView *startupSplashView;
@property (nonatomic,retain) IBOutlet UIView *miniBackgroundView;
@property (nonatomic,retain) IBOutlet UIView *headerView;
@property (nonatomic,retain) IBOutlet UIImageView *leg_photoView;
@property (nonatomic,retain) IBOutlet UILabel *leg_indexTitleLab, *leg_rankLab, *leg_chamberPartyLab, *leg_chamberLab;
@property (nonatomic,retain) IBOutlet UILabel *leg_partyLab, *leg_districtLab, *leg_tenureLab, *leg_nameLab, *freshmanPlotLab;
@property (nonatomic,retain) IBOutlet StaticGradientSliderView *indivSlider, *partySlider, *allSlider;
@property (nonatomic,retain) IBOutlet UIView *indivPHolder, *partyPHolder, *allPHolder;
@property (nonatomic,retain) UIPopoverController *notesPopover;

@property (nonatomic, retain) IBOutlet LegislatorObj *legislator;

- (NSString *)popoverButtonTitle;

@end
