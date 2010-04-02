//
//  MapImageView.h
//  TexLege
//
//  Created by Gregory Combs on 5/18/09.
//  Copyright 2009 University of Texas at Dallas. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailTableViewController;

@interface MapImageView : UIView <UIScrollViewDelegate> {
	NSString *imageFile;
	UIScrollView *scrollView;
    UIImageView *imageView;
	DetailTableViewController *viewController;

}

@property (nonatomic,retain) NSString *imageFile;
@property (nonatomic, assign) DetailTableViewController *viewController;

@end
