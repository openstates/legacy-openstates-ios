//
//  LegislatorsNoFetchViewController.m
//  Created by Greg Combs on 1/18/12.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "LegislatorsNoFetchViewController.h"
#import "LegislatorDetailViewController.h"
#import "SLFDataModels.h"
#import "LegislatorCell.h"
#import "MTInfoPanel.h"
#import "SVPlacemark.h"

@interface LegislatorsNoFetchViewController()
- (void)loadTableWithCoordinate:(CLLocationCoordinate2D)coordinate;
- (void)startUpdatingLocation:(id)sender;
- (void)stopUpdatingLocation:(NSString *)reason;
- (BOOL)isNewStateDifferentThanCurrentState;
- (void)presentAlertForDifferentState;
@property (nonatomic,retain) MTInfoPanel *locationActivityPanel;
@property (nonatomic,assign) BOOL hasWarnedForDifferentStates;
@property (nonatomic,retain) SVGeocoder *geocoder;
@end

@implementation LegislatorsNoFetchViewController
@synthesize locationManager = _locationManager;
@synthesize locationActivityPanel = _locationActivityPanel;
@synthesize hasWarnedForDifferentStates = _hasWarnedForDifferentStates;
@synthesize geocoder = _geocoder;

- (id)initWithState:(SLFState *)newState usingGeolocation:(BOOL)usingGeolocation {
    NSString *resourcePath = [SLFLegislator resourcePathForAllWithStateID:newState.stateID];
    if (usingGeolocation)
        resourcePath = nil;
    self = [super initWithState:newState resourcePath:resourcePath dataClass:[SLFLegislator class]];
    if (self) {
        if (usingGeolocation) {
            self.title = NSLocalizedString(@"Your Legislators", @"");
            [self startUpdatingLocation:nil];
        }
    }
    return self;
}

- (id)initWithState:(SLFState *)newState {
    self = [self initWithState:newState usingGeolocation:NO];
    return self;
}

- (void)dealloc {
    [self stopUpdatingLocation:nil];
    self.locationManager = nil;
    self.locationActivityPanel = nil;
    self.geocoder = nil;
    [super dealloc];
}

- (void)viewDidUnload {
    [self stopUpdatingLocation:nil];
    self.locationManager = nil;
    self.locationActivityPanel = nil;
    self.geocoder = nil;
    [super viewDidUnload];
}

- (void)configureTableController {
    [super configureTableController];
    self.tableController.tableView.rowHeight = 73;
    [self configureSearchBarWithPlaceholder:NSLocalizedString(@"Search by address", @"") withConfigurationBlock:nil];

    __block __typeof__(self) bself = self;
    LegislatorCellMapping *objCellMap = [LegislatorCellMapping cellMappingUsingBlock:^(RKTableViewCellMapping* cellMapping) {
        [cellMapping mapKeyPath:@"self" toAttribute:@"legislator"];
        cellMapping.onSelectCellForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath *indexPath) {
            NSString *path = [SLFActionPathNavigator navigationPathForController:[LegislatorDetailViewController class] withResource:object];
            [SLFActionPathNavigator navigateToPath:path skipSaving:NO fromBase:bself popToRoot:NO];
        };
    }];
    [self.tableController mapObjectsWithClass:self.dataClass toTableCellsWithMapping:objCellMap];    
}

- (void)tableControllerDidFinishFinalLoad:(RKAbstractTableController*)tableController {
    if ([self isNewStateDifferentThanCurrentState] && !self.hasWarnedForDifferentStates) {
        self.hasWarnedForDifferentStates = YES;
        [self presentAlertForDifferentState];
    }
    //    [super tableControllerDidFinishFinalLoad:tableController];
}

- (BOOL)isNewStateDifferentThanCurrentState {
    if (!self.tableController)
        return NO;
    BOOL isNewStateDifferent = NO;
    for (RKTableSection *section in self.tableController.sections) {
        for (SLFLegislator *legislator in section.objects) {
            NSString *legStateID = legislator.stateID;
            if (IsEmpty(legStateID))
                continue;
            if (![legStateID isEqualToString:self.state.stateID]) {
                isNewStateDifferent = YES;
                break;
            }
        }
    }
    return isNewStateDifferent;
}

- (void)presentAlertForDifferentState {
    [MTInfoPanel showPanelInView:self.view type:MTInfoPanelTypeNotice title:NSLocalizedString(@"States Differ",@"") subtitle:NSLocalizedString(@"The previously selected state differs from that of your geolocated reps.  Please keep that in mind.",@"") hideAfter:3.f];
}

- (void)setState:(SLFState *)state {
    [super setState:state];
    self.hasWarnedForDifferentStates = NO;
}

#pragma mark Geolocation

- (void)loadTableWithCoordinate:(CLLocationCoordinate2D)coordinate {
    if (!CLLocationCoordinate2DIsValid(coordinate))
        return;
    NSString *resourcePath = [SLFLegislator resourcePathForCoordinate:coordinate];
    self.resourcePath = resourcePath;
    [self loadTableFromNetwork];
}

- (void)startUpdatingLocation:(id)sender {
    if (!self.locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.purpose = NSLocalizedString(@"This application uses your geographic location (via Location Services) to determine legislative representation for your area.", @"");
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    }
    if ([CLLocationManager locationServicesEnabled] == NO) {
        [MTInfoPanel showPanelInView:self.view type:MTInfoPanelTypeError title:NSLocalizedString(@"Cannot Geolocate",@"") subtitle:NSLocalizedString(@"Location Services are unavailable.  Ensure that Location Services are enabled in the iOS General Settings.",@"") hideAfter:4.f];
        return;
    }
    _locationManager.delegate = (id<CLLocationManagerDelegate>) self;    
    self.locationActivityPanel = [MTInfoPanel showPanelInView:self.view type:MTInfoPanelTypeActivity title:NSLocalizedString(@"Finding Location",@"") subtitle:NSLocalizedString(@"Geolocating to determine representation.",@"")];
    [_locationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation:(NSString *)reason {
    if (self.locationActivityPanel) {
        [self.locationActivityPanel hidePanel];
        self.locationActivityPanel = nil;
    }
    if (!self.locationManager)
        return;
    [_locationManager stopUpdatingLocation];
    _locationManager.delegate = nil;
    self.locationManager = nil;
    if (reason && self.isViewLoaded) {
        [MTInfoPanel showPanelInView:self.view type:MTInfoPanelTypeError title:NSLocalizedString(@"Geolocation Error",@"") subtitle:reason hideAfter:4.f];
        RKLogError(@"Geolocation Error: %@", reason);
    } 
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([error code] != kCLErrorLocationUnknown) {
        NSString *reason = [error localizedFailureReason];
        if (!reason)
            reason = NSLocalizedString(@"Unable to determine your current location.", @"");
        [self stopUpdatingLocation:reason];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self stopUpdatingLocation:nil];
    [self loadTableWithCoordinate:newLocation.coordinate];
}

- (void)geocodeCoordinateWithAddress:(NSString *)address {
    self.geocoder = nil;
    MKCoordinateRegion defaultRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.250556, -96.358333), MKCoordinateSpanMake(62.20933368, 25.85818456)); // United States
    _geocoder = [[SVGeocoder alloc] initWithAddress:address inBounds:defaultRegion];
    [_geocoder setDelegate:self];
    [_geocoder startAsynchronous];
}

- (void)geocoder:(SVGeocoder *)geocoder didFindPlacemark:(SVPlacemark *)placemark
{
    RKLogInfo(@"Geocoder found placemark: %@", placemark);
    self.geocoder = nil;
    [self.searchBar resignFirstResponder];
    [self loadTableWithCoordinate:placemark.coordinate];
}

- (void)geocoder:(SVGeocoder *)geocoder didFailWithError:(NSError *)error
{
    RKLogError(@"SVGeocoder has failed: %@", error);
    self.geocoder = nil;
    if (self.isViewLoaded) {
        NSString *reason = NSLocalizedString(@"Unable to find that address.", @"");
        [MTInfoPanel showPanelInView:self.view type:MTInfoPanelTypeError title:NSLocalizedString(@"Geolocation Error",@"") subtitle:reason hideAfter:4.f];
        RKLogError(@"Geolocation Error: %@", reason);
    } 
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
    [self geocodeCoordinateWithAddress:aSearchBar.text];
    [super searchBarSearchButtonClicked:aSearchBar];
}

@end

