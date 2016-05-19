//
//  TableSectionHeaderView.m
//  Created by Greg Combs on 10/21/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "TableSectionHeaderView.h"
#import "SLFTheme.h"

@interface TableSectionHeaderView()
@property (nonatomic,readonly) CGFloat offset;
@end

@implementation TableSectionHeaderView

- (TableSectionHeaderView*)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.style = style;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.autoresizesSubviews = YES;
        CGFloat offset = [self offsetForStyle:style];
        CGRect labelRect = CGRectMake(offset, 0, CGRectGetWidth(frame)-offset, CGRectGetHeight(frame));
        _titleLabel = [[UILabel alloc] initWithFrame:labelRect];
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_titleLabel];

        UIColor *backgroundColor = nil;
        if (style == UITableViewStyleGrouped) {
            backgroundColor = [UIColor clearColor];
            _titleLabel.shadowOffset = CGSizeMake(0, 1);
            _titleLabel.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:.7];
            _titleLabel.textColor = [SLFAppearance tableSectionColor];
            _titleLabel.font = SLFFont(15);
        }
        else
        {
            backgroundColor = SLFColorWithRGB(207,208,194);
            _titleLabel.textColor = [UIColor whiteColor];
            _titleLabel.font = SLFFont(12);
        }
        _titleLabel.backgroundColor = backgroundColor;
        self.backgroundColor = backgroundColor;
        [self setNeedsLayout];
    }
    return self;
}

- (TableSectionHeaderView*)initWithTitle:(NSString *)title width:(CGFloat)width style:(UITableViewStyle)style
{
    CGFloat height = [TableSectionHeaderView heightForTableViewStyle:style];
    self = [self initWithFrame:CGRectMake(0, 0, width, height) style:style];
    if (self) {
        [self setTitle:title];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!self.titleLabel)
        return;
    self.titleLabel.origin = CGPointMake(self.offset, 0);
    [self.titleLabel sizeToFit];
}

- (void)setTitle:(NSString *)title
{
    _title = [title copy];
    if (!self.titleLabel || !SLFTypeStringOrNil(title))
        return;
    self.titleLabel.text = title;
    [self.titleLabel sizeToFit];
    [self setNeedsLayout];
}

+ (CGFloat)heightForTableViewStyle:(UITableViewStyle)style
{
    if (style == UITableViewStyleGrouped)
        return 26.f;
    return 18.f;
}

- (CGFloat)offsetForStyle:(UITableViewStyle)style
{
    if (style == UITableViewStyleGrouped)
        return 20.f;
    return 10.f;
}

- (CGFloat)offset
{
    return [self offsetForStyle:self.style];
}

@end
