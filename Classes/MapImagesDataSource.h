/*

File: MapImagesDataSource.h
Abstract: Provides the table view data for the Maps menu.

Version: 1.0

*/

#import <UIKit/UIKit.h>
#import "TableDataSourceProtocol.h"

@interface MapImagesDataSource : NSObject <UITableViewDataSource,TableDataSource> {
	NSArray *InteriorMaps;
	NSArray *ExteriorMaps;

}
@property (readonly,nonatomic,retain) NSArray *InteriorMaps;
@property (readonly,nonatomic,retain) NSArray *ExteriorMaps;

- (void) reload;

@end
