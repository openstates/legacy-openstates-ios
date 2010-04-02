//
//  DirectoryDetailView.h
//  TexLege
//
//  Created by Gregory S. Combs on 5/31/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "Constants.h"
#include "CommitteeObj.h"

@class DetailTableViewController;

@interface CommitteeDetailView : UITableView <UITableViewDataSource>{
	CommitteeObj		*committee;
	NSMutableArray	*sectionArray;
	DetailTableViewController *detailController;
}

@property (nonatomic, retain) DetailTableViewController *detailController;
@property (nonatomic, retain) CommitteeObj *committee;
@property (nonatomic, retain) NSMutableArray *sectionArray;
@property (readonly) NSString *name;


- (id) initWithFrameAndCommittee:(CGRect)frame Committee:(CommitteeObj *)aCommittee;
- (void) didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath;

@end
