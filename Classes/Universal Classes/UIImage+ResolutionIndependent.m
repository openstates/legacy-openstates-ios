//
//  UIImage+ResolutionIndependent.m
//  TexLege
//
//	http://atastypixel.com/blog/uiimage-resolution-independence-and-the-iphone-4s-retina-display/
//


#import "UIImage+ResolutionIndependent.h"


@implementation UIImage (ResolutionIndependent)

- (id)initWithContentsOfResolutionIndependentFile:(NSString *)path {
    if ( [UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0 ) {
        NSString *path2x = [[path stringByDeletingLastPathComponent] 
                            stringByAppendingPathComponent:[NSString stringWithFormat:@"%@@2x.%@", 
                                                            [[path lastPathComponent] stringByDeletingPathExtension], 
                                                            [path pathExtension]]];
		
        if ( [[NSFileManager defaultManager] fileExistsAtPath:path2x] ) {
            return [self initWithContentsOfFile:path2x];
        }
    }
	
    return [self initWithContentsOfFile:path];
}

+ (UIImage*)imageWithContentsOfResolutionIndependentFile:(NSString *)path {
    return [[[UIImage alloc] initWithContentsOfResolutionIndependentFile:path] autorelease];
}

+ (UIImage*)highResImageWithPath:(NSString *)path {
	return  [UIImage imageNamed:[[path stringByDeletingLastPathComponent] 
							  stringByAppendingPathComponent:[NSString stringWithFormat:@"%@@2x.%@", 
															  [[path lastPathComponent] stringByDeletingPathExtension], 
															  [path pathExtension]]]];
}

@end
