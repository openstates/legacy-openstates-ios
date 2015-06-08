//
//  AppendingFlowCell.h
//  Created by Greg Combs on 12/29/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


@interface AppendingFlowCell : UITableViewCell
@property (nonatomic,copy) NSArray *stages;
@property (nonatomic,assign) BOOL useDarkBackground;
@end

@interface AppendingFlowCellMapping : RKTableViewCellMapping
@property (nonatomic,copy) NSArray *stages;
@end
