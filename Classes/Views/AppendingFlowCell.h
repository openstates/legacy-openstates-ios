//
//  AppendingFlowCell.h
//  Created by Greg Combs on 12/29/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

@interface AppendingFlowCell : UITableViewCell
@property (nonatomic,copy) NSArray *stages;
@property (nonatomic,assign) BOOL useDarkBackground;
@end

@interface AppendingFlowCellMapping : RKTableViewCellMapping
@property (nonatomic,copy) NSArray *stages;
@end
