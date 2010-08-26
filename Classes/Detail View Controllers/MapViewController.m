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

#import "CustomAnnotation.h"

#import "TexLegeAppDelegate.h"
#import "DistrictOfficeMasterViewController.h"
#import "DistrictOfficeDataSource.h"
#import "DistrictOfficeAnnotationView.h"

#import "LocalyticsSession.h"
#import "UIColor-Expanded.h"

@interface MapViewController (Private)
- (void)animateToState:(id<MKAnnotation>)annotation;
- (void)animateToAnnotation:(id<MKAnnotation>)annotation;
- (void)dismissDistrictOfficesPopover:(id)sender;
@end

NSInteger colorIndex;;

@implementation MapViewController
@synthesize bookmarksButton, mapTypeControl, mapView, userLocationButton, reverseGeocoder;
@synthesize toolbar, searchBar, forwardGeocoder, addressString, texasRegion;
@synthesize popoverController, shouldAnimate;

#pragma mark -
#pragma mark Initialization and Memory Management

- (NSString *)nibName {
	return @"MapViewController";
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
	
		[self view]; // why do we have to cheat it like this? shouldn't the view load automatically from the nib?
		self.shouldAnimate = YES;
		colorIndex = 0;
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

- (void) didReceiveMemoryWarning {
	[self dismissDistrictOfficesPopover:nil];
	
	self.mapView.region = self.texasRegion;
	[self.mapView removeAnnotations:[self.mapView annotations]];

	self.forwardGeocoder = nil;
	self.reverseGeocoder = nil;
/*
	if ([self.view superview])	{// we're in a view heirarchy, so don't wipe everything.
		
		id<MKAnnotation> lastAnnotation = [[self.mapView annotations] lastObject];
		
		id<MKAnnotation> currentAnnotation = [[self.mapView annotations] objectAtIndex:0];
		while ([[self.mapView annotations] count] > 1) {
			
			if (![currentAnnotation isEqual:lastAnnotation])
				[self.mapView removeAnnotation:currentAnnotation];
			
			currentAnnotation = [[self.mapView annotations] objectAtIndex:0];		
		}
	}
*/
	[super didReceiveMemoryWarning];
}

- (void) viewDidLoad {
	[super viewDidLoad];
	
	[self.view setBackgroundColor:[TexLegeTheme backgroundLight]];
	self.mapView.showsUserLocation = NO;
	
	// Set up the map's region to frame the state of Texas.
	// Zoom = 6
	self.mapView.region = self.texasRegion;
	
	self.toolbar.tintColor = [TexLegeTheme navbar];
	if ([UtilityMethods isIPadDevice]) {
		self.navigationItem.titleView = self.toolbar; 
		
		self.bookmarksButton.enabled = ![UtilityMethods isLandscapeOrientation];
		self.bookmarksButton.target = self;
		self.bookmarksButton.action = @selector(displayDistrictOfficesPopover:);
	}
	else
		self.navigationItem.titleView = self.searchBar;
	//self.navigationItem.titleView = self.mapTypeControl;
}

- (void) viewDidUnload {
	[self.mapView removeAnnotations:[self.mapView annotations]];

	self.bookmarksButton = nil;
	self.mapTypeControl = nil;
	self.mapView = nil;
	self.userLocationButton = nil;
	self.reverseGeocoder = nil;
	self.forwardGeocoder = nil;
	self.searchBar = nil;
	self.addressString = nil;	
}

- (void) testingMkPolyline {
	if (![UtilityMethods supportsMKPolyline])
		return;
	
	CLLocationCoordinate2D coords0[5]={
		{37.33544, -122.036677},
		{37.338511, -122.036677},
		{37.338511, -122.032128},
		{37.33544, -122.032128},
		{37.33544, -122.036677}
	};
	MKPolygon *polygon=[MKPolygon polygonWithCoordinates:coords0 count:5];
	
	CLLocationCoordinate2D coords[5]={
		{37.33444, -122.036777},
		{37.337511, -122.036777},
		{37.337511, -122.032228},
		{37.33444, -122.032228},
		{37.33444, -122.036777}
	};
	MKPolyline *polyLine=[MKPolyline polylineWithCoordinates:coords count:5];
	
	CLLocationCoordinate2D coords2[5]={
		{37.33434, -122.036767},
		{37.337411, -122.036767},
		{37.337411, -122.032218},
		{37.33434, -122.032218},
		{37.33434, -122.036767}
	};
	MKPolyline *polyLine2=[MKPolyline polylineWithCoordinates:coords2 count:5];
	
	NSArray *arrayOfPolylines = [NSArray arrayWithObjects:polygon, polyLine, polyLine2, nil];
	//MultiPolyline *multipoly = [[MultiPolyline alloc] initWithPolylines:arrayOfPolylines];
	
	CLLocationCoordinate2D center = {37.336086,-122.03454};
	[[self mapView] setCenterCoordinate:center];
	[[self mapView] addOverlays:arrayOfPolylines];
	//[[self mapView] addOverlay:multipoly];
	
	MKCoordinateSpan span = MKCoordinateSpanMake(0.005, 0.005);
	[[self mapView]setRegion:MKCoordinateRegionMake(center, span) animated:YES];
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	//self.bookmarksButton.enabled = ([UtilityMethods isIPadDevice] && ![UtilityMethods isLandscapeOrientation]);

	//[self testingMkPolyline];
	
	NSURL *tempURL = [NSURL URLWithString:@"http://maps.google.com"];		
	if (![UtilityMethods canReachHostWithURL:tempURL])// do we have a good URL/connection?
		return;
	
}

- (void) viewDidDisappear:(BOOL)animated {
	self.mapView.showsUserLocation = NO;
	[super viewDidDisappear:animated];
}


#pragma mark -
#pragma mark Popover Support

/*- (NSString*)popoverButtonTitle {
	return  @"District Offices";
}
*/

- (IBAction)displayDistrictOfficesPopover:(id)sender {
	if ( ![UtilityMethods isIPadDevice])
		return;
	
	if (!self.popoverController) {
		self.popoverController = [[UIPopoverController alloc] initWithContentViewController:[[TexLegeAppDelegate appDelegate] districtOfficeMasterVC]]; // (Autorelease??)
		self.popoverController.delegate = (id<UIPopoverControllerDelegate>)self; //self.currentDetailViewController;	
	}
	
	if (!self.bookmarksButton || !self.popoverController) {
		debug_NSLog(@"Bookmarks Button Item or District Offices Popover Controller is unallocated ... cannot display master list popover.");
		return;		// should never happen?
	}
	//self.isOpening = YES;
	[self.popoverController presentPopoverFromBarButtonItem:self.bookmarksButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	//self.isOpening = NO;
	
	// now that the menu is displayed, let's reset the action so it's ready to go away again on demand
	[self.bookmarksButton setTarget:self];
	[self.bookmarksButton setAction:@selector(dismissDistrictOfficesPopover:)];
}

- (IBAction)dismissDistrictOfficesPopover:(id)sender {
	if (!self.popoverController || ![UtilityMethods isIPadDevice] /*|| self.isOpening*/)
		return;
	
	if (self.popoverController)	{
		if ([self.popoverController isPopoverVisible])
			[self.popoverController dismissPopoverAnimated:YES];
		self.popoverController = nil;
	}
	
	if (self.bookmarksButton) {
		[self.bookmarksButton setTarget:self];
		[self.bookmarksButton setAction:@selector(displayDistrictOfficesPopover:)];
	}
}

#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController 
		  withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
	
	barButtonItem.enabled = YES;
	self.bookmarksButton.enabled = YES;
	self.popoverController = pc;
}

// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
	
	barButtonItem.enabled = NO;
	self.bookmarksButton.enabled = NO;
	[self dismissDistrictOfficesPopover:barButtonItem];		
}

/*
// we're about to show the popover, with the master list inside
- (void) splitViewController:(UISplitViewController *)svc popoverController: (UIPopoverController *)pc
   willPresentViewController: (UIViewController *)aViewController
{
	 
}
*/

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
		if(!self.forwardGeocoder)
			self.forwardGeocoder = [[BSForwardGeocoder alloc] initWithDelegate:self];
		
		// Forward geocode!
		[self.forwardGeocoder findLocation:string];
		
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

- (IBAction) showAllDistrictMaps:(id)sender {
	[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"SHOWING_ALL_DISTRICT_MAPS"];
	
	// create a LegislatorDetailViewController. This controller will display the full size tile for the element
	
	NSFetchedResultsController *frc = [[[TexLegeAppDelegate appDelegate] districtMapDataSource] fetchedResultsController];
	if (!frc)
		return;
	
	NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:181];
	for (DistrictMapObj *map in [frc fetchedObjects]) {
		//[array addObject:[map polyline]];
		[array addObject:[map polygon]];
	}
		
	[self.mapView removeOverlays:[self.mapView overlays]];
	
	[self performSelector:@selector(animateToState:) withObject:nil afterDelay:0.3f];
	self.shouldAnimate = NO;
	[self.mapView addOverlays:array];	
	self.shouldAnimate = YES;
	
	[array release];
}

- (IBAction) showAllDistrictOffices:(id)sender {
	
	[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"SHOWING_ALL_DISTRICT_OFFICES"];
	
	// create a LegislatorDetailViewController. This controller will display the full size tile for the element
	
	DistrictOfficeMasterViewController *masterList = [[TexLegeAppDelegate appDelegate] districtOfficeMasterVC];	
	NSFetchedResultsController *frc = [(DistrictOfficeDataSource *) masterList.dataSource fetchedResultsController];
	if (!frc)
		return;
	
	NSArray *array = [frc fetchedObjects];
	
	NSMutableArray *officeAnnotations = [[NSMutableArray alloc] init];
	for (id<MKAnnotation> annotation in [self.mapView annotations]) {
		if ([annotation isKindOfClass:[DistrictOfficeObj class]])
			[officeAnnotations addObject:annotation];
	}
	[self.mapView removeAnnotations:officeAnnotations];
	[officeAnnotations release];
	
	[self performSelector:@selector(animateToState:) withObject:nil afterDelay:0.3f];
	self.shouldAnimate = NO;
	[self.mapView addAnnotations:array];	
	self.shouldAnimate = YES;

	[self showAllDistrictMaps:sender];
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


- (NSArray *) districtsContainingCoordinate:(CLLocationCoordinate2D)aCoordinate {
		
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSManagedObjectContext *context = [[TexLegeAppDelegate appDelegate] managedObjectContext];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"DistrictMapObj" inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	[fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"legislator", @"district", @"chamber", 
										@"minLat", @"maxLat", @"minLon", @"maxLon", nil]];
	
		NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"district" ascending:YES] ;
		NSSortDescriptor *sort2 = [[NSSortDescriptor alloc] initWithKey:@"chamber" ascending:NO] ;
		[fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sort1, sort2, nil]];
		[sort1 release];
		[sort2 release];
	
	NSError *error = nil;
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	if (error) {
		debug_NSLog(@"Problem fetching district maps.");
		return nil;
	}
	
	NSMutableArray *districts = [[[NSMutableArray alloc] initWithCapacity:181] autorelease];
	for (DistrictMapObj *map in fetchedObjects) {
		if ([map districtContainsCoordinate:aCoordinate])
			[districts addObject:map];
	}
	
	//[self.mapView removeOverlays:[self.mapView overlays]];
	
	//[self performSelector:@selector(animateToState:) withObject:nil afterDelay:0.3f];
	//self.shouldAnimate = NO;
	//[self.mapView addOverlays:array];	
	
	return districts;
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
	NSArray *districts = [self districtsContainingCoordinate:placemark.coordinate];
	for (DistrictMapObj *district in districts) {
		//[self.mapView  performSelector:@selector(addOverlay:) withObject:[district polyline] afterDelay:0.3f];
		[self.mapView  performSelector:@selector(addOverlay:) withObject:[district polygon] afterDelay:0.3f];
		for (DistrictOfficeObj *office in district.legislator.districtOffices)
			[self.mapView  performSelector:@selector(addAnnotation:) withObject:office afterDelay:0.3f];
	}
	
	[self.reverseGeocoder cancel];
	self.reverseGeocoder = nil;
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    debug_NSLog(@"MKReverseGeocoder has failed: %@", error);
}


-(void)forwardGeocoderFoundLocation
{
	
	id<MKAnnotation> lastAnnotation = [[self.mapView annotations] lastObject];	
	
	if(self.forwardGeocoder.status == G_GEO_SUCCESS)
	{
		NSInteger searchResults = [self.forwardGeocoder.results count];
		
		// Add placemarks for each result
		for(NSInteger i = 0; i < searchResults; i++)
		{
			BSKmlResult *place = [self.forwardGeocoder.results objectAtIndex:i];
			
			// Add a placemark on the map
			CustomAnnotation *placemark = [[[CustomAnnotation alloc] initWithBSKmlResult:place] autorelease];
			
			//self.shouldAnimate = NO;
			NSArray *districts = [self districtsContainingCoordinate:placemark.coordinate];
			for (DistrictMapObj *district in districts) {
				//[self.mapView addOverlay:[district polyline]];
				[self.mapView addOverlay:[district polygon]];
				for (DistrictOfficeObj *office in district.legislator.districtOffices) {
					[self.mapView addAnnotation:office];
				}
			}
			//self.shouldAnimate = YES;
			[self.mapView addAnnotation:placemark];	

		}
		
		if([self.forwardGeocoder.results count] >= 1)
		{
			BSKmlResult *place = [self.forwardGeocoder.results objectAtIndex:0];
			
			// Zoom into the location		
			//[mapView setRegion:place.coordinateRegion animated:TRUE];
			
			if (self.shouldAnimate) {
				if (lastAnnotation) { // we've already got one annotation set, let's zoom in/out
					[self performSelector:@selector(animateToState:) withObject:lastAnnotation afterDelay:0.3];
					[self performSelector:@selector(animateToAnnotation:) withObject:place afterDelay:1.7];        
				}
				else
					[self performSelector:@selector(animateToAnnotation:) withObject:place afterDelay:0.3];
			}
			
		}
		
		// Dismiss the keyboard
		[self.searchBar resignFirstResponder];
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
	
	
	debug_NSLog(@"Searching for: %@", theSearchBar.text);
	if(forwardGeocoder == nil)
	{
		forwardGeocoder = [[BSForwardGeocoder alloc] initWithDelegate:self];
	}
	
	// Forward geocode!
	[forwardGeocoder findLocation:theSearchBar.text];
	
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


- (void)mapView:(MKMapView *)theMapView didAddAnnotationViews:(NSArray *)views
{
	[self dismissDistrictOfficesPopover:nil];

	for (MKAnnotationView *aView in views) {
		if ([aView.annotation class] == [MKUserLocation class])
			//[aView isKindOfClass:NSClassFromString(@"MKUserLocationView")])
		{
			// we have received our current location, so start reverse geocoding the address
			[self reverseGeocodeCurrentLocation];
			
			if (!theMapView.userLocationVisible){
				MKCoordinateSpan span = MKCoordinateSpanMake(2.f, 2.f);
				
				CLLocationCoordinate2D location=self.mapView.userLocation.coordinate;
				MKCoordinateRegion region = MKCoordinateRegionMake(location, span);
				[theMapView setRegion:region animated:TRUE];

				//[self.mapView regionThatFits:region];
				//debug_NSLog(@"[Found user location] %f %f %f %f", location.latitude, location.longitude, span.latitudeDelta, span.longitudeDelta);
			}
			self.shouldAnimate = YES;

			return;
		}
	}
	
	MKAnnotationView *lastView = [views lastObject];
	id<MKAnnotation> lastAnnotation = lastView.annotation;
	MKCoordinateRegion region;
	
	if (lastAnnotation && self.shouldAnimate) {
		
		if ([lastAnnotation isKindOfClass:[DistrictOfficeObj class]]) {
			DistrictOfficeObj *obj = lastAnnotation;
			region = [obj region];
			[theMapView setRegion:region animated:TRUE];
		}
		else if ([lastAnnotation isKindOfClass:[CustomAnnotation class]]) {
			CustomAnnotation *obj = lastAnnotation;
			region = [obj region];
			[theMapView setRegion:region animated:TRUE];
		}
		else {
			MKCoordinateSpan span = {2.f,2.f};
			
			MKCoordinateRegion region = MKCoordinateRegionMake(lastAnnotation.coordinate, span);
			[theMapView setRegion:region animated:TRUE];
		}

		
		[theMapView selectAnnotation:lastAnnotation animated:YES];
	}
	
	self.shouldAnimate = YES;
}


+ (CGFloat)annotationPadding;
{
    return 10.0f;
}
+ (CGFloat)calloutHeight;
{
    return 80.0f;
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
    if ([annotation isKindOfClass:[DistrictOfficeObj class]]) // for Golden Gate Bridge
    {
		DistrictOfficeObj *districtOffice = (DistrictOfficeObj *)annotation;
		
        // try to dequeue an existing pin view first
        static NSString* districtOfficeAnnotationID = @"districtOfficeAnnotationID";
        DistrictOfficeAnnotationView* pinView = (DistrictOfficeAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:districtOfficeAnnotationID];
        if (!pinView)
        {
            // if an existing pin view was not available, create one
            DistrictOfficeAnnotationView* customPinView = [[[DistrictOfficeAnnotationView alloc]
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
        MKPinAnnotationView* pinView =
		(MKPinAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:customAnnotationIdentifier];
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
			region.span.latitudeDelta = .05f;
			region.span.longitudeDelta = .05f;
			[self.mapView setRegion:region animated:TRUE];

			//debug_NSLog(@"annotation selected %f, %f", annotation.coordinate.latitude, annotation.coordinate.longitude);
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
