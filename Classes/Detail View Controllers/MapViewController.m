//
//  MapViewController.m
//
//  Created by Gregory Combs on 8/16/10.
//  Copyright 2010 University of Texas at Dallas. All rights reserved.
//

#import "MapViewController.h"
#import "TexLegeTheme.h"
#import "UtilityMethods.h"
#import "LegislatorObj.h"
#import "LegislatorDetailViewController.h"

@implementation MapViewController
@synthesize bookmarksButton, mapTypeControl, mapView, userLocationButton, reverseGeocoder;
@synthesize toolbar, searchBar, forwardGeocoder, addressString, legislator, texasRegion;

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
	self.legislator = nil;
	[super dealloc];
}

- (void) viewWillAppear:(BOOL)animated {
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

- (void)setAddressString:(NSString *)string withLegislator:(LegislatorObj *)newLegislator {
	if (string && newLegislator) {
		self.legislator = newLegislator;

		self.addressString = string;
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
		int searchResults = [forwardGeocoder.results count];
		
		// Add placemarks for each result
		for(int i = 0; i < searchResults; i++)
		{
			BSKmlResult *place = [forwardGeocoder.results objectAtIndex:i];
			
			// Add a placemark on the map
			DistrictOfficeAnnotation *placemark = [[[DistrictOfficeAnnotation alloc] initWithBSKmlResult:place] autorelease];
			if (self.legislator) {
				placemark.legislator = self.legislator;
				self.legislator = nil;
			}
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

- (void)showDetails:(id)sender
{
    // the detail view does not want a toolbar so hide it
    //[self.navigationController setToolbarHidden:YES animated:NO];
    
   //[self.navigationController pushViewController:self.detailViewController animated:YES];
	LegislatorDetailViewController *legVC = [[LegislatorDetailViewController alloc] initWithNibName:@"LegislatorDetailViewController" bundle:nil];
	legVC.legislator = self.legislator;
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

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // handle our custom annotations
    //
    if ([annotation isKindOfClass:[DistrictOfficeAnnotation class]]) // for Golden Gate Bridge
    {
		DistrictOfficeAnnotation *districtOffice = (DistrictOfficeAnnotation *)annotation;
		
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
            
            // add a detail disclosure button to the callout which will open a new view controller page
            //
            // note: you can assign a specific call out accessory view, or as MKMapViewDelegate you can implement:
            //  - (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;
            //
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:self
                            action:@selector(showDetails:)
                  forControlEvents:UIControlEventTouchUpInside];
            customPinView.rightCalloutAccessoryView = rightButton;
			
			UIImageView *photoView = [[UIImageView alloc] initWithImage:[districtOffice image]];
			/*CGRect bounds = customPinView.bounds;
			bounds.size.height = photoView.bounds.size.height;
			
			customPinView.bounds = bounds;*/
            customPinView.leftCalloutAccessoryView = photoView;
            [photoView release];
			
            return customPinView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    }
/*  
	if ([annotation isKindOfClass:[CustomPlacemark class]])   // for City of San Francisco
    {
        static NSString* legislatorAnnotationIdentifier = @"legislatorAnnotationIdentifier";
        MKPinAnnotationView* pinView =
		(MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:legislatorAnnotationIdentifier];
        if (!pinView)
        {
            MKAnnotationView *annotationView = [[[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                             reuseIdentifier:legislatorAnnotationIdentifier] autorelease];
            annotationView.canShowCallout = YES;
			
            UIImage *flagImage = [UIImage imageNamed:@"72-pin.png"];
            
            CGRect resizeRect;
            
            resizeRect.size = flagImage.size;
            CGSize maxSize = CGRectInset(self.view.bounds,
                                         [MapViewController annotationPadding],
                                         [MapViewController annotationPadding]).size;
            maxSize.height -= self.navigationController.navigationBar.frame.size.height + [MapViewController calloutHeight];
            if (resizeRect.size.width > maxSize.width)
                resizeRect.size = CGSizeMake(maxSize.width, resizeRect.size.height / resizeRect.size.width * maxSize.width);
            if (resizeRect.size.height > maxSize.height)
                resizeRect.size = CGSizeMake(resizeRect.size.width / resizeRect.size.height * maxSize.height, maxSize.height);
            
            resizeRect.origin = (CGPoint){0.0f, 0.0f};
            UIGraphicsBeginImageContext(resizeRect.size);
            [flagImage drawInRect:resizeRect];
            UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            annotationView.image = resizedImage;
			
            annotationView.opaque = NO;
			
            UIImageView *sfIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"anchia.png"]];
            annotationView.leftCalloutAccessoryView = sfIconView;
            [sfIconView release];
            
            return annotationView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    }
 */  
    return nil;
}
/*

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context{
	
	NSString *action = (NSString*)context;
	
	
	if([action isEqualToString:@"GMAP_ANNOTATION_SELECTED"]) 
	{
		if([((MKAnnotationView*) object).annotation isKindOfClass:[CustomPlacemark class]])
		{
			CustomPlacemark *place = ((MKAnnotationView*) object).annotation;
			
			// Zoom into the location		
			[mapView setRegion:place.coordinateRegion animated:TRUE];
			debug_NSLog(@"annotation selected %f, %f", ((MKAnnotationView*) object).annotation.coordinate.latitude, ((MKAnnotationView*) object).annotation.coordinate.longitude);
		}
	}
}


*/

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
