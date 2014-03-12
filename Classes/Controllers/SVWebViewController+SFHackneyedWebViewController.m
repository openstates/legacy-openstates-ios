//
//  SVWebViewController+SFHackneyedWebViewController.m
//  OpenStates
//
//  Created by Daniel Cloud on 3/12/14.
//
//

#import "SVWebViewController+SFHackneyedWebViewController.h"

@implementation SVWebViewController (SFHackneyedWebViewController)

- (void)layoutSubviews {
    CGRect deviceBounds = self.view.bounds;
    CGFloat offset = 0;

    if ([[UIDevice currentDevice] systemMajorVersion] >= 7) {
        offset = 20.0f;
    }

    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && !deviceIsTablet && !self.navigationController) {
        navBar.frame = CGRectMake(0, offset, CGRectGetWidth(deviceBounds), 32);
        toolbar.frame = CGRectMake(0, CGRectGetHeight(deviceBounds)-32, CGRectGetWidth(deviceBounds), 32);
    } else if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation) && !deviceIsTablet && !self.navigationController) {
        navBar.frame = CGRectMake(0, offset, CGRectGetWidth(deviceBounds), 44);
        toolbar.frame = CGRectMake(0, CGRectGetHeight(deviceBounds)-44, CGRectGetWidth(deviceBounds), 44);
    }

    if(self.navigationController && deviceIsTablet)
        self.webView.frame = CGRectMake(0, 0, CGRectGetWidth(deviceBounds), CGRectGetHeight(deviceBounds));
    else if(deviceIsTablet)
        self.webView.frame = CGRectMake(0, CGRectGetMaxY(navBar.frame), CGRectGetWidth(deviceBounds), CGRectGetHeight(deviceBounds)-CGRectGetMaxY(navBar.frame));
    else if(self.navigationController && !deviceIsTablet)
        self.webView.frame = CGRectMake(0, offset, CGRectGetWidth(deviceBounds), CGRectGetMaxY(self.view.bounds));
    else if(!deviceIsTablet)
        self.webView.frame = CGRectMake(0, CGRectGetMaxY(navBar.frame), CGRectGetWidth(deviceBounds), CGRectGetMinY(toolbar.frame)-CGRectGetMaxY(navBar.frame));

    backButton.frame = CGRectMake(CGRectGetWidth(deviceBounds)-180, 0, 44, 44);
    forwardButton.frame = CGRectMake(CGRectGetWidth(deviceBounds)-120, 0, 44, 44);
    actionButton.frame = CGRectMake(CGRectGetWidth(deviceBounds)-60, 0, 44, 44);
    refreshStopButton.frame = CGRectMake(CGRectGetWidth(deviceBounds)-240, 0, 44, 44);
    titleLabel.frame = CGRectMake(titleLeftOffset, 0, CGRectGetWidth(deviceBounds)-240-titleLeftOffset-5, 44);
}


@end
