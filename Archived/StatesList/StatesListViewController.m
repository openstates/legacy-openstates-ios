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
#import "SLFDataModels.h"
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
    self = [super initWithStyle:style];
    if (self) {
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSArray *storedFavorites = [[NSUserDefaults standardUserDefaults] objectForKey:kFavoriteStatesKey];
        
        if (storedFavorites) 
            favorites = [[NSMutableSet alloc] initWithArray:storedFavorites];
        else
            favorites = [[NSMutableSet alloc] init];
        
        
        [StatesListMetaLoader sharedStatesLoader];
        
        self.modalPresentationStyle = UIModalPresentationFormSheet;
        
    }
    return self;
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
											 selector:@selector(tableDataChanged:) name:kStatesListLoadedKey object:nil];	

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
    tFrame.size.height -= 88.f;
    self.tableView.frame = tFrame;
    
    
    UILabel *whereToChange = [[UILabel alloc] initWithFrame:CGRectMake(0.f, CGRectGetHeight(self.view.bounds)-44.f,
                                                                       CGRectGetWidth(self.view.frame),
                                                                       44.f)];
    whereToChange.text = NSLocalizedStringFromTable(@"You can change this in the 'Resources' tab", @"StandardUI", @"");
    whereToChange.font = [TexLegeTheme boldTwelve];
    whereToChange.textColor = [TexLegeTheme textDark];
    whereToChange.textAlignment = UITextAlignmentCenter;
    whereToChange.lineBreakMode = UILineBreakModeWordWrap;
    whereToChange.numberOfLines = 1;
    whereToChange.backgroundColor = [TexLegeTheme tableBackground];
    whereToChange.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:whereToChange];
    [whereToChange release];
                                                                       
    [self.tableView setAllowsSelectionDuringEditing:YES];
	[self finishEditing:self];
    
}


- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.statesNavItem = nil;
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
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

- (void)tableDataChanged:(NSNotification *)notification {
    [self constructTableGroups];
    
    [self.tableView reloadData];
}

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

- (void)constructTableGroups
{	
    
    StatesListMetaLoader *statesMeta = [StatesListMetaLoader sharedStatesLoader];
    
	self.tableCells = [NSMutableArray array];
    
	NSInteger i;
	for (i = 0; i < [statesMeta.states count]; i++)
	{
        SLFState *state = [statesMeta.states objectAtIndex:i];
        
        NSCAssert(state != NULL, @"Received bad data dictionary in StatesListViewController");
        
        NSString *labelText = state.name;
        
        MultiSelectCellController *cellCtl = [[MultiSelectCellController alloc] initWithLabel:labelText];
        
        cellCtl.dataObject = state;
        
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
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    StatesListMetaLoader *statesMeta = [StatesListMetaLoader sharedStatesLoader];

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StatesListMetaLoader *statesMeta = [StatesListMetaLoader sharedStatesLoader];

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    StatesListMetaLoader *statesMeta = [StatesListMetaLoader sharedStatesLoader];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (statesMeta.loadingStatus > LOADING_IDLE) {
		if (indexPath.row > 0) {
            // to make things work with our upcoming configureCell:, we need to trick this a little
			indexPath = [NSIndexPath indexPathForRow:(indexPath.row-1) inSection:indexPath.section];
		}
        else {
            return; // they're clicking on a network error or loading cell ... don't do anything.
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
    
    if (ctl && NO == [tableView isEditing] && [ctl.dataObject isKindOfClass:[SLFState class]]) {
        SLFState *state = (SLFState *)ctl.dataObject;
        if (state) {
            [[StateMetaLoader sharedStateMeta] setSelectedState:state];
        }
        
        UIViewController *parent = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        if (parent) {
            [parent dismissModalViewControllerAnimated:YES];
        }
        else if (self.parentViewController) {
            [self.parentViewController dismissModalViewControllerAnimated:YES];
        } else {
            RKLogCritical(@"Can't close a simple modal view controller??? Parent = %@", self.parentViewController);
        }
    }
}

- (void)tableView:(UITableView *)aTableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	BOOL useDark = (indexPath.row % 2 == 0);
	cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
}

#pragma mark Editing Cells

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[StatesListMetaLoader sharedStatesLoader] loadingStatus] > LOADING_IDLE)
        return NO;
	return YES;
}


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

