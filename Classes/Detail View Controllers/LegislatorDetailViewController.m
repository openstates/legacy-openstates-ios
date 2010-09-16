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
#import "DirectoryDetailInfo.h"
#import "NotesViewController.h"
#import "TexLegeAppDelegate.h"

#import "CommitteeDetailViewController.h"
#import "DistrictOfficeMasterViewController.h"

#import "MapViewController.h"
#import "MiniBrowserController.h"
#import "CapitolMapsDetailViewController.h"

#import "PartisanIndexStats.h"
#import "UIImage+ResolutionIndependent.h"
#import "ImageCache.h"

#import "TexLegeEmailComposer.h"
#import "PartisanScaleView.h"

@interface LegislatorDetailViewController (Private)

- (void) pushMapViewWithMap:(CapitolMap *)capMap;
- (void) showWebViewWithURL:(NSURL *)url;
- (void) setupHeaderView;
- (void) setupHeader;

- (void)hideChartLoading;
- (void)showChartLoading;
	
@end


@implementation LegislatorDetailViewController

@synthesize legislator, dataSource;
@synthesize headerView, miniBackgroundView;

@synthesize chartView, chartLoadingLab, chartLoadingAct;
@synthesize leg_indexTitleLab, leg_rankLab, leg_chamberPartyLab, leg_chamberLab;
@synthesize leg_photoView, leg_partyLab, leg_districtLab, leg_tenureLab, leg_nameLab, freshmanPlotLab;
@synthesize indivSlider, partySlider, allSlider;
@synthesize notesPopover, masterPopover;
@synthesize mapViewController;

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
	[[self navigationController] popToRootViewControllerAnimated:YES];
	
	self.leg_photoView = nil;
	self.mapViewController = nil;
	
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
	self.indivSlider = nil;
	self.partySlider = nil;
	self.allSlider = nil;
	self.legislator = nil;
	self.dataSource = nil;
	self.headerView = nil;
	self.leg_photoView = nil;
	self.tableView = nil;
	self.miniBackgroundView = nil;
	self.leg_partyLab = self.leg_districtLab = self.leg_tenureLab = self.leg_nameLab = self.freshmanPlotLab = nil;
	self.chartView = nil;
	self.mapViewController = nil;
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
	self.tableView = nil;
	self.chartView = nil;
	self.miniBackgroundView = nil;
	self.leg_partyLab = self.leg_districtLab = self.leg_tenureLab = self.leg_nameLab = self.freshmanPlotLab = nil;
	self.mapViewController = nil;
	self.notesPopover = nil;
	self.masterPopover = nil;

	[super dealloc];
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
		return nil;
	}
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
	
	BOOL hasScores = (self.legislator.wnomScores && [self.legislator.wnomScores count]);
	if (!hasScores) {
		[self hideChartLoading];			
	}
	self.freshmanPlotLab.hidden = hasScores;

#define kChartPortraitWidth ([UtilityMethods isIPadDevice]) ? @"685px" : @"305px"
#define kChartLandscapeWidth ([UtilityMethods isIPadDevice]) ? @"623px" : @"465px"
#define kChartWidth ([UtilityMethods isLandscapeOrientation]) ? kChartLandscapeWidth : kChartPortraitWidth
	
	NSString *chartHTML = [[PartisanIndexStats sharedPartisanIndexStats] partisanChartForLegislator:self.legislator width:kChartWidth];
	if (chartHTML) {
		[self.chartView loadHTMLString:chartHTML baseURL:[UtilityMethods urlToMainBundle]];
	}
	
	PartisanIndexStats *indexStats = [PartisanIndexStats sharedPartisanIndexStats];
	if (self.leg_indexTitleLab)
		self.leg_indexTitleLab.text = [NSString stringWithFormat:@"%@ %@", 
									   [self.legislator legTypeShortName], [self.legislator lastname]];

	if (self.leg_rankLab)
		self.leg_rankLab.text = [self partisanRankStringForLegislator];
	
	if (self.leg_chamberPartyLab) {
		self.leg_chamberPartyLab.text = [self chamberPartyAbbrev];
		self.leg_chamberLab.text = [[self.legislator chamberName] stringByAppendingString:@" Avg."];				
	}
	
	CGFloat minSlider = [[indexStats minPartisanIndexUsingLegislator:self.legislator] floatValue];
	CGFloat maxSlider = [[indexStats maxPartisanIndexUsingLegislator:self.legislator] floatValue];
	
	if (self.indivSlider) {
		self.indivSlider.sliderMin = minSlider;
		self.indivSlider.sliderMax = maxSlider;
		self.indivSlider.sliderValue = self.legislator.partisan_index.floatValue;
	}	
	if (self.partySlider) {
		self.partySlider.sliderMin = minSlider;
		self.partySlider.sliderMax = maxSlider;
		self.partySlider.sliderValue = [[indexStats partyPartisanIndexUsingLegislator:self.legislator] floatValue];
	}	
	if (self.allSlider) {
		self.allSlider.sliderMin = minSlider;
		self.allSlider.sliderMax = maxSlider;
		self.allSlider.sliderValue = [[indexStats overallPartisanIndexUsingLegislator:self.legislator] floatValue];
	}	
	
}

- (void)setLegislator:(LegislatorObj *)newLegislator {
	if (legislator) [legislator release], legislator = nil;
	if (newLegislator) {
		legislator = [newLegislator retain];
		
		LegislatorDetailDataSource *ds = [[LegislatorDetailDataSource alloc] initWithLegislator:legislator];
		self.tableView.dataSource = self.dataSource = ds;
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

// Called on the delegate when the user has taken action to dismiss the popover. This is not called when -dismissPopoverAnimated: is called directly.
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	[self.tableView reloadData];
	if (self.notesPopover && [self.notesPopover isEqual:popoverController])
		self.notesPopover = nil;
}
	
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

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
	NSString *chartWidth = UIDeviceOrientationIsLandscape(toInterfaceOrientation) ? kChartLandscapeWidth : kChartPortraitWidth;
	NSString *chartHTML = [[PartisanIndexStats sharedPartisanIndexStats] partisanChartForLegislator:self.legislator width:chartWidth];
	if (chartHTML) {
		[self.chartView loadHTMLString:chartHTML baseURL:[UtilityMethods urlToMainBundle]];
	}
	
}

#pragma mark -
#pragma mark Web View Delegate

- (void)hideChartLoading {
	[self.chartLoadingAct stopAnimating];
	self.chartLoadingAct.hidden = YES;
	self.chartLoadingLab.hidden = YES;
}

- (void)showChartLoading {
	[self.chartLoadingAct startAnimating];
	self.chartLoadingAct.hidden = NO;
	self.chartLoadingLab.hidden = NO;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[self showChartLoading];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[self hideChartLoading];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[self hideChartLoading];
}

#pragma mark -
#pragma mark Table View Delegate
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
		else if (cellInfo.entryType == DirectoryTypeContributions) {
			LegislatorContributionsViewController *subDetailController = [[LegislatorContributionsViewController alloc] init];
			subDetailController.legislator = self.legislator;
			[self.navigationController pushViewController:subDetailController animated:YES];
			[subDetailController release];
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
				if (!self.mapViewController)
					self.mapViewController = [[[MapViewController alloc] init] autorelease];
				[self.mapViewController view];
				
				DistrictOfficeObj *districtOffice = nil;
				if ([cellInfo.entryValue isKindOfClass:[DistrictOfficeObj class]])
					districtOffice = cellInfo.entryValue;
				
				[self.mapViewController resetMapViewWithAnimation:NO];

				if (districtOffice) {
					[self.mapViewController.mapView addAnnotation:districtOffice];
					[self.mapViewController moveMapToAnnotation:districtOffice];
				}
				else {
					[self.mapViewController.mapView addAnnotation:self.legislator.districtMap];
					[self.mapViewController.mapView addOverlay:[self.legislator.districtMap polygon]];
					//[mapVC.mapView setRegion:self.legislator.districtMap.region animated:YES]; 
					[self.mapViewController moveMapToAnnotation:self.legislator.districtMap];

				}
				if ([self.navigationController.viewControllers containsObject:self.mapViewController])
					[self.navigationController popToViewController:self.mapViewController animated:YES];
				else
					[self.navigationController pushViewController:self.mapViewController animated:YES];
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
	
	DirectoryDetailInfo *cellInfo = [self.dataSource dataObjectForIndexPath:indexPath];
	
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

- (void) showWebViewWithURL:(NSURL *)url { 

	if ([UtilityMethods canReachHostWithURL:url]) { // do we have a good URL/connection?
		MiniBrowserController *mbc = [MiniBrowserController sharedBrowserWithURL:url];
		[mbc display:self.tabBarController];
	}

}	

@end

