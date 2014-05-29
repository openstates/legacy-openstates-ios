//
//  SLFImprovedRKTableController.m
//  OpenStates
//
//
//  Created by Daniel Cloud on 5/29/14.
//
//

#import "SLFImprovedRKTableController.h"

@implementation SLFImprovedRKTableController

// !!!: Reimplement private method.
- (void)addToOverlayView:(UIView *)view modally:(BOOL)modally {
    CGRect frame = CGRectIsEmpty(self.overlayFrame) ? self.tableView.frame : self.overlayFrame;
    if (! _tableOverlayView) {
        _tableOverlayView = [[UIView alloc] initWithFrame:frame];
        _tableOverlayView.autoresizesSubviews = YES;
        _tableOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
        NSInteger tableIndex = [self.tableView.superview.subviews indexOfObject:self.tableView];
        if (tableIndex != NSNotFound) {
            [self.tableView.superview addSubview:_tableOverlayView];
        }
    }

    // When modal, we enable user interaction to catch & discard events on the overlay and its subviews
    _tableOverlayView.userInteractionEnabled = modally;
    view.userInteractionEnabled = modally;

    if (CGRectIsEmpty(view.frame)) {
        view.frame = _tableOverlayView.bounds;

        // Center it in the overlay
        view.center = _tableOverlayView.center;
    }

    _tableOverlayView.frame = frame;
    [self.tableView.superview bringSubviewToFront:_tableOverlayView];
    [_tableOverlayView addSubview:view];
}

// !!!: Override to fix implementation
- (void)showImageInOverlay:(UIImage *)image {
    NSAssert(self.tableView, @"Cannot add an overlay image to a nil tableView");
    if (! _stateOverlayImageView) {
        _stateOverlayImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        _stateOverlayImageView.opaque = YES;
        _stateOverlayImageView.autoresizingMask = UIViewAutoresizingNone;
        _stateOverlayImageView.contentMode = UIViewContentModeTop | UIViewContentModeLeft;
    }
    _stateOverlayImageView.image = image;
    [self addToOverlayView:_stateOverlayImageView modally:self.showsOverlayImagesModally];
}

@end
