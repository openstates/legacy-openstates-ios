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

@interface LegislatorDetailViewController : UITableViewController <UITableViewDelegate, UIPopoverControllerDelegate, 
												UISplitViewControllerDelegate, CPLTPlotDataSource, CPLTPieChartDataSource>
{	
	IBOutlet LegislatorObj *legislator;
    UIPopoverController *popoverController;

	IBOutlet UIView *startupSplashView;
	IBOutlet UIView *headerView;
	IBOutlet UIView *miniBackgroundView;
	IBOutlet UIImageView *leg_photoView;
	IBOutlet UILabel *leg_partyLab, *leg_districtLab, *leg_tenureLab, *leg_nameLab, *freshmanPlotLab;
	IBOutlet UILabel *leg_indexTitleLab, *leg_rankLab, *leg_chamberPartyLab, *leg_chamberLab;
	IBOutlet CPLTLayerHostingView *scatterPlotView;
	IBOutlet UIView *indivPHolder, *partyPHolder, *allPHolder;
	IBOutlet StaticGradientSliderView *indivSlider, *partySlider, *allSlider;
			
@private
	CPLTXYGraph *graph;
	NSMutableArray	*sectionArray;
	NSMutableArray *dataForPlot;
	
	CPLTColor *texasRed, *texasBlue, *texasOrange;
}

@property(nonatomic, retain) NSMutableArray *dataForPlot;
@property (nonatomic, retain) UIPopoverController *popoverController;

@property (nonatomic,retain) CPLTXYGraph *graph;
@property (nonatomic,retain) CPLTColor *texasRed, *texasBlue, *texasOrange;
@property (nonatomic,retain) IBOutlet UIView *startupSplashView;
@property (nonatomic,retain) IBOutlet UIView *miniBackgroundView;
@property (nonatomic,retain) IBOutlet UIView *headerView;
@property (nonatomic,retain) IBOutlet CPLTLayerHostingView *scatterPlotView;
@property (nonatomic,retain) IBOutlet UIImageView *leg_photoView;
@property (nonatomic,retain) IBOutlet UILabel *leg_indexTitleLab, *leg_rankLab, *leg_chamberPartyLab, *leg_chamberLab;
@property (nonatomic,retain) IBOutlet UILabel *leg_partyLab, *leg_districtLab, *leg_tenureLab, *leg_nameLab, *freshmanPlotLab;
@property (nonatomic,retain) IBOutlet StaticGradientSliderView *indivSlider, *partySlider, *allSlider;
@property (nonatomic,retain) IBOutlet UIView *indivPHolder, *partyPHolder, *allPHolder;

@property (nonatomic, retain) IBOutlet LegislatorObj *legislator;

@property (nonatomic, retain) NSMutableArray *sectionArray;

@end
