//
//  CapitolMapsDataSource.h
//  TexLege
//
//  Created by Gregory Combs on 7/22/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "TableDataSourceProtocol.h"
#import "CapitolMap.h"

@interface CapitolMapsDataSource : NSObject <TableDataSource> {
}
@property (nonatomic,retain) NSMutableArray *sectionList;

@end
