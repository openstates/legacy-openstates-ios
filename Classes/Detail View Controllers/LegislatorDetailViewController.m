//
//  LegislatorDetailViewController.m
//  TexLege
//
//  Created by Gregory Combs on 6/28/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "TableDataSourceProtocol.h"
#import "LegislatorDetailViewController.h"
#import "LegislatorObj.h"
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
#import "CommonPopoversController.h"
#import "TexLegeEmailComposer.h"

#import "ColoredBarButtonItem.h"
@interface LegislatorDetailViewController (Private)

- (void) pushMapViewWithMap:(CapitolMap *)capMap;
- (void) showWebViewWithURL:(NSURL *)url;
- (void) setupHeaderView;
- (void) setupHeader;
- (void) createSectionList;
- (void) plotHistory;
@end


@implementation LegislatorDetailViewController

@synthesize legislator, sectionArray;
@synthesize startupSplashView, headerView, miniBackgroundView;

@synthesize scatterPlotView, graph, dataForPlot;
@synthesize texasRed, texasBlue, texasOrange;

@synthesize leg_indexTitleLab, leg_rankLab, leg_chamberPartyLab, leg_chamberLab;
@synthesize leg_photoView, leg_partyLab, leg_districtLab, leg_tenureLab, leg_nameLab, freshmanPlotLab;
@synthesize indivSlider, partySlider, allSlider;
@synthesize indivPHolder, partyPHolder, allPHolder;
@synthesize notesPopover;

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
	//self.hidesBottomBarWhenPushed = YES;
	
	self.dataForPlot = [NSMutableArray array];
	
	self.texasRed = [CPLTColor colorWithComponentRed:198.0/255 green:0.0 blue:47.0/255 alpha:1.0f];
	//	self.texasBlue = [CPLTColor colorWithComponentRed:50.0/255 green:79.0/255 blue:133.0/255 alpha:1.0f];
	self.texasBlue = [CPLTColor colorWithComponentRed:90.0/255 green:141.0/255 blue:222.0/255 alpha:1.0f];
	self.texasOrange = [CPLTColor colorWithComponentRed:204.0/255 green:85.0/255 blue:0.0 alpha:1.0f];
	
	[self.tableView setTableHeaderView:self.headerView];
	
	if ([UtilityMethods isIPadDevice]) {
		self.indivSlider = [[StaticGradientSliderView alloc] initWithFrame:CGRectZero];
		self.partySlider = [[StaticGradientSliderView alloc] initWithFrame:CGRectZero];
		self.allSlider = [[StaticGradientSliderView alloc] initWithFrame:CGRectZero];
		
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

	[[ImageCache sharedImageCache] loadImageView:self.leg_photoView fromPath:[UIImage highResImagePathWithPath:self.legislator.photo_name]];
	//self.leg_photoView.image = [UIImage imageNamed:[UIImage highResImagePathWithPath:self.legislator.photo_name]];
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
		
		[self setupHeader];
		
		if ([UtilityMethods isIPadDevice]) {
			[[CommonPopoversController sharedCommonPopoversController] dismissMasterListPopover:self.navigationItem.rightBarButtonItem];
		}
		
		[self createSectionList];
		
		[self.tableView reloadData];
		[self.view setNeedsDisplay];
	}
}
#pragma mark -
#pragma mark Managing the popover


- (NSString *)popoverButtonTitle {
	return @"Legislators";	
}

// Called on the delegate when the user has taken action to dismiss the popover. This is not called when -dismissPopoverAnimated: is called directly.
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	[self.tableView reloadData];
	debug_NSLog(@"%@", self.tableView);
	self.notesPopover = nil;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	BOOL showSplash = ([UtilityMethods isLandscapeOrientation] == NO && [UtilityMethods isIPadDevice]);
	TexLegeAppDelegate *appDelegate = [TexLegeAppDelegate appDelegate];

	// we don't have a legislator selected and yet we're appearing in portrait view ... got to have something here !!! 
	if (!self.legislator && ![UtilityMethods isLandscapeOrientation])  {
		id masterVC = [appDelegate currentMasterViewController];
					   
		if ([masterVC respondsToSelector:@selector(selectObjectOnAppear)])
			self.legislator = [masterVC performSelector:@selector(selectObjectOnAppear)];

		if (!self.legislator) {
			NSString *vcKey = [appDelegate currentMasterViewControllerKey];
			NSManagedObjectID *objectID = [appDelegate savedTableSelectionForKey:vcKey];
			if (objectID)
				self.legislator = (LegislatorObj *)[[[masterVC valueForKey:@"dataSource"] managedObjectContext] objectWithID:objectID];
			
			//if (!self.legislator && [masterVC respondsToSelector:@selector(selectDefaultObject:)])
			//		[masterVC performSelector:@selector(selectDefaultObject:)];
		}
	}
	
	if (self.legislator) {
		showSplash = NO;
		[self setupHeader];
	}

	//[[CommonPopoversController sharedCommonPopoversController] resetPopoverMenus:self];

	if (showSplash) {
		// TODO: We could alternatively use this opportunity to open a proper informational introduction
		// for instance, drop in a new view taking the full screen that gives a full menu and helpful info
		
		if (self.startupSplashView == nil) {
			NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"StartupSplashView-Portrait" owner:self options:NULL];
			self.startupSplashView = [objects objectAtIndex:0];
		}
		[self.view addSubview:self.startupSplashView];
		
		//[[CommonPopoversController sharedCommonPopoversController] displayMainMenuPopover:self.navigationItem.leftBarButtonItem];
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
	
	//[self showMasterListPopoverButtonItem:barButtonItem];
	//[self showMainMenuPopoverButtonItem];
	
    //self.popoverController = pc;
}

// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc 
	 willShowViewController:(UIViewController *)aViewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
	
	//[self invalidateMasterListPopoverButtonItem:barButtonItem];
	//[self invalidateMainMenuPopoverButtonItem];

	//self.popoverController = nil;
}

- (void) splitViewController:(UISplitViewController *)svc popoverController: (UIPopoverController *)pc
   willPresentViewController: (UIViewController *)aViewController
{
/*    if (pc != nil) {
		[[TexLegeAppDelegate appDelegate] dismissMasterListPopover:self.navigationItem.rightBarButtonItem];
        //[pc dismissPopoverAnimated:YES];
		// do I need to set pc to nil?  I need to confirm, but I think it breaks things.
    }
*/
}

#pragma mark -
#pragma mark orientations

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	//[self showPopoverMenus:UIDeviceOrientationIsPortrait(toInterfaceOrientation)];
	//[[TexLegeAppDelegate appDelegate] resetPopoverMenus];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	//[self showPopoverMenus:UIDeviceOrientationIsPortrait(toInterfaceOrientation)];
	//[[TexLegeAppDelegate appDelegate] resetPopoverMenus];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
	[[self navigationController] popToRootViewControllerAnimated:YES];

	self.leg_photoView = nil;
	self.graph = nil;
	self.dataForPlot = nil;
	self.startupSplashView = nil;
	
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
	self.legislator = nil;
	self.startupSplashView = nil;	
	self.sectionArray = nil;
	self.leg_photoView = nil;
	self.dataForPlot = nil;
	self.graph = nil;
	self.notesPopover = nil;

}


- (void)dealloc {
	self.notesPopover = nil;
	self.sectionArray = nil;
	self.indivSlider = self.partySlider = self.allSlider = nil;
	self.indivPHolder = self.partyPHolder = self.allPHolder = nil;
	self.legislator = nil;
	self.leg_photoView = nil;
	self.leg_partyLab = self.leg_districtLab = self.leg_tenureLab = self.leg_nameLab = self.freshmanPlotLab = nil;
	self.headerView = self.startupSplashView = nil;
	self.scatterPlotView = nil;
	self.dataForPlot = nil;
	self.graph = nil;
	self.texasRed = self.texasBlue = self.texasOrange = nil;
	self.miniBackgroundView = nil;
    [super dealloc];
}



#pragma mark -
#pragma mark Table view data source

- (void) createSectionList {
	NSInteger numberOfSections = 3 + [self.legislator numberOfDistrictOffices];	
	NSString *tempString = nil;
	BOOL isPhone = [UtilityMethods canMakePhoneCalls];
	DirectoryDetailInfo *cellInfo = nil;
	
	// create an array of sections, with arrays of DirectoryDetailInfo entries as contents
	self.sectionArray = nil;	// this calls removeAllObjects and release automatically
	self.sectionArray = [NSMutableArray arrayWithCapacity:numberOfSections];

	NSInteger i;
	for (i=0; i < numberOfSections; i++) {
		NSMutableArray *entryArray = [[NSMutableArray alloc] initWithCapacity:30]; // just an arbitrary maximum
		[self.sectionArray addObject:entryArray];
		[entryArray release], entryArray = nil;
	}
	
	/*	Section 0: Personal Information */		
	NSInteger sectionIndex = 0;	
	
	cellInfo = [[DirectoryDetailInfo alloc] initWithName:@"Name" value:[self.legislator fullName] 
											isClickable:NO type:DirectoryTypeNone];
	[[self.sectionArray objectAtIndex:sectionIndex] addObject:cellInfo];
	[cellInfo release], cellInfo = nil;
	
	
	cellInfo = [[DirectoryDetailInfo alloc] initWithName:@"Website" value:self.legislator.website 
											 isClickable:YES type:DirectoryTypeWeb];
	[[self.sectionArray objectAtIndex:sectionIndex] addObject:cellInfo];
	[cellInfo release], cellInfo = nil;
	
	
	cellInfo = [[DirectoryDetailInfo alloc] initWithName:@"District Map" value:self.legislator.districtMap 
											 isClickable:YES type:DirectoryTypeWeb];
	[[self.sectionArray objectAtIndex:sectionIndex] addObject:cellInfo];
	[cellInfo release], cellInfo = nil;
	
	
	
	cellInfo = [[DirectoryDetailInfo alloc] initWithName:@"Bio" value:self.legislator.bio_url 
											 isClickable:YES type:DirectoryTypeWeb];
	[[self.sectionArray objectAtIndex:sectionIndex] addObject:cellInfo];
	[cellInfo release], cellInfo = nil;
	
	
	cellInfo = [[DirectoryDetailInfo alloc] initWithName:@"Email" value:self.legislator.email 
											 isClickable:YES type:DirectoryTypeMail];
	[[self.sectionArray objectAtIndex:sectionIndex] addObject:cellInfo];
	[cellInfo release], cellInfo = nil;
	
	
	if (self.legislator.twitter.length > 0) {
		tempString = ([self.legislator.twitter hasPrefix:@"@"]) ? self.legislator.twitter : [[NSString alloc] initWithFormat:@"@%@", self.legislator.twitter];
		cellInfo = [[DirectoryDetailInfo alloc] initWithName:@"Twitter" value: tempString
															   isClickable:YES type:DirectoryTypeTwitter];
		[[self.sectionArray objectAtIndex:sectionIndex] addObject:cellInfo];
		[cellInfo release], cellInfo = nil;
		[tempString release], tempString = nil;
	}
	
	
	if ([UtilityMethods isIPadDevice] == NO && self.legislator.partisan_index.floatValue != 0.0f) {
		cellInfo = [[DirectoryDetailInfo alloc] initWithName:@"Index" value:[self.legislator.partisan_index description] 
												 isClickable:NO type:DirectoryTypeIndex];
		[[self.sectionArray objectAtIndex:sectionIndex] addObject:cellInfo];
		[cellInfo release], cellInfo = nil;
	}
	
	if (self.legislator.notes.length > 0)
		tempString = self.legislator.notes;
	else
		tempString = kStaticNotes;
	
	cellInfo = [[DirectoryDetailInfo alloc] initWithName:@"Notes" value: tempString
											 isClickable:YES type:DirectoryTypeNotes];
	[[self.sectionArray objectAtIndex:sectionIndex] addObject:cellInfo];
	[cellInfo release], cellInfo = nil;
	
	
	/* after that section's done... DO COMMITTEES */
	sectionIndex++;
	for (CommitteePositionObj *position in [self.legislator sortedCommitteePositions]) {
		cellInfo = [[DirectoryDetailInfo alloc] initWithName:[position positionString] value:[position.committee committeeName] 
												 isClickable:YES type:DirectoryTypeCommittee];
		[[self.sectionArray objectAtIndex:sectionIndex] addObject:cellInfo];
		[cellInfo release], cellInfo = nil;
	}
	
	/* Now we handle all the office locations ... */
	sectionIndex++;
	/*	Section 1: Capitol Office */		
	
	if (legislator.staff.length > 0) {
		cellInfo = [[DirectoryDetailInfo alloc] initWithName:@"Staff" value:self.legislator.staff 
												 isClickable:NO type:DirectoryTypeNone];
		[[self.sectionArray objectAtIndex:sectionIndex] addObject:cellInfo];
		[cellInfo release], cellInfo = nil;		
	}
	if (self.legislator.cap_office.length > 0) {
		cellInfo = [[DirectoryDetailInfo alloc] initWithName:@"Office" value:self.legislator.cap_office 
												 isClickable:YES type:DirectoryTypeOfficeMap];
		[[self.sectionArray objectAtIndex:sectionIndex] addObject:cellInfo];
		[cellInfo release], cellInfo = nil;		
	} 
	if (legislator.chamber_desk.length > 0) {
		cellInfo = [[DirectoryDetailInfo alloc] initWithName:@"Desk #" value:self.legislator.chamber_desk 
												 isClickable:YES type:DirectoryTypeChamberMap];
		[[self.sectionArray objectAtIndex:sectionIndex] addObject:cellInfo];
		[cellInfo release], cellInfo = nil;		
	}
	if (legislator.cap_phone.length > 0) {
		cellInfo = [[DirectoryDetailInfo alloc] initWithName:@"Phone" value:self.legislator.cap_phone 
												 isClickable:isPhone type:DirectoryTypePhone];
		[[self.sectionArray objectAtIndex:sectionIndex] addObject:cellInfo];
		[cellInfo release], cellInfo = nil;		
	} 
	if (legislator.cap_fax.length > 0) {
		cellInfo = [[DirectoryDetailInfo alloc] initWithName:@"Fax" value:self.legislator.cap_fax 
												 isClickable:NO type:DirectoryTypeNone];
		[[self.sectionArray objectAtIndex:sectionIndex] addObject:cellInfo];
		[cellInfo release], cellInfo = nil;		
	}
	if (legislator.cap_phone2.length > 0) {
		tempString = (self.legislator.cap_phone2_name.length > 0) ? self.legislator.cap_phone2_name : @"Phone #2";
		cellInfo = [[DirectoryDetailInfo alloc] initWithName:tempString value:self.legislator.cap_phone2 
												 isClickable:isPhone type:DirectoryTypePhone];
		[[self.sectionArray objectAtIndex:sectionIndex] addObject:cellInfo];
		[cellInfo release], cellInfo = nil;		
	} 
	
	/* after that section's done... */
	
	if ([legislator numberOfDistrictOffices] >= 1) {
		sectionIndex++;
		/*	Section 2: District 1 */		
		
		if (legislator.dist1_phone.length > 0) {
			cellInfo = [[DirectoryDetailInfo alloc] initWithName:@"Phone" value:self.legislator.dist1_phone 
													 isClickable:isPhone type:DirectoryTypePhone];
			[[self.sectionArray objectAtIndex:sectionIndex] addObject:cellInfo];
			[cellInfo release], cellInfo = nil;		
		} 
		if (legislator.dist1_fax.length > 0) {
			cellInfo = [[DirectoryDetailInfo alloc] initWithName:@"Fax" value:self.legislator.dist1_fax 
													 isClickable:NO type:DirectoryTypeNone];
			[[self.sectionArray objectAtIndex:sectionIndex] addObject:cellInfo];
			[cellInfo release], cellInfo = nil;
		}
		if (legislator.dist1_street.length > 0) {
			tempString = [[NSString alloc] initWithFormat:@"%@\n%@, TX\n%@", 
						  [self.legislator.dist1_street stringByReplacingOccurrencesOfString:@", " withString:@"\n"], 
						  self.legislator.dist1_city, self.legislator.dist1_zip];
			
			cellInfo = [[DirectoryDetailInfo alloc] initWithName:@"Address" value:tempString 
													 isClickable:YES type:DirectoryTypeMap];
			[[self.sectionArray objectAtIndex:sectionIndex] addObject:cellInfo];
			[cellInfo release], cellInfo = nil;
			[tempString release], tempString = nil;
		} 
	}
	
	/* after that section's done... */
	
	if ([legislator numberOfDistrictOffices] >= 2) {
		sectionIndex++;
		/*	Section 3: District 2 */		
		
		if (legislator.dist2_phone.length > 0) {
			cellInfo = [[DirectoryDetailInfo alloc] initWithName:@"Phone" value:self.legislator.dist2_phone 
													 isClickable:isPhone type:DirectoryTypePhone];
			[[self.sectionArray objectAtIndex:sectionIndex] addObject:cellInfo];
			[cellInfo release], cellInfo = nil;
		} 
		if (legislator.dist2_fax.length > 0) {
			cellInfo = [[DirectoryDetailInfo alloc] initWithName:@"Fax" value:self.legislator.dist2_fax 
													 isClickable:NO type:DirectoryTypeNone];
			[[self.sectionArray objectAtIndex:sectionIndex] addObject:cellInfo];
			[cellInfo release], cellInfo = nil;
		}
		if (legislator.dist2_street.length > 0) {
			tempString = [[NSString alloc] initWithFormat:@"%@\n%@, TX\n%@", 
						  [self.legislator.dist2_street stringByReplacingOccurrencesOfString:@", " withString:@"\n"], 
						  self.legislator.dist2_city, self.legislator.dist2_zip];
			
			cellInfo = [[DirectoryDetailInfo alloc] initWithName:@"Address" value:tempString 
													 isClickable:YES type:DirectoryTypeMap];
			[[self.sectionArray objectAtIndex:sectionIndex] addObject:cellInfo];
			[cellInfo release], cellInfo = nil;
			[tempString release], tempString = nil;
		} 
	}
	
	/* after that section's done... */
	
	if ([legislator numberOfDistrictOffices] >= 3) {
		sectionIndex++;
		/*	Section 4: District 3 */		
		
		if (legislator.dist3_phone1.length > 0) {
			cellInfo = [[DirectoryDetailInfo alloc] initWithName:@"Phone" value:self.legislator.dist3_phone1 
													 isClickable:isPhone type:DirectoryTypePhone];
			[[self.sectionArray objectAtIndex:sectionIndex] addObject:cellInfo];
			[cellInfo release], cellInfo = nil;			
		} 
		if (legislator.dist3_fax.length > 0) {
			cellInfo = [[DirectoryDetailInfo alloc] initWithName:@"Fax" value:self.legislator.dist3_fax 
													 isClickable:NO type:DirectoryTypeNone];
			[[self.sectionArray objectAtIndex:sectionIndex] addObject:cellInfo];
			[cellInfo release], cellInfo = nil;
		}
		if (legislator.dist3_street.length > 0) {
			tempString = [[NSString alloc] initWithFormat:@"%@\n%@, TX\n%@", 
						  [self.legislator.dist3_street stringByReplacingOccurrencesOfString:@", " withString:@"\n"], 
						  self.legislator.dist3_city, self.legislator.dist3_zip];
			
			cellInfo = [[DirectoryDetailInfo alloc] initWithName:@"Address" value:tempString 
													 isClickable:YES type:DirectoryTypeMap];
			[[self.sectionArray objectAtIndex:sectionIndex] addObject:cellInfo];
			[cellInfo release], cellInfo = nil;
			[tempString release], tempString = nil;
		} 
	}
	
	/* after that section's done... */
	
	if ([legislator numberOfDistrictOffices] >= 4) {
		sectionIndex++;
		/*	Section 5: District 4 */		
		
		if (legislator.dist4_phone1.length > 0) {
			cellInfo = [[DirectoryDetailInfo alloc] initWithName:@"Phone" value:self.legislator.dist4_phone1 
													 isClickable:isPhone type:DirectoryTypePhone];
			[[self.sectionArray objectAtIndex:sectionIndex] addObject:cellInfo];
			[cellInfo release], cellInfo = nil;						
		} 
		if (legislator.dist4_fax.length > 0) {
			cellInfo = [[DirectoryDetailInfo alloc] initWithName:@"Fax" value:self.legislator.dist4_fax 
													 isClickable:NO type:DirectoryTypeNone];
			[[self.sectionArray objectAtIndex:sectionIndex] addObject:cellInfo];
			[cellInfo release], cellInfo = nil;
		}
		if (legislator.dist4_street.length > 0) {
			tempString = [[NSString alloc] initWithFormat:@"%@\n%@, TX\n%@", 
						  [self.legislator.dist4_street stringByReplacingOccurrencesOfString:@", " withString:@"\n"], 
						  self.legislator.dist4_city, self.legislator.dist4_zip];
			
			cellInfo = [[DirectoryDetailInfo alloc] initWithName:@"Address" value:tempString 
													 isClickable:YES type:DirectoryTypeMap];
			[[self.sectionArray objectAtIndex:sectionIndex] addObject:cellInfo];
			[cellInfo release], cellInfo = nil;
			[tempString release], tempString = nil;
		} 
	}
}	

#pragma mark -
#pragma mark Custom Slider

/* This determines the appropriate size for the custom slider view, given its superview */
- (CGRect) preshrinkSliderViewFromView:(UIView *)aView {
	CGFloat sliderHeight = 24.0f;
	CGFloat sliderInset = 18.0f;
	
	CGRect rect = aView.bounds;
	CGFloat sliderWidth = aView.bounds.size.width - (sliderInset * 2);
	
	rect.origin.y = aView.center.y - (sliderHeight / 2);
	rect.size.height = sliderHeight;
	rect.origin.x = sliderInset; //aView.center.x - (sliderWidth / 2);
	rect.size.width = sliderWidth;
	
	return rect;
}

#pragma mark -
#pragma mark UITableViewDataSource methods


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{		
	//DirectoryDetailInfo * cellInfo = [[DirectoryDetailInfo alloc] init];
	//[self infoForRow:cellInfo atIndexPath:indexPath];
	
	NSInteger row = [indexPath row];
	NSInteger section = [indexPath section];
	
	DirectoryDetailInfo *cellInfo = nil;
	NSMutableArray *entryArray = [self.sectionArray objectAtIndex:section];
	if (entryArray)
		cellInfo = [entryArray objectAtIndex:row];
	
	if (cellInfo == nil) {
		debug_NSLog(@"LegislatorDetailViewController:cellForRow: error finding table entry for section:%d row:%d", section, row);
		 return nil;
	}
		 
	BOOL clickable = cellInfo.isClickable;
	//NSString *CellIdentifier = [NSString stringWithFormat:@"Section: %d Row: %d",indexPath.section,indexPath.row];
	NSString *CellIdentifier = [NSString stringWithFormat:@"Type: %d",cellInfo.entryType];
	//NSString *CellIdentifier = @"DirectoryDetailCell";
	
	/* Look up cell in the table queue */
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	UITableViewCellStyle currentStyle = UITableViewCellStyleValue2;
	UITableViewCellSelectionStyle selectionStyle = clickable ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
	
	/* Not found in queue, create a new cell object */
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:currentStyle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	cell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	
	cell.selectionStyle = selectionStyle;
	if (clickable)
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	
	
	switch(cellInfo.entryType) {
		case DirectoryTypeNotes:		// Since our notes data can change, we must tend to the cached info ...
			if (self.legislator.notes.length > 0)
				cell.detailTextLabel.textColor = [UIColor blackColor];
			else
				cell.detailTextLabel.textColor = [UIColor grayColor];
			cell.detailTextLabel.text = cellInfo.entryValue;
			cell.textLabel.text = cellInfo.entryName;
			break;
			
		case DirectoryTypeIndex:		// partisan index custom slider
			if (![UtilityMethods isIPadDevice]) {
				cell.textLabel.opaque = NO;
				cell.textLabel.numberOfLines = 2;
				cell.textLabel.highlightedTextColor = [UIColor blackColor];
				//cell.textLabel.text = cellInfo.entryName;
				
				CGRect sliderViewFrame = [self preshrinkSliderViewFromView:cell.contentView];
				if (self.indivSlider == nil) {
					self.indivSlider = [[StaticGradientSliderView alloc] initWithFrame:CGRectZero];
				}
				if (self.indivSlider) {
					[self.indivSlider setFrame:sliderViewFrame];
					[self.indivSlider setLegislator:self.legislator];
					[self.indivSlider setSliderValue:cellInfo.entryValue.floatValue animated:NO];
					[cell.contentView addSubview:self.indivSlider];
				}
				cell.userInteractionEnabled = NO;
			}
			break;
			
		case DirectoryTypeMap:
			cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
			cell.detailTextLabel.numberOfLines = 4;
			cell.detailTextLabel.text = cellInfo.entryValue;
			cell.textLabel.text = cellInfo.entryName;
			break;
			
		case DirectoryTypeWeb:
			if (cellInfo.entryValue.length > 0) {
				if ([cellInfo.entryName isEqualToString:@"Website"])
					cell.detailTextLabel.text = @"Official Website";
				else if ([cellInfo.entryName isEqualToString:@"Bio"])
					cell.detailTextLabel.text = @"VoteSmart Bio";
				else if ([cellInfo.entryName isEqualToString:@"District Map"])
					cell.detailTextLabel.text = @"District Map";
				cell.textLabel.text = @"Web";
			}
			break;
			
		case DirectoryTypeCommittee:
		case DirectoryTypeOfficeMap:
		case DirectoryTypeChamberMap:
		case DirectoryTypeTwitter:
		case DirectoryTypeMail:
		case DirectoryTypePhone:
		case DirectoryTypeSMS:
		case DirectoryTypeNone:
			cell.detailTextLabel.text = cellInfo.entryValue;
			cell.textLabel.text = cellInfo.entryName;
			break;
			
		default:
			cell.autoresizingMask = UIViewAutoresizingFlexibleHeight;
			cell.hidden = YES;
			cell.frame  = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, 0.01f, 0.01f);
			cell.tag = 999; //EMPTY
			[cell sizeToFit];
			break;
	}
	
	[cell sizeToFit];
	[cell setNeedsDisplay];
	
	return cell;
	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
	return [sectionArray count];
	
}


- (NSInteger)tableView:(UITableView *)aTableView  numberOfRowsInSection:(NSInteger)section {		
	return [[sectionArray objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {	
	if (section == 0)
		return @"Legislator Information";
	else if (section == 1)
		return @"Committee Assignments";
	else if (section == 2)
		return @"Capitol Office";
	else if (section == 3)
		return @"District Office #1";
	else if (section == 4)
		return @"District Office #2";
	else if (section == 5)
		return @"District Office #3";
	else //if (section == 6)
		return @"District Office #4";
}

// the user selected a row in the table.
- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	int row = [newIndexPath row];
	int section = [newIndexPath section];
	
	// deselect the new row using animation
	[aTableView deselectRowAtIndexPath:newIndexPath animated:YES];	
	
	DirectoryDetailInfo *cellInfo = nil;
	NSMutableArray *entryArray = [self.sectionArray objectAtIndex:section];
	if (entryArray)
		cellInfo = [entryArray objectAtIndex:row];
	
	if (cellInfo == nil) {
		debug_NSLog(@"LegislatorDetailViewController:didSelectRow: error finding table entry for section:%d row:%d", section, row);
		return;
	}
	
	if (cellInfo.isClickable) {
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
					self.notesPopover = [[UIPopoverController alloc] initWithContentViewController:nextViewController];
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
			subDetailController.committee = [[[self.legislator sortedCommitteePositions] objectAtIndex:row] committee];
			// push the detail view controller onto the navigation stack to display it
			[self.navigationController pushViewController:subDetailController animated:YES];
			[subDetailController release];
		}
		else if (cellInfo.entryType == DirectoryTypeOfficeMap) {
			CapitolMap *capMap = [UtilityMethods capitolMapFromOfficeString:cellInfo.entryValue];			
			[self pushMapViewWithMap:capMap];
		}
		else if (cellInfo.entryType == DirectoryTypeChamberMap) {
			CapitolMap *capMap = [UtilityMethods capitolMapFromChamber:self.legislator.legtype.integerValue];			
			[self pushMapViewWithMap:capMap];
		}
		else if (cellInfo.entryType == DirectoryTypeMail) {
			[[TexLegeEmailComposer sharedTexLegeEmailComposer] presentMailComposerTo:cellInfo.entryValue 
																			 subject:@"" body:@""];			
		}
		// Switch to the appropriate application for this url...
		else if (cellInfo.entryType == DirectoryTypeMap) {
			MapViewController *mapVC = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
			if (!mapVC) {
				debug_NSLog(@"Tried to map services, but couldn't allocate memory for the view.");
				return;
			}
			NSString *address = [cellInfo.entryValue stringByReplacingOccurrencesOfString:@"\n" withString:@", "];
			[mapVC setAddressString:address withLegislator:self.legislator];
			[self.navigationController pushViewController:mapVC animated:YES];
			[mapVC release];
			
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
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	CGFloat height = 44.0f;
	NSInteger row = [indexPath row];
	NSInteger section = [indexPath section];
	
	DirectoryDetailInfo *cellInfo = nil;
	NSMutableArray *entryArray = [self.sectionArray objectAtIndex:section];
	if (entryArray)
		cellInfo = [entryArray objectAtIndex:row];
	
	if (cellInfo == nil) {
		debug_NSLog(@"LegislatorDetailViewController:heightForRow: error finding table entry for section:%d row:%d", section, row);
		return height;
	}
	
	if (cellInfo.entryValue.length <= 0) {
		height = 0.0f;
	}
	else if ([cellInfo.entryName rangeOfString:@"Address"].length > 0) { // We found "Address" in the string.
		height = 98.0f;
	}
	return height;
}

- (void) pushMapViewWithMap:(CapitolMap *)capMap {
	CapitolMapsDetailViewController *detailController = [[CapitolMapsDetailViewController alloc] initWithNibName:@"CapitolMapsDetailViewController" bundle:nil];
	detailController.map = capMap;
	//detailController.navigationItem.title = @"Maps";
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

	if (!countOfScores) {
		graph.hidden = YES;
		self.freshmanPlotLab.hidden = NO;
		return;
	}
	
	if (self.dataForPlot && [self.dataForPlot count])
		[self.dataForPlot removeAllObjects];
	
	NSMutableArray *sortedScores = [[NSMutableArray alloc] initWithArray:[self.legislator.wnomScores allObjects]];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"session" ascending:YES];
	[sortedScores sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	
	NSInteger year = 1847 + ([[[sortedScores objectAtIndex:0] session] integerValue] * 2);
	NSString *refStr = [NSString stringWithFormat:@"%d-02-02", year];
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setDateFormat:@"yyyy-MM-dd"];
	NSDate *refDate = [inputFormatter dateFromString:refStr];
	[inputFormatter release];
	
    NSTimeInterval oneSession = 24 * 60 * 60 * 365 * 2;
		
    // Create graph from theme
	if (self.graph)
		self.graph = nil;
    self.graph = [(CPLTXYGraph *)[CPLTXYGraph alloc] initWithFrame:CGRectZero];
	CPLTTheme *theme = [CPLTTheme themeNamed:kCPStocksTheme];
	[self.graph applyTheme:theme];
	scatterPlotView.hostedLayer = self.graph;
    
    // Setup scatter plot space
    CPLTXYPlotSpace *plotSpace = (CPLTXYPlotSpace *)self.graph.defaultPlotSpace;
	plotSpace.allowsUserInteraction = YES;

    NSTimeInterval xLow = 0.0f;
    plotSpace.xRange = [CPLTPlotRange plotRangeWithLocation:CPLTDecimalFromFloat(xLow-(oneSession/2)) length:CPLTDecimalFromInteger(oneSession*countOfScores)];
    plotSpace.yRange = [CPLTPlotRange plotRangeWithLocation:CPLTDecimalFromFloat(-1.25) length:CPLTDecimalFromFloat(2.5)];
    
    // Axes
	CPLTXYAxisSet *axisSet = (CPLTXYAxisSet *)self.graph.axisSet;
    CPLTXYAxis *x = axisSet.xAxis;
    x.majorIntervalLength = CPLTDecimalFromFloat(oneSession);
    x.orthogonalCoordinateDecimal = CPLTDecimalFromString(@"0.0");
    x.minorTicksPerInterval = 0;
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
	[dateFormatter setDateFormat:@"‘YY"];

    CPLTTimeFormatter *timeFormatter = [[[CPLTTimeFormatter alloc] initWithDateFormatter:dateFormatter] autorelease];
    timeFormatter.referenceDate = refDate;
    x.labelFormatter = timeFormatter;
	NSArray *exclusionRanges = [NSArray arrayWithObjects:
								[CPLTPlotRange plotRangeWithLocation:CPLTDecimalFromFloat(-10 * oneSession) length:CPLTDecimalFromFloat(9*oneSession)],
								[CPLTPlotRange plotRangeWithLocation:CPLTDecimalFromFloat(oneSession*countOfScores) length:CPLTDecimalFromFloat(9*oneSession)],
								nil];
	x.labelExclusionRanges = exclusionRanges;
	
    CPLTXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength = CPLTDecimalFromString(@"0.5");
    y.minorTicksPerInterval = 1;

    y.orthogonalCoordinateDecimal = CPLTDecimalFromFloat(oneSession/2);
	exclusionRanges = [NSArray arrayWithObjects:
					   [CPLTPlotRange plotRangeWithLocation:CPLTDecimalFromFloat(-10.0) length:CPLTDecimalFromFloat(8.5f)], 
					   [CPLTPlotRange plotRangeWithLocation:CPLTDecimalFromFloat(0.0) length:CPLTDecimalFromFloat(0.02)], 
					   [CPLTPlotRange plotRangeWithLocation:CPLTDecimalFromFloat(1.5) length:CPLTDecimalFromFloat(8.5f)], 
					   nil];
	y.labelExclusionRanges = exclusionRanges;
	
	// Create a blue plot area
	CPLTScatterPlot *democratPlot = [[[CPLTScatterPlot alloc] init] autorelease];
    democratPlot.identifier = @"Democrat Plot";
	democratPlot.dataLineStyle.miterLimit = 5.0f;
	democratPlot.dataLineStyle.lineWidth = 2.5f;
	democratPlot.dataLineStyle.lineColor = self.texasBlue;
	democratPlot.dataLineStyle.lineCap = kCGLineCapRound;
    democratPlot.dataSource = self;
	[self.graph addPlot:democratPlot];

	// Add plot symbols
	CPLTLineStyle *symbolLineStyle = [CPLTLineStyle lineStyle];
	symbolLineStyle.lineColor = self.texasBlue;
	CPLTPlotSymbol *plotSymbol = [CPLTPlotSymbol ellipsePlotSymbol];
	plotSymbol.fill = [CPLTFill fillWithColor:self.texasBlue];
	plotSymbol.lineStyle = symbolLineStyle;
    plotSymbol.size = CGSizeMake(5.0, 5.0);
    democratPlot.plotSymbol = plotSymbol;
	
	// Create a blue plot area
	CPLTScatterPlot *republicanPlot = [[[CPLTScatterPlot alloc] init] autorelease];
    republicanPlot.identifier = @"Republican Plot";
	republicanPlot.dataLineStyle.miterLimit = 5.0f;
	republicanPlot.dataLineStyle.lineWidth = 2.5f;
	republicanPlot.dataLineStyle.lineColor = self.texasRed;
	republicanPlot.dataLineStyle.lineCap = kCGLineCapRound;
    republicanPlot.dataSource = self;
	[self.graph addPlot:republicanPlot];
	
	// Add plot symbols
	//CPLTLineStyle *symbolLineStyle = [CPLTLineStyle lineStyle];
	symbolLineStyle.lineColor = self.texasRed;
	//CPLTPlotSymbol *plotSymbol = [CPLTPlotSymbol ellipsePlotSymbol];
	plotSymbol.fill = [CPLTFill fillWithColor:self.texasRed];
	plotSymbol.lineStyle = symbolLineStyle;
    plotSymbol.size = CGSizeMake(5.0, 5.0);
    republicanPlot.plotSymbol = plotSymbol;
	
	
    // Create a plot that uses the data source method
	CPLTScatterPlot *dataSourceLinePlot = [[[CPLTScatterPlot alloc] init] autorelease];
    dataSourceLinePlot.identifier = @"Legislator Plot";
	dataSourceLinePlot.dataLineStyle.miterLimit = 5.0f;
	dataSourceLinePlot.dataLineStyle.lineWidth = 3.0f;
    dataSourceLinePlot.dataLineStyle.lineColor = self.texasOrange;
    dataSourceLinePlot.dataSource = self;
	[self.graph addPlot:dataSourceLinePlot];
	
	// Add plot symbols
	//CPLTLineStyle *symbolLineStyle = [CPLTLineStyle lineStyle];
	symbolLineStyle.lineColor = [CPLTColor blackColor];
	plotSymbol = [CPLTPlotSymbol starPlotSymbol];
	plotSymbol.fill = [CPLTFill fillWithColor:self.texasOrange];
	plotSymbol.lineStyle = symbolLineStyle;
    plotSymbol.size = CGSizeMake(14.0, 14.0);
    dataSourceLinePlot.plotSymbol = plotSymbol;
		
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
	[sortedScores release];
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

-(CPLTFill *) barFillForBarPlot:(CPLTBarPlot *)barPlot recordIndex:(NSNumber *)index; 
{
	return nil;
}


@end

