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
@class CPColor;

@interface LegislatorDetailViewController : UITableViewController <UITableViewDelegate, UIPopoverControllerDelegate, 
												UISplitViewControllerDelegate, CPPlotDataSource, CPPieChartDataSource>
{	
	IBOutlet LegislatorObj *legislator;
    UIPopoverController *popoverController;

	IBOutlet UIView *startupSplashView;
	IBOutlet UIView *headerView;
	IBOutlet UIView *miniBackgroundView;
	IBOutlet UIImageView *leg_photoView;
	IBOutlet UILabel *leg_partyLab, *leg_districtLab, *leg_tenureLab, *leg_nameLab;
	IBOutlet UILabel *leg_indexTitleLab, *leg_rankLab, *leg_chamberPartyLab, *leg_chamberLab;
	IBOutlet CPLayerHostingView *scatterPlotView;//, *barChartView, *pieChartView;
	IBOutlet UIView *indivPHolder, *partyPHolder, *allPHolder;
	IBOutlet StaticGradientSliderView *indivSlider, *partySlider, *allSlider;
			
@private
	CPXYGraph *graph;//, *barChart, *pieChart;
	NSMutableArray	*sectionArray;
	NSMutableArray *dataForPlot; //, *dataForChart;
	
	CPColor *texasRed, *texasBlue, *texasOrange;
}

@property(nonatomic, retain) NSMutableArray *dataForPlot; //, *dataForChart
@property (nonatomic, retain) UIPopoverController *popoverController;

@property (nonatomic,retain) CPXYGraph *graph;
@property (nonatomic,retain) CPColor *texasRed, *texasBlue, *texasOrange;
@property (nonatomic,retain) IBOutlet UIView *startupSplashView;
@property (nonatomic,retain) IBOutlet UIView *miniBackgroundView;
@property (nonatomic,retain) IBOutlet UIView *headerView;
@property (nonatomic,retain) IBOutlet CPLayerHostingView *scatterPlotView;
@property (nonatomic,retain) IBOutlet UIImageView *leg_photoView;
@property (nonatomic,retain) IBOutlet UILabel *leg_indexTitleLab, *leg_rankLab, *leg_chamberPartyLab, *leg_chamberLab;
@property (nonatomic,retain) IBOutlet UILabel *leg_partyLab, *leg_districtLab, *leg_tenureLab, *leg_nameLab;
@property (nonatomic,retain) IBOutlet StaticGradientSliderView *indivSlider, *partySlider, *allSlider;
@property (nonatomic,retain) IBOutlet UIView *indivPHolder, *partyPHolder, *allPHolder;

@property (nonatomic, retain) IBOutlet LegislatorObj *legislator;

@property (nonatomic, retain) NSMutableArray *sectionArray;

@end
