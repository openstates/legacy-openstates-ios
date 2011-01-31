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
#import "LegislatorContributionsViewController.h"

#import "LegislatorMasterViewController.h"
#import "LegislatorObj.h"
#import "DistrictOfficeObj.h"
#import "DistrictMapObj.h"
#import "CommitteeObj.h"
#import "CommitteePositionObj.h"
#import "WnomObj.h"
#import "TexLegeCoreDataUtils.h"
#import "UtilityMethods.h"
#import "TableDataSourceProtocol.h"
#import "TableCellDataObject.h"
#import "NotesViewController.h"
#import "TexLegeAppDelegate.h"

#import "CommitteeDetailViewController.h"
#import "DistrictOfficeMasterViewController.h"

#import "MapMiniDetailViewController.h"
#import "MiniBrowserController.h"
#import "CapitolMapsDetailViewController.h"

#import "PartisanIndexStats.h"
#import "UIImage+ResolutionIndependent.h"

#import "TexLegeEmailComposer.h"
#import "PartisanScaleView.h"
#import "LocalyticsSession.h"

@interface LegislatorDetailViewController (Private)

- (void) pushMapViewWithMap:(CapitolMap *)capMap;
- (void) setupHeader;

- (void)reloadChartForOrientationChange;	
- (NSString *)svgChartPath;
- (BOOL)svgChartPathExists;	
@end


@implementation LegislatorDetailViewController

@synthesize legislator, dataSource;
@synthesize headerView, miniBackgroundView;

@synthesize chartView, chartLoadingAct, isChartSVG;
@synthesize leg_indexTitleLab, leg_rankLab, leg_chamberPartyLab, leg_chamberLab, leg_reelection;
@synthesize leg_photoView, leg_partyLab, leg_districtLab, leg_tenureLab, leg_nameLab, freshmanPlotLab;
@synthesize indivSlider, partySlider, allSlider;
@synthesize notesPopover, masterPopover;

#pragma mark -
#pragma mark View lifecycle

- (NSString *)nibName {
	if ([UtilityMethods isIPadDevice])
		return @"LegislatorDetailViewController~ipad";
	else
		return @"LegislatorDetailViewController~iphone";
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	//UIImage *sealImage = [UIImage imageWithContentsOfResolutionIndependentFile:@"seal.png"];
	UIImage *sealImage = [UIImage imageNamed:@"seal.png"];
	UIColor *sealColor = [[UIColor colorWithPatternImage:sealImage] colorWithAlphaComponent:0.5f];	
	self.miniBackgroundView.backgroundColor = sealColor;
	//self.headerView.backgroundColor = sealColor;
	
	self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
	self.clearsSelectionOnViewWillAppear = NO;
		
	self.chartView.backgroundColor = [UIColor groupTableViewBackgroundColor];
	//self.chartView.backgroundColor = sealColor;
	
	UIScrollView* sv = nil;
	for(UIView* v in self.chartView.subviews){
		if([v isKindOfClass:[UIScrollView class] ]){
			sv = (UIScrollView*) v;
			sv.scrollEnabled = NO;
			sv.bounces = NO;
		}
	}		
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
	UINavigationController *nav = [self navigationController];
	if (nav && [nav.viewControllers count]>2)
		[nav popToRootViewControllerAnimated:YES];
	
	//self.leg_photoView.image = nil;
	
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
	self.indivSlider = nil;
	self.partySlider = nil;
	self.allSlider = nil;
	//self.legislator = nil;
	self.dataSource = nil;
	self.headerView = nil;
	self.leg_photoView = nil;
	self.leg_reelection = nil;
	//self.tableView = nil;
	self.miniBackgroundView = nil;
	self.leg_partyLab = self.leg_districtLab = self.leg_tenureLab = self.leg_nameLab = self.freshmanPlotLab = nil;
	self.chartView = nil;
	self.chartLoadingAct = nil;
	self.notesPopover = nil;
	self.masterPopover = nil;

	[super viewDidUnload];
}


- (void)dealloc {
	self.indivSlider = nil;
	self.partySlider = nil;
	self.allSlider = nil;
	self.dataSource = nil;
	self.legislator = nil;
	self.headerView = nil;
	self.leg_photoView = nil;
	self.leg_reelection = nil;
	//self.tableView = nil;
	self.chartView = nil;
	self.chartLoadingAct = nil;
	self.miniBackgroundView = nil;
	self.leg_partyLab = self.leg_districtLab = self.leg_tenureLab = self.leg_nameLab = self.freshmanPlotLab = nil;
	self.notesPopover = nil;
	self.masterPopover = nil;

	[super dealloc];
}

- (id)dataObject {
	return self.legislator;
}

- (void)setDataObject:(id)newObj {
	[self setLegislator:newObj];
}

#pragma mark -
#pragma mark SVG Charts

// 134123212.2009.iphone.port.svg
// 134123212.2009.iphone.land.svg
- (NSString *)svgChartPath {
	NSString *device = [UtilityMethods isIPadDevice] ? @"ipad" : @"iphone";
	NSString *orientation = [UtilityMethods isLandscapeOrientation] ? @"land" : @"port";
	NSString *svgFile = [[NSString alloc] initWithFormat:@"%@.2009.%@.%@.svg", self.legislator.legislatorID, device, orientation];
	NSString *svgPath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent: svgFile];
	[svgFile release];
	
	return svgPath;
}

- (void)reloadChartForOrientationChangeTo:(UIInterfaceOrientation)orientation {
	BOOL isLandscape = UIInterfaceOrientationIsLandscape(orientation);
	BOOL isIPad = [UtilityMethods isIPadDevice];
	NSString *chartWidth = nil;
	if (!isLandscape)
		chartWidth = (isIPad) ? @"685px" : @"305px";	// we actually ignore the width on iPhones
	else
		chartWidth = (isIPad) ? @"623px" : @"465px";
	
	BOOL hasScores = (self.legislator.wnomScores && [self.legislator.wnomScores count]);
	NSString *svgPath = [self svgChartPath];
	
	self.freshmanPlotLab.hidden = hasScores;
	//self.chartView.hidden = !hasScores;

	if (!hasScores)
		[self.chartLoadingAct stopAnimating];
	else if (![[NSFileManager defaultManager] fileExistsAtPath:svgPath]) {
		self.isChartSVG = NO;
		PartisanIndexStats *indexStats = [PartisanIndexStats sharedPartisanIndexStats];
		NSString *chartHTML = [indexStats partisanChartForLegislator:self.legislator 
															   width:chartWidth];
		if (chartHTML) {
			[self.chartView loadHTMLString:chartHTML baseURL:[UtilityMethods urlToMainBundle]];
		}
	}
	else {		// we have scores, and we have an SVG file
		self.isChartSVG = YES;
		NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:svgPath];
		
		NSURLRequest *req = [NSURLRequest requestWithURL:fileURL];
		[self.chartView loadRequest:req];
		[fileURL release];
	}
}

- (NSString *)chamberPartyAbbrev {
	NSString *partyName = nil;
	if ([self.legislator.party_id integerValue] == DEMOCRAT) // Democrat
		partyName = @"Dems";
	else if ([self.legislator.party_id integerValue] == REPUBLICAN) // Republican
		partyName = @"Repubs";
	else // don't know the party?
		partyName = @"Indeps";
	
	return [NSString stringWithFormat:@"%@ %@", [self.legislator chamberName], partyName];
}

- (NSString *) partisanRankStringForLegislator {
	//self.rank = @"3rd most partisan (out of 76 Repubs)";
	
	if (self.legislator.tenure.integerValue == 0)
		return @"";

	NSArray *legislators = [TexLegeCoreDataUtils allLegislatorsSortedByPartisanshipFromChamber:[self.legislator.legtype integerValue] 
																					andPartyID:[self.legislator.party_id integerValue] 
																					   context:self.legislator.managedObjectContext];
	if (legislators) {
		NSInteger rankIndex = [legislators indexOfObject:self.legislator] + 1;
		NSInteger count = [legislators count];
		NSString *partyShortName = [self.legislator.party_id integerValue] == DEMOCRAT ? @"Dems" : @"Repubs";
		
		NSString *ordinalRank = [UtilityMethods ordinalNumberFormat:rankIndex];
		return [NSString stringWithFormat:@"%@ most partisan (out of %d %@)", ordinalRank, count, partyShortName];	
	}
	else {
		return @"";
	}
}

- (void)setupHeader {	
	self.chartView.hidden = YES;
	
	NSString *legName = [NSString stringWithFormat:@"%@ %@",  [self.legislator legTypeShortName], [self.legislator legProperName]];
	self.leg_nameLab.text = legName;
	self.navigationItem.title = legName;

	//[[ImageCache sharedImageCache] loadImageView:self.leg_photoView fromPath:[UIImage highResImagePathWithPath:self.legislator.photo_name]];
	self.leg_photoView.image = [UIImage imageNamed:[UIImage highResImagePathWithPath:self.legislator.photo_name]];
	self.leg_partyLab.text = [self.legislator party_name];
	self.leg_districtLab.text = [NSString stringWithFormat:@"District %@", self.legislator.district];
	self.leg_tenureLab.text = [self.legislator tenureString];
	if (self.legislator.nextElection) {
		
		self.leg_reelection.text = [NSString stringWithFormat:@"Reelection: %@", self.legislator.nextElection];
	}
	
	PartisanIndexStats *indexStats = [PartisanIndexStats sharedPartisanIndexStats];

	[self reloadChartForOrientationChangeTo:[[UIApplication sharedApplication] statusBarOrientation]];

	if (self.leg_indexTitleLab)
		self.leg_indexTitleLab.text = [NSString stringWithFormat:@"%@ %@", 
									   [self.legislator legTypeShortName], [self.legislator lastname]];

	if (self.leg_rankLab)
		self.leg_rankLab.text = [self partisanRankStringForLegislator];
	
	if (self.leg_chamberPartyLab) {
		self.leg_chamberPartyLab.text = [self chamberPartyAbbrev];
		self.leg_chamberLab.text = [[self.legislator chamberName] stringByAppendingString:@" Avg."];				
	}
	
	CGFloat minSlider = [indexStats minPartisanIndexUsingChamber:[self.legislator.legtype integerValue]];
	CGFloat maxSlider = [indexStats maxPartisanIndexUsingChamber:[self.legislator.legtype integerValue]];
	
	if (self.indivSlider) {
		self.indivSlider.sliderMin = minSlider;
		self.indivSlider.sliderMax = maxSlider;
		self.indivSlider.sliderValue = self.legislator.partisan_index.floatValue;
	}	
	if (self.partySlider) {
		self.partySlider.sliderMin = minSlider;
		self.partySlider.sliderMax = maxSlider;
		self.partySlider.sliderValue = [indexStats partyPartisanIndexUsingChamber:[self.legislator.legtype integerValue] andPartyID:[self.legislator.party_id integerValue]];
	}	
	if (self.allSlider) {
		self.allSlider.sliderMin = minSlider;
		self.allSlider.sliderMax = maxSlider;
		self.allSlider.sliderValue = [indexStats overallPartisanIndexUsingChamber:[self.legislator.legtype integerValue]];
	}	
	
}


- (LegislatorDetailDataSource *)dataSource {
	if (!dataSource && self.legislator) {
		dataSource = [[LegislatorDetailDataSource alloc] initWithLegislator:legislator];
	}
	return dataSource;
}

- (void)setDataSource:(LegislatorDetailDataSource *)newObj {	
	if (newObj == dataSource)
		return;
	if (dataSource)
		[dataSource release], dataSource = nil;
	if (newObj)
		dataSource = [newObj retain];
}

- (void)setLegislator:(LegislatorObj *)newLegislator {
	if (self.dataSource && newLegislator && self.legislator && [[newLegislator objectID] isEqual:[self.legislator objectID]])
		return;
	
	self.dataSource = nil;
	if (legislator) [legislator release], legislator = nil;
	if (newLegislator) {
		legislator = [newLegislator retain];

		self.tableView.dataSource = self.dataSource;

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

- (IBAction)resetTableData:(id)sender {
	// this will force our datasource to renew everything
	self.dataSource.legislator = self.legislator;
	[self.tableView reloadData];	
}

// Called on the delegate when the user has taken action to dismiss the popover. This is not called when -dismissPopoverAnimated: is called directly.
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	[self.tableView reloadData];
	if (self.notesPopover && [self.notesPopover isEqual:popoverController]) {
		self.notesPopover = nil;
	}
}
	
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

	[[PartisanIndexStats sharedPartisanIndexStats] resetChartCacheIfNecessary];

	BOOL ipad = [UtilityMethods isIPadDevice];
	BOOL portrait = (![UtilityMethods isLandscapeOrientation]);
	
	if (portrait && ipad && !self.legislator)
		self.legislator = [[[TexLegeAppDelegate appDelegate] legislatorMasterVC] selectObjectOnAppear];		
	
	if (self.legislator)
		[self setupHeader];
}

#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc 
	 willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem 
	   forPopoverController: (UIPopoverController*)pc {
	//debug_NSLog(@"Entering portrait, showing the button: %@", [aViewController class]);
	barButtonItem.title = @"Legislators";
	[self.navigationItem setRightBarButtonItem:barButtonItem animated:YES];
	self.masterPopover = pc;
}

// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc 
	 willShowViewController:(UIViewController *)aViewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
	//debug_NSLog(@"Entering landscape, hiding the button: %@", [aViewController class]);
	[self.navigationItem setRightBarButtonItem:nil animated:YES];
	self.masterPopover = nil;
}

- (void) splitViewController:(UISplitViewController *)svc popoverController: (UIPopoverController *)pc
   willPresentViewController: (UIViewController *)aViewController
{
	if ([UtilityMethods isLandscapeOrientation]) {
		[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"ERR_POPOVER_IN_LANDSCAPE"];
	}
		 
	if (self.notesPopover) {
		[self.notesPopover dismissPopoverAnimated:YES];
		self.notesPopover = nil;
	}
}

#pragma mark -
#pragma mark orientations

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration 
//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self reloadChartForOrientationChangeTo:toInterfaceOrientation];
}

#pragma mark -
#pragma mark Web View Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
	BOOL hasScores = (self.legislator.wnomScores && [self.legislator.wnomScores count]);
	
	if (hasScores /*&& !self.isChartSVG*/) {
		[self.chartLoadingAct startAnimating];
	}
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
		
	if (!self.isChartSVG)
	{		
		NSString *javaScript = @"{ chart.getSVG(); }";
		NSString *svgPath = [self svgChartPath];
		NSString *data = [self.chartView stringByEvaluatingJavaScriptFromString:javaScript];
		NSError *error = nil;
		
		if (data)
			[data writeToFile:svgPath atomically:NO encoding:NSUTF8StringEncoding error:&error];
		if (error) {
			NSLog(@"Error writing svg to file, %@", svgPath);
		}
		if ([[NSFileManager defaultManager] fileExistsAtPath:svgPath]) {
			[self reloadChartForOrientationChangeTo:[[UIApplication sharedApplication] statusBarOrientation]];
		}
		else {	// There must have been some sort of problem, so just stop the activity indicator
			[self.chartLoadingAct stopAnimating];
		}

	}
	else {
		self.chartView.hidden = NO;
		[self.chartLoadingAct stopAnimating];
	}
	
#ifdef AUTOMATED_TESTING_CHARTS
	[[NSNotificationCenter defaultCenter] postNotificationName:@"AUTOMATED_TESTING_CHARTS" object:self.legislator];
#endif
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[self.chartLoadingAct stopAnimating];
}

#pragma mark -
#pragma mark Table View Delegate
// the user selected a row in the table.
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	
	// deselect the new row using animation
	[aTableView deselectRowAtIndexPath:newIndexPath animated:YES];	
	
	TableCellDataObject *cellInfo = [self.dataSource dataObjectForIndexPath:newIndexPath];

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
				nextViewController.backViewController = self;
				
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
		else if (cellInfo.entryType == DirectoryTypeContributions) {
			if ([TexLegeReachability canReachHostWithURL:[NSURL URLWithString:@"http://transparencydata.org"]]) { 
				LegislatorContributionsViewController *subDetailController = [[LegislatorContributionsViewController alloc] initWithStyle:UITableViewStyleGrouped];
				[subDetailController setQueryEntityID:cellInfo.entryValue type:[NSNumber numberWithInteger:kContributionQueryRecipient] cycle:@"-1"];
				[self.navigationController pushViewController:subDetailController animated:YES];
				[subDetailController release];
			}
		}
		else if (cellInfo.entryType == DirectoryTypeOfficeMap) {
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
				MapMiniDetailViewController *mapViewController = [[MapMiniDetailViewController alloc] init];
				[mapViewController view];
				
				DistrictOfficeObj *districtOffice = nil;
				if ([cellInfo.entryValue isKindOfClass:[DistrictOfficeObj class]])
					districtOffice = cellInfo.entryValue;
				
				[mapViewController resetMapViewWithAnimation:NO];
				BOOL isDistMap = NO;
				id<MKAnnotation> theAnnotation = nil;
				if (districtOffice) {
					theAnnotation = districtOffice;
					[mapViewController.mapView addAnnotation:theAnnotation];
					[mapViewController moveMapToAnnotation:theAnnotation];
				}
				else {
					theAnnotation = self.legislator.districtMap;
					[mapViewController.mapView addAnnotation:theAnnotation];
					[mapViewController moveMapToAnnotation:theAnnotation];
					[mapViewController.mapView performSelector:@selector(addOverlay:) 
													withObject:[self.legislator.districtMap polygon] afterDelay:0.5f];
					isDistMap = YES;
				}
				if (theAnnotation)
					mapViewController.navigationItem.title = [theAnnotation title];

				[self.navigationController pushViewController:mapViewController animated:YES];
				[mapViewController release];
				
				if (isDistMap)
					[[[TexLegeAppDelegate appDelegate] managedObjectContext] refreshObject:self.legislator.districtMap mergeChanges:NO];
			}
		}
		else if (cellInfo.entryType > kDirectoryTypeIsURLHandler &&
				 cellInfo.entryType < kDirectoryTypeIsExternalHandler) {	// handle the URL ourselves in a webView
			NSURL *myURL = [cellInfo generateURL];
			
			if ([TexLegeReachability canReachHostWithURL:myURL]) { // do we have a good URL/connection?

				if ([[myURL scheme] isEqualToString:@"twitter"])
					[[UIApplication sharedApplication] openURL:myURL];
				else {
					MiniBrowserController *mbc = [MiniBrowserController sharedBrowserWithURL:myURL];
					[mbc display:self.tabBarController];
				}
			}
		}
		else if (cellInfo.entryType > kDirectoryTypeIsExternalHandler)		// tell the device to open the url externally
		{
			NSURL *myURL = [cellInfo generateURL];
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
	
	TableCellDataObject *cellInfo = [self.dataSource dataObjectForIndexPath:indexPath];
	
	if (cellInfo == nil) {
		debug_NSLog(@"LegislatorDetailViewController:heightForRow: error finding table entry for section:%d row:%d", indexPath.section, indexPath.row);
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

@end

