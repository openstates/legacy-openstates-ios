//
//  SLFDataSource.h
//  Created by Gregory S. Combs on 8/3/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <RestKit/RestKit.h>
#import "TableDataSourceProtocol.h"

@interface SLFDataSource : NSObject <TableDataSource, RKObjectLoaderDelegate>

- (void)loadData;
- (void)loadDataWithResourcePath:(NSString *)newPath;

- (id)initWithObjClass:(Class)newClass 
                    sortBy:(NSString *)newSort
                   groupBy:(NSString *)newGroup;


@property (nonatomic, retain)   NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, copy)     NSString        *stateID;    
@property (nonatomic, copy)     NSString        *sortBy;    
@property (nonatomic, copy)     NSString        *groupBy;  
@property (nonatomic, assign)   BOOL             loading;  

@property (nonatomic,readonly)  NSString        *resourcePath;
@property (nonatomic,assign)    Class            resourceClass;
@property (nonatomic,retain)    NSMutableDictionary *queryParameters;

// override and return a property that must not be null in order to loadData
@property (nonatomic, readonly) NSString        *primaryKeyProperty;
@end
