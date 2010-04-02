/*
 
 File: CommitteesDataSource.h
 Abstract: Provides the table view data for the elements sorted by atomic symbol.
 
 Version: 1.7
 
 */

#import <UIKit/UIKit.h>
#import "TableDataSourceProtocol.h"

@interface CommitteesDataSource : NSObject <UITableViewDataSource,TableDataSource> {
}

@end
