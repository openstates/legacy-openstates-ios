//
//  EXFile.h
//  Entropy
//

#import <Foundation/Foundation.h>

@interface EXFile : NSObject {
	NSString* fileName;
}

- (id)initWithName:(NSString*)_fileName;
+ (id)fileWithName:(NSString*)_fileName;
- (BOOL)exists;
- (NSString*)fileName;

@end
