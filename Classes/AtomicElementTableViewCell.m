/*

File: AtomicElementTableViewCell.m
Abstract: Draws the tableview cell and lays out the subviews.

Version: 1.7

*/

#import "AtomicElementTableViewCell.h"
#import "AtomicElement.h"
#import "AtomicElementTileView.h"

@implementation AtomicElementTableViewCell

@synthesize element;
@synthesize elementTileView;
@synthesize labelView;


 
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


- (void)layoutSubviews {
	[super layoutSubviews];

	// determine the content rect for the cell. This will change depending on the
	// style of table (grouped vs plain)
	CGRect contentRect = self.contentView.bounds;
	
	// position the image tile in the content rect.
	CGRect elementTileRect = self.contentView.bounds;
	elementTileRect.size = [AtomicElementTileView preferredViewSize];
	elementTileRect = CGRectOffset(elementTileRect,10,3);
	elementTileView.frame = elementTileRect;
	
	// position the elment name in the content rect
	CGRect labelRect = contentRect;
	labelRect.origin.x = labelRect.origin.x+56;
	labelRect.origin.y = labelRect.origin.y+3;
	labelView.frame = labelRect;	
}


- (void)dealloc {
	[element release];
	[elementTileView release];
	[labelView release];
    [super dealloc];
}


// the element setter
// we implement this because the table cell values need
// to be updated when this property changes, and this allows
// for the changes to be encapsulated
- (void)setElement:(AtomicElement *)anElement {
	if (anElement != element) {
		[element release];
		[anElement retain];
		element = anElement;
	}
	elementTileView.element = element;
	labelView.text = element.name;
	[elementTileView setNeedsDisplay];
	[labelView setNeedsDisplay];
}


@end
