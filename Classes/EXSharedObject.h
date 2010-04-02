//
//  EXSharedObject.h
//  Entropy
//

#import <Foundation/Foundation.h>

@interface EXSharedObject : NSObject {
	long long __uniqueID;
}

- (long long)__uniqueID;

@end
