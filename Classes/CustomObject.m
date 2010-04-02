//
//  CustomObject.m
//  EntropySample1
//

#import "CustomObject.h"

@implementation CustomObject

- (id)initWithText:(NSString*)_text number:(int)_number {
	if (self = [super init]) {
		text = [_text retain];
		number = _number;
	}
	return self;
}

- (void)dealloc {
	[text release];
	[super dealloc];
}

- (NSString*)description {
	return [NSString stringWithFormat: @"%@: %d", text, number];
}

@end
