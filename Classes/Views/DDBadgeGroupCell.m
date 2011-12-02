//
//  DDBadgeViewCell.m
//  DDBadgeViewCell
//
//  Created by digdog on 1/23/10.
//  Copyright 2010 Ching-Lan 'digdog' HUANG. http://digdog.tumblr.com
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//   
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//   
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import <QuartzCore/QuartzCore.h>
#import "DDBadgeGroupCell.h"
#import "SLFDataModels.h"
#import "TableCellDataObject.h"
#import "SLFTheme.h"

#pragma mark -
#pragma mark DDBadgeView declaration

@interface DDBadgeView : UIView {
    
@private
    DDBadgeGroupCell *cell_;
}

@property (nonatomic, assign) DDBadgeGroupCell *cell;

- (id)initWithFrame:(CGRect)frame cell:(DDBadgeGroupCell *)newCell;
@end

#pragma mark -
#pragma mark DDBadgeView implementation

@implementation DDBadgeView 

@synthesize cell = cell_;

#pragma mark -
#pragma mark init

- (id)initWithFrame:(CGRect)frame cell:(DDBadgeGroupCell *)newCell {
    
    if ((self = [super initWithFrame:frame])) {
        cell_ = newCell;
        
        self.backgroundColor = [UIColor clearColor];
        self.layer.masksToBounds = YES;
    }
    return self;
}

#pragma mark -
#pragma mark redraw

- (void)drawRect:(CGRect)rect {    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *currentSummaryColor = [SLFAppearance cellTextColor];
    UIColor *currentBadgeColor = self.cell.badgeColor;
    if (!currentBadgeColor) {
        currentBadgeColor = [SLFAppearance menuSelectedTextColor]; 
    }
    
    if (self.cell && self.cell.isClickable && (self.cell.isHighlighted || self.cell.isSelected)) {
        currentSummaryColor = [UIColor whiteColor];
        currentBadgeColor = self.cell.badgeHighlightedColor;
        if (!currentBadgeColor) {
            currentBadgeColor = [UIColor whiteColor];
        }
    } 
    
    if (self.cell && self.cell.isEditing) {
        [currentSummaryColor set];
        [self.cell.summary drawAtPoint:CGPointMake(10, 10) forWidth:rect.size.width withFont:SLFFont(15) lineBreakMode:UILineBreakModeTailTruncation];
    } else {
        CGSize badgeTextSize = [self.cell.badgeText sizeWithFont:SLFFont(12)];
        CGRect badgeViewFrame = CGRectIntegral(CGRectMake(rect.size.width - badgeTextSize.width - 24, (rect.size.height - badgeTextSize.height - 4) / 2, badgeTextSize.width + 14, badgeTextSize.height + 4));
        
        CGContextSaveGState(context);    
        CGContextSetFillColorWithColor(context, currentBadgeColor.CGColor);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddArc(path, NULL, badgeViewFrame.origin.x + badgeViewFrame.size.width - badgeViewFrame.size.height / 2, badgeViewFrame.origin.y + badgeViewFrame.size.height / 2, badgeViewFrame.size.height / 2, M_PI / 2, M_PI * 3 / 2, YES);
        CGPathAddArc(path, NULL, badgeViewFrame.origin.x + badgeViewFrame.size.height / 2, badgeViewFrame.origin.y + badgeViewFrame.size.height / 2, badgeViewFrame.size.height / 2, M_PI * 3 / 2, M_PI / 2, YES);
        CGContextAddPath(context, path);
        CGContextDrawPath(context, kCGPathFill);
        CFRelease(path);
        CGContextRestoreGState(context);
        
        CGContextSaveGState(context);    
        CGContextSetBlendMode(context, kCGBlendModeClear);
        [self.cell.badgeText drawInRect:CGRectInset(badgeViewFrame, 7, 2) withFont:SLFFont(12)];
        CGContextRestoreGState(context);
        
        [currentSummaryColor set];
        [self.cell.summary drawAtPoint:CGPointMake(10, 10) forWidth:(rect.size.width - badgeViewFrame.size.width - 24) withFont:SLFFont(15) lineBreakMode:UILineBreakModeTailTruncation];
    }
}

@end

#pragma mark -
#pragma mark DDBadgeGroupCell private

@interface DDBadgeGroupCell()
@property (nonatomic,retain) DDBadgeView *badgeView;
@end

#pragma mark -
#pragma mark DDBadgeGroupCell implementation

@implementation DDBadgeGroupCell

@synthesize summary = _summary;
@synthesize badgeView = _badgeView;
@synthesize badgeText = _badgeText;
@synthesize badgeColor = _badgeColor;
@synthesize badgeHighlightedColor = _badgeHighlightedColor;
@synthesize isClickable = _isClickable;
@synthesize subjectEntry = _subjectEntry;
@synthesize cellInfo = _cellInfo;

+ (NSString *)cellIdentifier {
    return @"DDBadgeGroupCell";
}

+ (UITableViewCellStyle)cellStyle {
    return UITableViewCellStyleDefault;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.backgroundColor = [SLFAppearance cellBackgroundLightColor];
        _isClickable = YES;
        _badgeView = [[DDBadgeView alloc] initWithFrame:self.contentView.bounds cell:self];
        _badgeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _badgeView.contentMode = UIViewContentModeRedraw;
        _badgeView.contentStretch = CGRectMake(1., 0., 0., 0.);
        [self.contentView addSubview:_badgeView];
    }
    return self;
}

#pragma mark -
#pragma mark init & dealloc

- (void)dealloc {
    self.badgeView = nil;
    self.summary = nil;
    self.badgeText = nil;
    self.badgeColor = nil;
    self.badgeHighlightedColor = nil;
    self.cellInfo = nil;
    self.subjectEntry = nil;
    [super dealloc];
}

- (void)setSubjectEntry:(BillsSubjectsEntry *)subjectEntry {
    SLFRelease(_subjectEntry);
    if (!subjectEntry)
        return;
    _subjectEntry = [subjectEntry retain];
    self.badgeText = [NSString stringWithFormat:NSLocalizedString(@"%@ Bills",@""), subjectEntry.billCount];
    self.summary = subjectEntry.name;
    self.isClickable = [subjectEntry.billCount integerValue] > 0;
    [self.badgeView setNeedsDisplay];
}

- (void)setCellInfo:(TableCellDataObject *)cellInfo {    
    SLFRelease(_cellInfo);
    if (!cellInfo)
        return;
    _cellInfo = [cellInfo retain];
    self.summary = cellInfo.title;
    self.badgeText = [NSString stringWithFormat:NSLocalizedString(@"%@ Bills", @""), cellInfo.entryValue];
    self.isClickable = cellInfo.isClickable;
    [self.badgeView setNeedsDisplay];
}

- (void)setIsClickable:(BOOL)isClickable {
    _isClickable = isClickable;
    if (isClickable) {
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        _badgeView.alpha = 1;
        self.badgeColor = [SLFAppearance menuSelectedTextColor];
    }
    else {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _badgeView.alpha = .3;
        self.badgeColor = [SLFAppearance menuTextColor];
    }
    [self.badgeView setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self.badgeView setNeedsDisplay];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [self.badgeView setNeedsDisplay];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.badgeView setNeedsDisplay];
}

@end
