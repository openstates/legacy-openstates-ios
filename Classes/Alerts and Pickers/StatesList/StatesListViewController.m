//
//  StatesListViewController.m
//  Created by Gregory Combs on 7/22/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "StatesListViewController.h"
#import "StatesListMetaLoader.h"
#import "StateMetaLoader.h"

#import "UtilityMethods.h"
#import "TexLegeTheme.h"
#import "LoadingCell.h"
#import "TexLegeStandardGroupCell.h"

#import "CellController.h"
#import "MultiSelectCellController.h"

#define kFavoriteStatesKey           @"favorite_states"


@implementation StatesListViewController
@synthesize tableCells;
@synthesize statesNavItem;
@synthesize favorites;

#pragma mark -
#pragma mark Initialization


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSArray *storedFavorites = [[NSUserDefaults standardUserDefaults] objectForKey:kFavoriteStatesKey];
        
        if (storedFavorites) 
            favorites = [[NSMutableSet alloc] initWithArray:storedFavorites];
        else
            favorites = [[NSMutableSet alloc] init];
        
        
        StatesListMetaLoader *statesMeta = [StatesListMetaLoader sharedStatesListMeta];
        
        [statesMeta downloadStatesList];

        self.modalPresentationStyle = UIModalPresentationFormSheet;
        
    }
    return self;
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.statesNavItem = nil;
    self.favorites = nil;
    self.tableCells = nil;
    
    [super dealloc];
}


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(reloadData:) name:kStatesListLoadedKey object:nil];	

    self.tableView.rowHeight = 55.f;
    self.tableView.backgroundColor = [TexLegeTheme tableBackground];
    
    
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 
                                                                                CGRectGetWidth(self.view.frame), 
                                                                                44.f)];
    navBar.tintColor = [TexLegeTheme accent];
    navBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:NSLocalizedStringFromTable(@"Select a State", @"StandardUI", @"State legislature control label")];
    [navBar setItems:[NSArray arrayWithObject:item]];
    self.statesNavItem = item;
    [item release];
    
    [self.view addSubview:navBar];
    [navBar release];

    CGRect tFrame = self.tableView.frame;
    tFrame.origin.y  = 44.f;
    tFrame.size.height -= 44.f;
    self.tableView.frame = tFrame;
    
    [self.tableView setAllowsSelectionDuringEditing:YES];
	//[self finishEditing:self];    // we're not editing right now
    
}


- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.statesNavItem = nil;
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}


#pragma mark -
#pragma mark Favorites Data

- (void)saveFavorites {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (NO == IsEmpty(favorites))
        [defaults setObject:[favorites allObjects] forKey:kFavoriteStatesKey];
    else
        [defaults removeObjectForKey:kFavoriteStatesKey];
    
    [defaults synchronize];
}


#pragma mark MultiSelect

- (void)reloadData:(NSNotification *)notification {
    [self constructTableGroups];
    
    [self.tableView reloadData];
}

//
// indexPathForCellController:
//
// Returns the indexPath for the specified CellController object
//
- (NSIndexPath *)indexPathForCellController:(id)cellController
{
    NSInteger rowIndex;
    for (rowIndex = 0; rowIndex < [self.tableCells count]; rowIndex++)
    {
        NSArray *row = [self.tableCells objectAtIndex:rowIndex];
        if ([row isEqual:cellController])
        {
            return [NSIndexPath indexPathForRow:rowIndex inSection:0];
        }
    }
	
	return nil;
}

//
// constructTableGroups
//
// Creates cell data.
//
- (void)constructTableGroups
{	
    
    StatesListMetaLoader *statesMeta = [StatesListMetaLoader sharedStatesListMeta];
    
	self.tableCells = [NSMutableArray array];
    
	NSInteger i;
	for (i = 0; i < [statesMeta.states count]; i++)
	{
        NSDictionary *dataObject = [statesMeta.states objectAtIndex:i];
        
        NSCAssert(dataObject != NULL, @"Received bad data dictionary in StatesListViewController");
        
        NSString *labelText = [dataObject valueForKey:@"name"];
        
        MultiSelectCellController *cellCtl = [[MultiSelectCellController alloc] initWithLabel:labelText];
        
        cellCtl.dataObject = dataObject;
        
        if ([favorites containsObject:labelText])
            cellCtl.selected = YES;
        
		[self.tableCells addObject:cellCtl];
        [cellCtl release];
	}
    NSSortDescriptor *bySel = [NSSortDescriptor sortDescriptorWithKey:@"selected" ascending:NO];
    NSSortDescriptor *byName = [NSSortDescriptor sortDescriptorWithKey:@"label" ascending:YES];
    [self.tableCells sortUsingDescriptors:[NSArray arrayWithObjects:bySel, byName,nil]];
        
}

#pragma mark UITableViewDataSource 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    StatesListMetaLoader *statesMeta = [StatesListMetaLoader sharedStatesListMeta];

	if (NO == IsEmpty(statesMeta.states)) {
        if (!self.tableCells)
        {
            [self constructTableGroups];
        }
        
		return [self.tableCells count];      // or return [self.statesMeta.states count], should be equal
    }
	else if (statesMeta.loadingStatus > LOADING_IDLE)
		return 1;
	else
		return 0;
    
}

//
// tableView:cellForRowAtIndexPath:
//
// Returns the cell for a given indexPath.
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StatesListMetaLoader *statesMeta = [StatesListMetaLoader sharedStatesListMeta];

    if (statesMeta.loadingStatus > LOADING_IDLE) {
		if (indexPath.row == 0) {
			return [LoadingCell loadingCellWithStatus:statesMeta.loadingStatus tableView:tableView];
		}
		else {	// to make things work with our upcoming configureCell:, we need to trick this a little
			indexPath = [NSIndexPath indexPathForRow:(indexPath.row-1) inSection:indexPath.section];
		}
	}

	if (!self.tableCells)
	{
		[self constructTableGroups];
	}
	
    NSObject<CellController> *ctl = [self.tableCells objectAtIndex:indexPath.row];
    
    if ([ctl respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)])
        return [ctl tableView:tableView cellForRowAtIndexPath:indexPath];
    else
        return nil;
}

#pragma mark UITableViewDelegate

//
// tableView:didSelectRowAtIndexPath:
//
// Handle row selection
//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    StatesListMetaLoader *statesMeta = [StatesListMetaLoader sharedStatesListMeta];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (statesMeta.loadingStatus > LOADING_IDLE) {
		if (indexPath.row > 0) {
            // to make things work with our upcoming configureCell:, we need to trick this a little
			indexPath = [NSIndexPath indexPathForRow:(indexPath.row-1) inSection:indexPath.section];
		}
	}
    
    
	if (!self.tableCells)
	{
		[self constructTableGroups];
	}
	    
	NSObject<CellController> *ctl = [self.tableCells objectAtIndex:indexPath.row];
	if ([ctl respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
	{
		[ctl tableView:tableView didSelectRowAtIndexPath:indexPath];
	}
    
    if (ctl && NO == [tableView isEditing]) {
        NSDictionary *dataObject = ctl.dataObject;
        if (dataObject) {
            
            NSString *stateID = [dataObject valueForKey:@"abbreviation"];
            if (NO == IsEmpty(stateID)) {
                [[StateMetaLoader sharedStateMeta] setSelectedState:stateID];
            }
        }
        
        if (self.parentViewController) {
            [self.parentViewController dismissModalViewControllerAnimated:YES];
        }            
    }
}

- (void)tableView:(UITableView *)aTableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	BOOL useDark = (indexPath.row % 2 == 0);
	cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
}

#pragma mark Editing Cells

//
// tableView:canEditRowAtIndexPath:
//
// Specifies editing enabled for all rows.
//
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}


//
// edit:
//
// Toggles edit mode.
//
- (void)edit:(id)sender
{
	
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self 
                                                                                action:@selector(finishEditing:)];
    
	[self.statesNavItem setRightBarButtonItem:doneButton animated:YES];
    [doneButton release];
    
	[self.tableView setEditing:YES animated:YES];
    
	[self.tableView beginUpdates];
    NSArray *visible = [self.tableView indexPathsForVisibleRows];
    [self.tableView reloadRowsAtIndexPaths:visible withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    
}

//
// finish:
//
// Remove the editing
//
- (void)finishEditing:(id)sender
{
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                target:self 
                                                                                action:@selector(edit:)];
    
	[self.statesNavItem setRightBarButtonItem:editButton animated:YES];
    [editButton release];
    
	NSInteger row = 0;
	for (MultiSelectCellController *cellController in self.tableCells)
	{
        if (cellController.selected)
            [favorites addObject:cellController.label];
        else
            [favorites removeObject:cellController.label];
        
		row++;
	}
    
    
    [self constructTableGroups];
    
    if ([self isViewLoaded] && self.tableView) {
        [self.tableView setEditing:NO animated:YES];

        [self.tableView beginUpdates];
        NSArray *visible = [self.tableView indexPathsForVisibleRows];
        if (visible && [visible count]) {
            [self.tableView reloadRowsAtIndexPaths:visible withRowAnimation:UITableViewRowAnimationMiddle];
        }
        [self.tableView endUpdates];
    }
    
    [self saveFavorites];
}

@end

