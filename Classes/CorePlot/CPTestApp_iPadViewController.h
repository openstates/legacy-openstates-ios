//
//  CPTestApp_iPadViewController.h
//  CPTestApp-iPad
//
//  Created by Brad Larson on 4/1/2010.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@class LegislatorObj;

@interface CPTestApp_iPadViewController : UIViewController <CPPlotDataSource, CPPieChartDataSource, UIPopoverControllerDelegate, UISplitViewControllerDelegate>
{
	IBOutlet CPLayerHostingView *scatterPlotView, *barChartView, *pieChartView;
	CPXYGraph *graph, *barChart, *pieChart;

	NSMutableArray *dataForChart, *dataForPlot;
	UIPopoverController *popoverController;
	LegislatorObj *legislator;
}
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) LegislatorObj *legislator;
@property (nonatomic,retain) id detailViewController;
@property(readwrite, retain, nonatomic) NSMutableArray *dataForChart, *dataForPlot;

// Plot construction methods
- (void)constructScatterPlot;
- (void)constructBarChart;
- (void)constructPieChart;

@end

