//
//  DistrictOfficeAnnotationView.m
//  TexLege
//
//  Created by Gregory Combs on 8/23/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "DistrictOfficeAnnotationView.h"


@implementation DistrictOfficeAnnotationView
@synthesize observer;

- (void)setSelectionObserver:(id)anObserver {
	if (!anObserver) 
		return;
	self.observer = anObserver;
	[self addObserver:anObserver forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:@"GMAP_ANNOTATION_SELECTED"];

}

- (void)dealloc {
	if (self.observer)
		[self removeObserver:self.observer forKeyPath:@"selected"];
	self.observer = nil;
	[super dealloc];
}
@end
