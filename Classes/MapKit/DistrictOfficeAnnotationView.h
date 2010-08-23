//
//  DistrictOfficeAnnotationView.h
//  TexLege
//
//  Created by Gregory Combs on 8/23/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <MapKit/MapKit.h>


@interface DistrictOfficeAnnotationView : MKPinAnnotationView {

}
@property (nonatomic,retain) id observer;
- (void)setSelectionObserver:(id)anObserver;

@end
