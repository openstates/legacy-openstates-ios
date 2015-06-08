//
//  TableSectionHeaderView.h
//  Created by Greg Combs on 10/21/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


@interface TableSectionHeaderView : UIView
@property (nonatomic,retain) IBOutlet UILabel *titleLabel;
@property (nonatomic,assign) UITableViewStyle style;
@property (nonatomic,copy) NSString *title;

- (TableSectionHeaderView*)initWithTitle:(NSString *)title width:(CGFloat)width style:(UITableViewStyle)style;
- (TableSectionHeaderView*)initWithFrame:(CGRect)frame style:(UITableViewStyle)style;
+ (CGFloat)heightForTableViewStyle:(UITableViewStyle)style;
@end
