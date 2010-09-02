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
#import "DistrictMapObj.h"
#import "DistrictMapDataSource.h"

#import "CustomAnnotation.h"

#import "TexLegeAppDelegate.h"
#import "DistrictOfficeMasterViewController.h"
#import "DistrictOfficeDataSource.h"
#import "SelectablePinAnnotationView.h"

#import "LocalyticsSession.h"
#import "UIColor-Expanded.h"

@interface MapViewController (Private)
- (void) animateToState;
- (void) animateToAnnotation:(id<MKAnnotation>)annotation;
- (void) clearAnnotationsAndOverlays;
- (void) resetMapViewWithAnimation:(BOOL)animated;
- (void) dismissDistrictOfficesPopover:(id)sender;
- (BOOL) region:(MKCoordinateRegion)region1 isEqualTo:(MKCoordinateRegion)region2;
- (IBAction) showHidePopoverButton:(id)sender;

@end

NSInteger colorIndex;
static MKCoordinateSpan kStandardZoomSpan = {2.f, 2.f};


@implementation MapViewController
@synthesize mapTypeControl, mapTypeControlButton;
@synthesize mapView, userLocationButton, reverseGeocoder;
@synthesize toolbar, searchBar, searchBarButton, districtOfficesButton;
@synthesize mapControlsButton, forwardGeocoder, texasRegion;
@synthesize masterPopover;

SYNTHESIZE_SINGLETON_FOR_CLASS(MapViewController);

#pragma mark -
#pragma mark Initialization and Memory Management

- (NSString *)nibName {
	if ([UtilityMethods isIPadDevice])
		return @"MapViewController~ipad";
	else
		return @"MapViewController~iphone";
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
	
		[self view]; // why do we have to cheat it like this? shouldn't the view load automatically from the nib?
		colorIndex = 0;
		if (![UtilityMethods isIPadDevice])
			self.hidesBottomBarWhenPushed = YES;
	}
	return self;
}

- (void) dealloc {
	self.mapTypeControl = nil;
	self.searchBarButton = nil;
	self.mapTypeControlButton = nil;
	self.mapView = nil;
	self.mapControlsButton = nil;
	self.userLocationButton = nil;
	self.reverseGeocoder = nil;
	self.forwardGeocoder = nil;
	self.districtOfficesButton = nil;
	self.searchBar = nil;
	self.masterPopover = nil;
	[super dealloc];
}

- (void) didReceiveMemoryWarning {
	[self dismissDistrictOfficesPopover:nil];
	
	self.forwardGeocoder = nil;
	self.reverseGeocoder = nil;

	[self clearAnnotationsAndOverlaysExceptRecent];
	//[self resetMapViewWithAnimation:YES];

	[super didReceiveMemoryWarning];
}

- (void) viewDidLoad {
	[super viewDidLoad];
	
	colorIndex = 0;

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
	[self.mapView removeAnnotations:[self.mapView annotations]];

	self.mapTypeControl = nil;
	self.mapControlsButton = nil;
	self.mapTypeControlButton = nil;
	self.mapView = nil;
	self.searchBarButton = nil;
	self.userLocationButton = nil;
	self.reverseGeocoder = nil;
	self.forwardGeocoder = nil;
	self.searchBar = nil;
	self.masterPopover = nil;
	[super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	NSURL *tempURL = [NSURL URLWithString:@"http://maps.google.com"];		
	if (![UtilityMethods canReachHostWithURL:tempURL])// do we have a good URL/connection?
		return;
	
}

- (void) viewDidDisappear:(BOOL)animated {
	self.mapView.showsUserLocation = NO;
	[super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark Animation and Zoom

- (void) clearAnnotationsAndOverlays {
	self.mapView.showsUserLocation = NO;
	[self.mapView removeOverlays:self.mapView.overlays];
	[self.mapView removeAnnotations:self.mapView.annotations];
}

- (void) clearAnnotationsAndOverlaysExceptRecent {
	self.mapView.showsUserLocation = NO;
	
	NSMutableArray *toRemove = [[NSMutableArray alloc] initWithArray:self.mapView.overlays];
	if (toRemove && [toRemove count]) {
		[toRemove removeLastObject];
		[self.mapView removeOverlays:toRemove];
		[toRemove removeAllObjects];
	}
	[toRemove setArray:self.mapView.annotations];
	if (toRemove && [toRemove count]) {
		[toRemove removeLastObject];
		[self.mapView removeAnnotations:toRemove];
	}
	[toRemove release];
}



- (void) resetMapViewWithAnimation:(BOOL)animated {
	[self clearAnnotationsAndOverlays];
	if (animated)
		[self animateToState];
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
	
	[self.mapView selectAnnotation:annotation animated:YES];
}

- (void)moveMapToAnnotation:(id<MKAnnotation>)annotation {
	if (masterPopover)
		[masterPopover dismissPopoverAnimated:YES];
	
	if (![self region:self.mapView.region isEqualTo:self.texasRegion]) { // we've already another region, let's zoom out
		[self performSelector:@selector(animateToState) withObject:nil afterDelay:0.3];
		[self performSelector:@selector(animateToAnnotation:) withObject:annotation afterDelay:1.7];        
	}
	else
		[self performSelector:@selector(animateToAnnotation:) withObject:annotation afterDelay:0.5];	
}


#pragma mark -
#pragma mark Popover Support


- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    
    barButtonItem.title = @"Districts";
    [self.navigationItem setRightBarButtonItem:barButtonItem animated:YES];
    self.masterPopover = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    self.masterPopover = nil;
}

- (void) splitViewController:(UISplitViewController *)svc popoverController: (UIPopoverController *)pc
   willPresentViewController: (UIViewController *)aViewController
{
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

- (IBAction) mapControlSheet:(id)sender {
	UIActionSheet *popupQuery = [[UIActionSheet alloc]
								 initWithTitle:nil
								 delegate:self
								 cancelButtonTitle:@"Cancel"
								 destructiveButtonTitle:nil
								 otherButtonTitles:@"My Location's Districts",
								 @"All District Offices",@"Map: Normal", @"Map: Satellite", @"Map: Hybrid", nil];
	
	popupQuery.actionSheetStyle = UIActionSheetStyleAutomatic;
	//[popupQuery showFromBarButtonItem:sender animated:YES];
	[popupQuery showFromTabBar:self.tabBarController.tabBar];
	[popupQuery release];
}

//- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	switch (buttonIndex) {
		case 0:
			[self locateUser:actionSheet];
			break;
		case 1:
			[self showAllDistrictOffices:actionSheet];
			break;
		case 2:
			self.mapView.mapType = MKMapTypeStandard;
			break;
		case 3:
			self.mapView.mapType = MKMapTypeSatellite;
			break;
		case 4:
			self.mapView.mapType = MKMapTypeHybrid;
			break;
		case 5:
		default:
			break;			
	}
}

- (IBAction)changeMapType:(id)sender {
	NSInteger index = self.mapTypeControl.selectedSegmentIndex;
	self.mapView.mapType = index;
}

- (IBAction)locateUser:(id)sender {
	[self clearAnnotationsAndOverlays];

	if ([UtilityMethods locationServicesEnabled]) 
		self.mapView.showsUserLocation = YES;
}

- (IBAction) showAllDistrictMaps:(id)sender {
	[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"SHOWING_ALL_DISTRICT_MAPS"];
	
	NSFetchedResultsController *frc = [[[TexLegeAppDelegate appDelegate] districtMapDataSource] fetchedResultsController];
	if (!frc)
		return;
	
	[self resetMapViewWithAnimation:YES];

	[self.mapView addOverlays:[frc fetchedObjects]];	
	
}

- (IBAction) showAllDistrictOffices:(id)sender {
	
	[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"SHOWING_ALL_DISTRICT_OFFICES"];
		
	DistrictOfficeMasterViewController *masterList = [[TexLegeAppDelegate appDelegate] districtOfficeMasterVC];	
	NSFetchedResultsController *frc = [(DistrictOfficeDataSource *) masterList.dataSource fetchedResultsController];
	if (!frc)
		return;
		
	[self resetMapViewWithAnimation:YES];

	//[self performSelector:@selector(animateToState) withObject:nil afterDelay:0.3f];
	[self.mapView addAnnotations:[frc fetchedObjects]];	
}



- (void)showLegislatorDetails:(LegislatorObj *)legislator
{
    // the detail view does not want a toolbar so hide it
    //[self.navigationController setToolbarHidden:YES animated:NO];
    	
	if (!legislator)
		return;
	
	LegislatorDetailViewController *legVC = [[LegislatorDetailViewController alloc] initWithNibName:@"LegislatorDetailViewController" bundle:nil];
	legVC.legislator = legislator;
	[self.navigationController pushViewController:legVC animated:YES];
	[legVC release];
}


#pragma mark -
#pragma mark Geocoding and Reverse Geocoding

- (IBAction)reverseGeocodeCurrentLocation
{
	if (!self.reverseGeocoder) {
		MKReverseGeocoder *rgc = [[MKReverseGeocoder alloc] initWithCoordinate:self.mapView.userLocation.location.coordinate];
		rgc.delegate = self;
		self.reverseGeocoder = rgc;
		[rgc release];
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

	if(self.forwardGeocoder.status == G_GEO_SUCCESS)
	{
		[self clearAnnotationsAndOverlays];		
		
		NSInteger searchResults = [self.forwardGeocoder.results count];
		
		// Add placemarks for each result
		id<MKAnnotation> lastAnnotation = nil;
		
		for(NSInteger i = 0; i < searchResults; i++)
		{
			BSKmlResult *place = [self.forwardGeocoder.results objectAtIndex:i];
			
			// Add a placemark on the map
			CustomAnnotation *placemark = [[[CustomAnnotation alloc] initWithBSKmlResult:place] autorelease];
			
			DistrictMapDataSource *dataSource = [[TexLegeAppDelegate appDelegate] districtMapDataSource];
			[dataSource searchDistrictMapsForCoordinate:placemark.coordinate withDelegate:self];

			[self.mapView addAnnotation:placemark];	
			
			lastAnnotation = placemark;
		}
		
		[self moveMapToAnnotation:lastAnnotation];
		
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
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	

	debug_NSLog(@"Searching for: %@", theSearchBar.text);
	if(self.forwardGeocoder == nil)
	{
		self.forwardGeocoder = [[[BSForwardGeocoder alloc] initWithDelegate:self] autorelease];
	}
	
	// Forward geocode!
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
	
}

#pragma mark -
#pragma mark MapViewDelegate

- (IBAction) foundDistrictMapsWithObjectIDs:(NSArray *)objectIDs {
	if (!objectIDs)
		return;

	for (NSManagedObjectID *objectID in objectIDs) {
		DistrictMapObj *district = (DistrictMapObj *)[[[TexLegeAppDelegate appDelegate] managedObjectContext] objectWithID:objectID];
		if (district) {
			[self.mapView addOverlay:[district polygon]];
			for (DistrictOfficeObj *office in district.legislator.districtOffices)
				[self.mapView addAnnotation:office];
		}
	}	
}


- (void)mapView:(MKMapView *)theMapView didAddAnnotationViews:(NSArray *)views
{
	[self dismissDistrictOfficesPopover:nil];

	for (MKAnnotationView *aView in views) {
		if ([aView.annotation class] == [MKUserLocation class])
			//[aView isKindOfClass:NSClassFromString(@"MKUserLocationView")])
		{
			// we have received our current location, so start reverse geocoding the address
			//[self reverseGeocodeCurrentLocation];
			
			DistrictMapDataSource *dataSource = [[TexLegeAppDelegate appDelegate] districtMapDataSource];
			[dataSource searchDistrictMapsForCoordinate:self.mapView.userLocation.coordinate withDelegate:self];
			
			if (!theMapView.userLocationVisible)
				[self performSelector:@selector(animateToAnnotation:) withObject:aView.annotation afterDelay:.5f];
			
			return;
		}
	}
	/*
	MKAnnotationView *lastView = [views lastObject];
	id<MKAnnotation> lastAnnotation = lastView.annotation;
	MKCoordinateRegion region;
	
	if (lastAnnotation) {
		
		if ([lastAnnotation isKindOfClass:[DistrictOfficeObj class]]) {
			DistrictOfficeObj *obj = lastAnnotation;
			region = [obj region];
			[theMapView setRegion:region animated:YES];
		}
		else if ([lastAnnotation isKindOfClass:[CustomAnnotation class]]) {
			CustomAnnotation *obj = lastAnnotation;
			region = [obj region];
			[theMapView setRegion:region animated:YES];
		}
		else {
			MKCoordinateRegion region = MKCoordinateRegionMake(lastAnnotation.coordinate, kStandardZoomSpan);
			[theMapView setRegion:region animated:YES];
		}

		
		//[theMapView selectAnnotation:lastAnnotation animated:YES];
	}*/
}


/*
- (void) mapViewDidFinishLoadingMap:(MKMapView *)theMapView {
 id<MKAnnotation> lastAnnotation = [[theMapView annotations] lastObject];
	
	if (lastAnnotation)
		[theMapView selectAnnotation:lastAnnotation animated:YES];
}
 */

- (void)mapView:(MKMapView *)theMapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
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
    if ([annotation isKindOfClass:[DistrictOfficeObj class]]) 
    {
		DistrictOfficeObj *districtOffice = (DistrictOfficeObj *)annotation;
		
        // try to dequeue an existing pin view first
        static NSString* districtOfficeAnnotationID = @"districtOfficeAnnotationID";
        SelectablePinAnnotationView* pinView = (SelectablePinAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:districtOfficeAnnotationID];
        if (!pinView)
        {
            // if an existing pin view was not available, create one
            SelectablePinAnnotationView* customPinView = [[[SelectablePinAnnotationView alloc]
												   initWithAnnotation:annotation reuseIdentifier:districtOfficeAnnotationID] autorelease];
            customPinView.pinColor = [[districtOffice pinColorIndex] integerValue];
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;
            
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];			
            customPinView.rightCalloutAccessoryView = rightButton;
			
			UIImageView *iconView = [[UIImageView alloc] initWithImage:[districtOffice image]];
            customPinView.leftCalloutAccessoryView = iconView;
            [iconView release];
			
			[customPinView setSelectionObserver:self];

            return customPinView;
        }
        else
        {
            pinView.annotation = annotation;
        }		

		
        return pinView;
    }
  
	if ([annotation isKindOfClass:[CustomAnnotation class]])  
    {
		CustomAnnotation *customAnotation = (CustomAnnotation *)annotation;

        static NSString* customAnnotationIdentifier = @"customAnnotationIdentifier";
        SelectablePinAnnotationView* pinView = (SelectablePinAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:customAnnotationIdentifier];
        if (!pinView)
        {
            SelectablePinAnnotationView *customPinView = [[[SelectablePinAnnotationView alloc] initWithAnnotation:annotation
                                                                             reuseIdentifier:customAnnotationIdentifier] autorelease];
            customPinView.pinColor = [[customAnotation pinColorIndex] integerValue];
			customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;
            customPinView.opaque = NO;
			
			UIImageView *iconView = [[UIImageView alloc] initWithImage:[customAnotation image]];
            customPinView.leftCalloutAccessoryView = iconView;
            [iconView release];
            
			[customPinView setSelectionObserver:self];

            return customPinView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    }
   
    return nil;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay{
	NSArray *colors = [[UIColor randomColor] triadicColors];
	UIColor *myColor = [[colors objectAtIndex:colorIndex] colorByDarkeningTo:.55f];
	colorIndex++;
	if (colorIndex > 1)
		colorIndex = 0;
	
	if ([overlay isKindOfClass:[MKPolygon class]])
    {
        MKPolygonView*    aView = [[[MKPolygonView alloc] initWithPolygon:(MKPolygon*)overlay] autorelease];
		
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


/*
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
	
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
	
}
*/

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context{
	
	NSString *action = (NSString*)context;
	
	//debug_NSLog(@"something");
	if([action isEqualToString:@"GMAP_ANNOTATION_SELECTED"]) 
	{				
		if ([object respondsToSelector:@selector(annotation)]) {
			id<MKAnnotation> annotation = [object performSelector:@selector(annotation)];
			if (!annotation)
				return;
			
			if (![self.mapView.selectedAnnotations containsObject:annotation])
				return;
			
			MKCoordinateRegion region;
			if ([annotation isKindOfClass:[DistrictOfficeObj class]]) {
				region = [(DistrictOfficeObj *)annotation region];
			}
			else {
				region = MKCoordinateRegionMake(annotation.coordinate, kStandardZoomSpan);
			}
			region.span = MKCoordinateSpanMake(0.05f, 0.05f);
			[self.mapView setRegion:region animated:TRUE];

			//debug_NSLog(@"annotation selected %f, %f", annotation.coordinate.latitude, annotation.coordinate.longitude);
		}
	}
}


#pragma mark -
#pragma mark Orientation


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation { // Override to allow rotation. Default returns YES only for UIDeviceOrientationPortrait
	return YES;
}

@end
