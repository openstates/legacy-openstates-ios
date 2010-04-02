//
//  CustomObject.h
//  EntropySample1
//

#import <Foundation/Foundation.h>
#import "EXSharedObject.h"

@interface CustomObject : EXSharedObject {
	NSString* text;
	int number;
}

- (id)initWithText:(NSString*)_text number:(int)_number;

@end
