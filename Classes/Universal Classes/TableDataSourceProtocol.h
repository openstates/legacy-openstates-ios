//
//  TableDataSourceProtocol.h
//  TexLege
//
//  Created by Gregory Combs on 7/22/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "Constants.h"
#import "LegislatorObj.h"
#import "CommitteeObj.h"
#import "CapitolMap.h"

@protocol TableDataSource <UITableViewDataSource, NSFetchedResultsControllerDelegate>
 
@required
@property (nonatomic, retain) IBOutlet NSManagedObjectContext *managedObjectContext;
- (id)initWithManagedObjectContext:(NSManagedObjectContext *)newContext;

// these properties are used by the view controller
// for the navigation and tab bar
@property (readonly) NSString *name;
@property (readonly) NSString *navigationBarName;
@property (readonly) UIImage *tabBarImage;

// this property determines the style of table view displayed
@property (readonly) UITableViewStyle tableViewStyle;
@property (readonly) BOOL usesCoreData;
@property (readonly) BOOL usesToolbar;
@property (readonly) BOOL usesSearchbar;
@property (readonly) BOOL canEdit;
@property(nonatomic, readonly) CGFloat rowHeight;

- (BOOL)showDisclosureIcon;

@optional
- (void) setFilterByString:(NSString *)filter;
- (void) removeFilter;

@property (nonatomic) NSInteger filterChamber;		// 0 means don't filter
@property (nonatomic, retain) UISearchDisplayController *searchDisplayController;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

- (void)initializeDatabase;

// this optional protocol allows us to send the datasource this message, since it has the 
// required information
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;

- (CapitolMap *)capitolMapForIndexPath:(NSIndexPath *)indexPath;
- (LegislatorObj *)legislatorDataForIndexPath:(NSIndexPath *)indexPath;
- (CommitteeObj *)committeeDataForIndexPath:(NSIndexPath *)indexPath;

// implement these for editing...
- (void)setEditing:(BOOL)isEditing animated:(BOOL)animated;
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath;
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath;

// set this on when you don't want to see the index, ala keyboard active
@property (nonatomic) BOOL hideTableIndex;

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)newContext;


@end
