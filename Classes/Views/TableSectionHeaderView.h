//
//  TableSectionHeaderView.h
//  Created by Greg Combs on 10/21/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

@interface TableSectionHeaderView : UIView
@property (nonatomic,retain) IBOutlet UILabel *titleLabel;
- (TableSectionHeaderView*)initWithTitle:(NSString *)title width:(CGFloat)width;
- (id)initWithFrame:(CGRect)frame offset:(CGFloat)offset;
- (void)setTitle:(NSString *)title;
@end

extern CGFloat const TableSectionHeaderViewDefaultHeight;
extern CGFloat const TableSectionHeaderViewDefaultOffset;
