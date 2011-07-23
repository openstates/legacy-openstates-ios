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

@implementation StatesListViewController
@synthesize statesMeta;

#pragma mark -
#pragma mark Initialization


- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    self = [super initWithStyle:style];
    if (self) {
        statesMeta = [[StatesListMetaLoader alloc] init];
        
        self.modalPresentationStyle = UIModalPresentationPageSheet;
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
    self.statesMeta = nil;
    
    [super dealloc];
}


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(reloadData:) name:kStatesListLoadedKey object:nil];	
 
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData:) name:kStateMetaNotifyError object:nil];	

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewDidUnload];
}

- (void)reloadData:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (NO == IsEmpty(self.statesMeta.states))
		return [self.statesMeta.states count];
	else if (self.statesMeta.loadingStatus > LOADING_IDLE)
		return 1;
	else
		return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  	if (self.statesMeta.loadingStatus > LOADING_IDLE) {
		if (indexPath.row == 0) {
			return [LoadingCell loadingCellWithStatus:self.statesMeta.loadingStatus tableView:tableView];
		}
		else {	// to make things work with our upcoming configureCell:, we need to trick this a little
			indexPath = [NSIndexPath indexPathForRow:(indexPath.row-1) inSection:indexPath.section];
		}
	}
	
	NSString *CellIdentifier = @"CellOn";
	
	TexLegeStandardGroupCell *cell = (TexLegeStandardGroupCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[[TexLegeStandardGroupCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                                                reuseIdentifier:CellIdentifier] autorelease];
        
		cell.textLabel.textColor = [TexLegeTheme textDark];
		cell.detailTextLabel.textColor = [TexLegeTheme indexText];
		cell.textLabel.font = [TexLegeTheme boldFifteen];
        
		if ([CellIdentifier isEqualToString:@"CellOff"]) {
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryView = nil;
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
    }
	if (NO == IsEmpty(self.statesMeta.states)) {
        BOOL useDark = (indexPath.row % 2 == 0);
        
        cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
        
        NSString *name = [[self.statesMeta.states objectAtIndex:indexPath.row] valueForKey:@"name"];
        if (NO == IsEmpty(name)) {
            cell.textLabel.text = name;
                
            //cell.detailTextLabel.text = bill_title;
        }
    }
    
	return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (NO == IsEmpty(self.statesMeta.states)) {
        
        NSString *stateID = [[self.statesMeta.states objectAtIndex:indexPath.row] valueForKey:@"abbreviation"];
        if (NO == IsEmpty(stateID)) {
            [[StateMetaLoader sharedStateMeta] setSelectedState:stateID];
        }
    }
    
    if (self.parentViewController) {
        [self.parentViewController dismissModalViewControllerAnimated:YES];
    }    
}


@end

