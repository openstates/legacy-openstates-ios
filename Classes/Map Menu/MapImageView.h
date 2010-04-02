//
//  MapImageView.h
//  TexLege
//
//  Created by Gregory S. Combs on 5/18/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "Constants.h"

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
