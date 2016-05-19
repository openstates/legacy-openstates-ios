//
//  MapViewController.m
//  Created by Greg Combs on 10/12/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "MapViewController.h"
#import "SLFTheme.h"
#import "UserPinAnnotation.h"
#import "UserPinAnnotationView.h"
#import <SLFRestKit/RestKit.h>
#import "SLFAlertView.h"
#import "ColorPinAnnotationView.h"
#import "MultiRowCalloutAnnotationView.h"
#import "MultiRowAnnotation.h"

#define LOCATE_USER_BUTTON_TAG 18887

@interface MapViewController()
@property (nonatomic,strong) CLGeocoder *geocoder;
@property (nonatomic,strong) UserPinAnnotation *searchLocation;
@property (nonatomic,strong) MultiRowAnnotation *calloutAnnotation;
@end

@implementation MapViewController
@synthesize toolbar = _toolbar;
@synthesize searchBar = _searchBar;
@synthesize mapView = _mapView;
@synthesize searchLocation = _searchLocation;
@synthesize geocoder = _geocoder;
@synthesize selectedAnnotationView = _selectedAnnotationView;
@synthesize calloutAnnotation = _calloutAnnotation;

#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.stackWidth = 650;
        _geocoder = [[CLGeocoder alloc] init];
    }
    return self;
}

- (void)dealloc
{
    self.mapView.delegate = nil;
    self.geocoder = nil;
}

- (void)viewDidUnload
{
    self.calloutAnnotation = nil;
    self.selectedAnnotationView = nil;
    self.toolbar = nil;
    self.searchBar = nil;
    self.mapView = nil;
    self.geocoder = nil;
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [SLFAppearance tableBackgroundDarkColor];
    CGFloat barHeight = SLFIsIpad() ? 44 : self.navigationController.navigationBar.height;
    CGRect mapViewRect, toolbarRect, searchRect;
    [self getControlFrameCalculationsWithBarHeight:barHeight searchRect:&searchRect toolbarRect:&toolbarRect mapViewRect:&mapViewRect];
    self.searchBar = [self setUpSearchBarWithFrame:searchRect];
    self.toolbar = [self setUpToolBarWithFrame:toolbarRect];
    self.mapView = [self setUpMapViewWithFrame:mapViewRect];
    self.screenName = @"Map Screen";
}

- (void)didReceiveMemoryWarning {
    if (self.isViewLoaded && self.mapView)
        [self resetMap:nil]; // clean house!
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)getControlFrameCalculationsWithBarHeight:(CGFloat)barHeight searchRect:(CGRect *)searchRef toolbarRect:(CGRect *)toolbarRef mapViewRect:(CGRect *)mapViewRef {
    NSParameterAssert(searchRef && toolbarRef && mapViewRef);
    CGRect viewRect = self.view.bounds;
    CGRect mapViewRect;
    CGRect toolbarRect;
    if (SLFIsIpad())
        CGRectDivide(viewRect, &toolbarRect, &mapViewRect, barHeight, CGRectMinYEdge);
    else {
        CGRectDivide(viewRect, &mapViewRect, &toolbarRect, CGRectGetHeight(viewRect)-barHeight, CGRectMinYEdge);
    }
    *searchRef = CGRectMake(0, 0, CGRectGetWidth(viewRect), barHeight);
    *toolbarRef = toolbarRect;
    *mapViewRef = mapViewRect;
}

#pragma mark - View Configuration

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if (SLFIsIpad())
        return;
    CGFloat barHeight = self.navigationController.navigationBar.height;
    CGRect mapViewRect;
    CGRect toolbarRect;
    CGRect searchRect;
    [self getControlFrameCalculationsWithBarHeight:barHeight searchRect:&searchRect toolbarRect:&toolbarRect mapViewRect:&mapViewRect];
    __weak __typeof__(self) wSelf = self;
    [UIView animateWithDuration:duration animations:^{
        wSelf.mapView.frame = mapViewRect;
        wSelf.searchBar.frame = searchRect;
        wSelf.toolbar.frame = toolbarRect;
    }];
}

- (UISearchBar *)setUpSearchBarWithFrame:(CGRect)rect {
    UISearchBar *aBar = [[UISearchBar alloc] initWithFrame:rect];
    aBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    aBar.delegate = self;
    if (!SLFIsIpad())
        self.navigationItem.titleView = aBar;
    else {
        aBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return aBar;
}

- (MKMapView *)setUpMapViewWithFrame:(CGRect)rect
{
    if (SLFIsIpad())
        rect = CGRectInset(rect, 20, 0);
    MKMapView *aView = [[MKMapView alloc] initWithFrame:rect];
    [self.view addSubview:aView];
    aView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    aView.delegate = self;
    aView.opaque = YES;
    aView.showsUserLocation = NO;
    aView.region = self.mapRegion;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.delegate = self;
    [aView addGestureRecognizer:longPress];        
    return aView;
}

- (UIToolbar *)setUpToolBarWithFrame:(CGRect)rect {
    NSAssert(self.searchBar, @"The searchBar must be configured (using setUpSearchBar) before the toolbar.");
    UIToolbar *aToolbar = [[UIToolbar alloc] initWithFrame:rect];
    [self.view addSubview:aToolbar];
    UIBarButtonItem *locate = SLFToolbarButton([UIImage imageNamed:@"193-location-arrow"], self, @selector(locateUser:));
    locate.tag = LOCATE_USER_BUTTON_TAG;
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UISegmentedControl *mapTypeSwitch = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"Map",@""), NSLocalizedString(@"Satellite",@""),NSLocalizedString(@"Hybrid",@""), nil]];
    mapTypeSwitch.selectedSegmentIndex = 0;
//    mapTypeSwitch.segmentedControlStyle = UISegmentedControlStyleBar;
    [mapTypeSwitch addTarget:self action:@selector(changeMapType:) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *mapType = [[UIBarButtonItem alloc] initWithCustomView:mapTypeSwitch];
    NSMutableArray *barItems = [[NSMutableArray alloc] initWithObjects:flex, locate, flex, mapType, flex, nil];

    if (!SLFIsIOS5OrGreater()) {
        UIColor *blue = [SLFAppearance accentBlueColor];
        UIColor *green = [SLFAppearance cellSecondaryTextColor];
        aToolbar.tintColor = blue;
        mapTypeSwitch.tintColor = green;
        self.searchBar.tintColor = blue;
        if (!SLFIsIpad())
            self.searchBar.tintColor = green;
    }
    if (SLFIsIpad()) {
        UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithCustomView:self.searchBar];
        self.searchBar.width = 235;
        search.width = 235;
        [barItems addObject:search];
        [barItems addObject:flex];
        SLFRelease(search);
        aToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    }
    else {
        aToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        self.hidesBottomBarWhenPushed = YES;
    }
    [aToolbar setItems:barItems animated:YES];
    SLFRelease(flex);
    SLFRelease(mapType);
    SLFRelease(mapTypeSwitch);
    SLFRelease(barItems);
    return aToolbar;
}

- (NSUInteger)indexOfToolbarItemWithTag:(NSInteger)searchTag
{
    if (!self.toolbar)
        return NSNotFound;

    return [self.toolbar.items indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL * stop){
        UIBarButtonItem *item = (UIBarButtonItem *)obj;
        *stop = (item.tag == searchTag);
        return *stop;
    }];
}

- (void)showLocateUserButton
{
    if (!self.isViewLoaded)
        return;
    UIToolbar *toolbar = self.toolbar;
    if (!toolbar)
        return;

    NSUInteger foundIndex = [self indexOfToolbarItemWithTag:LOCATE_USER_BUTTON_TAG];

    if (foundIndex != NSNotFound
        && [toolbar.items count] > foundIndex)
    {
        UIBarButtonItem *locate = SLFToolbarButton([UIImage imageNamed:@"193-location-arrow"], self, @selector(locateUser:));
        locate.tag = LOCATE_USER_BUTTON_TAG;

        NSMutableArray *items = [[NSMutableArray alloc] initWithArray:toolbar.items];
        items[foundIndex] = locate;
        [toolbar setItems:items animated:YES];
    }
}

- (void)showLocateActivityButton
{
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [activityIndicator startAnimating];
    UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    activityItem.tag = LOCATE_USER_BUTTON_TAG;
    NSMutableArray *items = [[NSMutableArray alloc] initWithArray:self.toolbar.items];
    NSUInteger foundIndex = [self indexOfToolbarItemWithTag:LOCATE_USER_BUTTON_TAG];
    if (foundIndex != NSNotFound
        && [self.toolbar.items count] > foundIndex)
    {
        [items replaceObjectAtIndex:foundIndex withObject:activityItem];
    }
    [self.toolbar setItems:items animated:YES];
}

#pragma mark - Actions

- (void)stackOrPushViewController:(UIViewController *)viewController
{
    if (!SLFIsIpad())
    {
        [self.navigationController pushViewController:viewController animated:YES];
        return;
    }
    [self.stackController pushViewController:viewController fromViewController:self animated:YES];
}

- (IBAction)changeMapType:(id)sender
{
    if (sender && [sender respondsToSelector:@selector(selectedSegmentIndex)])
    {
        NSInteger index = [sender selectedSegmentIndex];
        self.mapView.mapType = index;
    }
}

- (IBAction)resetMap:(id)sender
{
    MKMapView *mapView = self.mapView;
    mapView.showsUserLocation = NO;
    [mapView removeOverlays:mapView.overlays];
    [mapView removeAnnotations:mapView.annotations];
}

- (IBAction)locateUser:(id)sender
{
    [self resetMap:sender];
    [self showLocateActivityButton];  // this gets changed in viewForAnnotation once we receive the location
    if ([CLLocationManager locationServicesEnabled]) 
        self.mapView.showsUserLocation = YES;
}

#pragma mark - Gestures

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer
        && gestureRecognizer.view
        && [gestureRecognizer.view isKindOfClass:[MKMapView class]])
    {
        return YES;
    }
    return NO;
}

- (void)handleLongPress:(UILongPressGestureRecognizer*)longPressRecognizer
{
    if (!longPressRecognizer || longPressRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    MKMapView *mapView = self.mapView;
    CGPoint touchPoint = [longPressRecognizer locationInView:mapView];
    CLLocationCoordinate2D touchCoord = [mapView convertPoint:touchPoint toCoordinateFromView:mapView];
    [self resetMap:nil];
    [mapView setCenterCoordinate:touchCoord animated:YES];
    [self geocodeAddressWithCoordinate:touchCoord];
}

#pragma mark - Regions and Annotations

- (void)beginBoundarySearchForCoordininate:(CLLocationCoordinate2D)coordinate { // override as needed
    RKLogCritical(@"This Does Nothing!!!");
}

- (MKCoordinateRegion)mapRegion
{
    // Defaults to United States
    return MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.250556, -96.358333), MKCoordinateSpanMake(62.20933368, 25.85818456)); 
}

- (CLCircularRegion *)usRegion
{
    MKCoordinateRegion mapRegion = [self mapRegion];
    CLLocationCoordinate2D mapCenter = mapRegion.center;
    MKCoordinateSpan mapSpan = mapRegion.span;
    CLLocation *mapCenterLocation = [[CLLocation alloc] initWithLatitude: mapCenter.latitude longitude: mapCenter.longitude];
    CLLocationDegrees degreeDelta = 0;
    CLLocation *convertedLocation = nil;

    if (mapSpan.latitudeDelta > mapSpan.longitudeDelta)
    {
        degreeDelta = mapSpan.longitudeDelta / 2;
        convertedLocation = [[CLLocation alloc] initWithLatitude:mapCenter.latitude longitude:(mapCenter.longitude - degreeDelta)];
    }
    else
    {
        degreeDelta = mapSpan.latitudeDelta / 2;
        convertedLocation = [[CLLocation alloc] initWithLatitude:(mapCenter.latitude - degreeDelta) longitude:mapCenter.longitude];
    }

    CLLocationDistance distance = [convertedLocation distanceFromLocation:mapCenterLocation];
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:mapCenter radius:distance identifier:@"SLFUSRegion"];
    return region;
}

- (void)moveMapToRegion:(MKCoordinateRegion)newRegion
{
    if (!self.isViewLoaded)
        return;
    [self.mapView setRegion:newRegion animated:YES];
}

- (void)animateToAnnotation:(id<MKAnnotation>)annotation
{
    if (!annotation)
        return;
    static const MKCoordinateSpan kStandardZoomSpan = {2.f, 2.f};
    [self moveMapToRegion:MKCoordinateRegionMake(annotation.coordinate, kStandardZoomSpan)];
}

- (void)moveMapToAnnotation:(id<MKAnnotation>)annotation
{
    [self performSelector:@selector(animateToAnnotation:) withObject:annotation afterDelay:0.7];    
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Failed to determine your geographic location due to the following: %@", @""), [error localizedDescription]];
    [SLFAlertView showWithTitle:NSLocalizedString(@"Geolocation Error", @"") message:message buttonTitle:NSLocalizedString(@"OK", @"")];
    mapView.showsUserLocation = NO;
    [self showLocateUserButton];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if (!userLocation)
        return;
    [self showLocateUserButton];
    [self beginBoundarySearchForCoordininate:userLocation.coordinate];
    if (mapView.userLocationVisible)
        return;
    for (id annotation in mapView.annotations) {
        if ([annotation isKindOfClass:[MKUserLocation class]]) {
            [self performSelector:@selector(moveMapToAnnotation:) withObject:annotation afterDelay:.5f];
            break;
        }
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState != MKAnnotationViewDragStateEnding)
        return;
    if ([annotationView.annotation isEqual:self.searchLocation])
        self.searchLocation.delegate = nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for (MKAnnotationView *aView in views)
    {
        if ([aView.annotation class] == [MKUserLocation class])
        {            
            if (!mapView.userLocationVisible)
                [self performSelector:@selector(moveMapToAnnotation:) withObject:aView.annotation afterDelay:.5f];
            [self showLocateUserButton];
            return;
        }
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;

    if ([annotation isKindOfClass:[UserPinAnnotation class]])  
    {
        UserPinAnnotationView* pinView = (UserPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:UserPinReuseIdentifier];
        if (!pinView)
            return [UserPinAnnotationView pinViewWithAnnotation:annotation];
        pinView.annotation = annotation;
        return pinView;
    }
    if (![annotation conformsToProtocol:@protocol(MultiRowAnnotationProtocol)])
        return nil;
    NSObject <MultiRowAnnotationProtocol> *newAnnotation = (NSObject <MultiRowAnnotationProtocol> *)annotation;
    if (newAnnotation == self.calloutAnnotation)
    {
        MultiRowCalloutAnnotationView *annotationView = (MultiRowCalloutAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:MultiRowCalloutReuseIdentifier];
        if (!annotationView)
            annotationView = [MultiRowCalloutAnnotationView calloutWithAnnotation:newAnnotation onCalloutAccessoryTapped:nil];
        else
            annotationView.annotation = newAnnotation;

        if (!self.selectedAnnotationView)
            self.selectedAnnotationView = annotationView;

        annotationView.parentAnnotationView = self.selectedAnnotationView;
        annotationView.mapView = mapView;
        return annotationView;
    }
    ColorPinAnnotationView *annotationView = (ColorPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:ColorPinReuseIdentifier];
    if (!annotationView)
        annotationView = [ColorPinAnnotationView pinViewWithAnnotation:newAnnotation];
    [annotationView setPinColorWithAnnotation:newAnnotation];
    annotationView.annotation = newAnnotation;
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView
{
    // Sometimes we get an annotation, not an annotation view as the incoming method parameter?
    id<MKAnnotation> annotation = aView.annotation;
    if (!annotation || ![aView isSelected])
        return;

    if ( NO == [annotation isKindOfClass:[MultiRowCalloutCell class]] &&
        [annotation conformsToProtocol:@protocol(MultiRowAnnotationProtocol)] )
    {
        NSObject <MultiRowAnnotationProtocol> *pinAnnotation = (NSObject <MultiRowAnnotationProtocol> *)annotation;
        self.selectedAnnotationView = aView;
        if (self.calloutAnnotation)
            [mapView removeAnnotation:self.calloutAnnotation];
        self.calloutAnnotation = [[MultiRowAnnotation alloc] init];
        [self.calloutAnnotation copyAttributesFromAnnotation:pinAnnotation];
        [mapView addAnnotation:self.calloutAnnotation];
        return;
    }
    CLLocationCoordinate2D coordinate = [annotation coordinate];
    if (CLLocationCoordinate2DIsValid(coordinate))
        [mapView setCenterCoordinate:coordinate animated:YES];

    if ([annotation isKindOfClass:[UserPinAnnotation class]])
        self.searchLocation = (UserPinAnnotation *)annotation;
    self.selectedAnnotationView = aView;
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)aView
{
    MultiRowAnnotation *annotation = (MultiRowAnnotation *)aView.annotation;
    if (!annotation || ![annotation isKindOfClass:[MultiRowAnnotation class]])
        return;
    GenericPinAnnotationView *pinView = (GenericPinAnnotationView *)aView;
    if (self.calloutAnnotation
        && !pinView.preventSelectionChange)
    {
        [mapView removeAnnotation:_calloutAnnotation];
        self.calloutAnnotation = nil;
    }
    self.selectedAnnotationView = nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)aView calloutAccessoryControlTapped:(UIControl *)control
{
    RKLogInfo(@"Annotation accessory tapped, does nothing by default %@", control);
}

- (void)annotationCoordinateChanged:(id)sender
{
    if (![sender isKindOfClass:[UserPinAnnotation class]])
        return;
    if (!self.searchLocation || ![sender isEqual:self.searchLocation])
        self.searchLocation = sender;
    [self resetMap:sender];
    [self geocodeAddressWithCoordinate:self.searchLocation.coordinate];
    [self beginBoundarySearchForCoordininate:self.searchLocation.coordinate];
}

#pragma mark - Geocoding

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar
{
    [self resetMap:aSearchBar];
    [self geocodeCoordinateWithAddress:aSearchBar.text];
}

- (void)geocodeCoordinateWithAddress:(NSString *)address
{
    [self showLocateActivityButton];

    if (!_geocoder)
        _geocoder = [[CLGeocoder alloc] init];

    __weak MapViewController *bself = self;
    [_geocoder geocodeAddressString:address inRegion:[self usRegion] completionHandler:^(NSArray<CLPlacemark *> * placemarks, NSError * error) {
        if (!bself)
            return;
        if (error || !placemarks || ![placemarks count])
        {
            RKLogError(@"Geocoder has failed: %@", error);
            [bself showLocateUserButton];
            return;
        }
        [bself geocoderDidFindPlacemarks:placemarks];
    }];
}

- (void)geocodeAddressWithCoordinate:(CLLocationCoordinate2D)newCoord
{
    [self showLocateActivityButton];

    if (!_geocoder)
        _geocoder = [[CLGeocoder alloc] init];

    CLLocation *location = [[CLLocation alloc] initWithLatitude:newCoord.latitude longitude:newCoord.longitude];

    __weak MapViewController *bself = self;
    [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * placemarks, NSError * error) {
        if (!bself)
            return;
        if (error || !placemarks || ![placemarks count])
        {
            RKLogError(@"Geocoder has failed: %@", error);
            [bself showLocateUserButton];
            return;
        }
        [bself geocoderDidFindPlacemarks:placemarks];
    }];
}

- (void)geocoderDidFindPlacemarks:(NSArray<CLPlacemark *> *)placemarks
{
    if (!placemarks || ![placemarks count] || !self.isViewLoaded)
        return;

    CLPlacemark *placemark = placemarks[0];

    RKLogInfo(@"Geocoder found placemark: %@ (was %@)", placemark, self.searchLocation);

    [self showLocateUserButton];

    if (self.searchLocation)
    {
        [self.mapView removeAnnotation:self.searchLocation];
        self.searchLocation = nil;
    }

    UserPinAnnotation *annotation = [[UserPinAnnotation alloc] initWithPlacemark:placemark];
    annotation.delegate = self;

    [self.mapView addAnnotation:annotation];
    
    [self beginBoundarySearchForCoordininate:annotation.coordinate];
    [self moveMapToAnnotation:annotation];
    self.searchLocation = annotation;

    if (self.searchBar)
        [self.searchBar resignFirstResponder];
}

@end
