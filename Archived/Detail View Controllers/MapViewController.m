//
//  MapViewController.m
//  Created by Gregory Combs on 8/16/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "MapViewController.h"
#import "SLFDataModels.h"
#import "SLFRestKitManager.h"

#import "TexLegeTheme.h"
#import "UtilityMethods.h"
#import "LegislatorDetailViewController.h"

#import "DistrictMapDataSource.h"

#import "UserPinAnnotation.h"
#import "UserPinAnnotationView.h"

#import "LocalyticsSession.h"
#import "UIColor-Expanded.h"

#import "TexLegeMapPins.h"
#import "DistrictPinAnnotationView.h"
#import "SLFAlertView.h"
#import "StateMetaLoader.h"

@interface MapViewController (Private)
- (MKCoordinateRegion) unitedStatesRegion;
- (void) animateToState;
- (void) animateToAnnotation:(id<MKAnnotation>)annotation;
- (void) clearAnnotationsAndOverlays;
- (void) clearOverlaysExceptRecent;
- (void) clearAnnotationsAndOverlaysExcept:(id)annotation;
- (void) resetMapViewWithAnimation:(BOOL)animated;
- (BOOL) region:(MKCoordinateRegion)region1 isEqualTo:(MKCoordinateRegion)region2;
- (IBAction) showHidePopoverButton:(id)sender;

- (void) geocodeAddressWithCoordinate:(CLLocationCoordinate2D)newCoord;
- (void) geocodeCoordinateWithAddress:(NSString *)address;
@end

NSInteger colorIndex;
static MKCoordinateSpan kStandardZoomSpan = {2.f, 2.f};

@implementation MapViewController
@synthesize resourceClass;
@synthesize resourcePath;
@synthesize region;

@synthesize mapView, geocoder, searchLocation;
@synthesize toolbar, searchBar;
@synthesize senateDistrictView, houseDistrictView;
@synthesize masterPopover;

@synthesize geoLegeSearch;

#pragma mark -
#pragma mark Initialization and Memory Management

- (NSString *)nibName {
    if ([UtilityMethods isIPadDevice])
        return @"MapViewController~ipad";
    else
        return @"MapViewController~iphone";
}

- (void) awakeFromNib {
    [super awakeFromNib];
    self.resourceClass = [SLFDistrict class];
    self.region = [self unitedStatesRegion];
}

- (void) dealloc {
    self.resourcePath = nil;
    
    self.geoLegeSearch = nil;
    self.geocoder = nil;
    self.searchLocation = nil;

    self.masterPopover = nil;
    self.toolbar = nil;
    self.searchBar = nil;
    self.mapView = nil;

    [super dealloc];
}

- (void) didReceiveMemoryWarning {    
    [self clearOverlaysExceptRecent];

    [super didReceiveMemoryWarning];
}

- (void) viewDidLoad {
    [super viewDidLoad];
        
    colorIndex = 0;
    
    [self.view setBackgroundColor:[TexLegeTheme backgroundLight]];
    self.mapView.showsUserLocation = NO;
    self.mapView.region = self.region;

    self.navigationController.navigationBar.tintColor = [TexLegeTheme navbar];
    self.toolbar.tintColor = [TexLegeTheme navbar];
    self.searchBar.tintColor = [TexLegeTheme navbar];
    if ([UtilityMethods isIPadDevice]) {
        self.navigationItem.titleView = self.toolbar; 
    }
    else {
        self.hidesBottomBarWhenPushed = YES;
        self.navigationItem.titleView = self.searchBar;
    }
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressRecognizer.delegate = self;
    [self.mapView addGestureRecognizer:longPressRecognizer];        
    [longPressRecognizer release];
    
    
}

- (void) viewDidUnload {    
    self.geoLegeSearch = nil;
    self.geocoder = nil;
    
    self.searchBar = nil;
    self.mapView = nil;    
    self.toolbar = nil;
    self.region = [self unitedStatesRegion];

    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
        
    NSURL *tempURL = [NSURL URLWithString:[UtilityMethods texLegeStringWithKeyPath:@"ExternalURLs.googleMapsWeb"]];        
    if (![TexLegeReachability canReachHostWithURL:tempURL])// do we have a good URL/connection?
        return;
}

- (void) viewDidDisappear:(BOOL)animated {
    self.mapView.showsUserLocation = NO;        
    [self.mapView removeOverlays:self.mapView.overlays];    // frees up memory
    
    [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark RestKit


- (void)loadDataWithResourcePath:(NSString *)newPath {
    if (!newPath)
        return;
    
    self.resourcePath = newPath;
    
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    NSDictionary *queryParams = [NSDictionary dictionaryWithObject:SUNLIGHT_APIKEY forKey:@"apikey"];
    NSString *queryString = [newPath appendQueryParams:queryParams];
    
    RKObjectMapping* objMapping = [objectManager.mappingProvider objectMappingForClass:self.resourceClass];
    RKLogDebug(@"loading map at: %@", queryString);
    [objectManager loadObjectsAtResourcePath:queryString objectMapping:objMapping delegate:self];
}

- (void)setMapDetailObject:(id)detailObj {
    if (!detailObj)
        return;
    
    if ([detailObj isKindOfClass:[SLFDistrict class]]) {
        SLFDistrict *map = detailObj;
        if (!IsEmpty(map.shape)) {
            [self setDistrictMap:map];
            return;
        }
        detailObj = map.boundaryID;
    }

    if ([detailObj isKindOfClass:[NSString class]]) {
        [self loadDataWithResourcePath:[NSString stringWithFormat:@"/districts/boundary/%@/", detailObj]];
    }
}

- (void)setDistrictMap:(SLFDistrict *)newMap {
    
    [self clearAnnotationsAndOverlays];
    
    if (!newMap) {
        return;
    }    
    [self.mapView addAnnotation:newMap];
    self.region = newMap.region;

    MKPolygon *polygon = [newMap polygonFactory];
    
    if (polygon) {
        [self.mapView addOverlay:polygon];
    }    
}

#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObject:(id)object {    
    
    if (!object || NO == [object isKindOfClass:self.resourceClass])
        return;
    
    [self setDistrictMap:object];    
}


- (void)objectLoaderDidFinishLoading:(RKObjectLoader*)objectLoader {
    //self.loading = NO;
    //[[NSNotificationCenter defaultCenter] postNotificationName:kNotifyTableDataUpdated object:self];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    //self.loading = NO;
    [SLFRestKitManager showFailureAlertWithRequest:objectLoader error:error];
    //[[NSNotificationCenter defaultCenter] postNotificationName:kNotifyTableDataError object:self];
}

#pragma mark -
#pragma mark Animation and Zoom

- (void) setRegion:(MKCoordinateRegion)newRegion {
    region = newRegion;
    if (self.isViewLoaded)
        [self.mapView setRegion:newRegion animated:YES];
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

- (void) resetMapViewWithAnimation:(BOOL)animated {
    [self clearAnnotationsAndOverlays];
}

- (MKCoordinateRegion) unitedStatesRegion {
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(37.250556, -96.358333); 
    MKCoordinateSpan span = MKCoordinateSpanMake((1.04*(126.766667 - 66.95)), (1.04*(49.384472 - 24.520833))); 
    return MKCoordinateRegionMake(center, span); 
}

- (void)animateToAnnotation:(id<MKAnnotation>)annotation
{
    if (!annotation)
        return;
    self.region = MKCoordinateRegionMake(annotation.coordinate, kStandardZoomSpan);
}

- (void)moveMapToAnnotation:(id<MKAnnotation>)annotation {
    if (masterPopover)
        [masterPopover dismissPopoverAnimated:YES];
    
    [self performSelector:@selector(animateToAnnotation:) withObject:annotation afterDelay:0.7];    
}

#pragma mark -
#pragma mark Gesture Recognizer

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
        
        [self.mapView setCenterCoordinate:touchCoord animated:YES];
        
        [self geocodeAddressWithCoordinate:touchCoord];                
    }
}

#pragma mark -
#pragma mark Popover Support


- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    barButtonItem.title = NSLocalizedStringFromTable(@"District Maps", @"StandardUI", @"Short name for district maps tab");
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
    if ([UtilityMethods isLandscapeOrientation]) {
        [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"ERR_POPOVER_IN_LANDSCAPE"];
    }         
}    


#pragma mark -
#pragma mark Properties

- (BOOL) region:(MKCoordinateRegion)region1 isEqualTo:(MKCoordinateRegion)region2 {
    MKMapPoint coord1 = MKMapPointForCoordinate(region1.center);
    MKMapPoint coord2 = MKMapPointForCoordinate(region2.center);
    BOOL coordsEqual = MKMapPointEqualToPoint(coord1, coord2);
    
    BOOL spanEqual = region1.span.latitudeDelta == region2.span.latitudeDelta; // let's just only do one, okay?
    return (coordsEqual && spanEqual);
}

#pragma mark -
#pragma mark District Map Searching

- (void) searchDistrictMapsForCoordinate:(CLLocationCoordinate2D)aCoordinate {    

    nice_release(geoLegeSearch);
    geoLegeSearch = [[DistrictSearchOperation alloc] init];
    
    if (geoLegeSearch) {
        [geoLegeSearch searchForCoordinate:aCoordinate 
                                  delegate:self];
    
    }    
    
}

- (void)districtSearchOperationDidFinishSuccessfully:(DistrictSearchOperation *)op {
        
    for (NSNumber *districtID in op.foundIDs) {
        SLFDistrict *district = [SLFDistrict findFirstByAttribute:@"boundaryID" withValue:districtID];
        if (district)
            [self setMapDetailObject:district];
        else
            [self setMapDetailObject:districtID];        
    }    
}

- (void)districtSearchOperationDidFail:(DistrictSearchOperation *)op 
                             errorMessage:(NSString *)errorMessage 
                                   option:(DistrictSearchOperationFailOption)failOption {    
    
    if (failOption == DistrictSearchOperationFailOptionLog) {
        RKLogError(@"%@", errorMessage);
    }
    else {
        [SLFAlertView showWithTitle:NSLocalizedStringFromTable(@"Geolocation Error", @"AppAlerts", @"Alert box title for an error")
                            message:errorMessage
                        buttonTitle:NSLocalizedStringFromTable(@"OK", @"StandardUI", @"Confirming a selection")];
    }
    
    self.geoLegeSearch = nil;
}

#pragma mark -
#pragma mark Control Element Actions

- (IBAction)changeMapType:(id)sender {
    if (sender && [sender respondsToSelector:@selector(selectedSegmentIndex)]) {
        NSInteger index = [sender selectedSegmentIndex];
        self.mapView.mapType = index;
    }
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
    [self.toolbar setItems:items animated:YES];
    [locateItem release];
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
    [self.toolbar setItems:items animated:YES];
    [activityItem release];
    [items release];
}

- (IBAction)locateUser:(id)sender {
    [self clearAnnotationsAndOverlays];
    [self showLocateActivityButton];                // this gets changed in viewForAnnotation once we receive the location

    if ([UtilityMethods locationServicesEnabled]) 
        self.mapView.showsUserLocation = YES;
}

- (IBAction) showAllDistricts:(id)sender {
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"SHOWING_ALL_DISTRICTS"];
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSFetchRequest *fetchRequest = [SLFDistrict fetchRequest];    
    NSArray *districts = [SLFDistrict objectsWithFetchRequest:fetchRequest];
    if (districts) {
        [self resetMapViewWithAnimation:YES];
        self.region = [self unitedStatesRegion];
        [self.mapView addAnnotations:districts];
    }
    [pool drain];
}

- (void)showLegislatorDetails:(SLFLegislator *)legislator
{
    if (!legislator)
        return;
    
    LegislatorDetailViewController *legVC = [[LegislatorDetailViewController alloc] initWithNibName:@"LegislatorDetailViewController" bundle:nil];
    legVC.detailObjectID = legislator.legID;
    [self.navigationController pushViewController:legVC animated:YES];
    [legVC release];
}


#pragma mark - Geocoding

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    [self clearAnnotationsAndOverlays];
    [self geocodeCoordinateWithAddress:theSearchBar.text];
}

- (void)geocodeCoordinateWithAddress:(NSString *)address {
    [self showLocateActivityButton];
    
    //self.geocoder = [[[SVGeocoder alloc] initWithAddress:address inBounds:self.texasRegion] autorelease];
    self.geocoder = [[[SVGeocoder alloc] initWithAddress:address] autorelease];
    [self.geocoder setDelegate:self];
    [self.geocoder startAsynchronous];
}

- (void)geocodeAddressWithCoordinate:(CLLocationCoordinate2D)newCoord {
    [self showLocateActivityButton];

    self.geocoder = [[[SVGeocoder alloc] initWithCoordinate:newCoord] autorelease];
    [self.geocoder setDelegate:self];
    [self.geocoder startAsynchronous];    
}

- (void)geocoder:(SVGeocoder *)geocoder didFindPlacemark:(SVPlacemark *)placemark
{
    RKLogDebug(@"Geocoder found placemark: %@ (was %@)", placemark, self.searchLocation);
    [self showLocateUserButton];

///    [self clearAnnotationsAndOverlays];            ??????

    if (self.searchLocation) {
        [self.mapView removeAnnotation:self.searchLocation];
        self.searchLocation = nil;
    }
    UserPinAnnotation *annotation = [[UserPinAnnotation alloc] initWithSVPlacemark:placemark];
    annotation.coordinateChangedDelegate = self;
    
    [self.mapView addAnnotation:annotation];
    
    [self searchDistrictMapsForCoordinate:annotation.coordinate];
    [self moveMapToAnnotation:annotation];
    
    self.searchLocation = annotation;
    [annotation release];
    
    // is this necessary??? because we will have just created the related annotation view, so we don't need to redisplay it.
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserPinAnnotationAddressChangeKey object:self.searchLocation];
            
    self.geocoder = nil;
    [self.searchBar resignFirstResponder];
}

- (void)geocoder:(SVGeocoder *)geocoder didFailWithError:(NSError *)error
{
    RKLogError(@"SVGeocoder has failed: %@", error);
    
    self.geocoder = nil;
    [self showLocateUserButton];
}

- (void)annotationCoordinateChanged:(id)sender {
    if (![sender isKindOfClass:[UserPinAnnotation class]])
        return;
    
    if (!self.searchLocation || ![sender isEqual:self.searchLocation])
        self.searchLocation = sender;
    
    [self clearAnnotationsAndOverlaysExcept:sender];
    [self geocodeAddressWithCoordinate:self.searchLocation.coordinate];
    [self searchDistrictMapsForCoordinate:self.searchLocation.coordinate];
}

#pragma mark -
#pragma mark MapViewDelegate

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    
    NSString *message = [NSString stringWithFormat:
                         NSLocalizedStringFromTable(@"Failed to determine your geographic location due to the following: %@", @"AppAlerts", @""), 
                         [error localizedDescription]];
    
    [SLFAlertView showWithTitle:NSLocalizedStringFromTable(@"Geolocation Error", @"AppAlerts", @"Alert box title for an error")
                        message:message
                    buttonTitle:NSLocalizedStringFromTable(@"OK", @"StandardUI", @"Confirming a selection")];
    
    self.mapView.showsUserLocation = NO;
    [self showLocateUserButton];

}


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
        [self showLocateUserButton];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    
    if (newState == MKAnnotationViewDragStateEnding)
    {
        if ([annotationView.annotation isEqual:self.searchLocation]) {
            if (self.searchLocation.coordinateChangedDelegate) {
                self.searchLocation.coordinateChangedDelegate = nil;        // it'll handle it once, then we'll do it.
            }
            else {
                RKLogDebug(@"When does this condition happen???");
                [self annotationCoordinateChanged:self.searchLocation];    
            }
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
    
    if ([annotation isKindOfClass:[SLFDistrict class]])
    {
        if ([annotation respondsToSelector:@selector(legislator)]) {
            SLFLegislator *legislator = [annotation performSelector:@selector(legislator)];
            if (legislator) {
                [self showLegislatorDetails:legislator];
            }
        }
    }        
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    if ([annotation isKindOfClass:[SLFDistrict class]]) 
    {
        static NSString* districtAnnotationID = @"districtObjectAnnotationID";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:districtAnnotationID];
        if (!pinView)
        {
            DistrictPinAnnotationView* customPinView = [[[DistrictPinAnnotationView alloc]
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
    
    if ([annotation isKindOfClass:[UserPinAnnotation class]])  
    {
        static NSString* customAnnotationIdentifier = @"customAnnotationIdentifier";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)[theMapView dequeueReusableAnnotationViewWithIdentifier:customAnnotationIdentifier];
        if (!pinView)
        {
            UserPinAnnotationView *customPinView = [[[UserPinAnnotationView alloc] initWithAnnotation:annotation
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

        SLFChamber *mapChamber = nil;
        if (ovTitle) {
            SLFState *state = [[StateMetaLoader sharedStateMeta] selectedState];
            for (SLFChamber *chamber in state.chambers) {
                if ([ovTitle hasSubstring:chamber.shortName caseInsensitive:YES]) {
                    mapChamber = chamber;
                    break;
                }
            }
        }
        if (mapChamber && [mapChamber.type isEqualToString:@"lower"])
            myColor = [TexLegeTheme texasGreen];
        else if (mapChamber && [mapChamber.type isEqualToString:@"upper"]) {
            myColor = [TexLegeTheme texasOrange];
            senate = YES;
        }
        else
            myColor = [UIColor cyanColor];

        MKPolygonView *aView = [[[MKPolygonView alloc] initWithPolygon:(MKPolygon*)overlay] autorelease];
        if (senate) {
            self.senateDistrictView = aView;
        }
        else {
            self.houseDistrictView = aView;
        }

        aView.fillColor = [myColor colorWithAlphaComponent:0.2];
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
    
    return nil;
}



- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView {
    
    id<MKAnnotation> annotation = aView.annotation;
    if (!annotation)
        return;
    
    if (![aView isSelected])
        return;
    
    [self.mapView setCenterCoordinate:annotation.coordinate animated:YES];
    
    if ([annotation isKindOfClass:[UserPinAnnotation class]]) {
        self.searchLocation = (UserPinAnnotation *)annotation;
    }    

    if ([annotation isKindOfClass:[SLFDistrict class]]) {
        SLFDistrict *map = (SLFDistrict *)annotation;
        
        NSMutableArray *toRemove = [[NSMutableArray alloc] initWithArray:self.mapView.overlays];
        BOOL foundOne = NO;
        for (id<MKOverlay>item in self.mapView.overlays) {
            if ([[item title] isEqualToString:[annotation title]]) {    // we clicked on an existing overlay
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
        
        if (!IsEmpty(toRemove)) {
            [self.mapView performSelector:@selector(removeOverlays:) withObject:toRemove];
        }
        [toRemove release];
        
        if (!foundOne) {
            MKPolygon *mapPoly = [map polygonFactory];
            [self.mapView performSelector:@selector(addOverlay:) withObject:mapPoly afterDelay:0.2f];
            [[SLFDistrict managedObjectContext] refreshObject:map mergeChanges:NO];
        }
        self.region = map.region;
    }            
}

#pragma mark -
#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation { // Override to allow rotation. Default returns YES only for UIDeviceOrientationPortrait
    return YES;
}

@end
