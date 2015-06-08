//
//  AppendingFlowCell.m
//  Created by Greg Combs on 12/29/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "AppendingFlowCell.h"
#import "AppendingFlowView.h"
#import "SLFDrawingExtensions.h"

@interface AppendingFlowCell()
@property (nonatomic,retain) AppendingFlowView *flowView;
@end

@implementation AppendingFlowCell
@synthesize stages = _stages;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (self)
    {
        self.clipsToBounds = YES;        
        _flowView = [[AppendingFlowView alloc] initWithFrame:CGRectInset(self.bounds, 4, 0)];
        _flowView.uniformWidth = NO;
        _flowView.preferredBoxSize = CGSizeMake(74.f, 38.f);    
        _flowView.connectorSize = CGSizeMake(7.f, 6.f); 
        _flowView.insetMargin = CGSizeMake(1.f, 7.f);
        _flowView.backgroundColor = [SLFAppearance cellBackgroundLightColor];
        _flowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:_flowView];
    }
    return self;
}

- (void)dealloc {
    self.stages = nil;
    self.flowView = nil;
    [super dealloc];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!_flowView) {
        return;
    }
    _flowView.frame = CGRectInset(self.bounds, 4, 0);
}

- (NSArray *)stages
{
    return _stages;
}

- (void)setStages:(NSArray *)stages {
    SLFRelease(_stages);
    _stages = [stages copy];
    if (_flowView && !IsEmpty(stages)) {
        [_flowView setStages:stages];
        [self setNeedsLayout];
    }
}

- (void)setUseDarkBackground:(BOOL)useDarkBackground {
    _useDarkBackground = useDarkBackground;
    self.backgroundColor = useDarkBackground ? [SLFAppearance cellBackgroundDarkColor] : [SLFAppearance cellBackgroundLightColor];
    [self setNeedsDisplay];
}


@end

@implementation AppendingFlowCellMapping

+ (id)cellMapping {
    return [self mappingForClass:[AppendingFlowCell class]];
}

- (id)init {
    self = [super init];
    if (self) {
        self.cellClass = [AppendingFlowCell class];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.rowHeight = 90; 
        self.reuseIdentifier = nil;
		__block __typeof__(self) bself = self;
        self.onCellWillAppearForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath* indexPath) {
            AppendingFlowCell *flowCell = (AppendingFlowCell *)cell;
            [flowCell setUseDarkBackground:NO];
            if (!IsEmpty(bself.stages)) {
                flowCell.stages = bself.stages;
            }
        };
    }
    return self;
}

- (void)dealloc {
    self.stages = nil;
    [super dealloc];
}

@end
