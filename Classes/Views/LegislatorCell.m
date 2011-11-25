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
        self.layer.shadowColor = [SLFAppearance tableSeparatorColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 1);
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = 1;
        //cellContentView.contentMode = UIViewContentModeScaleAspectFit;
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

- (void)setGenericName:(NSString *)genericName {
    self.cellContentView.genericName = genericName;
}

- (NSString *)genericName {
    return self.cellContentView.genericName;
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
    if (value && value.photoURL)
        [self.imageView setImageWithURL:[NSURL URLWithString:value.photoURL] placeholderImage:[UIImage imageNamed:@"placeholder"]];
    else
        [self.imageView setImage:[UIImage imageNamed:@"placeholder"]];
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

- (void)setUseDarkBackground:(BOOL)useDarkBackground {
    self.cellContentView.useDarkBackground = useDarkBackground;
}

- (BOOL)useDarkBackground {
    return self.cellContentView.useDarkBackground;
}

- (void)dealloc
{
    nice_release(cellContentView);    
    [super dealloc];
}
@end

@implementation LegislatorCellMapping
@synthesize roundImageCorners = _roundCorners;

+ (id)cellMapping {
    return [self mappingForClass:[LegislatorCell class]];
}

- (id)init {
    self = [super init];
    if (self) {
        self.cellClass = [LegislatorCell class];
        self.rowHeight = 73; 
        self.roundImageCorners = NO;
        self.reuseIdentifier = nil; // turns off caching, sucky but we don't want to reuse facial photos
        self.onCellWillAppearForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath* indexPath) {
            if (_roundCorners && indexPath.row == 0)
                [cell.imageView roundTopLeftCorner];
            BOOL useDarkBG = SLFAlternateCellForIndexPath(cell, indexPath);
            [(LegislatorCell *)cell setUseDarkBackground:useDarkBG];
        };
    }
    return self;
}

- (void)addDefaultMappings {
    [self mapKeyPath:@"self" toAttribute:@"legislator"];
}

@end

@implementation FoundLegislatorCellMapping

- (id)init {
    self = [super init];
    if (self) {
        self.roundImageCorners = YES;
    }
    return self;
}

- (void)addDefaultMappings {
    [self mapKeyPath:@"foundLegislator" toAttribute:@"legislator"];
    [self mapKeyPath:@"type" toAttribute:@"role"];
    [self mapKeyPath:@"name" toAttribute:@"genericName"];
}

@end
