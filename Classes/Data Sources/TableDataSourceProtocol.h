//
//  TableDataSourceProtocol.h
//  TexLege
//
//  Created by Gregory Combs on 7/22/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "LegislatorObj.h"
#import "CommitteeObj.h"
#import "CapitolMap.h"
#import "LinkObj.h"
#import "ChamberCalendarObj.h"

@protocol TableDataSource <UITableViewDataSource, NSFetchedResultsControllerDelegate>
 
@required

// these properties are used by the view controller
// for the navigation and tab bar
@property (readonly) NSString *name;
@property (readonly) NSString *navigationBarName;
@property (readonly) UIImage *tabBarImage;

// this property determines the style of table view displayed
@property (readonly) UITableViewStyle tableViewStyle;
@property (readonly) BOOL usesCoreData;
@property (readonly) BOOL canEdit;

- (BOOL)showDisclosureIcon;

@optional
- (Class)dataClass;

@property (nonatomic, readonly) BOOL hasFilter;
- (void) setFilterByString:(NSString *)filter;
- (void) removeFilter;

@property (nonatomic) NSInteger filterChamber;		// 0 means don't filter
@property (nonatomic, retain) UISearchDisplayController *searchDisplayController;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

- (void)initializeDatabase;

// this optional protocol allows us to send the datasource this message, since it has the 
// required information
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;

- (id)dataObjectForIndexPath:(NSIndexPath*)indexPath;
- (NSIndexPath *)indexPathForDataObject:(id)dataObject;

// implement these for editing...
- (void)setEditing:(BOOL)isEditing animated:(BOOL)animated;
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath;
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath;

// set this on when you don't want to see the index, ala keyboard active
@property (nonatomic) BOOL hideTableIndex;

- (void)resetData:(NSNotification *)notification;


@end
