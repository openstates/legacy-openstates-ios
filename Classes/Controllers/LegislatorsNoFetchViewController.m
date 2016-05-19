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
#import "SLFInfoPanelManager.h"

#import "SLFInfoView.h"

@interface LegislatorsNoFetchViewController()
@property (nonatomic,strong) SLFInfoPanelManager *infoPanelManager;
@property (nonatomic,strong) SLFInfoView *locationActivityPanel;
@property (nonatomic,assign) BOOL hasWarnedForDifferentStates;
@property (nonatomic,strong) CLGeocoder *geocoder;
@property (nonatomic,assign) BOOL didAskForLocation;
@end

@implementation LegislatorsNoFetchViewController
@synthesize locationManager = _locationManager;
@synthesize locationActivityPanel = _locationActivityPanel;
@synthesize hasWarnedForDifferentStates = _hasWarnedForDifferentStates;
@synthesize geocoder = _geocoder;

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
    self.infoPanelManager = nil;
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
    //self.infoPanelManager = [[SLFInfoPanelManager alloc] initWithManagerId:self.screenName parentView:self.view];
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

    NSString *title = NSLocalizedString(@"States Differ",@"");
    NSString *subtitle = NSLocalizedString(@"The previously selected state differs from that of your geolocated reps.  Please keep that in mind.",@"");
    SLFInfoItem *infoItem = [[SLFInfoItem alloc] initWithIdentifier:title type:SLFInfoTypeNotice title:title subtitle:subtitle image:nil duration:3.f];
    [self.infoPanelManager addInfoItem:infoItem];

    [SLFInfoView showInfoInView:self.view infoItem:infoItem completion:^(SLFInfoStatus status, SLFInfoItem * _Nonnull item) {
        // do something?
    }];
//    [SLFInfoView showInfoInView:self.view type:SLFInfoTypeNotice title:title subtitle:subtitle image:nil hideAfter:3.f];
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
            if (self.locationActivityPanel)
                break;

            NSString *title = NSLocalizedString(@"Cannot Geolocate",@"");
            NSString *subtitle = NSLocalizedString(@"Location Services are unavailable.  Ensure that Location Services are enabled in the iOS General Settings.",@"");

            SLFInfoItem *infoItem = [[SLFInfoItem alloc] initWithIdentifier:title type:SLFInfoTypeError title:title subtitle:subtitle image:nil duration:4.f];

            [SLFInfoView showInfoInView:self.view infoItem:infoItem completion:^(SLFInfoStatus status, SLFInfoItem * _Nonnull item) {
                // do something?
            }];

            [self.infoPanelManager addInfoItem:infoItem];
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

            if (self.locationActivityPanel)
                break;

            NSString *title = NSLocalizedString(@"Finding Location",@"");
            NSString *subtitle = NSLocalizedString(@"Geolocating to determine representation.",@"");
            SLFInfoItem *infoItem = [[SLFInfoItem alloc] initWithIdentifier:title type:SLFInfoTypeActivity title:title subtitle:subtitle image:nil duration:0];
            [self.infoPanelManager addInfoItem:infoItem];

            self.locationActivityPanel = [SLFInfoView showInfoInView:self.view infoItem:infoItem completion:^(SLFInfoStatus status, SLFInfoItem * _Nonnull item) {
                // do something?
            }];

//            self.locationActivityPanel = [SLFInfoView showInfoInView:self.view
//                                                                 type:SLFInfoTypeActivity
//                                                                title:title
//                                                             subtitle:subtitle
//                                                            hideAfter:0];
            break;
        }
    }

}

- (void)stopUpdatingLocation:(NSString *)reason
{
    SLFInfoItem *infoItem = nil;

    if (reason)
    {
        NSString *title = NSLocalizedString(@"Geolocation Error",@"");
        RKLogError(@"%@: %@", title, reason);
        infoItem = [[SLFInfoItem alloc] initWithIdentifier:title type:SLFInfoTypeError title:title subtitle:reason image:nil duration:4];
    }

    if (!self.locationActivityPanel)
    {
        if (infoItem)
        {
            [self.infoPanelManager addInfoItem:infoItem];

            SLFInfoView *infoView = [SLFInfoView showInfoInView:self.view infoItem:infoItem completion:^(SLFInfoStatus status, SLFInfoItem * _Nonnull item) {
                // do something?
            }];


            //MTInfoPanel *panel = [MTInfoPanel showPanelInView:self.view type:MTInfoPanelTypeError title:NSLocalizedString(@"Geolocation Error",@"") subtitle:reason hideAfter:4.f];
            if (infoView)
                self.locationActivityPanel = infoView;
        }
    }
    else
    {
        if (infoItem)
        {
            [self.locationActivityPanel setType:SLFInfoTypeError title:NSLocalizedString(@"Geolocation Error",@"") subtitle:reason];
            [self.infoPanelManager addInfoItem:infoItem];
        }
        else
        {
            [self.locationActivityPanel hideInfoView];
            self.locationActivityPanel = nil;
        }
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
    if (!reason) // (!reason && [error code] != kCLErrorLocationUnknown)
        reason = NSLocalizedString(@"Unable to determine your current location.", @"");
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
    RKLogInfo(@"Geocoder found placemark: %@", placemark);

    [self.searchBar resignFirstResponder];
    [self loadTableWithCoordinate:placemark.location.coordinate];
}

- (void)geocoderDidFailWithError:(NSError *)error
{
    RKLogError(@"Location eocoder has failed: %@", error);

    if (!self.isViewLoaded)
        return;

    NSString *title = NSLocalizedString(@"Geolocation Error",@"");
    NSString *reason = NSLocalizedString(@"Unable to find that address.", @"");

    SLFInfoItem *infoItem = [[SLFInfoItem alloc] initWithIdentifier:@"geocode-failure-error" type:SLFInfoTypeError title:title subtitle:reason image:nil duration:4.f];
    [self.infoPanelManager addInfoItem:infoItem];

    SLFInfoView *infoView = [SLFInfoView showInfoInView:self.view infoItem:infoItem completion:^(SLFInfoStatus status, SLFInfoItem * _Nonnull item) {
        // do something?
    }];
    if (infoView)
        self.locationActivityPanel = infoView;
    RKLogError(@"%@: %@", title, reason);
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar
{
    [self geocodeCoordinateWithAddress:aSearchBar.text];
    [super searchBarSearchButtonClicked:aSearchBar];
}

@end
