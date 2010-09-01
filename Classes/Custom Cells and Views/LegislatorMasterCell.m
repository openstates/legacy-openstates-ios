//
//  LegislatorMasterCell.m
//  TexLege
//
//  Created by Gregory Combs on 8/9/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "LegislatorMasterCell.h"
#import "LegislatorMasterCellView.h"
#import "LegislatorObj.h"
#import "DisclosureQuartzView.h"

@implementation LegislatorMasterCell
@synthesize legislator, cellView;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	
	if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
		
		// Create a time zone view and add it as a subview of self's contentView.

		//UIImage *tempImage = [UIImage imageNamed:@"anchia.png"];
		//self.imageView.image = tempImage;
		
		DisclosureQuartzView *qv = [[DisclosureQuartzView alloc] initWithFrame:CGRectMake(0.f, 0.f, 25.f, 25.f)];
		//UIImageView *iv = [[UIImageView alloc] initWithImage:[qv imageFromUIView]];
		self.accessoryView = qv;
		[qv release];
		//[iv release];
		
		CGFloat endX = self.contentView.bounds.size.width - 53.f;
		CGRect tzvFrame = CGRectMake(53.f, 0.0, endX, self.contentView.bounds.size.height);
		cellView = [[LegislatorMasterCellView alloc] initWithFrame:tzvFrame];
		cellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.contentView addSubview:cellView];
	}
	return self;
}


 - (void)setHighlighted:(BOOL)val animated:(BOOL)animated {               // animate between regular and highlighted state
	[super setHighlighted:val animated:animated];

	self.cellView.highlighted = val;
}

- (void)setSelected:(BOOL)val animated:(BOOL)animated {               // animate between regular and highlighted state
	[super setHighlighted:val animated:animated];
	
	self.cellView.highlighted = val;
}


- (void)setLegislator:(LegislatorObj *)value {
	if ([legislator isEqual:value])
		return;
	legislator = [value retain];
	self.imageView.image = [UIImage imageNamed:legislator.photo_name];
		
	self.cellView.legislator = value;
}

- (void)redisplay {
	[cellView setNeedsDisplay];
}



- (void)dealloc {
	self.legislator = nil;
	[cellView release], cellView = nil;
	
    [super dealloc];
}


@end
