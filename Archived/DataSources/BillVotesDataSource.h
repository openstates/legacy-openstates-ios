//
//  BillVotesDataSource.m
//  Created by Gregory S. Combs on 3/31/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
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

@interface BillVotesViewController : UITableViewController {
}

@end

