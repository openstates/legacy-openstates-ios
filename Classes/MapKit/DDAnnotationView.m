//
//  DDAnnotationView.m
//  MapKitDragAndDrop 3
//
//  Created by digdog on 7/24/09.
//  Copyright 2009-2010 Ching-Lan 'digdog' HUANG and digdog software.
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//   
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//   
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "DDAnnotationView.h"
#import "DDAnnotation.h"
#import <QuartzCore/QuartzCore.h> // For CAAnimation
#import "TexLegeMapPins.h"

@interface DDAnnotationView () 
@property (nonatomic, assign) BOOL hasBuiltInDraggingSupport;

@property (nonatomic, assign) BOOL isMoving;
@property (nonatomic, assign) CGPoint startLocation;
@property (nonatomic, assign) CGPoint originalCenter;

@property (nonatomic, retain) UIImageView *	pinShadow;
@property (nonatomic, retain) NSTimer * pinTimer;

+ (CAAnimation *)pinBounceAnimation_;
+ (CAAnimation *)pinFloatingAnimation_;
+ (CAAnimation *)pinLiftAnimation_;
+ (CAAnimation *)liftForDraggingAnimation_; // Used in touchesBegan:
+ (CAAnimation *)liftAndDropAnimation_;		// Used in touchesEnded: when touchesMoved: previous triggered
- (void)shadowLiftWillStart_:(NSString *)animationID context:(void *)context;
- (void)shadowDropDidStop_:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void)resetPinPosition_:(NSTimer *)timer;
@end

@implementation DDAnnotationView
@synthesize hasBuiltInDraggingSupport, isMoving, startLocation, originalCenter, pinShadow, pinTimer, mapView;
- (void)dealloc {
	
	if (self.pinShadow) {
		self.pinShadow = nil;		
	}
	
	if (self.pinTimer) {
		[self.pinTimer invalidate];
		self.pinTimer = nil;		
	}
	
	[super dealloc];
}

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
		
	self.hasBuiltInDraggingSupport = [[MKAnnotationView class] instancesRespondToSelector:NSSelectorFromString(@"isDraggable")];

	if (self.hasBuiltInDraggingSupport) {
		if ((self = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier])) {
			[self performSelector:NSSelectorFromString(@"setDraggable:") withObject:[NSNumber numberWithBool:YES]];
		}
	} else {
		if ((self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier])) {
			self.image = [TexLegeMapPins imageForPinColorIndex:TexLegePinAnnotationColorBlue status:TexLegePinAnnotationStatusNormal];
			//self.image = [UIImage imageNamed:@"Pin.png"];
			self.centerOffset = CGPointMake(8, -14);
			self.calloutOffset = CGPointMake(-8, 0);
			
			self.pinShadow = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PinShadow.png"]] autorelease];
			self.pinShadow.frame = CGRectMake(0, 0, 32, 39);
			self.pinShadow.hidden = YES;
			[self addSubview:self.pinShadow];
		}
	}
		
	self.canShowCallout = YES;
	
	return self;
}

// NOTE: iOS 4 MapKit won't use the source code below, we return a draggable MKPinAnnotationView instance instead.

#pragma mark -
#pragma mark Core Animation class methods

+ (CAAnimation *)pinBounceAnimation_ {
	
	CAKeyframeAnimation *pinBounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
	
	NSMutableArray *values = [NSMutableArray array];

	[values addObject:(id)[TexLegeMapPins imageForPinColorIndex:TexLegePinAnnotationColorBlue status:TexLegePinAnnotationStatusDown1].CGImage];
	[values addObject:(id)[TexLegeMapPins imageForPinColorIndex:TexLegePinAnnotationColorBlue status:TexLegePinAnnotationStatusDown2].CGImage];
	[values addObject:(id)[TexLegeMapPins imageForPinColorIndex:TexLegePinAnnotationColorBlue status:TexLegePinAnnotationStatusDown3].CGImage];
	
	[pinBounceAnimation setValues:values];
	pinBounceAnimation.duration = 0.1;
	
	return pinBounceAnimation;
}

+ (CAAnimation *)pinFloatingAnimation_ {
	
	CAKeyframeAnimation *pinFloatingAnimation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
	
	[pinFloatingAnimation setValues:[NSArray arrayWithObject:(id)[TexLegeMapPins imageForPinColorIndex:TexLegePinAnnotationColorBlue status:TexLegePinAnnotationStatusFloating].CGImage]];
	pinFloatingAnimation.duration = 0.2;
	
	return pinFloatingAnimation;
}

+ (CAAnimation *)pinLiftAnimation_ {
	
	CABasicAnimation *liftAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
	
	liftAnimation.byValue = [NSValue valueWithCGPoint:CGPointMake(0.0, -39.0)];	
	liftAnimation.duration = 0.2;
	
	return liftAnimation;
}

+ (CAAnimation *)liftForDraggingAnimation_ {
	
	CAAnimation *pinBounceAnimation = [DDAnnotationView pinBounceAnimation_];	
	CAAnimation *pinFloatingAnimation = [DDAnnotationView pinFloatingAnimation_];
	pinFloatingAnimation.beginTime = pinBounceAnimation.duration;
	CAAnimation *pinLiftAnimation = [DDAnnotationView pinLiftAnimation_];	
	pinLiftAnimation.beginTime = pinBounceAnimation.duration;
	
	CAAnimationGroup *group = [CAAnimationGroup animation];
	group.animations = [NSArray arrayWithObjects:pinBounceAnimation, pinFloatingAnimation, pinLiftAnimation, nil];
	group.duration = pinBounceAnimation.duration + pinFloatingAnimation.duration;
	group.fillMode = kCAFillModeForwards;
	group.removedOnCompletion = NO;
	
	return group;
}

+ (CAAnimation *)liftAndDropAnimation_ {
	
	CAAnimation *pinLiftAndDropAnimation = [DDAnnotationView pinLiftAnimation_];
	CAAnimation *pinFloatingAnimation = [DDAnnotationView pinFloatingAnimation_];
	CAAnimation *pinBounceAnimation = [DDAnnotationView pinBounceAnimation_];
	pinBounceAnimation.beginTime = pinFloatingAnimation.duration;
	
	CAAnimationGroup *group = [CAAnimationGroup animation];
	group.animations = [NSArray arrayWithObjects:pinLiftAndDropAnimation, pinFloatingAnimation, pinBounceAnimation, nil];
	group.duration = pinFloatingAnimation.duration + pinBounceAnimation.duration;	
	
	return group;	
}

#pragma mark -
#pragma mark UIView animation delegates

- (void)shadowLiftWillStart_:(NSString *)animationID context:(void *)context {
	self.pinShadow.hidden = NO;
}

- (void)shadowDropDidStop_:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	self.pinShadow.hidden = YES;
}

#pragma mark NSTimer fire method

- (void)resetPinPosition_:(NSTimer *)timer {
    
    [self.pinTimer invalidate];
    self.pinTimer = nil;
    
    [self.layer addAnimation:[DDAnnotationView liftAndDropAnimation_] forKey:@"DDPinAnimation"];		
    
    // TODO: animation out-of-sync with self.layer
    [UIView beginAnimations:@"DDShadowLiftDropAnimation" context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(shadowDropDidStop_:context:)];
    [UIView setAnimationDuration:0.1];
    self.pinShadow.center = CGPointMake(90, -30);
    self.pinShadow.center = CGPointMake(16.0, 19.5);
    self.pinShadow.alpha = 0;
    [UIView commitAnimations];		
    
    // Update the map coordinate to reflect the new position.
    CGPoint newCenter;
    newCenter.x = self.center.x - self.centerOffset.x;
    newCenter.y = self.center.y - self.centerOffset.y - self.image.size.height + 4.;
    
    DDAnnotation *theAnnotation = (DDAnnotation *)self.annotation;
    CLLocationCoordinate2D newCoordinate = [self.mapView convertPoint:newCenter toCoordinateFromView:self.superview];
    [theAnnotation setCoordinate:newCoordinate];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DDAnnotationCoordinateDidChangeNotification" object:theAnnotation];
    
    // Clean up the state information.
    self.startLocation = CGPointZero;
    self.originalCenter = CGPointZero;
    self.isMoving = NO;
}

#pragma mark -
#pragma mark Handling events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if (self.mapView) {
		[self.layer removeAllAnimations];
		
		[self.layer addAnimation:[DDAnnotationView liftForDraggingAnimation_] forKey:@"DDPinAnimation"];
		
		[UIView beginAnimations:@"DDShadowLiftAnimation" context:NULL];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationWillStartSelector:@selector(shadowLiftWillStart_:context:)];
		[UIView setAnimationDuration:0.2];
		self.pinShadow.center = CGPointMake(80, -20);
		self.pinShadow.alpha = 1;
		[UIView commitAnimations];
	}
	
	// The view is configured for single touches only.
	self.startLocation = [[touches anyObject] locationInView:[self superview]];
	self.originalCenter = self.center;		
	
    [super touchesBegan:touches withEvent:event];	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	CGPoint newLocation = [[touches anyObject] locationInView:[self superview]];
	CGPoint newCenter;
	
	// If the user's finger moved more than 5 pixels, begin the drag.
	if ((abs(newLocation.x - self.startLocation.x) > 5.0) || (abs(newLocation.y - self.startLocation.y) > 5.0)) {
		self.isMoving = YES;
	}
	
	// If dragging has begun, adjust the position of the view.
	if (self.mapView && self.isMoving) {
		
		newCenter.x = self.originalCenter.x + (newLocation.x - self.startLocation.x);
		newCenter.y = self.originalCenter.y + (newLocation.y - self.startLocation.y);
		
		self.center = newCenter;
		
		[self.pinTimer invalidate];
		self.pinTimer = nil;
		self.pinTimer = [NSTimer timerWithTimeInterval:0.3 target:self selector:@selector(resetPinPosition_:) userInfo:nil repeats:NO];
		[[NSRunLoop currentRunLoop] addTimer:self.pinTimer forMode:NSDefaultRunLoopMode];        
	} else {
		// Let the parent class handle it.
		[super touchesMoved:touches withEvent:event];		
	}			
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if (self.mapView) {
		if (self.isMoving) {
			[self.pinTimer invalidate];
			self.pinTimer = nil;
			
			[self.layer addAnimation:[DDAnnotationView liftAndDropAnimation_] forKey:@"DDPinAnimation"];		
			
			// TODO: animation out-of-sync with self.layer
			[UIView beginAnimations:@"DDShadowLiftDropAnimation" context:NULL];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(shadowDropDidStop_:finished:context:)];
			[UIView setAnimationDuration:0.1];
			self.pinShadow.center = CGPointMake(90, -30);
			self.pinShadow.center = CGPointMake(16.0, 19.5);
			self.pinShadow.alpha = 0;
			[UIView commitAnimations];		
			
			// Update the map coordinate to reflect the new position.
			CGPoint newCenter;
			newCenter.x = self.center.x - self.centerOffset.x;
			newCenter.y = self.center.y - self.centerOffset.y - self.image.size.height + 4.;
			
			DDAnnotation* theAnnotation = (DDAnnotation *)self.annotation;
			CLLocationCoordinate2D newCoordinate = [self.mapView convertPoint:newCenter toCoordinateFromView:self.superview];
			
			[theAnnotation setCoordinate:newCoordinate];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"DDAnnotationCoordinateDidChangeNotification" object:theAnnotation];
			
			// Clean up the state information.
			self.startLocation = CGPointZero;
			self.originalCenter = CGPointZero;
			self.isMoving = NO;
		} else {
			
			// TODO: Currently no drop down effect but pin bounce only 
			[self.layer addAnimation:[DDAnnotationView pinBounceAnimation_] forKey:@"DDPinAnimation"];
			
			// TODO: animation out-of-sync with self.layer
			[UIView beginAnimations:@"DDShadowDropAnimation" context:NULL];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(shadowDropDidStop_:finished:context:)];
			[UIView setAnimationDuration:0.2];
			self.pinShadow.center = CGPointMake(16.0, 19.5);
			self.pinShadow.alpha = 0;
			[UIView commitAnimations];		
		}		
	} else {
		[super touchesEnded:touches withEvent:event];
	}	
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if (self.mapView) {
		// TODO: Currently no drop down effect but pin bounce only 
		[self.layer addAnimation:[DDAnnotationView pinBounceAnimation_] forKey:@"DDPinAnimation"];
		
		// TODO: animation out-of-sync with self.layer
		[UIView beginAnimations:@"DDShadowDropAnimation" context:NULL];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(shadowDropDidStop_:finished:context:)];
		[UIView setAnimationDuration:0.2];
		self.pinShadow.center = CGPointMake(16.0, 19.5);
		self.pinShadow.alpha = 0;
		[UIView commitAnimations];		
		
		if (self.isMoving) {
			[self.pinTimer invalidate];
			self.pinTimer = nil;
			
			// Move the view back to its starting point.
			self.center = self.originalCenter;
			
			// Clean up the state information.
			self.startLocation = CGPointZero;
			self.originalCenter = CGPointZero;
			self.isMoving = NO;			
		}		
	} else {
		[super touchesCancelled:touches withEvent:event];		
	}
}

@end
