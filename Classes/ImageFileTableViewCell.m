//
//  ImageFileTableViewCell.m
//  TexLege
//
//  Created by Gregory Combs on 5/18/09.
//  Copyright 2009 University of Texas at Dallas. All rights reserved.
//

#import "ImageFileTableViewCell.h"


@implementation ImageFileTableViewCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
		element = nil;
		elementTileView = nil;
		labelView = nil;
		
		// create the elementTileView and the labelView
		// both of these will be laid out again by the layoutSubviews method
		AtomicElementTileView *tileView = [[AtomicElementTileView alloc] initWithFrame:CGRectZero];
		self.elementTileView = tileView;
		[self.contentView addSubview:tileView];
		[tileView release];
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
		// set the label view to have a clear background and a 20 point font
		label.backgroundColor = [UIColor clearColor];
		label.font = [UIFont boldSystemFontOfSize:20];
		self.labelView = label;
		[self.contentView addSubview:label];
		[label release];
		
		
		// add both the label and elementTile to the TableViewCell view
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
