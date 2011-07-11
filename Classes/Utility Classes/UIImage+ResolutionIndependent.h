//
//  UIImage+ResolutionIndependent.h
//  Created by Gregory Combs on 7/9/10.
//	http://atastypixel.com/blog/uiimage-resolution-independence-and-the-iphone-4s-retina-display/
//


@interface UIImage (ResolutionIndependent)
- (id)initWithContentsOfResolutionIndependentFile:(NSString *)path;
+ (UIImage*)imageWithContentsOfResolutionIndependentFile:(NSString *)path;
+ (NSString*)highResImagePathWithPath:(NSString *)path;
+ (NSString *)resolutionIndependentFilePath:(NSString *)path;

@end
