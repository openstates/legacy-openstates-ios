//
//  MapMiniDetailViewController.m
//
//  Created by Gregory Combs on 8/16/10.
//  Copyright 2010 University of Texas at Dallas. All rights reserved.
//

#import "MapMiniDetailViewController.h"
#import "TexLegeTheme.h"
#import "UtilityMethods.h"
#import "DistrictOfficeObj.h"
#import "DistrictMapObj.h"

#import "CustomAnnotation.h"
#import "CustomAnnotationView.h"

#import "TexLegeAppDelegate.h"
#import "TexLegeCoreDataUtils.h"

#import "LocalyticsSession.h"
#import "UIColor-Expanded.h"

#import "TexLegeMapPins.h"
#import "TexLegePinAnnotationView.h"
#import "MKPinAnnotationView+ZIndexFix.h"


@interface MapMiniDetailViewController (Private)
- (void) animateToState;
- (void) animateToAnnotation:(id<MKAnnotation>)annotation;
- (void) clearAnnotationsAndOverlays;
- (void) clearOverlaysExceptRecent;
- (void) clearAnnotationsExceptRecent;	
- (void) clearAnnotationsAndOverlaysExcept:(id)annotation;
- (void) resetMapViewWithAnimation:(BOOL)animated;
- (BOOL) region:(MKCoordinateRegion)region1 isEqualTo:(MKCoordinateRegion)region2;
- (IBAction) showHidePopoverButton:(id)sender;
- (void) invalidateDistrictView;
@end

NSInteger colorIndex;
static MKCoordinateSpan kStandardZoomSpan = {2.f, 2.f};


@implementation MapMiniDetailViewController
@synthesize mapTypeControl, mapTypeControlButton;
@synthesize mapView, reverseGeocoder, searchLocation;
@synthesize toolbar, searchBar, searchBarButton;
@synthesize forwardGeocoder, texasRegion;
@synthesize districtView;

#pragma mark -
#pragma mark Initialization and Memory Management

- (NSString *)nibName {
	if ([UtilityMethods isIPadDevice])
		return @"MapMiniDetailViewController~ipad";
	else
		return @"MapMiniDetailViewController~iphone";
}

/*- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
	
		[self view]; // why do we have to cheat it like this? shouldn't the view load automatically from the nib?
	}
	return self;
}
*/

- (void) invalidateDistrictView {
	if (self.districtView) {
		[self.districtView invalidatePath];
		self.districtView = nil;
	}
}

- (void) dealloc {
	[self invalidateDistrictView];
	[self.mapView removeOverlays:self.mapView.overlays];
	[self.mapView removeAnnotations:self.mapView.annotations];

	self.mapTypeControl = nil;
	self.searchBarButton = nil;
	self.mapTypeControlButton = nil;
	self.mapView = nil;
	//self.mapControlsButton = nil;
	[self.reverseGeocoder cancel];
	self.reverseGeocoder = nil;
	self.forwardGeocoder = nil;
	self.searchBar = nil;
	self.searchLocation = nil;
	[super dealloc];
}

- (void) didReceiveMemoryWarning {	
	self.forwardGeocoder = nil;
	[self.reverseGeocoder cancel];
	self.reverseGeocoder = nil;

	//[self clearAnnotationsAndOverlaysExceptRecent];
	[self clearOverlaysExceptRecent];

	[super didReceiveMemoryWarning];
}

- (void) viewDidLoad {
	[super viewDidLoad];
	
	colorIndex = 0;
	if (![UtilityMethods isIPadDevice])
		self.hidesBottomBarWhenPushed = YES;
	
	[self.view setBackgroundColor:[TexLegeTheme backgroundLight]];
	self.mapView.showsUserLocation = NO;
	
	// Set up the map's region to frame the state of Texas.
	// Zoom = 6
	self.mapView.region = self.texasRegion;
	
	self.navigationController.navigationBar.tintColor = [TexLegeTheme navbar];
	self.toolbar.tintColor = [TexLegeTheme navbar];
	self.searchBar.tintColor = [TexLegeTheme navbar];
	if ([UtilityMethods isIPadDevice]) {
		self.navigationItem.titleView = self.toolbar; 
	}
	else {
		self.navigationItem.titleView = self.searchBar;
	}
	
	if (![UtilityMethods supportsMKPolyline])
		[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"__NO_MKPOLYLINE!__"];
	
}

- (void) viewDidUnload {
	[self invalidateDistrictView];
	[self.mapView removeOverlays:self.mapView.overlays];
	[self.mapView removeAnnotations:self.mapView.annotations];

	self.mapView = nil;
	self.reverseGeocoder = nil;
	self.forwardGeocoder = nil;
	self.searchLocation = nil;
	[super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	NSURL *tempURL = [NSURL URLWithString:@"http://maps.google.com"];		
	if (![UtilityMethods canReachHostWithURL:tempURL])// do we have a good URL/connection?
		return;
	
}

/*
 - (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];	
}
 */

- (void) viewDidDisappear:(BOOL)animated {
	self.mapView.showsUserLocation = NO;
		
	//if (![self isEqual:[self.navigationController.viewControllers objectAtIndex:0]])
	[self invalidateDistrictView];
	[self.mapView removeOverlays:self.mapView.overlays];
	
	[super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark Animation and Zoom


- (void) clearAnnotationsAndOverlays {
	self.mapView.showsUserLocation = NO;
	[self invalidateDistrictView];
	[self.mapView removeOverlays:self.mapView.overlays];
	[self.mapView removeAnnotations:self.mapView.annotations];
}


- (void) clearAnnotationsAndOverlaysExcept:(id)keep {
	self.mapView.showsUserLocation = NO;	
	
	NSMutableArray *annotes = [[NSMutableArray alloc] initWithCapacity:[self.mapView.annotations count]];
	for (id object in self.mapView.annotations) {
		if (![object isEqual:keep])
			[annotes addObject:object];
	}
	if (annotes && [annotes count]) {
		[self invalidateDistrictView];
		[self.mapView removeOverlays:self.mapView.overlays];
		[self.mapView removeAnnotations:annotes];
	}
	[annotes release];
}

- (void) clearOverlaysExceptRecent {
	self.mapView.showsUserLocation = NO;
	
	NSMutableArray *toRemove = [[NSMutableArray alloc] init];
	if (toRemove) {
		[toRemove setArray:self.mapView.overlays];
		if ([toRemove count]>1) {
			[toRemove removeLastObject];
			BOOL dropMe = NO;
			for (id <MKOverlay>overlay in toRemove) {
				if (self.districtView && [self.districtView.overlay isEqual:overlay])
					dropMe = YES;
				
			}
			if (dropMe)
				[self invalidateDistrictView];

			[self.mapView removeOverlays:toRemove];
		}
		[toRemove release];
	}
}

- (void) clearAnnotationsExceptRecent {	
	NSMutableArray *toRemove = [[NSMutableArray alloc] init];
	if (toRemove) {
		[toRemove setArray:self.mapView.annotations];
		if ([toRemove containsObject:self.mapView.userLocation])
			[toRemove removeObject:self.mapView.userLocation];
		
		if ([toRemove count]>2) {
			[toRemove removeLastObject];
			[toRemove removeLastObject];
		}
		
		[self.mapView removeAnnotations:toRemove];
		[toRemove release];
	}
}

//#warning This doesn't actually work great, because MapKit uses Z-Ordering of annotations and overlays!!!
- (void) clearAnnotationsAndOverlaysExceptRecent {
	
	[self clearOverlaysExceptRecent];
	[self clearAnnotationsExceptRecent];	
}


- (void) resetMapViewWithAnimation:(BOOL)animated {
	[self clearAnnotationsAndOverlays];
	if (animated)
		[self.mapView setRegion:self.texasRegion animated:YES];
	else
		[self.mapView setRegion:self.texasRegion animated:NO];
	
}

- (void)animateToState
{    
    [self.mapView setRegion:self.texasRegion animated:YES];
}

- (void)animateToAnnotation:(id<MKAnnotation>)annotation
{
	if (!annotation)
		return;
	
    MKCoordinateRegion region = MKCoordinateRegionMake(annotation.coordinate, kStandardZoomSpan);
    [self.mapView setRegion:region animated:YES];	
}

- (void)moveMapToAnnotation:(id<MKAnnotation>)annotation {	
	if (![self region:self.mapView.region isEqualTo:self.texasRegion]) { // it's another region, let's zoom out/in
		[self performSelector:@selector(animateToState) withObject:nil afterDelay:0.3];
		[self performSelector:@selector(animateToAnnotation:) withObject:annotation afterDelay:1.7];        
	}
	else
		[self performSelector:@selector(animateToAnnotation:) withObject:annotation afterDelay:0.7];	
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

- (BOOL) region:(MKCoordinateRegion)region1 isEqualTo:(MKCoordinateRegion)region2 {
	MKMapPoint coord1 = MKMapPointForCoordinate(region1.center);
	MKMapPoint coord2 = MKMapPointForCoordinate(region2.center);
	BOOL coordsEqual = MKMapPointEqualToPoint(coord1, coord2);
	
	BOOL spanEqual = region1.span.latitudeDelta == region2.span.latitudeDelta; // let's just only do one, okay?
	return (coordsEqual && spanEqual);
}

#pragma mark -
#pragma mark Control Element Actions

- (IBAction)changeMapType:(id)sender {
	NSInteger index = self.mapTypeControl.selectedSegmentIndex;
	self.mapView.mapType = index;
}

- (void)showLocateUserButton {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

	NSInteger buttonIndex = 0;
	
	UIBarButtonItem *locateItem = [[UIBarButtonItem alloc] 
								   initWithImage:[UIImage imageNamed:@"locationarrow.png"]
									style:UIBarButtonItemStyleBordered
									target:self
									action:@selector(locateUser:)];

	locateItem.tag = 999;
	
	NSMutableArray *items = [[NSMutableArray alloc] initWithArray:self.toolbar.items];

	UIBarButtonItem *otherButton = [items objectAtIndex:buttonIndex];
	if (otherButton.tag == 998 || otherButton.tag == 999)
		[items removeObjectAtIndex:buttonIndex];
	[items insertObject:locateItem atIndex:buttonIndex];
	[locateItem release];
	[self.toolbar setItems:items animated:YES];
	[items release];
}

- (void)showLocateActivityButton {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

	NSInteger buttonIndex = 0;

	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
	[activityIndicator startAnimating];
	UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	[activityIndicator release];
	activityItem.tag = 998;
	
	NSMutableArray *items = [[NSMutableArray alloc] initWithArray:self.toolbar.items];
	
	UIBarButtonItem *otherButton = [items objectAtIndex:buttonIndex];
	if (otherButton.tag == 999 || otherButton.tag == 998)
		[items removeObjectAtIndex:buttonIndex];
	[items insertObject:activityItem atIndex:buttonIndex];
	[activityItem release];
	[self.toolbar setItems:items animated:YES];
	[items release];
}

- (IBAction)locateUser:(id)sender {
	//[self clearAnnotationsAndOverlays];
	[self showLocateActivityButton];				// this gets changed in viewForAnnotation once we receive the location

	if ([UtilityMethods locationServicesEnabled]) 
		self.mapView.showsUserLocation = YES;
}


#pragma mark -
#pragma mark Geocoding and Reverse Geocoding

- (IBAction)reverseGeocodeLocation:(CLLocationCoordinate2D)coordinate
{
	if (!self.reverseGeocoder) {
		self.reverseGeocoder = [[[MKReverseGeocoder alloc] initWithCoordinate:coordinate] autorelease];
		self.reverseGeocoder.delegate = self;
		[self.reverseGeocoder start];
	}
}


- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
	[self.searchLocation setAddressDictWithPlacemark:placemark];
		
	if (self.reverseGeocoder) {
		[self.reverseGeocoder cancel];
		self.reverseGeocoder = nil;
	}
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    debug_NSLog(@"MKReverseGeocoder has failed: %@", error);
	if (self.reverseGeocoder) {
		[self.reverseGeocoder cancel];
		self.reverseGeocoder = nil;
	}	
}

-(void)forwardGeocoderFoundLocation
{
	[self showLocateUserButton];
	
	if(self.forwardGeocoder.status == G_GEO_SUCCESS)
	{
		[self clearAnnotationsExceptRecent];		
		
		NSInteger searchResults = [self.forwardGeocoder.results count];
		
		// Add placemarks for each result
		id<MKAnnotation> lastAnnotation = nil;
		
		for(NSInteger i = 0; i < searchResults; i++)
		{
			BSKmlResult *place = [self.forwardGeocoder.results objectAtIndex:i];
			
			// Add a placemark on the map
			CustomAnnotation *annotation = [[[CustomAnnotation alloc] initWithBSKmlResult:place] autorelease];
			
			if (![UtilityMethods iOSVersion4])
				annotation.coordinateChangedDelegate = self;
			
			[self.mapView addAnnotation:annotation];	
			
			lastAnnotation = annotation;
			
		}
		if (lastAnnotation) {
			[self moveMapToAnnotation:lastAnnotation];
		}
		// Dismiss the keyboard
		[self.searchBar resignFirstResponder];
	}
	else {
		NSString *message = @"";
		
		switch (forwardGeocoder.status) {
			case G_GEO_UNKNOWN_ADDRESS:
				message = [NSString stringWithFormat:@"Could not find %@", forwardGeocoder.searchQuery];
				break;
			case G_GEO_SERVER_ERROR:
			default:
				message = @"Map server error, please try again.";
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
	self.forwardGeocoder = nil;
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	[self showLocateActivityButton];

	if(self.forwardGeocoder == nil)
		self.forwardGeocoder = [[[BSForwardGeocoder alloc] initWithDelegate:self] autorelease];
	
	if(self.forwardGeocoder)
		[self.forwardGeocoder findLocation:theSearchBar.text];
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
	
	self.forwardGeocoder = nil;
	[self showLocateUserButton];

}

- (void)annotationCoordinateChanged:(id)sender {
	if (![sender isKindOfClass:[CustomAnnotation class]])
		return;
	
	if (!self.searchLocation || ![sender isEqual:self.searchLocation])
		self.searchLocation = sender;
	
	[self clearAnnotationsAndOverlaysExceptRecent];
	
	[self reverseGeocodeLocation:self.searchLocation.coordinate];
}

#pragma mark -
#pragma mark MapViewDelegate

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
	
	//if (oldState == MKAnnotationViewDragStateDragging)
	if (newState == MKAnnotationViewDragStateEnding)
	{
		if ([annotationView.annotation isEqual:self.searchLocation]) {
			if (self.searchLocation.coordinateChangedDelegate)
				self.searchLocation.coordinateChangedDelegate = nil;		// it'll handle it once, then we'll do it.
			else
				[self annotationCoordinateChanged:self.searchLocation];	
		}
	}
}


- (void)mapView:(MKMapView *)theMapView didAddAnnotationViews:(NSArray *)views
{
	for (MKAnnotationView *aView in views) {
		if ([aView.annotation class] == [MKUserLocation class])
		{						
			if (!theMapView.userLocationVisible)
				[self performSelector:@selector(moveMapToAnnotation:) withObject:aView.annotation afterDelay:.5f];
			
			[self showLocateUserButton];
			return;
		}
	}
}


- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    if ([annotation isKindOfClass:[DistrictOfficeObj class]] || [annotation isKindOfClass:[DistrictMapObj class]]) 
    {
        static NSString* districtAnnotationID = @"districtObjectAnnotationID";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:districtAnnotationID];
        if (!pinView)
        {
            TexLegePinAnnotationView* customPinView = [[[TexLegePinAnnotationView alloc]
												   initWithAnnotation:annotation reuseIdentifier:districtAnnotationID] autorelease];
			customPinView.rightCalloutAccessoryView = nil;
			
            return customPinView;
        }
        else
        {
            pinView.annotation = annotation;
			if ([pinView respondsToSelector:@selector(resetPinColorWithAnnotation:)])
				[pinView performSelector:@selector(resetPinColorWithAnnotation:) withObject:annotation];
			
			pinView.rightCalloutAccessoryView = nil;
        }		

        return pinView;
    }
	
	if ([annotation isKindOfClass:[CustomAnnotation class]])  
    {
        static NSString* customAnnotationIdentifier = @"customAnnotationIdentifier";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:customAnnotationIdentifier];
        if (!pinView)
        {
            CustomAnnotationView *customPinView = [[[CustomAnnotationView alloc] initWithAnnotation:annotation
                                                                             reuseIdentifier:customAnnotationIdentifier] autorelease];
            customPinView.rightCalloutAccessoryView = nil;
            return customPinView;
        }
        else
        {
            pinView.annotation = annotation;
			pinView.rightCalloutAccessoryView = nil;
        }
        return pinView;
    }
    return nil;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay{
	NSArray *colors = [[UIColor randomColor] triadicColors];
	UIColor *myColor = [[colors objectAtIndex:colorIndex] colorByDarkeningTo:0.50f];
	colorIndex++;
	if (colorIndex > 1)
		colorIndex = 0;
	
	if ([overlay isKindOfClass:[MKPolygon class]])
    {		
		NSString *ovTitle = [overlay title];
		if (ovTitle && [ovTitle hasPrefix:@"House"]) {
			myColor = [TexLegeTheme texasGreen];
		}
		else if (ovTitle && [ovTitle hasPrefix:@"Senate"]) {
			myColor = [TexLegeTheme texasOrange];
		}

		//MKPolygonView*    aView = [[[MKPolygonView alloc] initWithPolygon:(MKPolygon*)overlay] autorelease];
		MKPolygonView *aView = nil;

		[self invalidateDistrictView];
		self.districtView = [[[MKPolygonView alloc] initWithPolygon:(MKPolygon*)overlay] autorelease];
		aView = self.districtView;
		
		aView.fillColor = [/*[UIColor cyanColor]*/myColor colorWithAlphaComponent:0.2];
        aView.strokeColor = [myColor colorWithAlphaComponent:0.7];
        aView.lineWidth = 3;
		
        return aView;
    }
	
	else if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineView*    aView = [[[MKPolylineView alloc] initWithPolyline:(MKPolyline*)overlay] autorelease];
				
        aView.strokeColor = myColor;// colorWithAlphaComponent:0.7];
        aView.lineWidth = 3;
		
        return aView;
    }
	
	/*
	 MultiPolylineView *multiPolyView = [[[MultiPolylineView alloc] initWithOverlay: overlay] autorelease];
	 multiPolyView.strokeColor = [UIColor redColor];
	 multiPolyView.lineWidth   = 5.0;
	 return multiPolyView;
	 */
	return nil;
}



- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView {
	
	id<MKAnnotation> annotation = aView.annotation;
	if (!annotation)
		return;
	
	if (![aView isSelected])
		return;
	
	[self.mapView setCenterCoordinate:annotation.coordinate animated:YES];
	
	if ([annotation isKindOfClass:[CustomAnnotation class]]) {
		self.searchLocation = annotation;
	}	

	if ([annotation isKindOfClass:[DistrictMapObj class]]) {
		MKCoordinateRegion region;
		region = [(DistrictMapObj *)annotation region];
		
		NSMutableArray *toRemove = [[NSMutableArray alloc] initWithArray:self.mapView.overlays];
		BOOL foundOne = NO;
		
		for (id<MKOverlay>item in self.mapView.overlays) {
			if ([[item title] isEqualToString:[annotation title]]) {	// we clicked on an existing overlay
				if ([[item title] isEqualToString:[self.districtView.polygon title]]) { // it's the senate
					foundOne = YES;
					[toRemove removeObject:item];
					break;
				}
			}
		}
		
		//[self.mapView removeOverlays:self.mapView.overlays];
		if (!foundOne)
			[self invalidateDistrictView];
		if (toRemove && [toRemove count])
			[self.mapView performSelector:@selector(removeOverlays:) withObject:toRemove];

		[toRemove release];
		
		if (!foundOne) {
			MKPolygon *mapPoly = [(DistrictMapObj*)annotation polygon];
			[self.mapView performSelector:@selector(addOverlay:) withObject:mapPoly afterDelay:0.2f];
		}
		[self.mapView setRegion:region animated:TRUE];
	}			
}


#pragma mark -
#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation { // Override to allow rotation. Default returns YES only for UIDeviceOrientationPortrait
	return YES;
}

@end
