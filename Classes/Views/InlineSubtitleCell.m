//
//  InlineSubtitleCell.m
//  Created by Greg Combs on 2/1/12.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "InlineSubtitleCell.h"
#import "SLFAppearance.h"

@implementation InlineSubtitleCell
@synthesize title = _title;
@synthesize subtitle = _subtitle;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
//      self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.opaque = YES;
        self.textLabel.opaque = YES;
        self.detailTextLabel.opaque = YES;
        UIColor *background = [SLFAppearance cellBackgroundLightColor];
        self.backgroundColor = background;
        self.textLabel.backgroundColor = background;
        self.detailTextLabel.backgroundColor = background;
        self.textLabel.font = SLFFont(18);
        self.detailTextLabel.font = SLFPlainFont(14);
        self.textLabel.textColor = [SLFAppearance cellTextColor];
        self.detailTextLabel.textColor = [SLFAppearance cellTextColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.textLabel sizeToFit];
    [self.detailTextLabel sizeToFit];
    CGFloat detailOffsetX = self.textLabel.origin.x + self.textLabel.width + 5;
    CGFloat detailCenterY = self.textLabel.center.y;
    self.detailTextLabel.origin = CGPointMake(detailOffsetX, self.textLabel.origin.y);
    self.detailTextLabel.center = CGPointMake(self.detailTextLabel.center.x, detailCenterY);
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    if (!backgroundColor)
        return;
    self.textLabel.backgroundColor = backgroundColor;
    self.detailTextLabel.backgroundColor = backgroundColor;
}

- (NSString *)title {
    return self.textLabel.text;
}

- (void)setTitle:(NSString *)title {
    self.textLabel.text = title;
    [self setNeedsLayout];
}

- (NSString *)subtitle {
    return self.detailTextLabel.text;
}

- (void)setSubtitle:(NSString *)subtitle {
    self.detailTextLabel.text = subtitle;
    [self setNeedsLayout];
}

@end


@implementation InlineSubtitleMapping

+ (id)cellMapping {
    return [InlineSubtitleMapping styledMappingForClass:[InlineSubtitleCell class] usingBlock:^(StyledCellMapping *cellMapping) {
        cellMapping.useAlternatingRowColors = YES;
        cellMapping.style = UITableViewCellStyleValue2;
        cellMapping.accessoryType = UITableViewCellAccessoryNone;
        cellMapping.textFont = SLFFont(18);
        cellMapping.textColor = [SLFAppearance cellTextColor];
        cellMapping.detailTextFont = SLFPlainFont(14);
        cellMapping.detailTextColor = [SLFAppearance cellTextColor];
        [cellMapping mapKeyPath:@"title" toAttribute:@"title"];
        [cellMapping mapKeyPath:@"subtitle" toAttribute:@"subtitle"];
    }];
}
@end

