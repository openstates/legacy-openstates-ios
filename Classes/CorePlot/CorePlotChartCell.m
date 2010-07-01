//
//  CorePlotChartCell.m
//  TexLege
//
//  Created by Gregory Combs on 6/26/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "CorePlotChartCell.h"

@implementation CorePlotChartCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		CPLayerHostingView *scatterPlotView = [[CPLayerHostingView alloc] initWithFrame:self.contentView.bounds];
		//scatterPlotView.frame = CGRectMake(20.0f, 55.0f, 728.0f, 556.0f);
		[self addSubview:scatterPlotView];
		
		CPTheme *theme = [CPTheme themeNamed:kCPDarkGradientTheme];
		[graph applyTheme:theme];
		scatterPlotView.hostedLayer = graph;
		
		graph.paddingLeft = 10.0;
		graph.paddingTop = 10.0;
		graph.paddingRight = 10.0;
		graph.paddingBottom = 10.0;
		
		// Setup plot space
		CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
		plotSpace.allowsUserInteraction = YES;
		plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(1.0) length:CPDecimalFromFloat(2.0)];
		plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(1.0) length:CPDecimalFromFloat(3.0)];
		
		// Axes
		CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
		CPXYAxis *x = axisSet.xAxis;
		x.majorIntervalLength = CPDecimalFromString(@"0.5");
		x.orthogonalCoordinateDecimal = CPDecimalFromString(@"2");
		x.minorTicksPerInterval = 2;
		NSArray *exclusionRanges = [NSArray arrayWithObjects:
									[CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(1.99) length:CPDecimalFromFloat(0.02)], 
									[CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.99) length:CPDecimalFromFloat(0.02)],
									[CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(2.99) length:CPDecimalFromFloat(0.02)],
									nil];
		x.labelExclusionRanges = exclusionRanges;
		
		CPXYAxis *y = axisSet.yAxis;
		y.majorIntervalLength = CPDecimalFromString(@"0.5");
		y.minorTicksPerInterval = 5;
		y.orthogonalCoordinateDecimal = CPDecimalFromString(@"2");
		exclusionRanges = [NSArray arrayWithObjects:
						   [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(1.99) length:CPDecimalFromFloat(0.02)], 
						   [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.99) length:CPDecimalFromFloat(0.02)],
						   [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(3.99) length:CPDecimalFromFloat(0.02)],
						   nil];
		y.labelExclusionRanges = exclusionRanges;
		
		// Create a blue plot area
		CPScatterPlot *boundLinePlot = [[[CPScatterPlot alloc] init] autorelease];
		boundLinePlot.identifier = @"Blue Plot";
		boundLinePlot.dataLineStyle.miterLimit = 1.0f;
		boundLinePlot.dataLineStyle.lineWidth = 3.0f;
		boundLinePlot.dataLineStyle.lineColor = [CPColor blueColor];
		boundLinePlot.dataSource = self.contentView;
		[graph addPlot:boundLinePlot];
		
		// Do a blue gradient
		CPColor *areaColor1 = [CPColor colorWithComponentRed:0.3 green:0.3 blue:1.0 alpha:0.8];
		CPGradient *areaGradient1 = [CPGradient gradientWithBeginningColor:areaColor1 endingColor:[CPColor clearColor]];
		areaGradient1.angle = -90.0f;
		CPFill *areaGradientFill = [CPFill fillWithGradient:areaGradient1];
		boundLinePlot.areaFill = areaGradientFill;
		boundLinePlot.areaBaseValue = [[NSDecimalNumber zero] decimalValue];    
		
		// Add plot symbols
		CPLineStyle *symbolLineStyle = [CPLineStyle lineStyle];
		symbolLineStyle.lineColor = [CPColor blackColor];
		CPPlotSymbol *plotSymbol = [CPPlotSymbol ellipsePlotSymbol];
		plotSymbol.fill = [CPFill fillWithColor:[CPColor blueColor]];
		plotSymbol.lineStyle = symbolLineStyle;
		plotSymbol.size = CGSizeMake(10.0, 10.0);
		boundLinePlot.plotSymbol = plotSymbol;
		
		// Create a green plot area
		CPScatterPlot *dataSourceLinePlot = [[[CPScatterPlot alloc] init] autorelease];
		dataSourceLinePlot.identifier = @"Green Plot";
		dataSourceLinePlot.dataLineStyle.lineWidth = 3.f;
		dataSourceLinePlot.dataLineStyle.lineColor = [CPColor greenColor];
		dataSourceLinePlot.dataLineStyle.dashPattern = [NSArray arrayWithObjects:[NSNumber numberWithFloat:5.0f], [NSNumber numberWithFloat:5.0f], nil];
		dataSourceLinePlot.dataSource = self.contentView;
		
		// Put an area gradient under the plot above
		CPColor *areaColor = [CPColor colorWithComponentRed:0.3 green:1.0 blue:0.3 alpha:0.8];
		CPGradient *areaGradient = [CPGradient gradientWithBeginningColor:areaColor endingColor:[CPColor clearColor]];
		areaGradient.angle = -90.0f;
		areaGradientFill = [CPFill fillWithGradient:areaGradient];
		dataSourceLinePlot.areaFill = areaGradientFill;
		dataSourceLinePlot.areaBaseValue = CPDecimalFromString(@"1.75");
		
		// Animate in the new plot, as an example
		dataSourceLinePlot.opacity = 0.0f;
		[graph addPlot:dataSourceLinePlot];
		
		CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
		fadeInAnimation.duration = 1.0f;
		fadeInAnimation.removedOnCompletion = NO;
		fadeInAnimation.fillMode = kCAFillModeForwards;
		fadeInAnimation.toValue = [NSNumber numberWithFloat:1.0];
		[dataSourceLinePlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
		
		
    }
    return self;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {

    [super dealloc];
}


@end
