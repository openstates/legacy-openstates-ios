/*

File: DirectoryDataSource.h
Abstract: Provides the table view data for the legislators sorted by name.

Version: 1.0

*/

#import <UIKit/UIKit.h>
#import "TableDataSourceProtocol.h"
#import "Legislator.h"

@interface DirectoryDataSource : NSObject <UITableViewDataSource,TableDataSource>  {
}

// means of asking for the legislator at the specific
// index path, regardless of the sorting or display technique for the specific
// datasource
- (Legislator *)legislatorDataForIndexPath:(NSIndexPath *)indexPath;

 
@end
