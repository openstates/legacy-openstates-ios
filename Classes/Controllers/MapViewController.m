//
//  MapViewController.m
//  Created by Greg Combs on 10/12/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "MapViewController.h"
#import "SLFTheme.h"
#import "SVPlacemark.h"
#import "UserPinAnnotation.h"
#import "UserPinAnnotationView.h"
#import <RestKit/RestKit.h>
#import "SLFAlertView.h"

#import "CalloutMapAnnotation.h"
#import "CalloutMapAnnotationView.h"
#import "BasicMapAnnotation.h"
#import "BasicMapAnnotationView.h"
#import "AccessorizedCalloutMapAnnotationView.h"

#define LOCATE_USER_BUTTON_TAG 18887

@interface MapViewController()
- (UISearchBar *)setUpSearchBarWithFrame:(CGRect)rect;
- (MKMapView *)setUpMapViewWithFrame:(CGRect)rect;
- (UIToolbar *)setUpToolBarWithFrame:(CGRect)rect;
- (void)geocodeAddressWithCoordinate:(CLLocationCoordinate2D)newCoord;
- (void)geocodeCoordinateWithAddress:(NSString *)address;
- (void)handleLongPress:(UILongPressGestureRecognizer*)longPressRecognizer;
- (void)showLocateActivityButton;
- (void)showLocateUserButton;
- (NSUInteger)indexOfToolbarItemWithTag:(NSInteger)searchTag;
@property (nonatomic,retain) SVGeocoder *geocoder;
@property (nonatomic,retain) UserPinAnnotation *searchLocation;
@property (nonatomic,retain) CalloutMapAnnotation *calloutAnnotation;
@property (nonatomic,retain) BasicMapAnnotation *customAnnotation;
@end

@implementation MapViewController
@synthesize toolbar;
@synthesize searchBar;
@synthesize mapView = _mapView;
@synthesize searchLocation;
@synthesize geocoder;
@synthesize selectedAnnotationView = _selectedAnnotationView;
@synthesize calloutAnnotation = _calloutAnnotation;
@synthesize customAnnotation = _customAnnotation;

#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.stackWidth = 650;
    }
    return self;
}

- (void)dealloc {
    self.toolbar = nil;
    self.searchBar = nil;
    self.mapView.delegate = nil;
    self.mapView = nil;
    self.searchLocation = nil;
    self.geocoder = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadView {
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [SLFAppearance tableBackgroundDarkColor];
    CGRect viewRect = self.view.bounds;
    CGRect mapViewRect;
    CGRect toolbarRect;
    CGRect searchRect = CGRectMake(0, 0, CGRectGetWidth(viewRect), 44);
    if (SLFIsIpad())
        CGRectDivide(viewRect, &toolbarRect, &mapViewRect, 44, CGRectMinYEdge);
    else
        CGRectDivide(viewRect, &mapViewRect, &toolbarRect, CGRectGetHeight(viewRect)-44, CGRectMinYEdge);
    self.searchBar = [self setUpSearchBarWithFrame:searchRect];
    self.toolbar = [self setUpToolBarWithFrame:toolbarRect];
    self.mapView = [self setUpMapViewWithFrame:mapViewRect];


    self.customAnnotation = [[[BasicMapAnnotation alloc] initWithLatitude:38.6335 andLongitude:-90.2045] autorelease];
    [self.mapView addAnnotation:self.customAnnotation];
}

- (void)viewDidUnload {
    self.toolbar = nil;
    self.searchBar = nil;
    self.mapView = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - View Configuration

- (UISearchBar *)setUpSearchBarWithFrame:(CGRect)rect {
    UISearchBar *aBar = [[[UISearchBar alloc] initWithFrame:rect] autorelease];
    aBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    aBar.delegate = self;
    if (!SLFIsIpad())
        self.navigationItem.titleView = aBar;
    else {
        aBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return aBar;
}

- (MKMapView *)setUpMapViewWithFrame:(CGRect)rect {
    if (SLFIsIpad())
        rect = CGRectInset(rect, 20, 0);
    MKMapView *aView = [[[MKMapView alloc] initWithFrame:rect] autorelease];
    [self.view addSubview:aView];
    aView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    aView.delegate = self;        
    aView.showsUserLocation = NO;
    aView.region = self.defaultRegion;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.delegate = self;
    [aView addGestureRecognizer:longPress];        
    [longPress release];
    return aView;
}

- (UIToolbar *)setUpToolBarWithFrame:(CGRect)rect {
    NSAssert(self.searchBar, @"The searchBar must be configured (using setUpSearchBar) before the toolbar.");
    UIToolbar *aToolbar = [[[UIToolbar alloc] initWithFrame:rect] autorelease];
    [self.view addSubview:aToolbar];
    UIBarButtonItem *locate = SLFToolbarButton([UIImage imageNamed:@"193-location-arrow"], self, @selector(locateUser:));
    locate.tag = LOCATE_USER_BUTTON_TAG;
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UISegmentedControl *mapTypeSwitch = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"Map",@""), NSLocalizedString(@"Satellite",@""),NSLocalizedString(@"Hybrid",@""), nil]];
    mapTypeSwitch.selectedSegmentIndex = 0;
    mapTypeSwitch.segmentedControlStyle = UISegmentedControlStyleBar;
    [mapTypeSwitch addTarget:self action:@selector(changeMapType:) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *mapType = [[UIBarButtonItem alloc] initWithCustomView:mapTypeSwitch];
    NSMutableArray *barItems = [[NSMutableArray alloc] initWithObjects:flex, locate, flex, mapType, flex, nil];

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

- (NSUInteger)indexOfToolbarItemWithTag:(NSInteger)searchTag {
    NSUInteger index = NSNotFound;
    if (self.toolbar) {
        index = [self.toolbar.items indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL * stop){
            UIBarButtonItem *item = (UIBarButtonItem *)obj;
            *stop = (item.tag == searchTag);
            return *stop;
        }];
    }
    return index;
}

- (void)showLocateUserButton {
    if (!self.toolbar)
        return;
    UIBarButtonItem *locate = SLFToolbarButton([UIImage imageNamed:@"193-location-arrow"], self, @selector(locateUser:));    
    locate.tag = LOCATE_USER_BUTTON_TAG;
    NSMutableArray *items = [[NSMutableArray alloc] initWithArray:self.toolbar.items];
    NSUInteger foundIndex = [self indexOfToolbarItemWithTag:LOCATE_USER_BUTTON_TAG];
    if (foundIndex != NSNotFound && [self.toolbar.items count] > foundIndex) {
        [items replaceObjectAtIndex:foundIndex withObject:locate];
    }
    [self.toolbar setItems:items animated:YES];
    [items release];
}

- (void)showLocateActivityButton {
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [activityIndicator startAnimating];
    UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [activityIndicator release];
    activityItem.tag = LOCATE_USER_BUTTON_TAG;
    NSMutableArray *items = [[NSMutableArray alloc] initWithArray:self.toolbar.items];
    NSUInteger foundIndex = [self indexOfToolbarItemWithTag:LOCATE_USER_BUTTON_TAG];
    if (foundIndex != NSNotFound && [self.toolbar.items count] > foundIndex) {
        [items replaceObjectAtIndex:foundIndex withObject:activityItem];
    }
    [self.toolbar setItems:items animated:YES];
    [activityItem release];
    [items release];
}

#pragma mark - Actions

- (void)stackOrPushViewController:(UIViewController *)viewController {
    if (!SLFIsIpad()) {
        [self.navigationController pushViewController:viewController animated:YES];
        return;
    }
    [self.stackController pushViewController:viewController fromViewController:self animated:YES];
}

- (IBAction)changeMapType:(id)sender {
    if (sender && [sender respondsToSelector:@selector(selectedSegmentIndex)]) {
        NSInteger index = [sender selectedSegmentIndex];
        self.mapView.mapType = index;
    }
}

- (IBAction)resetMap:(id)sender {
    self.mapView.showsUserLocation = NO;
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
}

- (IBAction)locateUser:(id)sender {
    [self resetMap:sender];
    [self showLocateActivityButton];  // this gets changed in viewForAnnotation once we receive the location
    if ([CLLocationManager locationServicesEnabled]) 
        self.mapView.showsUserLocation = YES;
}

#pragma mark - Gestures

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {    
    if (gestureRecognizer && gestureRecognizer.view && [gestureRecognizer.view isKindOfClass:[MKMapView class]])
        return YES;
    return NO;
}

- (void)handleLongPress:(UILongPressGestureRecognizer*)longPressRecognizer {
    if (!longPressRecognizer)
        return;
    if (longPressRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint touchPoint = [longPressRecognizer locationInView:self.mapView];
        CLLocationCoordinate2D touchCoord = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
        [self resetMap:nil];
        [self.mapView setCenterCoordinate:touchCoord animated:YES];
        [self geocodeAddressWithCoordinate:touchCoord];                
    }
}

#pragma mark - Regions and Annotations

- (void)beginBoundarySearchForCoordininate:(CLLocationCoordinate2D)coordinate { // override as needed
    RKLogCritical(@"This Does Nothing!!!");
}

- (MKCoordinateRegion)defaultRegion { // Defaults to United States
    return MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.250556, -96.358333), MKCoordinateSpanMake(62.20933368, 25.85818456)); 
}

- (void)moveMapToRegion:(MKCoordinateRegion)newRegion {
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

- (void)moveMapToAnnotation:(id<MKAnnotation>)annotation {
    [self performSelector:@selector(animateToAnnotation:) withObject:annotation afterDelay:0.7];    
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Failed to determine your geographic location due to the following: %@", @""), [error localizedDescription]];
    [SLFAlertView showWithTitle:NSLocalizedString(@"Geolocation Error", @"") message:message buttonTitle:NSLocalizedString(@"OK", @"")];
    mapView.showsUserLocation = NO;
    [self showLocateUserButton];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
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

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    if (newState != MKAnnotationViewDragStateEnding)
        return;
    if ([annotationView.annotation isEqual:self.searchLocation])
        self.searchLocation.delegate = nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for (MKAnnotationView *aView in views) {
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

    NSString *identifier = nil;
    if ([annotation isKindOfClass:[UserPinAnnotation class]])  
    {
        identifier = UserPinAnnotationViewReuseIdentifier;
        UserPinAnnotationView* pinView = (UserPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (!pinView)
            return [UserPinAnnotationView userPinViewWithAnnotation:annotation identifier:identifier];
        pinView.annotation = annotation;
        return pinView;
    }
    else if (annotation == self.calloutAnnotation) {
        identifier = @"CalloutAnnotation";
        CalloutMapAnnotationView *annotationView = (CalloutMapAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (!annotationView) {
            annotationView = [[[AccessorizedCalloutMapAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
            annotationView.contentHeight = 34.0f;
            UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"silverstar"]];
            logoView.frame = CGRectMake(5, 2, logoView.frame.size.width, logoView.frame.size.height);
            [annotationView.contentView addSubview:logoView];
            [logoView release];
        }
        annotationView.parentAnnotationView = self.selectedAnnotationView;
        annotationView.mapView = mapView;
        return annotationView;
    } else if (annotation == self.customAnnotation) {
        identifier = @"CustomAnnotation";
        MKPinAnnotationView* annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (!annotationView) {
            annotationView = [[[BasicMapAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier] autorelease];
            annotationView.canShowCallout = NO;
            annotationView.pinColor = MKPinAnnotationColorGreen;
        }
        annotationView.annotation = annotation;
        return annotationView;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView {
    id<MKAnnotation> annotation = aView.annotation;
    if (!annotation || ![aView isSelected])
        return;
    [mapView setCenterCoordinate:annotation.coordinate animated:YES];
    if ([annotation isKindOfClass:[UserPinAnnotation class]]) {
        self.searchLocation = (UserPinAnnotation *)annotation;
        self.selectedAnnotationView = aView;
    }    
    else if (aView.annotation == self.customAnnotation) {
        if (self.calloutAnnotation == nil) {
            _calloutAnnotation = [[CalloutMapAnnotation alloc] initWithLatitude:aView.annotation.coordinate.latitude andLongitude:aView.annotation.coordinate.longitude];
        } else {
            _calloutAnnotation.latitude = aView.annotation.coordinate.latitude;
            _calloutAnnotation.longitude = aView.annotation.coordinate.longitude;
        }
        [mapView addAnnotation:_calloutAnnotation];
        self.selectedAnnotationView = aView;
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)aView {
    if (self.calloutAnnotation && aView.annotation == self.customAnnotation && !((BasicMapAnnotationView *)aView).preventSelectionChange) {
        [mapView removeAnnotation:self.calloutAnnotation];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)aView calloutAccessoryControlTapped:(UIControl *)control {
    RKLogInfo(@"Annotation accessory tapped, does nothing by default %@", control);
}

- (void)annotationCoordinateChanged:(id)sender {
    if (![sender isKindOfClass:[UserPinAnnotation class]])
        return;
    if (!self.searchLocation || ![sender isEqual:self.searchLocation])
        self.searchLocation = sender;
    [self resetMap:sender];
    [self geocodeAddressWithCoordinate:self.searchLocation.coordinate];
    [self beginBoundarySearchForCoordininate:self.searchLocation.coordinate];
}

#pragma mark - Geocoding

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
    [self resetMap:aSearchBar];
    [self geocodeCoordinateWithAddress:aSearchBar.text];
}

- (void)geocodeCoordinateWithAddress:(NSString *)address {
    [self showLocateActivityButton];
    self.geocoder = nil;
    geocoder = [[SVGeocoder alloc] initWithAddress:address inBounds:self.defaultRegion];
    [geocoder setDelegate:self];
    [geocoder startAsynchronous];
}

- (void)geocodeAddressWithCoordinate:(CLLocationCoordinate2D)newCoord {
    [self showLocateActivityButton];
    self.geocoder = nil;
    geocoder = [[SVGeocoder alloc] initWithCoordinate:newCoord];
    [geocoder setDelegate:self];
    [geocoder startAsynchronous];    
}

- (void)geocoder:(SVGeocoder *)geocoder didFindPlacemark:(SVPlacemark *)placemark
{
    RKLogDebug(@"Geocoder found placemark: %@ (was %@)", placemark, self.searchLocation);
    [self showLocateUserButton];
    if (self.searchLocation) {
        [self.mapView removeAnnotation:self.searchLocation];
        self.searchLocation = nil;
    }
    UserPinAnnotation *annotation = [[UserPinAnnotation alloc] initWithSVPlacemark:placemark];
    annotation.delegate = self;
    [self.mapView addAnnotation:annotation];
    
    [self beginBoundarySearchForCoordininate:annotation.coordinate];
    [self moveMapToAnnotation:annotation];
    self.searchLocation = annotation;
    [annotation release];
        // is this necessary??? because we will have just created the related annotation view, so we don't need to redisplay it.
        //[[NSNotificationCenter defaultCenter] postNotificationName:kUserPinAnnotationAddressChangeKey object:self.searchLocation];
    self.geocoder = nil;
    [self.searchBar resignFirstResponder];
}

- (void)geocoder:(SVGeocoder *)geocoder didFailWithError:(NSError *)error
{
    RKLogError(@"SVGeocoder has failed: %@", error);
    self.geocoder = nil;
    [self showLocateUserButton];
}

@end
