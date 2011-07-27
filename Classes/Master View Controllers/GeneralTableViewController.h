//
//  GeneralTableViewController.h
//  Created by Gregory Combs on 7/10/09.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "GCTableViewController.h"
#import "TableDataSourceProtocol.h"

@interface GeneralTableViewController : GCTableViewController {
    BOOL isFeatureEnabled;
    BOOL isServerReachable;
}

@property (nonatomic,retain) id<TableDataSource> dataSource;
@property (nonatomic,retain) id selectObjectOnAppear;
@property (nonatomic,retain) IBOutlet id detailViewController;

@property (nonatomic) BOOL controllerEnabled;
- (NSString *)reachabilityStatusKey;
- (NSString *)apiFeatureFlag;

- (void)configure;
- (void)runLoadView;
- (Class)dataSourceClass;
- (IBAction)selectDefaultObject:(id)sender;
- (id)firstDataObject;

- (void)beginUpdates:(NSNotification *)aNotification;
- (void)endUpdates:(NSNotification *)aNotification;

@end
