//
//  LegislatorDetailViewController.m
//  TexLege
//
//  Created by Gregory Combs on 6/28/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "TableDataSourceProtocol.h"
#import "LegislatorDetailViewController.h"
#import "LegislatorDetailDataSource.h"

#import "LegislatorMasterViewController.h"
#import "LegislatorObj.h"
#import "DistrictOfficeObj.h"
#import "DistrictMapObj.h"

#import "CommitteeObj.h"
#import "CommitteePositionObj.h"
#import "WnomObj.h"

#import "StaticGradientSliderView.h"
#import "UtilityMethods.h"
#import "TableDataSourceProtocol.h"
#import "DirectoryDetailInfo.h"
#import "NotesViewController.h"
#import "TexLegeAppDelegate.h"

#import "CommitteeDetailViewController.h"

#import "MapViewController.h"
#import "MiniBrowserController.h"
#import "CapitolMapsDetailViewController.h"

#import "PartisanIndexStats.h"
#import "UIImage+ResolutionIndependent.h"
#import "ImageCache.h"

#import "TexLegeEmailComposer.h"

#import "ColoredBarButtonItem.h"
@interface LegislatorDetailViewController (Private)

- (void) pushMapViewWithMap:(CapitolMap *)capMap;
- (void) showWebViewWithURL:(NSURL *)url;
- (void) setupHeaderView;
- (void) setupHeader;
- (void) plotHistory;
@end


@implementation LegislatorDetailViewController

@synthesize legislator, dataSource;
@synthesize startupSplashView, headerView, miniBackgroundView;

@synthesize scatterPlotView, dataForPlot;
@synthesize texasRed, texasBlue, texasOrange;

@synthesize leg_indexTitleLab, leg_rankLab, leg_chamberPartyLab, leg_chamberLab;
@synthesize leg_photoView, leg_partyLab, leg_districtLab, leg_tenureLab, leg_nameLab, freshmanPlotLab;
@synthesize indivSlider, partySlider, allSlider;
@synthesize indivPHolder, partyPHolder, allPHolder;
@synthesize notesPopover, masterPopover;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (self.headerView == nil) {
		NSString * headerViewXib = [UtilityMethods isIPadDevice] ? @"LegislatorDetailHeaderView~ipad" : @"LegislatorDetailHeaderView~iphone";
		// Load one of our header views (iPad or iPhone selected automatically by the file's name extension
		NSArray *objects = [[NSBundle mainBundle] loadNibNamed:headerViewXib owner:self options:NULL];
		self.headerView = [objects objectAtIndex:0];
	}
	
	CGRect headerRect = self.headerView.bounds;
	headerRect.size.width = self.tableView.bounds.size.width;
	
	//UIImage *sealImage = [UIImage imageWithContentsOfResolutionIndependentFile:@"seal.png"];
	UIImage *sealImage = [UIImage imageNamed:@"seal.png"];
	UIColor *sealColor = [UIColor colorWithPatternImage:sealImage];	
	self.miniBackgroundView.backgroundColor = sealColor;
	//self.headerView.backgroundColor = sealColor;
	//self.scatterPlotView.backgroundColor = sealColor;
	//self.scatterPlotView.backgroundColor = self.tableView.backgroundColor;
	//self.scatterPlotView.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
	self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
	self.clearsSelectionOnViewWillAppear = NO;
	
	self.dataForPlot = [NSMutableArray array];
	
	self.texasRed = [CPLTColor colorWithComponentRed:198.0/255 green:0.0 blue:47.0/255 alpha:1.0f];
	//	self.texasBlue = [CPLTColor colorWithComponentRed:50.0/255 green:79.0/255 blue:133.0/255 alpha:1.0f];
	self.texasBlue = [CPLTColor colorWithComponentRed:90.0/255 green:141.0/255 blue:222.0/255 alpha:1.0f];
	self.texasOrange = [CPLTColor colorWithComponentRed:204.0/255 green:85.0/255 blue:0.0 alpha:1.0f];
	
	[self.tableView setTableHeaderView:self.headerView];
	
	if ([UtilityMethods isIPadDevice]) {
		StaticGradientSliderView *sliderV = [[StaticGradientSliderView alloc] initWithFrame:CGRectZero];
		self.indivSlider = sliderV;
		[sliderV release];
		
		sliderV = [[StaticGradientSliderView alloc] initWithFrame:CGRectZero];
		self.partySlider = sliderV;
		[sliderV release];
		
		sliderV = [[StaticGradientSliderView alloc] initWithFrame:CGRectZero];
		self.allSlider = sliderV;
		[sliderV release];
		
		if (self.indivSlider) {
			[self.indivSlider addToPlaceholder:self.indivPHolder];
			self.indivSlider.usesSmallStar = NO;
		}
		if (self.partySlider) {
			[self.partySlider addToPlaceholder:self.partyPHolder];
			self.partySlider.usesSmallStar = NO;
		}
		if (self.allSlider) {
			[self.allSlider addToPlaceholder:self.allPHolder];
			self.allSlider.usesSmallStar = NO;
		}
	}	
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
	[[self navigationController] popToRootViewControllerAnimated:YES];
	
	self.leg_photoView = nil;
	self.dataForPlot = nil;
	//self.scatterPlotView = nil;
	self.startupSplashView = nil;
	
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
	self.texasRed = nil;
	self.texasBlue = nil;
	self.texasOrange = nil;
	self.indivSlider = nil;
	self.partySlider = nil;
	self.allSlider = nil;
	self.indivPHolder = nil;
	self.partyPHolder = nil;
	self.allPHolder = nil;
	self.legislator = nil;
	self.dataSource = nil;
	self.headerView = nil;
	self.startupSplashView = nil;	
	self.leg_photoView = nil;
	self.dataForPlot = nil;
	self.tableView = nil;
	self.scatterPlotView = nil;
	self.miniBackgroundView = nil;
	self.leg_partyLab = self.leg_districtLab = self.leg_tenureLab = self.leg_nameLab = self.freshmanPlotLab = nil;
	//self.scatterPlotView = nil;
	
	self.notesPopover = nil;
	self.masterPopover = nil;

	[super viewDidUnload];
}


- (void)dealloc {
	self.texasRed = nil;
	self.texasBlue = nil;
	self.texasOrange = nil;
	self.indivSlider = nil;
	self.partySlider = nil;
	self.allSlider = nil;
	self.indivPHolder = nil;
	self.partyPHolder = nil;
	self.allPHolder = nil;
	self.dataSource = nil;
	self.legislator = nil;
	self.headerView = nil;
	self.startupSplashView = nil;	
	self.leg_photoView = nil;
	self.dataForPlot = nil;
	self.tableView = nil;
	self.scatterPlotView = nil;
	self.miniBackgroundView = nil;
	self.leg_partyLab = self.leg_districtLab = self.leg_tenureLab = self.leg_nameLab = self.freshmanPlotLab = nil;

	self.notesPopover = nil;
	self.masterPopover = nil;

	[super dealloc];
}


- (NSString *)chamberAbbrev {
	NSString *chamberName = nil;
	if ([self.legislator.legtype integerValue] == HOUSE) // Representative
		chamberName = @"House";
	else if ([self.legislator.legtype integerValue] == SENATE) // Senator
		chamberName = @"Senate";
	else // don't know the party?
		chamberName = @"";

	return chamberName;
}

- (NSString *)chamberPartyAbbrev {
	NSString *partyName = nil;
	if ([self.legislator.party_id integerValue] == DEMOCRAT) // Democrat
		partyName = @"Dem.";
	else if ([self.legislator.party_id integerValue] == REPUBLICAN) // Republican
		partyName = @"Rep.";
	else // don't know the party?
		partyName = @"Ind.";
	
	return [NSString stringWithFormat:@"%@ %@ Avg.", [self chamberAbbrev], partyName];
}

	
- (void)setupHeader {	
	NSString *legName = [NSString stringWithFormat:@"%@ %@",  [self.legislator legTypeShortName], [self.legislator legProperName]];
	self.leg_nameLab.text = legName;
	self.navigationItem.title = legName;

	//[[ImageCache sharedImageCache] loadImageView:self.leg_photoView fromPath:[UIImage highResImagePathWithPath:self.legislator.photo_name]];
	self.leg_photoView.image = [UIImage imageNamed:[UIImage highResImagePathWithPath:self.legislator.photo_name]];
	self.leg_partyLab.text = [self.legislator party_name];
	self.leg_districtLab.text = [NSString stringWithFormat:@"District %@", self.legislator.district];
	self.leg_tenureLab.text = [self.legislator tenureString];
	
	[self plotHistory];

	if ([UtilityMethods isIPadDevice]) {
		PartisanIndexStats *indexStats = [PartisanIndexStats sharedPartisanIndexStats];

		self.leg_indexTitleLab.text = [NSString stringWithFormat:@"Legislator Roll Call Index (%@)",
									   [indexStats currentSessionYear]];

		if ([self.legislator.partisan_index floatValue] == 0.0f)
			self.leg_rankLab.enabled = NO;
		self.leg_rankLab.text = [NSString stringWithFormat:@"Rank: %@",
								 [indexStats partisanRankForLegislator:self.legislator onlyParty:YES]];
		
		self.leg_chamberPartyLab.text = [self chamberPartyAbbrev];
		self.leg_chamberLab.text = [[self chamberAbbrev] stringByAppendingString:@" Avg."];
		
		if (self.indivSlider) {
			[self.indivSlider setLegislator:self.legislator];
			self.indivSlider.sliderValue = self.legislator.partisan_index.floatValue;
		}	
		if (self.partySlider) {
			[self.partySlider setLegislator:self.legislator];
			self.partySlider.sliderValue = [[indexStats partyPartisanIndexUsingLegislator:self.legislator] floatValue];
		}	
		if (self.allSlider) {
			[self.allSlider setLegislator:self.legislator];
			self.allSlider.sliderValue = [[indexStats overallPartisanIndexUsingLegislator:self.legislator] floatValue];
		}	
	}
}

- (void)setLegislator:(LegislatorObj *)newLegislator {
	if (self.startupSplashView) {
		[self.startupSplashView removeFromSuperview];
	}
	if (legislator) [legislator release], legislator = nil;
	if (newLegislator) {
		legislator = [newLegislator retain];
		
		LegislatorDetailDataSource *ds = [[LegislatorDetailDataSource alloc] initWithLegislator:legislator];
		self.dataSource = ds;
		self.tableView.dataSource = self.dataSource;
		[ds release];
		
		[self setupHeader];
		
		if (masterPopover != nil) {
			[masterPopover dismissPopoverAnimated:YES];
		}		
		
		[self.tableView reloadData];
		[self.view setNeedsDisplay];
	}
}
#pragma mark -
#pragma mark Managing the popover

/*
- (NSString *)popoverButtonTitle {
	return @"Legislators";	
}
*/

// Called on the delegate when the user has taken action to dismiss the popover. This is not called when -dismissPopoverAnimated: is called directly.
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	[self.tableView reloadData];
	debug_NSLog(@"%@", self.tableView);
	if (self.notesPopover && [self.notesPopover isEqual:popoverController])
		self.notesPopover = nil;
}
	
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	BOOL showSplash = ([UtilityMethods isLandscapeOrientation] == NO && [UtilityMethods isIPadDevice]);

	if ([UtilityMethods isIPadDevice] && !self.legislator && ![UtilityMethods isLandscapeOrientation])  {
		TexLegeAppDelegate *appDelegate = [TexLegeAppDelegate appDelegate];
				
		self.legislator = [[appDelegate legislatorMasterVC] selectObjectOnAppear];		
	}
	
	
	if (self.legislator) {
		showSplash = NO;
		[self setupHeader];
	}

	if (showSplash) {
		// TODO: We could alternatively use this opportunity to open a proper informational introduction
		// for instance, drop in a new view taking the full screen that gives a full menu and helpful info
		
		if (self.startupSplashView == nil) {
			NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"StartupSplashView-Portrait" owner:self options:NULL];
			self.startupSplashView = [objects objectAtIndex:0];
		}
		[self.view addSubview:self.startupSplashView];
	}
	else {
		[self.startupSplashView removeFromSuperview];
		self.startupSplashView = nil;
	}
}

#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc 
	 willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem 
	   forPopoverController: (UIPopoverController*)pc {
	
	barButtonItem.title = @"Legislators";
	[self.navigationItem setRightBarButtonItem:barButtonItem animated:YES];
	self.masterPopover = pc;
}

// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc 
	 willShowViewController:(UIViewController *)aViewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
		
	[self.navigationItem setRightBarButtonItem:nil animated:YES];
	self.masterPopover = nil;
}

- (void) splitViewController:(UISplitViewController *)svc popoverController: (UIPopoverController *)pc
   willPresentViewController: (UIViewController *)aViewController
{
	if (self.notesPopover) {
		[self.notesPopover dismissPopoverAnimated:YES];
		self.notesPopover = nil;
	}
/*    if (pc != nil) {
		[[TexLegeAppDelegate appDelegate] dismissMasterListPopover:self.navigationItem.rightBarButtonItem];
        //[pc dismissPopoverAnimated:YES];
		// do I need to set pc to nil?  I need to confirm, but I think it breaks things.
    }
*/
}

#pragma mark -
#pragma mark orientations

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}


// the user selected a row in the table.
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	
	// deselect the new row using animation
	[aTableView deselectRowAtIndexPath:newIndexPath animated:YES];	
	
	DirectoryDetailInfo *cellInfo = [self.dataSource dataObjectForIndexPath:newIndexPath];

	if (!cellInfo.isClickable)
		return;
	
		if (cellInfo.entryType == DirectoryTypeNotes) { // We need to edit the notes thing...
			NotesViewController *nextViewController = nil;
			if ([UtilityMethods isIPadDevice])
				nextViewController = [[NotesViewController alloc] initWithNibName:@"NotesView~ipad" bundle:nil];
			else
				nextViewController = [[NotesViewController alloc] initWithNibName:@"NotesView" bundle:nil];
			
			// If we got a new view controller, push it .
			if (nextViewController) {
				nextViewController.legislator = self.legislator;
				nextViewController.backView = aTableView;
				
				if ([UtilityMethods isIPadDevice]) {
					//nextViewController.toolbar.hidden = NO;
					self.notesPopover = [[[UIPopoverController alloc] initWithContentViewController:nextViewController] autorelease];
					self.notesPopover.delegate = self;
					CGRect cellRect = [aTableView rectForRowAtIndexPath:newIndexPath];
					[self.notesPopover presentPopoverFromRect:cellRect inView:aTableView permittedArrowDirections:(UIPopoverArrowDirectionLeft & UIPopoverArrowDirectionRight & UIPopoverArrowDirectionDown ) animated:YES];
				}
				else
					[self.navigationController pushViewController:nextViewController animated:YES];
				
				[nextViewController release];
			}
			
		}
		else if (cellInfo.entryType == DirectoryTypeCommittee) {
			CommitteeDetailViewController *subDetailController = [[CommitteeDetailViewController alloc] initWithNibName:@"CommitteeDetailViewController" bundle:nil];
			subDetailController.committee = cellInfo.entryValue;
			[self.navigationController pushViewController:subDetailController animated:YES];
			[subDetailController release];
		}
		else if (cellInfo.entryType == DirectoryTypeOfficeMap || cellInfo.entryType == DirectoryTypeChamberMap) {
			CapitolMap *capMap = cellInfo.entryValue;			
			[self pushMapViewWithMap:capMap];
		}
		else if (cellInfo.entryType == DirectoryTypeMail) {
			[[TexLegeEmailComposer sharedTexLegeEmailComposer] presentMailComposerTo:cellInfo.entryValue 
																			 subject:@"" body:@"" commander:self];			
		}
		// Switch to the appropriate application for this url...
		else if (cellInfo.entryType == DirectoryTypeMap) {
			if ([cellInfo.entryValue isKindOfClass:[DistrictOfficeObj class]] || [cellInfo.entryValue isKindOfClass:[DistrictMapObj class]])
			{			
				MapViewController *mapVC = [MapViewController sharedMapViewController];
				
				DistrictOfficeObj *districtOffice = nil;
				if ([cellInfo.entryValue isKindOfClass:[DistrictOfficeObj class]])
					districtOffice = cellInfo.entryValue;
				
				[mapVC resetMapViewWithAnimation:NO];
				[mapVC.mapView addOverlay:[self.legislator.districtMap polygon]];

				if (districtOffice) {
					[mapVC.mapView addAnnotation:districtOffice];
					[mapVC moveMapToAnnotation:districtOffice];
				}
				else {
					[mapVC.mapView setRegion:self.legislator.districtMap.region animated:YES]; 
				}
				[self.navigationController pushViewController:mapVC animated:YES];
				//[mapVC release];
			}
		}
		else if (cellInfo.entryType > kDirectoryTypeIsURLHandler &&
				 cellInfo.entryType < kDirectoryTypeIsExternalHandler) {	// handle the URL ourselves in a webView
			[self showWebViewWithURL:[cellInfo generateURL:self.legislator]];
		}
		else if (cellInfo.entryType > kDirectoryTypeIsExternalHandler)		// tell the device to open the url externally
		{
			NSURL *myURL = [cellInfo generateURL:self.legislator];
			// do the URL
			
			BOOL isPhone = ([UtilityMethods canMakePhoneCalls]);
			if ((cellInfo.entryType == DirectoryTypePhone) && (!isPhone)) {
				debug_NSLog(@"Tried to make a phonecall, but this isn't a phone: %@", myURL.description);
				[UtilityMethods alertNotAPhone];
				return;
			}
			
			[UtilityMethods openURLWithoutTrepidation:myURL];
		}
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat height = 44.0f;
	NSInteger row = [indexPath row];
	NSInteger section = [indexPath section];
	
	DirectoryDetailInfo *cellInfo = [self.dataSource dataObjectForIndexPath:indexPath];
	
	if (cellInfo == nil) {
		debug_NSLog(@"LegislatorDetailViewController:heightForRow: error finding table entry for section:%d row:%d", section, row);
		return height;
	}
	
	if ([cellInfo.subtitle rangeOfString:@"Address"].length )
		height = 98.0f;
	else if ([cellInfo.entryValue isKindOfClass:[NSString string]]) {
		NSString *tempStr = cellInfo.entryValue;
		if (!tempStr || [tempStr length] <= 0) {
			height = 0.0f;
		}
	}
	return height;
}

- (void) pushMapViewWithMap:(CapitolMap *)capMap {
	CapitolMapsDetailViewController *detailController = [[CapitolMapsDetailViewController alloc] initWithNibName:@"CapitolMapsDetailViewController" bundle:nil];
	detailController.map = capMap;

	// push the detail view controller onto the navigation stack to display it
	[[self navigationController] pushViewController:detailController animated:YES];
	[detailController release];
}

- (void) showWebViewWithURL:(NSURL *)url { 

	if ([UtilityMethods canReachHostWithURL:url]) { // do we have a good URL/connection?
		MiniBrowserController *mbc = [MiniBrowserController sharedBrowserWithURL:url];
		[mbc display:self];
	}

}	


#pragma mark -
#pragma mark Plot construction methods

- (void)plotHistory {
	NSInteger countOfScores = [self.legislator.wnomScores count];

	self.freshmanPlotLab.hidden = (countOfScores > 0);
	if (countOfScores == 0)
		return;
	
	if (self.dataForPlot && [self.dataForPlot count])
		[self.dataForPlot removeAllObjects];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"session" ascending:YES];
	NSArray *descriptors = [[NSArray alloc] initWithObjects:sortDescriptor,nil];
	NSArray *sortedScores = [[self.legislator.wnomScores allObjects] sortedArrayUsingDescriptors:descriptors];
	[sortDescriptor release];
	[descriptors release];
	
	
	WnomObj *firstScore = [sortedScores objectAtIndex:0];
	NSInteger year = 2010;
	if (firstScore && firstScore.session) {
		year = 1847 + [firstScore.session integerValue] * 2;
	}
		
	NSString *refStr = [NSString stringWithFormat:@"%d-02-02", year];
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setDateFormat:@"yyyy-MM-dd"];
	NSDate *refDate = [inputFormatter dateFromString:refStr];
	[inputFormatter release];
	
    NSTimeInterval oneSession = 24 * 60 * 60 * 365 * 2;
		
    // Create graph from theme
    CPLTXYGraph * graph = [[CPLTXYGraph alloc] initWithFrame:CGRectZero];
	CPLTTheme *theme = [CPLTTheme themeNamed:kCPStocksTheme];
	[graph applyTheme:theme];
	
    
    // Setup scatter plot space
    CPLTXYPlotSpace *plotSpace = (CPLTXYPlotSpace *)graph.defaultPlotSpace;
	plotSpace.allowsUserInteraction = YES;

    NSTimeInterval xLow = 0.0f;
    plotSpace.xRange = [CPLTPlotRange plotRangeWithLocation:CPLTDecimalFromFloat(xLow-(oneSession/2)) length:CPLTDecimalFromInteger(oneSession*countOfScores)];
    plotSpace.yRange = [CPLTPlotRange plotRangeWithLocation:CPLTDecimalFromFloat(-1.25) length:CPLTDecimalFromFloat(2.5)];
    
    // Axes
	CPLTXYAxisSet *axisSet = (CPLTXYAxisSet *)graph.axisSet;
    CPLTXYAxis *x = axisSet.xAxis;
    x.majorIntervalLength = CPLTDecimalFromFloat(oneSession);
    x.orthogonalCoordinateDecimal = CPLTDecimalFromString(@"0.0");
    x.minorTicksPerInterval = 0;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
	[dateFormatter setDateFormat:@"‘YY"];

    CPLTTimeFormatter *timeFormatter = [[CPLTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
	[dateFormatter release];
	
    timeFormatter.referenceDate = refDate;
    x.labelFormatter = timeFormatter;
	[timeFormatter release];
	NSArray *exclusionRanges = [[NSArray alloc] initWithObjects:
								[CPLTPlotRange plotRangeWithLocation:CPLTDecimalFromFloat(-10 * oneSession) length:CPLTDecimalFromFloat(9*oneSession)],
								[CPLTPlotRange plotRangeWithLocation:CPLTDecimalFromFloat(oneSession*countOfScores) length:CPLTDecimalFromFloat(9*oneSession)],
								nil];
	x.labelExclusionRanges = exclusionRanges;
	[exclusionRanges release];
	
    CPLTXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength = CPLTDecimalFromString(@"0.5");
    y.minorTicksPerInterval = 1;

    y.orthogonalCoordinateDecimal = CPLTDecimalFromFloat(oneSession/2);
	exclusionRanges = [[NSArray alloc] initWithObjects:
					   [CPLTPlotRange plotRangeWithLocation:CPLTDecimalFromFloat(-10.0) length:CPLTDecimalFromFloat(8.5f)], 
					   [CPLTPlotRange plotRangeWithLocation:CPLTDecimalFromFloat(0.0) length:CPLTDecimalFromFloat(0.02)], 
					   [CPLTPlotRange plotRangeWithLocation:CPLTDecimalFromFloat(1.5) length:CPLTDecimalFromFloat(8.5f)], 
					   nil];
	y.labelExclusionRanges = exclusionRanges;
	[exclusionRanges release];
	
	// Create a blue plot area
	CPLTScatterPlot *democratPlot = [[CPLTScatterPlot alloc] init];
    democratPlot.identifier = @"Democrat Plot";
	democratPlot.dataLineStyle.miterLimit = 5.0f;
	democratPlot.dataLineStyle.lineWidth = 2.5f;
	democratPlot.dataLineStyle.lineColor = self.texasBlue;
	democratPlot.dataLineStyle.lineCap = kCGLineCapRound;
    democratPlot.dataSource = self;

	// Add plot symbols
	CPLTLineStyle *symbolLineStyle = [CPLTLineStyle lineStyle];
	symbolLineStyle.lineColor = self.texasBlue;
	CPLTPlotSymbol *plotSymbol = [CPLTPlotSymbol ellipsePlotSymbol];
	plotSymbol.fill = [CPLTFill fillWithColor:self.texasBlue];
	plotSymbol.lineStyle = symbolLineStyle;
    plotSymbol.size = CGSizeMake(5.0, 5.0);
    democratPlot.plotSymbol = plotSymbol;
	[graph addPlot:democratPlot];
	[democratPlot release];

	// Create a blue plot area
	CPLTScatterPlot *republicanPlot = [[CPLTScatterPlot alloc] init];
    republicanPlot.identifier = @"Republican Plot";
	republicanPlot.dataLineStyle.miterLimit = 5.0f;
	republicanPlot.dataLineStyle.lineWidth = 2.5f;
	republicanPlot.dataLineStyle.lineColor = self.texasRed;
	republicanPlot.dataLineStyle.lineCap = kCGLineCapRound;
    republicanPlot.dataSource = self;
	
	// Add plot symbols
	//CPLTLineStyle *symbolLineStyle = [CPLTLineStyle lineStyle];
	symbolLineStyle.lineColor = self.texasRed;
	//CPLTPlotSymbol *plotSymbol = [CPLTPlotSymbol ellipsePlotSymbol];
	plotSymbol.fill = [CPLTFill fillWithColor:self.texasRed];
	plotSymbol.lineStyle = symbolLineStyle;
    plotSymbol.size = CGSizeMake(5.0, 5.0);
    republicanPlot.plotSymbol = plotSymbol;
	[graph addPlot:republicanPlot];
	[republicanPlot release];

	
    // Create a plot that uses the data source method
	CPLTScatterPlot *dataSourceLinePlot = [[CPLTScatterPlot alloc] init];
    dataSourceLinePlot.identifier = @"Legislator Plot";
	dataSourceLinePlot.dataLineStyle.miterLimit = 5.0f;
	dataSourceLinePlot.dataLineStyle.lineWidth = 3.0f;
    dataSourceLinePlot.dataLineStyle.lineColor = self.texasOrange;
    dataSourceLinePlot.dataSource = self;
	
	// Add plot symbols
	//CPLTLineStyle *symbolLineStyle = [CPLTLineStyle lineStyle];
	symbolLineStyle.lineColor = [CPLTColor blackColor];
	plotSymbol = [CPLTPlotSymbol starPlotSymbol];
	plotSymbol.fill = [CPLTFill fillWithColor:self.texasOrange];
	plotSymbol.lineStyle = symbolLineStyle;
    plotSymbol.size = CGSizeMake(14.0, 14.0);
    dataSourceLinePlot.plotSymbol = plotSymbol;
	[graph addPlot:dataSourceLinePlot];
	[dataSourceLinePlot release];

    // Add some data
	NSInteger chamber = [legislator.legtype integerValue];
	NSDictionary *democDict = [[PartisanIndexStats sharedPartisanIndexStats] historyForParty:DEMOCRAT Chamber:chamber];
	NSDictionary *repubDict = [[PartisanIndexStats sharedPartisanIndexStats] historyForParty:REPUBLICAN Chamber:chamber];
	NSUInteger i;
	for ( i = 0; i < countOfScores ; i++) {
		NSTimeInterval x = oneSession*i; 
		id y = [[sortedScores objectAtIndex:i] wnomAdj];
		id democY = [democDict objectForKey:[[sortedScores objectAtIndex:i] session]];
		id repubY = [repubDict objectForKey:[[sortedScores objectAtIndex:i] session]];
		
		[self.dataForPlot addObject:[NSDictionary dictionaryWithObjectsAndKeys:	
							[NSDecimalNumber numberWithFloat:x], [NSNumber numberWithInt:CPLTScatterPlotFieldX], 
							y, [NSNumber numberWithInt:CPLTScatterPlotFieldY], 
							repubY, @"RepubY", 
							democY, @"DemocY", nil]];
	}
	self.scatterPlotView.hostedLayer = graph;
	[graph release];

	//[sortedScores release];
}
#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPLTPlot *)plot 
{
	return [self.dataForPlot count];
}

-(NSNumber *)numberForPlot:(CPLTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index 
{
	NSDecimalNumber *num = nil;
	
	if ([(NSString *)plot.identifier isEqualToString:@"Democrat Plot"] && fieldEnum ==CPLTScatterPlotFieldY) {
		num = [[self.dataForPlot objectAtIndex:index] objectForKey:@"DemocY"];
		return num;
	}
	if ([(NSString *)plot.identifier isEqualToString:@"Republican Plot"] && fieldEnum ==CPLTScatterPlotFieldY) {
		num = [[self.dataForPlot objectAtIndex:index] objectForKey:@"RepubY"];
		return num;
	}
	
	num = [[self.dataForPlot objectAtIndex:index] objectForKey:[NSNumber numberWithInt:fieldEnum]];

    return num;
}

@end

