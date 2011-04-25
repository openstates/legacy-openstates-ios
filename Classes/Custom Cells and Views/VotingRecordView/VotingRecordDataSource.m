//
//  VotingRecordDataSource.m
//  TexLege
//
//  Created by Gregory Combs on 3/25/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import "VotingRecordDataSource.h"
#import "NSDate+Helper.h"
#import "TexLegeTheme.h"
#import "PartisanIndexStats.h"
#import "LegislatorObj.h"

@implementation VotingRecordDataSource
@synthesize legislatorID, chartData;

- (id)init {
	if ((self=[super init])) {
		legislatorID = nil;
		chartData = nil;
	}
	return self;
}

- (void)dealloc {
	self.chartData = nil;
	self.legislatorID = nil;
	[super dealloc];
}

- (void)setLegislatorID:(NSNumber *)newID {
	if (legislatorID)
		[legislatorID release];
	if (newID) {
		legislatorID = [newID retain];
		self.chartData = [[PartisanIndexStats sharedPartisanIndexStats] partisanshipDataForLegislatorID:newID];	
#warning find a way to drop in a graph key ... like what colors mean...
	}
}

// stupid to go here, but I'm too tired to put this someplace proper
- (void)prepareVotingRecordView:(S7GraphView *)aView {
	if (!aView)
		return;
	
	aView.dataSource = self;
	aView.delegate = self;
	
	aView.backgroundColor = [TexLegeTheme backgroundLight];
    
    aView.drawAxisX = YES;
    aView.drawAxisY = YES;
    aView.drawGridX = NO;
    aView.drawGridY = YES;
    
    aView.xValuesColor = [TexLegeTheme textDark];	// The values on the bottom of the chart (years)
    aView.yValuesColor = [TexLegeTheme textDark];	// The values on the left side of the chart (scores)
    
    aView.gridXColor = [UIColor darkGrayColor];
    aView.gridYColor = [UIColor darkGrayColor];
	
	aView.info = @"Historical Voting Comparison";
	aView.infoColor = [TexLegeTheme textDark];
    aView.drawInfo = YES;
	
	aView.highlightColor = [UIColor colorWithRed:0.6f green:0.745f blue:0.353f alpha:.3f]; // accent + transp
	
	aView.xUnit = @"Year";
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMinimumFractionDigits:1];
    [numberFormatter setMaximumFractionDigits:1];
    
    aView.yValuesFormatter = numberFormatter;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"''yy"];
    aView.xValuesFormatter = dateFormatter;
    
    [dateFormatter release];
    [numberFormatter release];
    
    aView.yUnit = @"Partisanship";
}

#pragma mark protocol S7GraphViewDataSource

- (NSDictionary *)graphViewMinAndMaxY:(S7GraphView *)graphView {
	
	LegislatorObj *member = [LegislatorObj objectWithPrimaryKeyValue:self.legislatorID];
	PartisanIndexStats *indexStats = [PartisanIndexStats sharedPartisanIndexStats];
	CGFloat sliderMin = [indexStats minPartisanIndexUsingChamber:[member.legtype integerValue]];
	CGFloat sliderMax = [indexStats maxPartisanIndexUsingChamber:[member.legtype integerValue]];

	if (sliderMax > (-sliderMin))
		sliderMin = (-sliderMax);
	else
		sliderMax = (-sliderMin);
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithFloat:sliderMin], @"minY",
			[NSNumber numberWithFloat:sliderMax], @"maxY",
			nil];
}

- (NSUInteger)graphViewMaximumNumberOfXaxisValues:(S7GraphView *)graphView {
	if (chartData)
		return [[chartData objectForKey:@"member"] count]; 
    return 0;
}

- (NSUInteger)graphViewNumberOfPlots:(S7GraphView *)graphView {
    /* Return the number of plots you are going to have in the view. 1+ */
    return 3;
}

- (UIColor *)graphView:(S7GraphView *)graphView colorForPlot:(NSUInteger)plotIndex {
	if (plotIndex == 0)
		return [TexLegeTheme texasRed];
	else if (plotIndex == 2)
		return [TexLegeTheme texasBlue];
	else
		return [TexLegeTheme texasGreen];
}


- (NSArray *)graphViewXValues:(S7GraphView *)graphView {
    /* An array of objects that will be further formatted to be displayed on the X-axis.
     The number of elements should be equal to the number of points you have for every plot. */
	
	return [chartData objectForKey:@"time"];
}

- (NSArray *)graphView:(S7GraphView *)graphView yValuesForPlot:(NSUInteger)plotIndex {
    /* Return the values for a specific graph. Each plot is meant to have equal number of points.
     And this amount should be equal to the amount of elements you return from graphViewXValues: method. */
	
	// Returning the following object in an array will treat it like missing data
	// [NSNumber numberWithFloat:CGFLOAT_MAX]
	
	
    switch (plotIndex) {
        case 0:
			return 	[chartData objectForKey:@"repub"];
            break;
		case 2:
			return 	[chartData objectForKey:@"democ"];
            break;
        case 1:
        default:
			return 	[chartData objectForKey:@"member"];
            break;
    }
}

- (BOOL)graphView:(S7GraphView *)graphView shouldFillPlot:(NSUInteger)plotIndex {
    return NO;
}

- (void)graphView:(S7GraphView *)graphView indexOfTappedXaxis:(NSInteger)indexOfTappedXaxis {
/*
 NSNumber *repub = [[chartData objectForKey:@"repub"] objectAtIndex:indexOfTappedXaxis];
	NSNumber *democ = [[chartData objectForKey:@"democ"] objectAtIndex:indexOfTappedXaxis];
	NSNumber *member = [[chartData objectForKey:@"member"] objectAtIndex:indexOfTappedXaxis];
	NSDate *time = [[chartData objectForKey:@"time"] objectAtIndex:indexOfTappedXaxis];
	
	if ([member floatValue] == CGFLOAT_MIN)
		return;
	
	LegislatorObj *legislator = [LegislatorObj objectWithPrimaryKeyValue:self.legislatorID];

	CGFloat diff1 = (CGFloat)([member floatValue] - [repub floatValue]);
	CGFloat diff2 = (CGFloat)([member floatValue] - [democ floatValue]);
	NSString *string = [NSString stringWithFormat:@"For %@:\n%@ is %01.2f pts from %@\n%@ is %01.2f pts from %@",
						[time stringWithFormat:@"yyyy"],
						[legislator legProperName], diff1, @"repubs",
						[legislator legProperName], diff2, @"dems"];
	
    debug_NSLog(@"%@",string);
 */
}

- (NSString *)graphView:(S7GraphView *)graphView nameForPlot:(NSInteger)plotIndex {
    switch (plotIndex) {
        case 0:
			return 	@"Reps";
            break;
		case 2:
			return 	@"Dems";
            break;
        case 1:
        default: {
			LegislatorObj *member = [LegislatorObj objectWithPrimaryKeyValue:self.legislatorID];
			return member.lastname;
		}
            break;
    }
}

@end
