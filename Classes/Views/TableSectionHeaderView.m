//
//  TableSectionHeaderView.m
//  Created by Greg Combs on 10/21/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "TableSectionHeaderView.h"
#import "SLFTheme.h"

CGFloat const TableSectionHeaderViewDefaultHeight = 26;
CGFloat const TableSectionHeaderViewDefaultOffset = 20;

@interface TableSectionHeaderView()
@end

@implementation TableSectionHeaderView
@synthesize titleLabel=__titleLabel;

- (TableSectionHeaderView*)initWithTitle:(NSString *)title width:(CGFloat)width {
    self = [self initWithFrame:CGRectMake(0, 0, width, TableSectionHeaderViewDefaultHeight) offset:TableSectionHeaderViewDefaultOffset];
    if (self) {
        [self setTitle:title];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame offset:(CGFloat)offset
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;

        CGRect labelRect = CGRectMake(offset, 0, frame.size.width-(offset*.5), frame.size.height);
        __titleLabel = [[UILabel alloc] initWithFrame:labelRect];
        __titleLabel.textColor = [SLFAppearance tableSectionColor];
        __titleLabel.shadowOffset = CGSizeMake(0, 1);
        __titleLabel.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:.7];
        __titleLabel.backgroundColor = [UIColor clearColor];
        __titleLabel.font = SLFFont(15);
        __titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.autoresizesSubviews = YES;
        [self addSubview:__titleLabel];
        [self setNeedsLayout];
        /*
         self.tableController.heightForHeaderInSection = 22;
         self.tableController.onViewForHeaderInSection = ^UIView*(NSUInteger sectionIndex, NSString* sectionTitle) {
         UIView* headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 22)] autorelease];
         headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"sectionheader_bg.png"]];
         UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, self.tableView.bounds.size.width, 22)];
         label.text = sectionTitle;
         label.textColor = [UIColor whiteColor];
         label.backgroundColor = [UIColor clearColor];
         label.font = [UIFont boldSystemFontOfSize:12];        
         [headerView addSubview:label];
         [label release];
         return headerView;
         };*/

    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.origin = CGPointMake(TableSectionHeaderViewDefaultOffset, 0);
}

- (void)dealloc {
    self.titleLabel = nil;
    [super dealloc];
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
    [self.titleLabel sizeToFit];
    [self setNeedsLayout];
}

@end
