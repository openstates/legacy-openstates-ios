//
//  StyledCellMapping.m
//  Created by Greg Combs on 2/1/12.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "StyledCellMapping.h"
#import "SLFTheme.h"
#import "OpenStatesTableViewCell.h"

@implementation StyledCellMapping
@synthesize useAlternatingRowColors = _useAlternatingRowColors;
@synthesize useLargeRowHeight = _useLargeRowHeight;
@synthesize isSelectableCell = _isSelectableCell;
@synthesize textColor = _textColor;
@synthesize detailTextColor = _detailTextColor;
@synthesize textFont = _textFont;
@synthesize detailTextFont = _detailTextFont;


+ (id)cellMapping {
    return [self mappingForClass:[OpenStatesTableViewCell class]];
}

+ (id)subtitleCellMapping {
    return [self mappingForClass:[OpenStatesSubtitleTableViewCell class]];
}


- (id)init
{
    self = [super init];
    if (self) {
        self.cellClass = [OpenStatesTableViewCell class];
        self.reuseIdentifier = NSStringFromClass([OpenStatesTableViewCell class]);
        self.style = UITableViewCellStyleValue2;
        self.isSelectableCell = YES;
        self.useLargeRowHeight = NO;
        self.textColor = [SLFAppearance cellTextColor];
        self.detailTextColor = [SLFAppearance cellSecondaryTextColor];
        self.textFont = SLFFont(14);
        self.detailTextFont = SLFFont(12);
        __weak __typeof__(self) wSelf = self;
        self.onCellWillAppearForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath* indexPath) {
            if (!wSelf)
                return;
            __strong __typeof__(wSelf) sSelf = wSelf;

            cell.textLabel.textColor = sSelf.textColor;
            cell.textLabel.font = sSelf.textFont;
            cell.detailTextLabel.textColor = sSelf.detailTextColor;
            cell.detailTextLabel.font = sSelf.detailTextFont;
            if (sSelf.useLargeRowHeight) {
                cell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
                cell.detailTextLabel.numberOfLines = 4;
            }
            if (sSelf.useAlternatingRowColors) {
                SLFAlternateCellForIndexPath(cell, indexPath);
            }
            else {
                cell.backgroundColor = [SLFAppearance cellBackgroundLightColor];
            }
        };
    }
    return self;
}


- (void)setUseLargeRowHeight:(BOOL)useLargeRowHeight {
    _useLargeRowHeight = useLargeRowHeight;
    if (useLargeRowHeight) {
        self.rowHeight = 90;
        self.textFont = SLFFont(15);
        return;
    }
    self.rowHeight = 44;
    self.textFont = SLFFont(14);
}

- (void)setIsSelectableCell:(BOOL)isSelectableCell {
    _isSelectableCell = isSelectableCell;
    if (!isSelectableCell) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        return;
    }
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

+ (StyledCellMapping *)cellMappingWithStyle:(UITableViewCellStyle)style alternatingColors:(BOOL)useAlternatingRowColors largeHeight:(BOOL)useLargeRowHeight selectable:(BOOL)isSelectableCell {
    StyledCellMapping *cellMap = [StyledCellMapping cellMapping];
    cellMap.style = style;
    cellMap.useAlternatingRowColors = useAlternatingRowColors;
    cellMap.useLargeRowHeight = useLargeRowHeight;
    cellMap.isSelectableCell = isSelectableCell;
    return cellMap;
}

+ (id)styledMappingUsingBlock:(void (^)(StyledCellMapping *cellMapping))block {
    return [self styledMappingForClass:[UITableViewCell class] usingBlock:block];
}

+ (id)styledMappingForClass:(Class)cellClass usingBlock:(void (^)(StyledCellMapping *cellMapping))block {
    id cellMapping = [StyledCellMapping mappingForClass:cellClass];
    block(cellMapping);
    return cellMapping;
}

+ (id)staticSubtitleMapping {
    StyledCellMapping *cellMap = [self cellMappingWithStyle:[self defaultCellStyle] alternatingColors:NO largeHeight:NO selectable:NO];
    cellMap.cellClass = [OpenStatesSubtitleTableViewCell class];
    cellMap.reuseIdentifier = NSStringFromClass([OpenStatesSubtitleTableViewCell class]);
    return cellMap;
}

+ (id)subtitleMapping {
    StyledCellMapping *cellMap = [self cellMappingWithStyle:[self defaultCellStyle] alternatingColors:NO largeHeight:NO selectable:YES];
    cellMap.cellClass = [OpenStatesSubtitleTableViewCell class];
    cellMap.reuseIdentifier = NSStringFromClass([OpenStatesSubtitleTableViewCell class]);
    return cellMap;
}

+ (UITableViewCellStyle)defaultCellStyle
{
    return UITableViewCellStyleSubtitle;
}

@end
