//
//  LegislatorsNoFetchViewController.m
//  Created by Greg Combs on 1/18/12.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "LegislatorsNoFetchViewController.h"
#import "LegislatorDetailViewController.h"
#import "SLFDataModels.h"
#import "LegislatorCell.h"
#import "SLToastManager+OpenStates.h"
#import "SLFLog.h"

@interface LegislatorsNoFetchViewController()
@property (nonatomic,assign) BOOL hasWarnedForDifferentStates;
@property (nonatomic,strong) CLGeocoder *geocoder;
@property (nonatomic,assign) BOOL didAskForLocation;
@end

@implementation LegislatorsNoFetchViewController

- (id)initWithState:(SLFState *)newState usingGeolocation:(BOOL)usingGeolocation
{
    NSString *resourcePath = [SLFLegislator resourcePathForAllWithStateID:newState.stateID];
    if (usingGeolocation)
        resourcePath = nil;
    self = [super initWithState:newState resourcePath:resourcePath dataClass:[SLFLegislator class]];
    if (self)
    {
        if (usingGeolocation)
        {
            self.title = NSLocalizedString(@"Your Legislators", @"");
            CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
            if (authStatus != kCLAuthorizationStatusDenied
                && authStatus != kCLAuthorizationStatusRestricted)
            {
                [self startUpdatingLocation:nil];
            }
        }
    }
    return self;
}

- (id)initWithState:(SLFState *)newState
{
    self = [self initWithState:newState usingGeolocation:NO];
    return self;
}

- (void)dealloc
{
    if (self.locationManager)
    {
        [self.locationManager stopUpdatingLocation];
        self.locationManager.delegate = nil;
    }
    self.locationManager = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenName = @"Legislators No-Fetch Screen";
}

- (void)configureTableController
{
    [super configureTableController];
    self.tableController.tableView.rowHeight = 73;
    [self configureSearchBarWithPlaceholder:NSLocalizedString(@"Search by address", @"") withConfigurationBlock:nil];

    __weak __typeof__(self) wSelf = self;
    LegislatorCellMapping *objCellMap = [LegislatorCellMapping cellMappingUsingBlock:^(RKTableViewCellMapping* cellMapping) {
        if (!wSelf)
            return;
        __strong __typeof__(wSelf) sSelf = wSelf;

        [cellMapping mapKeyPath:@"self" toAttribute:@"legislator"];

        __weak __typeof__(sSelf) wSelf = sSelf;
        cellMapping.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
            if (!wSelf)
                return;
            __strong __typeof__(wSelf) sSelf = wSelf;

            NSString *path = [SLFActionPathNavigator navigationPathForController:[LegislatorDetailViewController class] withResource:object];
            [SLFActionPathNavigator navigateToPath:path skipSaving:NO fromBase:sSelf popToRoot:NO];
            [sSelf.searchBar resignFirstResponder];
        };
    }];
    [self.tableController mapObjectsWithClass:self.dataClass toTableCellsWithMapping:objCellMap];    
}

- (void)tableControllerDidFinishFinalLoad:(RKAbstractTableController*)tableController
{
    if ([self isNewStateDifferentThanCurrentState]
        && !self.hasWarnedForDifferentStates)
    {
        self.hasWarnedForDifferentStates = YES;
        [self presentAlertForDifferentState];
    }
    //    [super tableControllerDidFinishFinalLoad:tableController];
}

- (BOOL)isNewStateDifferentThanCurrentState
{
    if (!self.tableController)
        return NO;
    BOOL isNewStateDifferent = NO;
    for (RKTableSection *section in self.tableController.sections)
    {
        for (SLFLegislator *legislator in section.objects)
        {
            NSString *legStateID = legislator.stateID;
            if (!SLFTypeNonEmptyStringOrNil(legStateID))
                continue;
            if (![legStateID isEqualToString:self.state.stateID])
            {
                isNewStateDifferent = YES;
                break;
            }
        }
    }
    return isNewStateDifferent;
}

- (void)presentAlertForDifferentState
{
    if (!self.isViewLoaded)
        return;

    NSString *title = NSLocalizedString(@"States Differ", nil);
    NSString *subtitle = NSLocalizedString(@"The previously selected state differs from that of your geolocated reps.  Please keep that in mind.", nil);
    [[SLToastManager opstSharedManager] addToastWithIdentifier:@"States-Differ"
                                                          type:SLToastTypeNotice
                                                         title:title
                                                      subtitle:subtitle
                                                         image:nil
                                                      duration:3];
}

- (void)setState:(SLFState *)state
{
    [super setState:state];
    self.hasWarnedForDifferentStates = NO;
}

#pragma mark Geolocation

- (void)loadTableWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    if (!CLLocationCoordinate2DIsValid(coordinate))
        return;
    NSString *resourcePath = [SLFLegislator resourcePathForCoordinate:coordinate];
    self.resourcePath = resourcePath;
    [self loadTableFromNetwork];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (!self.isViewLoaded)
        return;

    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            if (self.didAskForLocation)
                [self startUpdatingLocation:nil];
            break;
        }
    }
}

- (void)startUpdatingLocation:(id)sender
{
    self.didAskForLocation = YES;

    if (!self.locationManager)
    {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    }

    CLAuthorizationStatus authorization = [CLLocationManager authorizationStatus];

    switch (authorization) {
        case kCLAuthorizationStatusNotDetermined: {
            NSLog(@"LegislatorsNoFetchViewController:requestWhenInUseAuthorization");
            [self.locationManager requestWhenInUseAuthorization];
            break;
        }
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
        {
            NSString *title = NSLocalizedString(@"Cannot Geolocate", nil);
            NSString *subtitle = NSLocalizedString(@"Location Services are unavailable.  Ensure that Location Services are enabled in the iOS General Settings.", nil);
            SLToast *toast = [[SLToast alloc] initWithIdentifier:title type:SLToastTypeError title:title subtitle:subtitle image:nil duration:4];
            [[SLToastManager opstSharedManager] addToast:toast];

            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            if (self.locationManager)
            {
                if (!self.locationManager.delegate || ![self.locationManager.delegate isEqual:self])
                    self.locationManager.delegate = self;
                [self.locationManager startUpdatingLocation];
            }

            NSString *title = NSLocalizedString(@"Finding Location", nil);
            NSString *subtitle = NSLocalizedString(@"Geolocating to determine representation.", nil);
            SLToast *toast = [[SLToast alloc] initWithIdentifier:title type:SLToastTypeActivity title:title subtitle:subtitle image:nil duration:0];
            [[SLToastManager opstSharedManager] addToast:toast];

            break;
        }
    }

}

- (void)stopUpdatingLocation:(NSString *)reason
{
    if (reason)
    {
        NSString *title = NSLocalizedString(@"Geolocation Error", nil);
        os_log_error([SLFLog common], "Geolocation Error: %s{public}", reason);
        SLToast *toast = [[SLToast alloc] initWithIdentifier:title type:SLToastTypeError title:title subtitle:reason image:nil duration:4];
        [[SLToastManager opstSharedManager] addToast:toast];
    }

    if (!self.locationManager)
        return;

    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    self.locationManager = nil;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSString *reason = [error localizedFailureReason];
    if (!reason)
        reason = NSLocalizedString(@"Unable to determine your current location.", nil);
    [self stopUpdatingLocation:reason];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [self stopUpdatingLocation:nil];
    [self loadTableWithCoordinate:newLocation.coordinate];
}

- (CLCircularRegion *)usRegion
{
    CLLocationCoordinate2D mapCenter = CLLocationCoordinate2DMake(37.250556, -96.358333);
    MKCoordinateSpan mapSpan = MKCoordinateSpanMake(62.20933368, 25.85818456);
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

- (void)geocodeCoordinateWithAddress:(NSString *)address
{
    if (!SLFTypeNonEmptyStringOrNil(address))
        return;

    if (!_geocoder)
        _geocoder = [[CLGeocoder alloc] init];

    __weak LegislatorsNoFetchViewController *bself = self;
    [_geocoder geocodeAddressString:address inRegion:[self usRegion] completionHandler:^(NSArray<CLPlacemark *> * placemarks, NSError * error) {
        if (!bself)
            return;
        if (error || !placemarks || ![placemarks count])
        {
            [bself geocoderDidFailWithError:error];
            return;
        }
        [bself geocoderDidFindPlacemarks:placemarks];
    }];
}

- (void)geocoderDidFindPlacemarks:(NSArray<CLPlacemark *> *)placemarks
{
    if (!SLFTypeNonEmptyArrayOrNil(placemarks) || !self.isViewLoaded)
        return;

    CLPlacemark *placemark = placemarks[0];
    NSLog(@"Geocoder found placemark: %@", placemark);

    [self.searchBar resignFirstResponder];
    [self loadTableWithCoordinate:placemark.location.coordinate];
}

- (void)geocoderDidFailWithError:(NSError *)error
{
    os_log_error([SLFLog common], "Location encoder has failed: %s{public}", error.localizedDescription);

    if (!self.isViewLoaded)
        return;

    NSString *title = NSLocalizedString(@"Geolocation Error", nil);
    NSString *reason = NSLocalizedString(@"Unable to find that address.", nil);
    SLToast *toast = [[SLToast alloc] initWithIdentifier:@"geocode-failure-error" type:SLToastTypeError title:title subtitle:reason image:nil duration:4.f];
    [[SLToastManager opstSharedManager] addToast:toast];

    NSString *logText = (error) ? error.localizedDescription : reason;
    os_log_error([SLFLog common], "Geolocation Error: %s{public}", logText);
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar
{
    [self geocodeCoordinateWithAddress:aSearchBar.text];
    [super searchBarSearchButtonClicked:aSearchBar];
}

@end
