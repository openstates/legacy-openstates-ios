//
//  DemoViewController.h
//  Demo
//
//  Created by digdog on 11/4/10.
//  Copyright 2010 Ching-Lan 'digdog' HUANG. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDActionHeaderView;

@interface DemoViewController : UIViewController {
	DDActionHeaderView *actionHeaderView;
}

@property(nonatomic, retain) DDActionHeaderView *actionHeaderView;

- (void)itemAction:(id)sender;

@end

