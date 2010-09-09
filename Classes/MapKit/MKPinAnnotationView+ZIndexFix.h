//
//  MKPinAnnotationView+ZIndexFix.h
//  TexLege
//
//  Created by Gregory Combs on 9/8/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <MapKit/Mapkit.h>


@interface MKPinAnnotationView (ZIndexFix)
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event; 
@end
