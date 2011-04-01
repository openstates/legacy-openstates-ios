//
//  BillVotesDataSource.m
//  TexLege
//
//  Created by Gregory S. Combs on 3/31/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//


#import "LegislatorsDataSource.h"

enum {
	BillVotesTypePNV = -1,
	BillVotesTypeNay,
	BillVotesTypeYea
} BillVotesTypes;

@interface BillVotesDataSource : LegislatorsDataSource <UITableViewDelegate> {
	NSMutableDictionary *billVotes_;
	NSMutableArray *voters_;
}

@property (nonatomic,retain) NSMutableDictionary *billVotes;
@property (nonatomic,retain) NSMutableArray *voters;
@property (nonatomic,retain) NSString *voteID;
@property (nonatomic,assign) UITableViewController *viewController;

- (id)initWithBillVotes:(NSMutableDictionary *)newVotes;

@end
