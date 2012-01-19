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

@interface LegislatorsNoFetchViewController()
- (void)startUpdatingLocation:(id)sender;
- (void)stopUpdatingLocation:(NSString *)reason;
@property (nonatomic,retain) MTInfoPanel *locationActivityPanel;
@end

@implementation LegislatorsNoFetchViewController
@synthesize locationManager = _locationManager;
@synthesize locationActivityPanel = _locationActivityPanel;

- (id)initWithState:(SLFState *)newState usingGeolocation:(BOOL)usingGeolocation {
    NSString *resourcePath = [SLFLegislator resourcePathForStateID:newState.stateID];
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
    [super dealloc];
}

- (void)viewDidUnload {
    [self stopUpdatingLocation:nil];
    self.locationManager = nil;
    self.locationActivityPanel = nil;
    [super viewDidUnload];
}

- (void)configureTableController {
    [super configureTableController];
    self.tableController.tableView.rowHeight = 73;
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
        //    [super tableControllerDidFinishFinalLoad:tableController];
}

#pragma mark Geolocation

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
    NSString *resourcePath = [SLFLegislator resourcePathForCoordinate:newLocation.coordinate];
    self.resourcePath = resourcePath;
    [self loadTableFromNetwork];
}

@end

