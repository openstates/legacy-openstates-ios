/*

File: TableDataSourceProtocol.h
Abstract: Protocol that defines information each Element tableview datasource
must provide.

Version: 1.7

*/

#import <UIKit/UIKit.h>
#import "AtomicElement.h"

@protocol TableDataSource <NSObject>
 
@required

// these properties are used by the view controller
// for the navigation and tab bar
@property (readonly) NSString *name;
@property (readonly) NSString *navigationBarName;
@property (readonly) UIImage *tabBarImage;

// this property determines the style of table view displayed
@property (readonly) UITableViewStyle tableViewStyle;


@optional

// provides a standardized means of asking for the element at the specific
// index path, regardless of the sorting or display technique for the specific
// datasource
- (AtomicElement *)cellDataForIndexPath:(NSIndexPath *)indexPath;

- (BOOL)showDisclosureIcon;

// this optional protocol allows us to send the datasource this message, since it has the 
// required information
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;

// return an image file name, used with maps.
- (NSString *)cellImageDataForIndexPath:(NSIndexPath *)indexPath;


@end
