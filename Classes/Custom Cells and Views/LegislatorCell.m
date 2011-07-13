//
//  LegislatorMasterCell.m
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
#import "LegislatorObj.h"
#import "DisclosureQuartzView.h"


@implementation LegislatorCell
@synthesize cellView;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	
	if ((self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])) {
		
		DisclosureQuartzView *qv = [[DisclosureQuartzView alloc] initWithFrame:CGRectMake(0.f, 0.f, 28.f, 28.f)];
		self.accessoryView = qv;
		[qv release];
		
		CGFloat endX = self.contentView.bounds.size.width - 53.f;
		CGRect tzvFrame = CGRectMake(53.f, 0.0, endX, self.contentView.bounds.size.height);
		cellView = [[LegislatorCellView alloc] initWithFrame:tzvFrame];
		cellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.contentView addSubview:cellView];
	}
	return self;
}

- (CGSize)cellSize {
	return cellView.cellSize;
}

- (NSString*)role {
	return self.cellView.role;
}

- (void)setRole:(NSString *)value {
	self.cellView.role = value;
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
	self.imageView.image = [UIImage imageNamed:value.photo_name];
	[self.cellView setLegislator:value];
}

- (void)redisplay {
	[cellView setNeedsDisplay];
}

- (void)dealloc {
	nice_release(cellView);
	
    [super dealloc];
}


@end
