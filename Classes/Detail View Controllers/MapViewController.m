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
#import "CustomAnnotationView.h"

#import "TexLegeAppDelegate.h"
#import "TexLegeCoreDataUtils.h"

#import "DistrictOfficeMasterViewController.h"
#import "DistrictOfficeDataSource.h"

#import "LocalyticsSession.h"
#import "UIColor-Expanded.h"

#import "TexLegeMapPins.h"

#import "MKPinAnnotationView+ZIndexFix.h"


@interface MapViewController (Private)
- (void) animateToState;
- (void) animateToAnnotation:(id<MKAnnotation>)annotation;
- (void) clearAnnotationsAndOverlays;
- (void) clearAnnotationsAndOverlaysExcept:(id)overlayOrAnnotation;
- (void) resetMapViewWithAnimation:(BOOL)animated;
- (BOOL) region:(MKCoordinateRegion)region1 isEqualTo:(MKCoordinateRegion)region2;
- (IBAction) showHidePopoverButton:(id)sender;

@end

NSInteger colorIndex;
static MKCoordinateSpan kStandardZoomSpan = {2.f, 2.f};


@implementation MapViewController
@synthesize mapTypeControl, mapTypeControlButton;
@synthesize mapView, userLocationButton, reverseGeocoder, searchLocation;
@synthesize toolbar, searchBar, searchBarButton, districtOfficesButton;
@synthesize mapControlsButton, forwardGeocoder, texasRegion;
@synthesize masterPopover;

//SYNTHESIZE_SINGLETON_FOR_CLASS(MapViewController);

#pragma mark -
#pragma mark Initialization and Memory Management

- (NSString *)nibName {
	if ([UtilityMethods isIPadDevice])
		return @"MapViewController~ipad";
	else
		return @"MapViewController~iphone";
}

/*- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
	
		[self view]; // why do we have to cheat it like this? shouldn't the view load automatically from the nib?
	}
	return self;
}
*/
- (void) dealloc {
	[self.mapView removeOverlays:self.mapView.overlays];
	
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
	self.searchLocation = nil;
	[super dealloc];
}

- (void) didReceiveMemoryWarning {	
	self.forwardGeocoder = nil;
	self.reverseGeocoder = nil;

	[self clearAnnotationsAndOverlaysExceptRecent];

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
	[self.mapView removeOverlays:self.mapView.overlays];
	[self.mapView removeAnnotations:self.mapView.annotations];

//	self.mapTypeControl = nil;
	self.mapControlsButton = nil;
//	self.mapTypeControlButton = nil;
	self.mapView = nil;
//	self.searchBarButton = nil;
//	self.userLocationButton = nil;
	self.reverseGeocoder = nil;
	self.forwardGeocoder = nil;
//	self.searchBar = nil;
	self.searchLocation = nil;
	self.masterPopover = nil;
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
	[self.mapView removeOverlays:self.mapView.overlays];
	
	[super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark Animation and Zoom


- (void) clearAnnotationsAndOverlays {
	self.mapView.showsUserLocation = NO;
	[self.mapView removeOverlays:self.mapView.overlays];
	[self.mapView removeAnnotations:self.mapView.annotations];
}

- (void) clearAnnotationsAndOverlaysExcept:(id)overlayOrAnnotation {
	if (!overlayOrAnnotation)
		return;
	
	self.mapView.showsUserLocation = NO;
	
	NSMutableArray *toRemove = [[NSMutableArray alloc] init];
	if (toRemove) {
		[toRemove setArray:self.mapView.overlays];
		for (id overlay in toRemove) {
			if (overlay && ![overlay isEqual:overlayOrAnnotation])
				[self.mapView removeOverlay:overlay];
		}
		[toRemove setArray:self.mapView.annotations];
		for (id annotation in toRemove) {
			if (annotation && ![annotation isEqual:overlayOrAnnotation])
				[self.mapView removeAnnotation:annotation];
		}	
		[toRemove release];
	}
}

#warning This doesn't actually work, because MapKit uses Z-Ordering of annotations and overlays!!!
- (void) clearAnnotationsAndOverlaysExceptRecent {
	self.mapView.showsUserLocation = NO;
	
	NSMutableArray *toRemove = [[NSMutableArray alloc] init];
	if (toRemove) {
		[toRemove setArray:self.mapView.overlays];
		if ([toRemove count]) {
			[toRemove removeLastObject];
			[self.mapView removeOverlays:toRemove];
		}
		[toRemove setArray:self.mapView.annotations];
		if ([toRemove count]) {
			[toRemove removeLastObject];
			[self.mapView removeAnnotations:toRemove];
		}
		[toRemove release];
	}
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
	if (masterPopover)
		[masterPopover dismissPopoverAnimated:YES];
	
	if (![self region:self.mapView.region isEqualTo:self.texasRegion]) { // it's another region, let's zoom out/in
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

- (IBAction) showAllDistricts:(id)sender {
	[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"SHOWING_ALL_DISTRICTS"];
	
	NSArray *districts = [TexLegeCoreDataUtils allDistrictMapsLightWithContext:[[TexLegeAppDelegate appDelegate]managedObjectContext]];
	if (districts) {
		[self resetMapViewWithAnimation:YES];
		[self.mapView addAnnotations:districts];
	}
}

- (IBAction) showAllDistrictOffices:(id)sender {
	
	[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"SHOWING_ALL_DISTRICT_OFFICES"];
	
	NSArray *districtOffices = [TexLegeCoreDataUtils allObjectsInEntityNamed:@"DistrictOfficeObj" context:[[TexLegeAppDelegate appDelegate]managedObjectContext]];
	if (districtOffices) {
		[self resetMapViewWithAnimation:YES];
		[self.mapView addAnnotations:districtOffices];
	}
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
	// get the annotation view to display?
	//[self setNeedsDisplay];

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
			CustomAnnotation *annotation = [[[CustomAnnotation alloc] initWithBSKmlResult:place] autorelease];
			[self.mapView addAnnotation:annotation];	
			
			DistrictMapDataSource *dataSource = [[TexLegeAppDelegate appDelegate] districtMapDataSource];
			[dataSource searchDistrictMapsForCoordinate:annotation.coordinate withDelegate:self];

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
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	debug_NSLog(@"Searching for: %@", theSearchBar.text);
	if(self.forwardGeocoder == nil)
	{
		self.forwardGeocoder = [[[BSForwardGeocoder alloc] initWithDelegate:self] autorelease];
	}
	
	// Forward geocode!
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
	
}

#pragma mark -
#pragma mark MapViewDelegate

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
	
	if (oldState == MKAnnotationViewDragStateDragging) {

		if ([annotationView.annotation isEqual:self.searchLocation]) {	
			[self clearAnnotationsAndOverlaysExcept:self.searchLocation];

			[self reverseGeocodeLocation:self.searchLocation.coordinate];
			
			DistrictMapDataSource *dataSource = [[TexLegeAppDelegate appDelegate] districtMapDataSource];
			[dataSource searchDistrictMapsForCoordinate:self.searchLocation.coordinate withDelegate:self];
		}
		
	}
}



- (IBAction) foundDistrictMapsWithObjectIDs:(NSArray *)objectIDs {
	if (!objectIDs)
		return;

	for (NSManagedObjectID *objectID in objectIDs) {
		DistrictMapObj *district = (DistrictMapObj *)[[[TexLegeAppDelegate appDelegate] managedObjectContext] objectWithID:objectID];
		if (district) {
			[self.mapView addOverlay:[district polygon]];
			[self.mapView addAnnotation:district];
			//for (DistrictOfficeObj *office in district.legislator.districtOffices)
			//	[self.mapView addAnnotation:office];
		}
	}	
}


- (void)mapView:(MKMapView *)theMapView didAddAnnotationViews:(NSArray *)views
{
	for (MKAnnotationView *aView in views) {
		if ([aView.annotation class] == [MKUserLocation class])
		{			
			DistrictMapDataSource *dataSource = [[TexLegeAppDelegate appDelegate] districtMapDataSource];
			[dataSource searchDistrictMapsForCoordinate:self.mapView.userLocation.coordinate withDelegate:self];
			
			if (!theMapView.userLocationVisible)
				[self performSelector:@selector(moveMapToAnnotation:) withObject:aView.annotation afterDelay:.5f];
			
			return;
		}
	}
}


- (void)mapView:(MKMapView *)theMapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	id <MKAnnotation> annotation = view.annotation;
	
	if ([annotation isKindOfClass:[DistrictOfficeObj class]] || [annotation isKindOfClass:[DistrictMapObj class]])
    {
		if ([annotation respondsToSelector:@selector(legislator)]) {
			LegislatorObj *legislator = [annotation performSelector:@selector(legislator)];
				if (legislator)
					[self showLegislatorDetails:legislator];
		}
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
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:districtOfficeAnnotationID];
        if (!pinView)
        {
            // if an existing pin view was not available, create one
            MKPinAnnotationView* customPinView = [[[MKPinAnnotationView alloc]
												   initWithAnnotation:annotation reuseIdentifier:districtOfficeAnnotationID] autorelease];
			customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;
            
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];			
            customPinView.rightCalloutAccessoryView = rightButton;
			
			UIImageView *iconView = [[UIImageView alloc] initWithImage:[districtOffice image]];
            customPinView.leftCalloutAccessoryView = iconView;
            [iconView release];
			
			NSInteger pinColorIndex = [[districtOffice pinColorIndex] integerValue];
			if (pinColorIndex >= TexLegePinAnnotationColorBlue) {
				UIImage *pinImage = [TexLegeMapPins imageForPinColorIndex:pinColorIndex status:TexLegePinAnnotationStatusHead];
				UIImageView *pinHead = [[UIImageView alloc] initWithImage:pinImage];
				[customPinView addSubview:pinHead];
				[pinHead release];
			}
			else
				customPinView.pinColor = [[districtOffice pinColorIndex] integerValue];

            return customPinView;
        }
        else
        {
            pinView.annotation = annotation;
        }		

		
        return pinView;
    }
	
	if ([annotation isKindOfClass:[DistrictMapObj class]]) 
    {
		DistrictMapObj *districtMap = (DistrictMapObj *)annotation;
		
        // try to dequeue an existing pin view first
        static NSString* districtMapAnnotationID = @"districtMapAnnotationID";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:districtMapAnnotationID];
        if (!pinView)
        {
            // if an existing pin view was not available, create one
            MKPinAnnotationView* customPinView = [[[MKPinAnnotationView alloc]
														   initWithAnnotation:annotation reuseIdentifier:districtMapAnnotationID] autorelease];
            customPinView.animatesDrop = YES;
            customPinView.canShowCallout = YES;
            
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];			
            customPinView.rightCalloutAccessoryView = rightButton;
			
			UIImageView *iconView = [[UIImageView alloc] initWithImage:[districtMap image]];
            customPinView.leftCalloutAccessoryView = iconView;
            [iconView release];
			
			NSInteger pinColorIndex = [[districtMap pinColorIndex] integerValue];
			if (pinColorIndex >= TexLegePinAnnotationColorBlue) {
				UIImage *pinImage = [TexLegeMapPins imageForPinColorIndex:pinColorIndex status:TexLegePinAnnotationStatusHead];
				UIImageView *pinHead = [[UIImageView alloc] initWithImage:pinImage];
				[customPinView addSubview:pinHead];
				[pinHead release];
			}
			else
				customPinView.pinColor = [[districtMap pinColorIndex] integerValue];
			
			
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
        static NSString* customAnnotationIdentifier = @"customAnnotationIdentifier";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:customAnnotationIdentifier];
        if (!pinView)
        {
            CustomAnnotationView *customPinView = [[[CustomAnnotationView alloc] initWithAnnotation:annotation
                                                                             reuseIdentifier:customAnnotationIdentifier] autorelease];            
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
		
		NSString *ovTitle = [overlay title];
		if (ovTitle && [ovTitle hasPrefix:@"House"])
			myColor = [TexLegeTheme texasGreen];
		else if (ovTitle && [ovTitle hasPrefix:@"Senate"])
			myColor = [TexLegeTheme texasOrange];

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
	
	if ([annotation isKindOfClass:[CustomAnnotation class]]) {
		self.searchLocation = annotation;
		//[self reverseGeocodeLocation:self.searchLocation.coordinate];
	}	
/*	if (aView.dragState != MKAnnotationViewDragStateNone)
		return;
	
//	if (![self.mapView.selectedAnnotations containsObject:annotation])
//		return;
*/	
	MKCoordinateRegion region;
	if ([annotation isKindOfClass:[DistrictMapObj class]]) {
		region = [(DistrictMapObj *)annotation region];
		
		[self.mapView removeOverlays:self.mapView.overlays];
		[self.mapView addOverlay:[(DistrictMapObj*)annotation polygon]];
		[self.mapView setRegion:region animated:TRUE];
	}			
/*	else {
		[self performSelector:@selector(moveMapToAnnotation:) withObject:annotation afterDelay:0.1f];
//		region = MKCoordinateRegionMake(annotation.coordinate, kStandardZoomSpan);
	}
*/	//region.span = MKCoordinateSpanMake(0.05f, 0.05f);
	
	//debug_NSLog(@"annotation selected %f, %f", annotation.coordinate.latitude, annotation.coordinate.longitude);
	
}

/*
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
	
}
*/


#pragma mark -
#pragma mark Orientation


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation { // Override to allow rotation. Default returns YES only for UIDeviceOrientationPortrait
	return YES;
}

@end
