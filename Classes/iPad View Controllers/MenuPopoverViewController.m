//
//  MenuPopoverViewController.m
//  TexLege
//
//  Created by Gregory Combs on 7/3/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "MenuPopoverViewController.h"
#import "TableDataSourceProtocol.h"
#import "TexLegeTheme.h"
#import "CommonPopoversController.h"
#import "TexLegeAppDelegate.h"
#import "UtilityMethods.h"
#import "TexLegeEmailComposer.h"

#define kMAILERKEY @"MAILERKEY"

@interface MenuPopoverViewController (Private)

- (void) showOrHideItemPopover:(UIViewController *) itemViewController fromRect:(CGRect)clickedRow;
@end

@implementation MenuPopoverViewController

@synthesize itemPopoverController, aboutViewController, appDelegate;

#pragma mark -
#pragma mark View lifecycle

#warning DEPRECATED

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.appDelegate = [TexLegeAppDelegate appDelegate];

	self.itemPopoverController = nil;
	
	self.aboutViewController = [[AboutViewController alloc] initWithNibName:@"TexLegeInfo~ipad" bundle:nil];
	self.aboutViewController.delegate = self;
	
	self.contentSizeForViewInPopover = CGSizeMake(300.0, 450.0);


	self.tableView.separatorColor = [TexLegeTheme separator];
	self.tableView.backgroundColor = [TexLegeTheme tableBackground];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	
	self.clearsSelectionOnViewWillAppear = NO;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
	self.itemPopoverController = nil;
}


- (void)dealloc {
	self.appDelegate = nil;
	self.aboutViewController = nil;
    [super dealloc];
	
	//self.itemPopoverController = nil;
}


#pragma mark -
#pragma mark Screen Orientation


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
	return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == 1)
		return 2;
	else
		return [self.appDelegate.functionalViewControllers count];	
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (![cell isSelected]) {
		BOOL useDark = (indexPath.row % 2 == 0);
		cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
	}
}

- (id)objectForRowAtIndexPath:(NSIndexPath *)indexPath {
	id object = nil;
	NSInteger row = indexPath.row;
	NSInteger section = indexPath.section;
	
	if (section == 1) {
		if (row == 0)
			object = self.aboutViewController;
		else 
			object = kMAILERKEY;
	}
	else
		object = [self.appDelegate.functionalViewControllers objectAtIndex:row];
	
	return object;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"MainMenuCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		cell.textLabel.font =		[TexLegeTheme boldFifteen];
		cell.textLabel.textColor = 	[TexLegeTheme textDark];
		//cell.textLabel.textColor =	[TexLegeTheme accent];
		
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.textLabel.lineBreakMode = UILineBreakModeTailTruncation;
		cell.textLabel.adjustsFontSizeToFitWidth = YES;
		cell.textLabel.minimumFontSize = 12.0f;
		//cell.accessoryView = [TexLegeTheme disclosureLabel:YES];
//		cell.textLabel.textColor =	[TexLegeTheme accent];
		
		//cell.accessoryView = [TexLegeTheme disclosureLabel:YES];
		//cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure.png"]] autorelease];
		
		
	}
	
    // Configure the cell...
	
	id object = [self objectForRowAtIndexPath:indexPath];
	
	if ([object respondsToSelector:@selector(title)])
		cell.textLabel.text = [object performSelector:@selector(title)];
	if ([object isKindOfClass:[NSString class]] && object == kMAILERKEY)
		cell.textLabel.text = @"Contact Me: TexLege Support";
	
	if ([object respondsToSelector:@selector(dataSource)]) {
		id<TableDataSource> selectedSource = [object performSelector:@selector(dataSource)];
		if ([selectedSource respondsToSelector:@selector(tabBarImage)])
			cell.imageView.image = [selectedSource performSelector:@selector(tabBarImage)];
	}
	
	if (indexPath.section == 1) {
		NSString *imagePath = nil;
		if (indexPath.row == 0)
			imagePath = @"28-star.png";
		else
			imagePath = @"110-bug.png";
		
		cell.imageView.image = [UIImage imageNamed:imagePath];
	}
	
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {	
	if (section == 0)
		return @"";
	else //(section == 1)
		return @"Application Info";	
}


- (void) showOrHideItemPopover:(UIViewController *) itemViewController fromRect:(CGRect)clickedRow {
	if (self.itemPopoverController) {
		itemViewController.modalInPopover = NO;
		[self modalViewControllerDidFinish:itemViewController];
	}
	else {
		itemViewController.modalInPopover = YES;

		self.itemPopoverController = [[UIPopoverController alloc] initWithContentViewController:itemViewController];
		self.itemPopoverController.popoverContentSize = itemViewController.view.frame.size;
		self.itemPopoverController.delegate = self;
		[self.itemPopoverController presentPopoverFromRect:clickedRow inView:self.view 
							  permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	}
	
}

- (void)modalViewControllerDidFinish:(UIViewController *)controller {
	if (self.itemPopoverController) {
        [self.itemPopoverController dismissPopoverAnimated:YES];
		self.itemPopoverController = nil;
	}
}
		
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	// the user (not us) has dismissed the popover, let's cleanup.
	self.itemPopoverController = nil;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//NSInteger row = indexPath.row;
	NSInteger section = indexPath.section;

	//[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//[appDelegate showOrHideMenuPopover:nil];

	id viewController = [self objectForRowAtIndexPath:indexPath];
	if (section == 1) {
		///CGRect clickedRow = [tableView rectForRowAtIndexPath:indexPath];

		//[self showOrHideItemPopover:viewController fromRect:clickedRow];
		if (indexPath.row == 0) {
			if (![[appDelegate topViewController] isEqual:viewController])
				[[[appDelegate topViewController] navigationController] pushViewController:viewController animated:YES];
			//[[CommonPopoversController sharedCommonPopoversController] resetPopoverMenus:self];
		}
		else {
			// This is the mailer.
			[[TexLegeEmailComposer sharedTexLegeEmailComposer] presentMailComposerTo:@"support@texlege.com" 
																			 subject:@"TexLege Support Question/Concern" 
																				body:@""];			
		}
		[tableView deselectRowAtIndexPath:indexPath animated:YES];

	}
	else {		
		//[appDelegate showOrHideMenuPopover:nil];
		
		NSInteger vcIndex = [appDelegate indexForFunctionalViewController:viewController];
		[appDelegate changeActiveFeaturedControllerTo:vcIndex];
		
//		if (![UtilityMethods isLandscapeOrientation])
//			[[CommonPopoversController sharedCommonPopoversController] performSelector:@selector(displayMasterListPopover:) withObject:self afterDelay:0];
				
	}
}

@end

