//
//  UIImage+ResolutionIndependent.m
//  TexLege
//
//	http://atastypixel.com/blog/uiimage-resolution-independence-and-the-iphone-4s-retina-display/
//


#import "UIImage+ResolutionIndependent.h"


@implementation UIImage (ResolutionIndependent)

+ (NSString*)highResImagePathWithPath:(NSString *)path {
	return  [[path stringByDeletingLastPathComponent] 
			 stringByAppendingPathComponent:[NSString stringWithFormat:@"%@@2x.%@", 
											 [[path lastPathComponent] stringByDeletingPathExtension], 
											 [path pathExtension]]];
}	

+ (NSString *)resolutionIndependentFilePath:(NSString *)path {
	// perhaps we already have @2x in the path, so just send it on through.
    if ( ![path hasSuffix:@"@2x.png"] && [UIScreen instancesRespondToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0 ) {
        NSString *path2x = [[path stringByDeletingLastPathComponent] 
                            stringByAppendingPathComponent:[NSString stringWithFormat:@"%@@2x.%@", 
                                                            [[path lastPathComponent] stringByDeletingPathExtension], 
                                                            [path pathExtension]]];
		
        if ( [[NSFileManager defaultManager] fileExistsAtPath:path2x] ) {
            return path2x;
        }
    }
	return path;
}

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

@end
