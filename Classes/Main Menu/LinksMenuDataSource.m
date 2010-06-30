//
//  LinksMenuDataSource.m
//  TexLege
//
//  Created by Gregory S. Combs on 5/24/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "LinksMenuDataSource.h"
#import "TexLegeAppDelegate.h"
#import "LinkObj.h"
#import "LinksDetailViewController.h"

@implementation LinksMenuDataSource


enum Sections {
    kHeaderSection = 0,
    kBodySection,
    NUM_SECTIONS
};
enum HeaderSectionRows {
    kHeaderSectionThisAppRow = 0,
    kHeaderSectionRollCalRow,
    NUM_HEADER_SECTION_ROWS
};

@synthesize moving;
@synthesize fetchedResultsController, managedObjectContext;
@synthesize theTableView;

#if NEEDS_TO_INITIALIZE_DATABASE
@synthesize linksData;
#endif

#pragma mark -
#pragma mark TableDataSourceProtocol methods
// return the data used by the navigation controller and tab bar item

- (NSString *)name
{ return @"Resources"; }

- (NSString *)navigationBarName
{ return @"Resources and Info"; }

- (UIImage *)tabBarImage {
	//return [UIImage imageNamed:@"33-cabinet.png"];
	return [UIImage imageNamed:@"info_30.png"];
}

- (BOOL)showDisclosureIcon
{ return YES; }

- (BOOL)usesCoreData
{ return YES; }

- (BOOL)usesToolbar
{ return NO; }

- (BOOL)usesSearchbar
{ return NO; }

- (BOOL)canEdit
{ return YES; }

- (UITableViewStyle)tableViewStyle {
	return UITableViewStylePlain;
} 

// setup the data collection
- init {
	if (self = [super init]) {
		moving = NO;
	}
	return self;
}

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)newContext {
	if ([self init])
		if (newContext) self.managedObjectContext = newContext;
	return self;
}

- (void)dealloc {	
#if NEEDS_TO_INITIALIZE_DATABASE
	[linksData release];
#endif
	self.fetchedResultsController = nil;
	self.managedObjectContext = nil;
	self.theTableView = nil;

    [super dealloc];
}

#if NEEDS_TO_INITIALIZE_DATABASE
- (void) setupDataArray {
//#error **** MAKE SURE YOU RE-ENABLE LINK FOR "Links.plist"
	NSString *DataPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Links.plist"];		
	NSDictionary *tempDict = [[NSDictionary alloc] initWithContentsOfFile:DataPath];
	NSArray *tempArray = [[NSArray alloc] initWithArray:[tempDict objectForKey:@"Links"]];
	self.linksData = tempArray;
	[tempArray release];
	[tempDict release];		
}

- (void)initializeDatabase {
	NSInteger count = [[self.fetchedResultsController sections] count];
	if (count == 0) { // try initializing it...
		
		// if numberOfSections is dynamic, we should move this up...
		if (self.linksData == nil) {
			[self setupDataArray];
		}
		
		// Create a new instance of the entity managed by the fetched results controller.
		NSEntityDescription *entity = [[fetchedResultsController fetchRequest] entity];
		
		for (NSDictionary *dictionary in self.linksData) {
			NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:
												 [entity name] inManagedObjectContext:self.managedObjectContext];
			
			[newManagedObject setValue:[dictionary objectForKey:@"label"] forKey:@"label"];
			[newManagedObject setValue:[dictionary objectForKey:@"url"] forKey:@"url"];
			[newManagedObject setValue:[dictionary objectForKey:@"order"] forKey:@"order"];
			[newManagedObject setValue:[dictionary objectForKey:@"section"] forKey:@"section"];
			[newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
			
			// Save the context.
			NSError *error;
			if (![self.managedObjectContext save:&error]) {
				// Handle the error...
			}
		}
	}
}
#endif

#pragma mark -
#pragma mark Editing Table



- (void)save{
	@try {
		NSError *error;
		if (![self.managedObjectContext save:&error]) {
			NSLog(@"LinksMenuDataSource:save - unresolved error %@, %@", error, [error userInfo]);
		}		
	}
	@catch (NSException * e) {
		debug_NSLog(@"Failure in LinksMenuDataSource:save, name=%@ reason=%@", e.name, e.reason);
	}
}

- (NSUInteger)numberOfBodyLinks {
	NSArray *sections = [fetchedResultsController sections];
    NSUInteger count = 0;
    if ([sections count]) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:kBodySection];
        count = [sectionInfo numberOfObjects];
    }
	return count;
}


- (BOOL) isAddLinkPlaceholderAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger row = indexPath.row;
	NSUInteger section = indexPath.section;
	NSUInteger count = [self numberOfBodyLinks];
	
	return ((section == kBodySection) && (row >= count));
}


- (NSArray *) getActionForRowAtIndexPath:(NSIndexPath *)indexPath {

	LinkObj *link = [fetchedResultsController objectAtIndexPath:indexPath];
	NSNumber * destination = nil;
	
	// If allowing the user to enter URLs for the internal browser creates an issue for App ratings in iTunes
	// (i.e. possible adult content), then we just force user entered links (determined by mod date) over to Safari
#if NEEDS_TO_CENSOR_USER_LINKS
	#define kReferenceDate 269721914.791581
	NSDate *referenceDate = [NSDate dateWithTimeIntervalSinceReferenceDate:kReferenceDate];
	if ([link.timeStamp compare:referenceDate] == NSOrderedDescending) // it's a newer/added link
		destination = [NSNumber numberWithInteger:URLAction_externalBrowser];
	else 
#endif
		destination = [NSNumber numberWithInteger:URLAction_internalBrowser];
	
	return [NSArray arrayWithObjects:destination, link.url, nil];	
}


- (BOOL)validateLinkOrders {		
	NSInteger index = 0;
	@try {		
		NSArray * fetchedObjects = [self.fetchedResultsController fetchedObjects];
		
		if (fetchedObjects == nil)
			return NO;
		
		LinkObj * link = nil;		
		for (link in fetchedObjects) {
			if (link.section.integerValue == kBodySection) {
				if (link.order.integerValue != index) {
					debug_NSLog(@"Info: Order out of sync, order=%@ expected=%d", link.order, index);

					link.order = [NSNumber numberWithInteger:index];
				}
				index++;
			}
		}
	}
	@catch (NSException * e) {
		debug_NSLog(@"Failure in validateLinkOrders, name=%@ reason=%@", e.name, e.reason);
	}
	
	return (index > 0 ? YES : NO);
}

// UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
#if NEEDS_TO_INITIALIZE_DATABASE
	[self initializeDatabase];
#endif
	NSUInteger section = indexPath.section;
	
	LinkObj *link = nil;
	NSString *CellIdentifier;
	UITableViewCell *cell;

	BOOL addLinkRow = [self isAddLinkPlaceholderAtIndexPath:indexPath];
	
	if (addLinkRow) { 
		CellIdentifier = @"AddLinkCell";
	}
	else if (section == kHeaderSection) {
		link = [fetchedResultsController objectAtIndexPath:indexPath];
		if (tableView.isEditing)
			CellIdentifier = @"LinksHeaderNoEditor";
		else
			CellIdentifier = @"LinksHeader";
	}
	else { // it's a real link in the body
		CellIdentifier = @"LinksBodyLink";
		@try {
			link = [fetchedResultsController objectAtIndexPath:indexPath];
		}
		@catch (NSException * e) {
			debug_NSLog(@"Exception in cellForRowAtIndexPath");
		}
	}
	
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

 	if (cell == nil) {
		// default to kBodySection stylings
		UITableViewCellStyle style = UITableViewCellStyleSubtitle;
		UITableViewCellAccessoryType disclosure = UITableViewCellAccessoryDisclosureIndicator;
		
		if (section == kHeaderSection) {
			style = UITableViewCellStyleDefault;
			if (tableView.isEditing)
				disclosure = UITableViewCellAccessoryNone;
			else
				disclosure = UITableViewCellAccessoryDetailDisclosureButton;
		}
		else if (addLinkRow) {
			style = UITableViewCellStyleDefault;
			disclosure = UITableViewCellAccessoryDisclosureIndicator;
		}

		cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = disclosure;
	}
    
	
	switch(indexPath.section) {
		case kHeaderSection:
			cell.textLabel.text = link.label;
			break;
		case kBodySection: {

			if (addLinkRow) {
				cell.textLabel.text = @"Add Resource Link";
			}
			else {
				//CORE DATA
				cell.detailTextLabel.text = link.url;
				cell.textLabel.text = link.label;
			}
		}
			break;
		default:
			NSAssert(NO, @"Resources Menu: Unhandled value in Section cellForRowAtIndexPath");
			return nil;
	}
	
    return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  {

	if (self.theTableView != tableView)
		self.theTableView = tableView;

	//CORE DATA
	NSUInteger count = [[fetchedResultsController sections] count];
    if (count == 0) {		
		count = 1;
    }
	return count;
}


- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section {

	NSArray *sections = [fetchedResultsController sections];
    NSUInteger count = 0;
    if ([sections count]) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
        count = [sectionInfo numberOfObjects];
		if (tableView.isEditing && (section == kBodySection))
			count++;
    }
	return count;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	switch(section) {
		case kHeaderSection:
			return @"This Application";
		default:
			return @"Web Resources";
	}	
}

- (void)setEditing:(BOOL)isEditing animated:(BOOL)animated {
					
    NSUInteger count = [self numberOfBodyLinks];
		
	[self.theTableView beginUpdates];
	
	NSArray *linkInsertIndexPath = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:count inSection:kBodySection]];
	
	if (isEditing) {
		[self.theTableView insertRowsAtIndexPaths:linkInsertIndexPath withRowAnimation:UITableViewRowAnimationTop];
	} else {
		[self.theTableView deleteRowsAtIndexPaths:linkInsertIndexPath withRowAnimation:UITableViewRowAnimationTop];
	}
	
	[self.theTableView endUpdates];

	/*
	 If editing is finished, save the managed object context.
	 */
	if (!isEditing) {
		[self save];
		//if ([self validateLinkOrders])
		//	[self save]; //again

	}
	
	// since we change the appearance of the header rows during editing, make sure to update that section
	[self.theTableView reloadSections:[NSIndexSet indexSetWithIndex:kHeaderSection] 
						withRowAnimation:UITableViewRowAnimationNone];
						//withRowAnimation:UITableViewRowAnimationFade];  // does a weird flashing thing.
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSIndexPath *rowToSelect = indexPath;
    NSInteger section = indexPath.section;
    
    // If editing, don't allow header to be selected
    if (tableView.isEditing && section == kHeaderSection) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        rowToSelect = nil;    
    }
	
	return rowToSelect;
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == kHeaderSection)
		return NO;
	else if ([self isAddLinkPlaceholderAtIndexPath:indexPath]) // if it's the "insert" row, don't move it.
		return NO;
	else
		return YES;
}
	
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	// Return NO if you do not want the specified item to be editable.
	
	switch(indexPath.section) {
		case kHeaderSection:
			return NO;
		default: {
			if (([self numberOfBodyLinks] > 1 ) || ([self isAddLinkPlaceholderAtIndexPath:indexPath]))
				return YES;
			else 
				return NO;
		}
	}
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section != kHeaderSection) {
		
		if (editingStyle == UITableViewCellEditingStyleDelete) {

			@try {
				LinkObj * link = [self.fetchedResultsController objectAtIndexPath:indexPath];
				
				debug_NSLog(@"Deleting at indexPath %@", [indexPath description]);
				//debug_NSLog(@"Deleting object %@", [link description]);
				
				if ([self numberOfBodyLinks] > 1) 
					[self.managedObjectContext deleteObject:link];
				
			}
			@catch (NSException * e) {
				debug_NSLog(@"Failure in commitEditingStyle, name=%@ reason=%@", e.name, e.reason);
			}

		}
		else if (editingStyle == UITableViewCellEditingStyleInsert) {
			// we need this for when they click the "+" icon; just select the row
			[tableView.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
		}
	}
}



- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
#if 0  // if we're using a mutable array instead ... how to sync with the core data
	NSUInteger fromRow = [fromIndexPath row]; 
	NSUInteger toRow = [toIndexPath row]; 
	
	if (fromRow != toRow) {
		
        // array up to date
        id object = [[eventsArray objectAtIndex:fromRow] retain]; 
        [eventsArray removeObjectAtIndex:fromRow]; 
        [eventsArray insertObject:object atIndex:toRow]; 
        [object release]; 
		
        NSFetchRequest *fetchRequestFrom = [[NSFetchRequest alloc] init];
        NSEntityDescription *entityFrom = [NSEntityDescription entityForName:@"Lister" inManagedObjectContext:managedObjectContext];
		
        [fetchRequestFrom setEntity:entityFrom];
		
        NSPredicate *predicate; 
        if (fromRow < toRow) predicate = [NSPredicate predicateWithFormat:@"itemOrder >= %d AND itemOrder <= %d", fromRow, toRow];      
        else predicate = [NSPredicate predicateWithFormat:@"itemOrder <= %d AND itemOrder >= %d", fromRow, toRow];                                                      
        [fetchRequestFrom setPredicate:predicate];
		
        NSError *error;
        NSArray *fetchedObjectsFrom = [managedObjectContext executeFetchRequest:fetchRequestFrom error:&error];
        [fetchRequestFrom release];     
		
        if (fetchedObjectsFrom != nil) { 
			for ( Lister* lister in fetchedObjectsFrom ) {
				
				if ([[lister itemOrder] integerValue] == fromRow) { // the item that moved
					NSNumber *orderNumber = [[NSNumber alloc] initWithInteger:toRow];                               
					[lister setItemOrder:orderNumber];
					[orderNumber release];
				} else { 
					NSInteger orderNewInt;
					if (fromRow < toRow) { 
						orderNewInt = [[lister itemOrder] integerValue] -1; 
					} else { 
						orderNewInt = [[lister itemOrder] integerValue] +1;     
					}
					NSNumber *orderNumber = [[NSNumber alloc] initWithInteger:orderNewInt];
					[lister setItemOrder:orderNumber];
					[orderNumber release];
				}
				
			}
			
			NSError *error;
			if (![managedObjectContext save:&error]) {
				NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
				exit(-1);  // Fail
			}                       
			
        }    
	}
#endif
	
#if 0//revert
	
	if (![self validateLinkOrders])
		debug_NSLog(@"Couldn't validate the link order");
	
	NSInteger start = fromIndexPath.row;
	NSInteger end = toIndexPath.row;
	NSInteger section = fromIndexPath.section;
	NSInteger i = 0;
	LinkObj *link = nil;
	
	//if (toIndexPath == fromIndexPath)
	// return; // don't do anything
	if (toIndexPath.row < start)
		start = toIndexPath.row;
	if (fromIndexPath.row > end)
		end = fromIndexPath.row;
	
	for (i = start; i <= end; i++) {
		link = [self.fetchedResultsController objectAtIndexPath:
				[NSIndexPath indexPathForRow:i inSection:section]];
		//debug_NSLog(@"Before: %@", link);
		
		if (i == fromIndexPath.row) // it's our initial cell, just set it to our final destination
			link.order = [NSNumber numberWithInteger:toIndexPath.row];
		else if (fromIndexPath.row < toIndexPath.row)
			link.order = [NSNumber numberWithInteger:i-1]; 	// it moved forward, shift back
		else // if (fromIndexPath.row > toIndexPath.row)
			link.order = [NSNumber numberWithInteger:i+1]; 	// it moved backward, shift forward
				
		//debug_NSLog(@"After: %@", link);
	}
	

#else
	//if (toIndexPath == fromIndexPath)
	//	return; // don't do anything
	
	NSArray * fetchedObjects = [self.fetchedResultsController fetchedObjects];	
	if (fetchedObjects == nil)
		return;
	
	NSUInteger fromRow = fromIndexPath.row + NUM_HEADER_SECTION_ROWS;
	NSUInteger toRow = toIndexPath.row + NUM_HEADER_SECTION_ROWS;
	
	NSInteger start = fromRow;
	NSInteger end = toRow;
	NSInteger i = 0;
	LinkObj *link = nil;
	
	if (toRow < start)
		start = toRow;
	if (fromRow > end)
		end = fromRow;
	
	@try {
		
		
		for (i = start; i <= end; i++) {
			link = [fetchedObjects objectAtIndex:i]; //
			//debug_NSLog(@"Before: %@", link);
			
			if (i == fromRow)	// it's our initial cell, just set it to our final destination
				link.order = [NSNumber numberWithInteger:(toRow-NUM_HEADER_SECTION_ROWS)];
			else if (fromRow < toRow)
				link.order = [NSNumber numberWithInteger:(i-1-NUM_HEADER_SECTION_ROWS)];		// it moved forward, shift back
			else // if (fromIndexPath.row > toIndexPath.row)
				link.order = [NSNumber numberWithInteger:(i+1-NUM_HEADER_SECTION_ROWS)];		// it moved backward, shift forward
			//debug_NSLog(@"After: %@", link);
		}
	}
	@catch (NSException * e) {
		debug_NSLog(@"Failure in moveRowAtIndexPath, name=%@ reason=%@", e.name, e.reason);
	}
#endif	
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {

	//     Moves are only allowed within the body section.	
    NSIndexPath *target = proposedDestinationIndexPath;	
    if (proposedDestinationIndexPath.section == kHeaderSection) {
        target = [NSIndexPath indexPathForRow:0 inSection:kBodySection];
    }
	else if ([self isAddLinkPlaceholderAtIndexPath:proposedDestinationIndexPath]) {
        target = [NSIndexPath indexPathForRow:proposedDestinationIndexPath.row-1 inSection:kBodySection];
    }	
    return target;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCellEditingStyle style = UITableViewCellEditingStyleNone;

	if (indexPath.section != kHeaderSection) { // we've already defaulted to None, that's fine for Header.
		if ([self isAddLinkPlaceholderAtIndexPath:indexPath]) { // if it's our "insert" row, show an insert
			style = UITableViewCellEditingStyleInsert;
		}
		else {
			style = UITableViewCellEditingStyleDelete;			// otherwise, show a delete.
		}
	}
	
	return style;
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {    
	@try {
		
		switch (type) {
			case NSFetchedResultsChangeInsert:
				if (newIndexPath)
					[theTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
				[self validateLinkOrders];
				break;
			case NSFetchedResultsChangeUpdate:
				//[theTableView reloadSections:[NSIndexSet indexSetWithIndex:newIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
				//[theTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
				break;
			case NSFetchedResultsChangeMove:
				self.moving = YES;
				[self validateLinkOrders];
			//[theTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
				// Reloading the section inserts a new row and ensures that titles are updated appropriately.
				//[theTableView reloadSections:[NSIndexSet indexSetWithIndex:newIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
				break;
				
			case NSFetchedResultsChangeDelete:
				if (indexPath)
					[theTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
				//[self performSelector:@selector(validateLinkOrders) withObject:nil afterDelay:0.02];
				[self validateLinkOrders];
				break;
			default:
				break;
		}
	}
	@catch (NSException * e) {
		debug_NSLog(@"Failure in didChangeObject, name=%@ reason=%@", e.name, e.reason);
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.theTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.theTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller is about to start sending change notifications, so prepare the table view for updates.
	//if (self.theTableView != nil)
		//[self.theTableView beginUpdates];
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// The fetch controller has sent all current change notifications, so tell the table view to process all updates.
	@try {
		if (self.theTableView != nil) {
			//[self.theTableView endUpdates];
			if (self.moving) {
				self.moving = NO;
				[self.theTableView reloadData];
				//[self performSelector:@selector(reloadData) withObject:nil afterDelay:0.02];
			}
			[self performSelector:@selector(save) withObject:nil afterDelay:0.02];
		}	
		
	}
	@catch (NSException * e) {
		debug_NSLog(@"Failure in controllerDidChangeContent, name=%@ reason=%@", e.name, e.reason);
	}
}


#pragma mark -
#pragma mark Core Data Methods


- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
    /*
	 Set up the fetched results controller.
	 */
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"LinkObj" inManagedObjectContext:self.managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sectionDescriptor = [[NSSortDescriptor alloc] initWithKey:@"section" ascending:YES];
	NSSortDescriptor *orderDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sectionDescriptor, orderDescriptor, nil];
	
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	// Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] 
															 initWithFetchRequest:fetchRequest 
															 managedObjectContext:self.managedObjectContext 
															 sectionNameKeyPath:@"section" cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
		
	[aFetchedResultsController release];
	[fetchRequest release];
	[orderDescriptor release];
	[sectionDescriptor release];
	[sortDescriptors release];
	
	
	return fetchedResultsController;
}    


@end
