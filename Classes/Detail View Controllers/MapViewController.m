//
//  MapViewController.m
//
//  Created by Gregory Combs on 8/16/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
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

#import "LocalyticsSession.h"
#import "UIColor-Expanded.h"

#import "TexLegeMapPins.h"
#import "TexLegePinAnnotationView.h"
#import "MKPinAnnotationView+ZIndexFix.h"


@interface MapViewController (Private)
- (void) animateToState;
- (void) animateToAnnotation:(id<MKAnnotation>)annotation;
- (void) clearAnnotationsAndOverlays;
- (void) clearOverlaysExceptRecent;
- (void) clearAnnotationsExceptRecent;	
- (void) clearAnnotationsAndOverlaysExcept:(id)annotation;
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
@synthesize forwardGeocoder, texasRegion;
@synthesize senateDistrictView, houseDistrictView;
@synthesize masterPopover;
@synthesize genericOperationQueue;

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
	//[self invalidateDistrictView:BOTH_CHAMBERS];
	
	if (self.mapView) {
		[self.mapView removeAnnotations:self.mapView.annotations];
		[self.mapView removeOverlays:self.mapView.overlays];
		self.mapView = nil;
	}

	if (self.genericOperationQueue)
		[self.genericOperationQueue cancelAllOperations];
	self.genericOperationQueue = nil;
	
	self.mapTypeControl = nil;
	self.searchBarButton = nil;
	self.mapTypeControlButton = nil;
	//self.mapControlsButton = nil;
	self.userLocationButton = nil;
	[self.reverseGeocoder cancel];
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
	
	UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
	longPressRecognizer.delegate = self;
	[self.mapView addGestureRecognizer:longPressRecognizer];        
	[longPressRecognizer release];
	
	
}

- (void) viewDidUnload {
	if (self.mapView) {
		[self.mapView removeAnnotations:self.mapView.annotations];
		[self.mapView removeOverlays:self.mapView.overlays];
		self.mapView = nil;
	}
	
	if (self.genericOperationQueue)
		[self.genericOperationQueue cancelAllOperations];
	self.genericOperationQueue = nil;
		
//	self.mapTypeControl = nil;
//	self.mapControlsButton = nil;
//	self.mapTypeControlButton = nil;
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
	if (![TexLegeReachability canReachHostWithURL:tempURL])// do we have a good URL/connection?
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
- (NSManagedObjectContext *)managedObjectContext {
	return [DistrictMapObj managedObjectContext];
}



- (void) clearAnnotationsAndOverlays {
	self.mapView.showsUserLocation = NO;
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
		if ([toRemove count]>2) {
			[toRemove removeLastObject];
			[toRemove removeLastObject];
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
	if (masterPopover)
		[masterPopover dismissPopoverAnimated:YES];
	
	if (![self region:self.mapView.region isEqualTo:self.texasRegion]) { // it's another region, let's zoom out/in
		[self performSelector:@selector(animateToState) withObject:nil afterDelay:0.3];
		[self performSelector:@selector(animateToAnnotation:) withObject:annotation afterDelay:1.7];        
	}
	else
		[self performSelector:@selector(animateToAnnotation:) withObject:annotation afterDelay:0.7];	
}

#pragma mark -
#pragma mark Gesture Recognizer

#pragma mark Handling long presses

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
	id theView = gestureRecognizer.view;

	if ([theView isKindOfClass:[MKPinAnnotationView class]])
		return NO;
	else if ([theView isKindOfClass:[MKMapView class]])
		return YES;
	else
		return NO;

}

-(void)handleLongPress:(UILongPressGestureRecognizer*)longPressRecognizer {
    
    /*
     For the long press, the only state of interest is Began.
     If there is a row at the location, create a suitable menu controller and display it.
     */
    if (longPressRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint touchPoint = [longPressRecognizer locationInView:self.mapView];
		CLLocationCoordinate2D touchCoord = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
		
		[self clearAnnotationsAndOverlays];
		
		MKCoordinateSpan newSpan = self.mapView.region.span;
		[self.mapView setCenterCoordinate:touchCoord animated:YES];
		
		MKCoordinateRegion newRegion = MKCoordinateRegionMake(touchCoord, newSpan);
		
		// Add a placemark on the map
		CustomAnnotation *annotation = [[[CustomAnnotation alloc] initWithRegion:newRegion] autorelease];
		annotation.coordinateChangedDelegate = self;
		[self.mapView addAnnotation:annotation];	
					
		[self searchDistrictMapsForCoordinate:annotation.coordinate];
    }
}

#pragma mark -
#pragma mark Popover Support


- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
	//debug_NSLog(@"Entering portrait, showing the button: %@", [aViewController class]);
    barButtonItem.title = @"Districts";
    [self.navigationItem setRightBarButtonItem:barButtonItem animated:YES];
    self.masterPopover = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
	//debug_NSLog(@"Entering landscape, hiding the button: %@", [aViewController class]);
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    self.masterPopover = nil;
}

- (void) splitViewController:(UISplitViewController *)svc popoverController: (UIPopoverController *)pc
   willPresentViewController: (UIViewController *)aViewController
{
	if ([UtilityMethods isLandscapeOrientation]) {
		[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"ERR_POPOVER_IN_LANDSCAPE"];
	}		 
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
#pragma DistrictMapSearchOperationDelegate

- (void) searchDistrictMapsForCoordinate:(CLLocationCoordinate2D)aCoordinate {	

	NSArray *list = [TexLegeCoreDataUtils allDistrictMapIDsWithBoundingBoxesContaining:aCoordinate];
	
	DistrictMapSearchOperation *op = [[DistrictMapSearchOperation alloc] initWithDelegate:self 
																			   coordinate:aCoordinate 
																				searchDistricts:list];
	if (op) {
		if (!self.genericOperationQueue)
			self.genericOperationQueue = [[[NSOperationQueue alloc] init] autorelease];
		[self.genericOperationQueue addOperation:op];
		[op release];
	}
}

- (void)districtMapSearchOperationDidFinishSuccessfully:(DistrictMapSearchOperation *)op {	
	//debug_NSLog(@"Found some search results in %d districts", [op.foundDistricts count]);
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	for (NSNumber *districtID in op.foundIDs) {
		DistrictMapObj *district = [DistrictMapObj objectWithPrimaryKeyValue:districtID];
		if (district) {
			[self.mapView addAnnotation:district];
			[self.mapView performSelector:@selector(addOverlay:) withObject:[district polygon] afterDelay:0.5f];
			//for (DistrictOfficeObj *office in district.legislator.districtOffices)
			//	[self.mapView addAnnotation:office];
			
			[[DistrictMapObj managedObjectContext] refreshObject:district mergeChanges:NO];	// re-fault it to free memory
		}
	}	
	
	if (self.genericOperationQueue)
		[self.genericOperationQueue cancelAllOperations];
	self.genericOperationQueue = nil;
	
	[pool drain];
}

- (void)districtMapSearchOperationDidFail:(DistrictMapSearchOperation *)op 
							 errorMessage:(NSString *)errorMessage 
								   option:(DistrictMapSearchOperationFailOption)failOption {	
	
	if (failOption == DistrictMapSearchOperationFailOptionLog) {
		NSLog(@"%@", errorMessage);
	}
	
	if (self.genericOperationQueue)
		[self.genericOperationQueue cancelAllOperations];
	self.genericOperationQueue = nil;
}

#pragma mark -
#pragma mark Control Element Actions
/*
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
*/
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
	self.userLocationButton = locateItem;
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
	[self clearAnnotationsAndOverlays];
	[self showLocateActivityButton];				// this gets changed in viewForAnnotation once we receive the location

	if ([UtilityMethods locationServicesEnabled]) 
		self.mapView.showsUserLocation = YES;
}

- (IBAction) showAllDistricts:(id)sender {
	[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"SHOWING_ALL_DISTRICTS"];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSArray *districts = [TexLegeCoreDataUtils allDistrictMapsLight];
	if (districts) {
		[self resetMapViewWithAnimation:YES];
		[self.mapView addAnnotations:districts];
	}
	[pool drain];
}
/*
- (IBAction) showAllDistrictOffices:(id)sender {
	
	[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"SHOWING_ALL_DISTRICT_OFFICES"];
	
	NSArray *districtOffices = [TexLegeCoreDataUtils allObjectsInEntityNamed:@"DistrictOfficeObj" context:self.managedObjectContext];
	if (districtOffices) {
		[self resetMapViewWithAnimation:YES];
		[self.mapView addAnnotations:districtOffices];
	}
}
*/


- (void)showLegislatorDetails:(LegislatorObj *)legislator
{
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
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    NSLog(@"MKReverseGeocoder has failed: %@", error);
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
		[self clearAnnotationsAndOverlays];		
		
		NSInteger searchResults = [self.forwardGeocoder.results count];
		
		for(NSInteger i = 0; i < searchResults; i++)
		{
			BSKmlResult *place = [self.forwardGeocoder.results objectAtIndex:i];
			
			// Add a placemark on the map
			CustomAnnotation *annotation = [[CustomAnnotation alloc] initWithBSKmlResult:place];
			
			if (![UtilityMethods iOSVersion4])
				annotation.coordinateChangedDelegate = self;
			
			[self.mapView addAnnotation:annotation];	
			
			if (i==0) {	// Only add maps for the first location found
				[self searchDistrictMapsForCoordinate:annotation.coordinate];
				[self moveMapToAnnotation:annotation];
			}
			[annotation release];
			
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
	
	[self clearAnnotationsAndOverlaysExcept:sender];
	[self reverseGeocodeLocation:self.searchLocation.coordinate];
	
	[self searchDistrictMapsForCoordinate:self.searchLocation.coordinate];
}

#pragma mark -
#pragma mark MapViewDelegate

// Only in 4.0+
- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
	
	NSString *message = [NSString stringWithFormat:@"Failed to locate you due to the following:", [error localizedDescription]];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Fix Error" 
													message:message
												   delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles: nil];
	[alert show];
	[alert release];
	self.mapView.showsUserLocation = NO;
	[self showLocateUserButton];

}

// Only in 4.0+
- (void)mapView:(MKMapView *)theMapView didUpdateUserLocation:(MKUserLocation *)userLocation {
	if (userLocation) {
		[self searchDistrictMapsForCoordinate:userLocation.coordinate];
		
		if (!theMapView.userLocationVisible) {
			for (id annotation in theMapView.annotations) {
				if ([annotation isKindOfClass:[MKUserLocation class]]) {
					[self performSelector:@selector(moveMapToAnnotation:) withObject:annotation afterDelay:.5f];
					break;
				}
			}
		}
		
		//self.mapView.showsUserLocation = NO;
		[self showLocateUserButton];
	}
}

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
			[self searchDistrictMapsForCoordinate:self.mapView.userLocation.coordinate];
			
			if (!theMapView.userLocationVisible)
				[self performSelector:@selector(moveMapToAnnotation:) withObject:aView.annotation afterDelay:.5f];
			
			[self showLocateUserButton];
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
    
    if ([annotation isKindOfClass:[DistrictOfficeObj class]] || [annotation isKindOfClass:[DistrictMapObj class]]) 
    {
        static NSString* districtAnnotationID = @"districtObjectAnnotationID";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:districtAnnotationID];
        if (!pinView)
        {
            TexLegePinAnnotationView* customPinView = [[[TexLegePinAnnotationView alloc]
												   initWithAnnotation:annotation reuseIdentifier:districtAnnotationID] autorelease];
            return customPinView;
        }
        else
        {
            pinView.annotation = annotation;
			if ([pinView respondsToSelector:@selector(resetPinColorWithAnnotation:)])
				[pinView performSelector:@selector(resetPinColorWithAnnotation:) withObject:annotation];
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
	UIColor *myColor = [[colors objectAtIndex:colorIndex] colorByDarkeningTo:0.50f];
	colorIndex++;
	if (colorIndex > 1)
		colorIndex = 0;
	
	if ([overlay isKindOfClass:[MKPolygon class]])
    {		
		BOOL senate = NO;
		NSString *ovTitle = [overlay title];
		if (ovTitle && [ovTitle hasPrefix:@"House"]) {
			if (self.mapView.mapType > MKMapTypeStandard)
				myColor = [UIColor cyanColor];
			else
				myColor = [TexLegeTheme texasGreen];
			senate = NO;
		}
		else if (ovTitle && [ovTitle hasPrefix:@"Senate"]) {
			myColor = [TexLegeTheme texasOrange];
			senate = YES;
		}

		//MKPolygonView*    aView = [[[MKPolygonView alloc] initWithPolygon:(MKPolygon*)overlay] autorelease];
		MKPolygonView *aView = nil;
		if (senate) {
			aView = [[[MKPolygonView alloc] initWithPolygon:(MKPolygon*)overlay] autorelease];
			self.senateDistrictView = aView;
		}
		else {
			aView = [[[MKPolygonView alloc] initWithPolygon:(MKPolygon*)overlay] autorelease];
			self.houseDistrictView = aView;
		}

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
				if ([[item title] isEqualToString:[self.senateDistrictView.polygon title]]) { // it's the senate
					[toRemove removeObject:item];
					foundOne = YES;
					break;
				}
				else if ([[item title] isEqualToString:[self.houseDistrictView.polygon title]]) { // it's the house
					[toRemove removeObject:item];
					foundOne = YES;
					break;
				}
				
			}
		}
		
		//[self.mapView removeOverlays:self.mapView.overlays];
		if (toRemove && [toRemove count])
			[self.mapView performSelector:@selector(removeOverlays:) withObject:toRemove];

		[toRemove release];
		
		if (!foundOne) {
			MKPolygon *mapPoly = [(DistrictMapObj*)annotation polygon];
			[self.mapView performSelector:@selector(addOverlay:) withObject:mapPoly afterDelay:0.2f];
			[[DistrictMapObj managedObjectContext] refreshObject:(DistrictMapObj*)annotation mergeChanges:NO];
		}
		[self.mapView setRegion:region animated:TRUE];
	}			
}

/*
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)aView {
	id<MKAnnotation> annotation = aView.annotation;
	if (!annotation)
		return;
	
	if ([annotation isKindOfClass:[DistrictMapObj class]]) {
		MKCoordinateRegion region;
		region = [(DistrictMapObj *)annotation region];
		
		NSMutableArray *toRemove = [[NSMutableArray alloc] initWithCapacity:[self.mapView.overlays count]];
		NSInteger deleteOne = -1;
		
		for (id<MKOverlay>item in self.mapView.overlays) {
			if ([[item title] isEqualToString:[annotation title]]) {	// we clicked on an existing overlay
				if ([[item title] isEqualToString:[self.senateDistrictView.polygon title]]) { // it's the senate
					deleteOne = SENATE;
					[toRemove addObject:item];
					break;
				}
				else if ([[item title] isEqualToString:[self.houseDistrictView.polygon title]]) { // it's the house
					deleteOne = HOUSE;
					[toRemove addObject:item];
					break;
				}
				
			}
		}
		
		if (deleteOne >= 0 && toRemove && [toRemove count]) {
			[self invalidateDistrictView:deleteOne];
			[self.mapView performSelector:@selector(removeOverlays:) withObject:toRemove];
		}
		[toRemove release];
		
		[self.mapView setRegion:region animated:TRUE];
	}			
}

*/

#pragma mark -
#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation { // Override to allow rotation. Default returns YES only for UIDeviceOrientationPortrait
	return YES;
}

@end
