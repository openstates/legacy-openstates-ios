//
//  MapViewController.m
//
//  Created by Gregory Combs on 8/16/10.
//  Copyright 2010 University of Texas at Dallas. All rights reserved.
//

#import "MapViewController.h"
#import "TexLegeTheme.h"
#import "UtilityMethods.h"

@implementation MapViewController
@synthesize bookmarksButton, mapTypeControl, mapView, userLocationButton, reverseGeocoder;
@synthesize toolbar;

#pragma mark -
#pragma mark Initialization and Memory Management

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		[self.view setBackgroundColor:[TexLegeTheme backgroundLight]];
		self.mapView.showsUserLocation = NO;

		// Set up the map's region to frame the state of Texas.
		// Zoom = 6
		CLLocationCoordinate2D texasCenter = {31.709476f, -99.997559f};
		MKCoordinateSpan texasSpan = MKCoordinateSpanMake(10.f, 10.f);
		MKCoordinateRegion texasRegion = MKCoordinateRegionMake(texasCenter, texasSpan);
		self.mapView.region = texasRegion;
		self.toolbar.tintColor = [TexLegeTheme navbar];
		if ([UtilityMethods isIPadDevice])
			self.navigationItem.titleView = self.toolbar; 
		else
			self.navigationItem.titleView = self.mapTypeControl;

	}
	return self;
}

- (void) dealloc {
	self.bookmarksButton = nil;
	self.mapTypeControl = nil;
	self.mapView = nil;
	self.userLocationButton = nil;
	self.reverseGeocoder = nil;
	[super dealloc];
}

- (void) viewDidDisappear:(BOOL)animated {
	self.mapView.showsUserLocation = NO;
	[super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark Control Element Actions

- (IBAction)changeMapType:(id)sender {
	NSInteger index = self.mapTypeControl.selectedSegmentIndex;
	self.mapView.mapType = index;
}

- (IBAction)locateUser:(id)sender {
	if ([UtilityMethods locationServicesEnabled]) 
		self.mapView.showsUserLocation = YES;
}

#pragma mark -
#pragma mark Map View Delegate

- (IBAction)reverseGeocodeCurrentLocation
{
	if (!self.reverseGeocoder) {
		self.reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:self.mapView.userLocation.location.coordinate];
		self.reverseGeocoder.delegate = self;
		[self.reverseGeocoder start];
	}
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    debug_NSLog(@"MKReverseGeocoder has failed: %@", error);
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
	
	debug_NSLog(@"User's Location: %@", placemark.addressDictionary);
	[self.reverseGeocoder cancel];
	self.reverseGeocoder = nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	for (MKAnnotationView *aView in views) {
		if ([aView.annotation class] == [MKUserLocation class])
			//[aView isKindOfClass:NSClassFromString(@"MKUserLocationView")])
		{
			// we have received our current location, so start reverse geocoding the address
			[self reverseGeocodeCurrentLocation];
			
			if (!self.mapView.userLocationVisible){
				MKCoordinateSpan span = MKCoordinateSpanMake(2.f, 2.f);
				
				CLLocationCoordinate2D location=self.mapView.userLocation.coordinate;
				MKCoordinateRegion region = MKCoordinateRegionMake(location, span);

				[self.mapView setRegion:region animated:TRUE];
				//[self.mapView regionThatFits:region];
			}
			
			continue;
		}
	}
}


/*- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	if ([annotation class] == MKUserLocation.class) {
		return nil;
	}
	...
}
*/
#pragma mark -
#pragma mark Map Movement

/*
- (void)animateToWorld:(WorldCity *)worldCity
{    
    MKCoordinateRegion current = mapView.region;
    MKCoordinateRegion zoomOut = { { (current.center.latitude + worldCity.coordinate.latitude)/2.0 , (current.center.longitude + worldCity.coordinate.longitude)/2.0 }, {90, 90} };
    [self.mapView setRegion:zoomOut animated:YES];
}

- (void)animateToPlace:(WorldCity *)worldCity
{
    MKCoordinateRegion region;
    region.center = worldCity.coordinate;
    MKCoordinateSpan span = {0.4, 0.4};
    region.span = span;
    [self.mapView setRegion:region animated:YES];
}
*/

#pragma mark -
#pragma mark Orientation


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation { // Override to allow rotation. Default returns YES only for UIDeviceOrientationPortrait
	return YES;
}

@end
