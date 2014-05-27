//
//  StyledCellMapping.m
//  Created by Greg Combs on 2/1/12.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

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

- (id)init {
    self = [super init];
    if (self) {
        self.cellClass = [OpenStatesTableViewCell class];
        self.reuseIdentifier = @"OpenStatesTableViewCell";
        self.style = UITableViewCellStyleValue2;
        self.isSelectableCell = YES;
        self.useLargeRowHeight = NO;
        self.textColor = [SLFAppearance cellTextColor];
        self.detailTextColor = [SLFAppearance cellSecondaryTextColor];
        self.textFont = SLFFont(14);
        self.detailTextFont = SLFFont(12);
 		__block __typeof__(self) bself = self;
        self.onCellWillAppearForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath* indexPath) {
            cell.textLabel.textColor = bself.textColor;
            cell.textLabel.font = bself.textFont;
            cell.detailTextLabel.textColor = bself.detailTextColor;
            cell.detailTextLabel.font = bself.detailTextFont;
            if (bself.useLargeRowHeight) {
                cell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
                cell.detailTextLabel.numberOfLines = 4;
            }
            if (bself.useAlternatingRowColors) {
                SLFAlternateCellForIndexPath(cell, indexPath);
            }
            else {
                cell.backgroundColor = [SLFAppearance cellBackgroundLightColor];
            }
        };
    }
    return self;
}

- (void)dealloc {
    self.textColor = nil;
    self.detailTextColor = nil;
    self.textFont = nil;
    self.detailTextFont = nil;
    [super dealloc];
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
    return [self cellMappingWithStyle:[self defaultCellStyle] alternatingColors:NO largeHeight:NO selectable:NO];
}

+ (id)subtitleMapping {
    return [self cellMappingWithStyle:[self defaultCellStyle] alternatingColors:NO largeHeight:NO selectable:YES];
}

+ (UITableViewCellStyle)defaultCellStyle
{
    return UITableViewCellStyleSubtitle;
}

@end
