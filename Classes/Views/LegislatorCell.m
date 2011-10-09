//
//  LegislatorCell.m
//  Created by Gregory Combs on 8/9/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "LegislatorCell.h"
#import "LegislatorCellView.h"
#import "SLFAppearance.h"
#import "SLFLegislator.h"
#import "DisclosureQuartzView.h"
#import "UIImageView+AFNetworking.h"
#import "UIImageView+RoundedCorners.h"
#import "SLFTheme.h"
@implementation LegislatorCell
@synthesize legislator;
@synthesize cellContentView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        DisclosureQuartzView *qv = [[DisclosureQuartzView alloc] initWithFrame:CGRectMake(0.f, 0.f, 28.f, 28.f)];
		self.accessoryView = qv;
		[qv release];
        CGRect tzvFrame = CGRectMake(53.f, 0, self.contentView.bounds.size.width - 53.f, self.contentView.bounds.size.height);
        cellContentView = [[LegislatorCellView alloc] initWithFrame:CGRectInset(tzvFrame, 0, 1.0)];
        cellContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        cellContentView.contentMode = UIViewContentModeRedraw;
        [self.contentView addSubview:cellContentView];
    }
    return self;
}

- (CGSize)cellSize {
	return cellContentView.cellSize;
}

- (NSString*)role {
	return self.cellContentView.role;
}

- (void)setRole:(NSString *)value {
	self.cellContentView.role = value;
}

- (void)setHighlighted:(BOOL)val animated:(BOOL)animated {
	[super setHighlighted:val animated:animated];
	self.cellContentView.highlighted = val;
}

- (void)setSelected:(BOOL)val animated:(BOOL)animated {
	[super setHighlighted:val animated:animated];
	self.cellContentView.highlighted = val;
}

- (void)setLegislator:(SLFLegislator *)value {
    if (!IsEmpty(value.photoURL)) {
        [self.imageView setImageWithURL:[NSURL URLWithString:value.photoURL] placeholderImage:[UIImage imageNamed:@"placeholder"]];
            //[self.imageView roundTopLeftCorner];
    }
	[self.cellContentView setLegislator:value];
}

- (void)redisplay {
	[cellContentView setNeedsDisplay];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    if (cellContentView.highlighted)
        return;
    cellContentView.backgroundColor = backgroundColor;
    [cellContentView setNeedsDisplay];
}

- (void)dealloc
{
    nice_release(cellContentView);    
    [super dealloc];
}
@end

@implementation LegislatorCellMapping

+ (id)cellMapping {
    return [self mappingForClass:[LegislatorCell class]];
}

- (id)init {
    self = [super init];
    if (self) {
        self.cellClass = [LegislatorCell class];
        self.rowHeight = 73; 
        self.onCellWillAppearForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath* indexPath) {
            cell.textLabel.textColor = [SLFAppearance cellTextColor];
                //SLFAlternateCellForIndexPath(cell, indexPath);
            BOOL useDarkBG = (indexPath.row % 2 == 0);
            cell.backgroundColor = [SLFAppearance cellBackgroundLightColor];
            if (useDarkBG)
                cell.backgroundColor = [SLFAppearance cellBackgroundDarkColor];
            if ([cell isKindOfClass:[LegislatorCell class]]) {
                LegislatorCell *legCell = (LegislatorCell *)cell;
                legCell.cellContentView.useDarkBackground = useDarkBG;
            }
        };
    }
    return self;
}

- (void)addDefaultMappings {
    [self mapKeyPath:@"self" toAttribute:@"legislator"];
}

@end

