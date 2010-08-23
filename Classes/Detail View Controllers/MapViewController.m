//
//  MapViewController.m
//
//  Created by Gregory Combs on 8/16/10.
//  Copyright 2010 University of Texas at Dallas. All rights reserved.
//

#import "MapViewController.h"
#import "TexLegeTheme.h"
#import "UtilityMethods.h"
#import "LegislatorDetailViewController.h"
#import "DistrictOfficeObj.h"
#import "CustomAnnotation.h"

@implementation MapViewController
@synthesize bookmarksButton, mapTypeControl, mapView, userLocationButton, reverseGeocoder;
@synthesize toolbar, searchBar, forwardGeocoder, addressString, texasRegion;

#pragma mark -
#pragma mark Initialization and Memory Management

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		[self.view setBackgroundColor:[TexLegeTheme backgroundLight]];
		self.mapView.showsUserLocation = NO;

		// Set up the map's region to frame the state of Texas.
		// Zoom = 6
		self.mapView.region = self.texasRegion;
		
		self.toolbar.tintColor = [TexLegeTheme navbar];
		if ([UtilityMethods isIPadDevice])
			self.navigationItem.titleView = self.toolbar; 
		else
			self.navigationItem.titleView = self.searchBar;
			//self.navigationItem.titleView = self.mapTypeControl;

	}
	return self;
}

- (void) dealloc {
	self.bookmarksButton = nil;
	self.mapTypeControl = nil;
	self.mapView = nil;
	self.userLocationButton = nil;
	self.reverseGeocoder = nil;
	self.forwardGeocoder = nil;
	self.searchBar = nil;
	self.addressString = nil;
	[super dealloc];
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	NSURL *tempURL = [NSURL URLWithString:@"http://maps.google.com"];
	//if (![UtilityMethods isNetworkReachable])
	//		[UtilityMethods noInternetAlert];
		
	if (![UtilityMethods canReachHostWithURL:tempURL])// do we have a good URL/connection?
		return;
	
}

- (void) viewDidDisappear:(BOOL)animated {
	self.mapView.showsUserLocation = NO;
	[super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark Properties

- (MKCoordinateRegion) texasRegion {
	// Set up the map's region to frame the state of Texas.
	// Zoom = 6	
	static CLLocationCoordinate2D texasCenter = {31.709476f, -99.997559f};
	static MKCoordinateSpan texasSpan = {10.f, 10.f};
	const MKCoordinateRegion txreg = MKCoordinateRegionMake(texasCenter, texasSpan);
	return txreg;
}

- (void)setAddressString:(NSString *)string {
	if (string && ![string isEqualToString:addressString]) {
		[addressString release];
		addressString = [string copy];
				
		//[self.mapView removeAnnotations:self.mapView.annotations];  // remove any annotations that exist
		
		debug_NSLog(@"Searching for: %@", addressString);
		if(!forwardGeocoder)
			forwardGeocoder = [[BSForwardGeocoder alloc] initWithDelegate:self];
		
		// Forward geocode!
		[forwardGeocoder findLocation:string];
		
	}
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
#pragma mark Geocoding and Reverse Geocoding

- (IBAction)reverseGeocodeCurrentLocation
{
	if (!self.reverseGeocoder) {
		self.reverseGeocoder = [[MKReverseGeocoder alloc] initWithCoordinate:self.mapView.userLocation.location.coordinate];
		self.reverseGeocoder.delegate = self;
		[self.reverseGeocoder start];
	}
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
	
	debug_NSLog(@"User's Location: %@", placemark.addressDictionary);
	[self.reverseGeocoder cancel];
	self.reverseGeocoder = nil;
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    debug_NSLog(@"MKReverseGeocoder has failed: %@", error);
}


-(void)forwardGeocoderFoundLocation
{
	
	id<MKAnnotation> lastAnnotation = [[mapView annotations] lastObject];	
	
	if(forwardGeocoder.status == G_GEO_SUCCESS)
	{
		NSInteger searchResults = [forwardGeocoder.results count];
		
		// Add placemarks for each result
		for(NSInteger i = 0; i < searchResults; i++)
		{
			BSKmlResult *place = [forwardGeocoder.results objectAtIndex:i];
			
			// Add a placemark on the map
			CustomAnnotation *placemark = [[[CustomAnnotation alloc] initWithBSKmlResult:place] autorelease];
			[mapView addAnnotation:placemark];	
		}
		
		if([forwardGeocoder.results count] >= 1)
		{
			BSKmlResult *place = [forwardGeocoder.results objectAtIndex:0];
			
			// Zoom into the location		
			//[mapView setRegion:place.coordinateRegion animated:TRUE];
			
			if (lastAnnotation) { // we've already got one annotation set, let's zoom in/out
				[self performSelector:@selector(animateToState:) withObject:lastAnnotation afterDelay:0.3];
				[self performSelector:@selector(animateToAnnotation:) withObject:place afterDelay:1.7];        
			}
			else
				[self performSelector:@selector(animateToAnnotation:) withObject:place afterDelay:0.3];
			
		}
		
		// Dismiss the keyboard
		[searchBar resignFirstResponder];
	}
	else {
		NSString *message = @"";
		
		switch (forwardGeocoder.status) {
			case G_GEO_BAD_KEY:
				message = @"The API key is invalid.";
				break;
				
			case G_GEO_UNKNOWN_ADDRESS:
				message = [NSString stringWithFormat:@"Could not find %@", forwardGeocoder.searchQuery];
				break;
				
			case G_GEO_TOO_MANY_QUERIES:
				message = @"Too many queries has been made for this API key.";
				break;
				
			case G_GEO_SERVER_ERROR:
				message = @"Server error, please try again.";
				break;
				
				
			default:
				break;
		}
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information" 
														message:message
													   delegate:nil 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles: nil];
		[alert show];
		[alert release];
	}
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	
	//[self.mapView removeAnnotations:self.mapView.annotations];  // remove any annotations that exist
	
	
	debug_NSLog(@"Searching for: %@", searchBar.text);
	if(forwardGeocoder == nil)
	{
		forwardGeocoder = [[BSForwardGeocoder alloc] initWithDelegate:self];
	}
	
	// Forward geocode!
	[forwardGeocoder findLocation:searchBar.text];
	
}

-(void)forwardGeocoderError:(NSString *)errorMessage
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" 
													message:errorMessage
												   delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles: nil];
	[alert show];
	[alert release];
	
}

#pragma mark -
#pragma mark Map View Delegate


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
				//debug_NSLog(@"[Found user location] %f %f %f %f", location.latitude, location.longitude, span.latitudeDelta, span.longitudeDelta);

			}
			
			return;
		}
	}
	
	MKAnnotationView *lastView = [views lastObject];
	id<MKAnnotation> lastAnnotation = lastView.annotation;
	MKCoordinateRegion region;
	
	if (lastAnnotation) {
		if ([lastAnnotation isKindOfClass:[DistrictOfficeObj class]]) {
			DistrictOfficeObj *obj = lastAnnotation;
			region = [obj region];
			[self.mapView setRegion:region animated:TRUE];
		}
		else if ([lastAnnotation isKindOfClass:[CustomAnnotation class]]) {
			CustomAnnotation *obj = lastAnnotation;
			region = [obj region];
			[self.mapView setRegion:region animated:TRUE];
		}
		else {
			MKCoordinateSpan span = {2.f,2.f};
			
			MKCoordinateRegion region = MKCoordinateRegionMake(lastAnnotation.coordinate, span);
			[self.mapView setRegion:region animated:TRUE];
		}

		[self.mapView selectAnnotation:lastAnnotation animated:YES];
	}
	
}


/*- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	if ([annotation class] == MKUserLocation.class) {
		return nil;
	}
	...
}
*/


/*
- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
	
	if([annotation isKindOfClass:[CustomPlacemark class]])
	{
		MKPinAnnotationView *newAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:[annotation title]];
		newAnnotation.pinColor = MKPinAnnotationColorPurple;
		newAnnotation.animatesDrop = YES; 
		newAnnotation.canShowCallout = YES;
		newAnnotation.enabled = YES;
		
		
		debug_NSLog(@"Created annotation at: %f", ((CustomPlacemark*)annotation).coordinate.latitude);
		
		[newAnnotation addObserver:self
						forKeyPath:@"selected"
						   options:NSKeyValueObservingOptionNew
						   context:@"GMAP_ANNOTATION_SELECTED"];
		
		[newAnnotation autorelease];
		
		return newAnnotation;
	}
	
	return nil;
}
*/
#pragma mark -
#pragma mark MKMapViewDelegate

- (void)showLegislatorDetails:(LegislatorObj *)legislator
{
    // the detail view does not want a toolbar so hide it
    //[self.navigationController setToolbarHidden:YES animated:NO];
    
   //[self.navigationController pushViewController:self.detailViewController animated:YES];
	
	if (!legislator)
		return;

	LegislatorDetailViewController *legVC = [[LegislatorDetailViewController alloc] initWithNibName:@"LegislatorDetailViewController" bundle:nil];
	legVC.legislator = legislator;
	[self.navigationController pushViewController:legVC animated:YES];
	[legVC release];
}

+ (CGFloat)annotationPadding;
{
    return 10.0f;
}
+ (CGFloat)calloutHeight;
{
    return 80.0f;
}

- (void) mapViewDidFinishLoadingMap:(MKMapView *)theMapView {
	id<MKAnnotation> lastAnnotation = [[mapView annotations] lastObject];
	
	if (lastAnnotation)
		[mapView selectAnnotation:lastAnnotation animated:YES];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	id <MKAnnotation> annotation = view.annotation;
	
	if ([annotation isKindOfClass:[DistrictOfficeObj class]]) // for Golden Gate Bridge
    {
		DistrictOfficeObj *districtOffice = (DistrictOfficeObj *)annotation;
		
		if (districtOffice && districtOffice.legislator)
			[self showLegislatorDetails:districtOffice.legislator];
	}		
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // handle our custom annotations
    //
    if ([annotation isKindOfClass:[DistrictOfficeObj class]]) // for Golden Gate Bridge
    {
		DistrictOfficeObj *districtOffice = (DistrictOfficeObj *)annotation;
		
        // try to dequeue an existing pin view first
        static NSString* districtOfficeAnnotationID = @"districtOfficeAnnotationID";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)
		[mapView dequeueReusableAnnotationViewWithIdentifier:districtOfficeAnnotationID];
        if (!pinView)
        {
            // if an existing pin view was not available, create one
            MKPinAnnotationView* customPinView = [[[MKPinAnnotationView alloc]
												   initWithAnnotation:annotation reuseIdentifier:districtOfficeAnnotationID] autorelease];
            customPinView.pinColor = [[districtOffice pinColorIndex] integerValue];
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;
            
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            //[rightButton addTarget:self action:@selector(showLegislatorDetails:) forControlEvents:UIControlEventTouchUpInside];
			
            customPinView.rightCalloutAccessoryView = rightButton;
			
			UIImageView *iconView = [[UIImageView alloc] initWithImage:[districtOffice image]];
            customPinView.leftCalloutAccessoryView = iconView;
            [iconView release];
			
            return customPinView;
        }
        else
        {
            pinView.annotation = annotation;
        }		
		
		[pinView addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:@"GMAP_ANNOTATION_SELECTED"];
		
        return pinView;
    }
  
	if ([annotation isKindOfClass:[CustomAnnotation class]])  
    {
		CustomAnnotation *customAnotation = (CustomAnnotation *)annotation;

        static NSString* customAnnotationIdentifier = @"customAnnotationIdentifier";
        MKPinAnnotationView* pinView =
		(MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:customAnnotationIdentifier];
        if (!pinView)
        {
            MKPinAnnotationView *annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                                             reuseIdentifier:customAnnotationIdentifier] autorelease];
            annotationView.canShowCallout = YES;
            annotationView.pinColor = [[customAnotation pinColorIndex] integerValue];
            annotationView.opaque = NO;
			
			UIImageView *iconView = [[UIImageView alloc] initWithImage:[customAnotation image]];
            annotationView.leftCalloutAccessoryView = iconView;
            [iconView release];
            
            return annotationView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    }
   
    return nil;
}


- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context{
	
	NSString *action = (NSString*)context;
	
	debug_NSLog(@"something");
	if([action isEqualToString:@"GMAP_ANNOTATION_SELECTED"]) 
	{				
		if ([object respondsToSelector:@selector(annotation)]) {
			id<MKAnnotation> annotation = [object performSelector:@selector(annotation)];
			if (!annotation)
				return;
			
			MKCoordinateRegion region;
			if ([annotation isKindOfClass:[DistrictOfficeObj class]]) {
				DistrictOfficeObj *obj = annotation;
				region = [obj region];
			}
			else if ([annotation isKindOfClass:[CustomAnnotation class]]) {
				CustomAnnotation *obj = annotation;
				region = [obj region];
			}
			else {
				MKCoordinateSpan span = {2.f,2.f};
				region = MKCoordinateRegionMake(annotation.coordinate, span);
			}
			[self.mapView setRegion:region animated:TRUE];

			debug_NSLog(@"annotation selected %f, %f", annotation.coordinate.latitude, annotation.coordinate.longitude);
		}
	}
}




#pragma mark -
#pragma mark Map Movement


- (void)animateToState:(id<MKAnnotation>)annotation
{    
    [self.mapView setRegion:self.texasRegion animated:YES];
}

- (void)animateToAnnotation:(id<MKAnnotation>)annotation
{
    MKCoordinateRegion region;
    region.center = annotation.coordinate;
    MKCoordinateSpan span = {0.4, 0.4};
    region.span = span;
    [self.mapView setRegion:region animated:YES];
	
	if (annotation)		// GREG, does this even work here?
		[mapView selectAnnotation:annotation animated:YES];
	
}


#pragma mark -
#pragma mark Orientation


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation { // Override to allow rotation. Default returns YES only for UIDeviceOrientationPortrait
	return YES;
}

@end
