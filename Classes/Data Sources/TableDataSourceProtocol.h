//
//  TableDataSourceProtocol.h
//  Created by Gregory Combs on 7/22/09.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#define kNotifyTableDataUpdated     @"TABLE_DATA_UPDATED"
#define kNotifyTableDataError       @"TABLE_DATA_ERROR"

@protocol TableDataSource <UITableViewDataSource>
 
@required

    @property (nonatomic,readonly)  BOOL             usesCoreData;

- (id)dataObjectForIndexPath:(NSIndexPath*)indexPath;
- (NSIndexPath *)indexPathForDataObject:(id)dataObject;

@optional

// set this on when you don't want to see the index, ala keyboard active
@property (nonatomic, assign)   BOOL                        hideTableIndex;
@property (nonatomic, retain)   UISearchDisplayController  *searchDisplayController;
@property (nonatomic, retain)   NSFetchedResultsController *fetchedResultsController;

@end
