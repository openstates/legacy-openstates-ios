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

@interface TableSectionHeaderView()
@property (nonatomic,readonly) CGFloat offset;
@end

@implementation TableSectionHeaderView
@synthesize titleLabel=__titleLabel;
@synthesize style = _style;

- (TableSectionHeaderView*)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame];
    if (self) {
        self.style = style;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.autoresizesSubviews = YES;
        __titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.offset, 0, frame.size.width-self.offset, frame.size.height)];
        __titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:__titleLabel];
        
        if (style == UITableViewStyleGrouped) {
            self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
            self.backgroundColor = [UIColor clearColor];
            __titleLabel.shadowOffset = CGSizeMake(0, 1);
            __titleLabel.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:.7];
            __titleLabel.backgroundColor = [UIColor clearColor];
            __titleLabel.textColor = [SLFAppearance tableSectionColor];
            __titleLabel.font = SLFFont(15);
        }
        else {
            self.backgroundColor = SLFColorWithRGB(207,208,194);
            __titleLabel.backgroundColor = self.backgroundColor;
            __titleLabel.textColor = [UIColor whiteColor];
            __titleLabel.font = SLFFont(12);
        }
        [self setNeedsLayout];
    }
    return self;
}

- (TableSectionHeaderView*)initWithTitle:(NSString *)title width:(CGFloat)width style:(UITableViewStyle)style {
    CGFloat height = [TableSectionHeaderView heightForTableViewStyle:style];
    self = [self initWithFrame:CGRectMake(0, 0, width, height) style:style];
    if (self) {
        [self setTitle:title];
    }
    return self;
}

- (void)dealloc {
    self.titleLabel = nil;
    [super dealloc];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.origin = CGPointMake(self.offset, 0);
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
    [self.titleLabel sizeToFit];
    [self setNeedsLayout];
}

+ (CGFloat)heightForTableViewStyle:(UITableViewStyle)style {
    if (style == UITableViewStyleGrouped)
        return 26.f;
    return 18.f;
}

- (CGFloat)offset {
    if (self.style == UITableViewStyleGrouped)
        return 20.f;
    return 10.f;
}

@end
