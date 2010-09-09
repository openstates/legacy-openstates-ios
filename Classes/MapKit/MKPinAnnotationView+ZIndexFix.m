//
//  MKPinAnnotationView+ZIndexFix.m
//  TexLege
//
//  Created by Gregory Combs on 9/8/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "MKPinAnnotationView+ZIndexFix.h"


@implementation MKPinAnnotationView (ZIndexFix)
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	[self.superview bringSubviewToFront:self];
	[super touchesBegan:touches withEvent:event];
}
@end