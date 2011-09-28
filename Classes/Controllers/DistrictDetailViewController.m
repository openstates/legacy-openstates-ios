//
//  DistrictDetailViewController.m
//  Created by Gregory Combs on 7/31/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "DistrictDetailViewController.h"
#import "LegislatorDetailViewController.h"
#import "SLFDataModels.h"
#import "SLFRestKitManager.h"
#import "SLFTheme.h"
#import "AppDelegate.h"
#import "SLFAlertView.h"

@interface DistrictDetailViewController()
- (void)loadDataFromDataStoreWithID:(NSString *)objID;
@end

@implementation DistrictDetailViewController
@synthesize resourcePath;
@synthesize resourceClass;
@synthesize districtMap;
@synthesize mapView;

- (id)initWithDistrictMapID:(NSString *)objID {
    self = [super init];
    if (self) {
        self.resourceClass = [SLFDistrict class];
        self.resourcePath = [NSString stringWithFormat:@"/districts/boundary/%@", objID];
        [self loadDataFromDataStoreWithID:objID];
        if (!self.districtMap)
            [self loadData];    // DON'T REALLY LOAD UNLESS WE HAVE TO
    }
    return self;
}

- (void)loadView {
    [super loadView];
	self.title = NSLocalizedString(@"Loading...",@"");
    self.mapView = [[[MKMapView alloc] initWithFrame:self.view.bounds] autorelease];
	self.mapView.delegate = self;		
    [self.view addSubview:self.mapView];
}

- (void)dealloc {
    [[RKObjectManager sharedManager].requestQueue cancelRequestsWithDelegate:self];
    self.mapView.delegate = nil;
    self.mapView = nil;
	self.districtMap = nil;
    self.resourcePath = nil;
    [super dealloc];
}

- (void)viewDidUnload {
    self.mapView = nil;
    [super viewDidUnload];
}

- (void)loadDataFromDataStoreWithID:(NSString *)objID {
	self.districtMap = [SLFDistrict findFirstByAttribute:@"boundaryID" withValue:objID];
}

- (void)loadData {
	if (self.resourcePath == NULL)
		return;	
	NSDictionary *queryParameters = [NSDictionary dictionaryWithObject:SUNLIGHT_APIKEY forKey:@"apikey"];
	NSString *pathToLoad = [self.resourcePath appendQueryParams:queryParameters];
    [[SLFRestKitManager sharedRestKit] loadObjectsAtResourcePath:pathToLoad delegate:self];
}

- (void)setDistrictMap:(SLFDistrict *)newObj {
	if (districtMap)
        [districtMap release];
	districtMap = [newObj retain];
	if (districtMap) {
		self.title = newObj.title;
        self.resourcePath = RKMakePathWithObject(@"/districts/boundary/:boundaryID", newObj);
		[self loadData];
	}
}

#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObject:(id)object {    
	if (districtMap)
        [districtMap release];
	districtMap = [object retain];
    self.title = districtMap.title;
    if (!districtMap || ![self isViewLoaded])
        return;
    [self.mapView addAnnotation:districtMap];
    MKPolygon *polygon = [districtMap polygonFactory];
    if (polygon) {
        [self.mapView addOverlay:polygon];
        [self.mapView setRegion:districtMap.region animated:YES];
    }
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    NSString *message = nil;
    @try {
        message = [error localizedDescription];
    } @catch (NSException *exception) {
        message = NSLocalizedString(@"Unknown Error",@"");
	}
    [SLFAlertView showWithTitle:NSLocalizedString(@"Error",@"") message:message buttonTitle:NSLocalizedString(@"Cancel",@"")];
	RKLogError(@"Error loading object: %@ %@", objectLoader.resourcePath, error);
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (MKOverlayView *)mapView:(MKMapView *)aMapView viewForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolygon class]])
    {
        MKPolygonView*    aView = [[[MKPolygonView alloc] initWithPolygon:(MKPolygon*)overlay] autorelease];
        UIColor *partyColor = [SLFAppearance partyGreen];
        if ([self.districtMap.legislators count] == 1) {
            SLFLegislator *leg = [self.districtMap.legislators anyObject];
            NSString *party = leg.party;
            if (party && NO == [party isEqual:[NSNull null]]) {
                partyColor = [[party lowercaseString] isEqualToString:@"republican"] ? [SLFAppearance partyRed] : [SLFAppearance partyBlue];
            }
        }
        aView.fillColor = [partyColor colorWithAlphaComponent:0.2];
        aView.strokeColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.7];
        aView.lineWidth = 2;
        return aView;
    }
    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    if ([annotation isKindOfClass:self.resourceClass])
    {
        static NSString *pinID = @"DistrictCentroid";
        MKPinAnnotationView*    pinView = (MKPinAnnotationView*)[aMapView
                                                                 dequeueReusableAnnotationViewWithIdentifier:pinID];
        if (!pinView)
        {
            pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                       reuseIdentifier:pinID] autorelease];
            pinView.pinColor = MKPinAnnotationColorPurple;
            pinView.animatesDrop = YES;
            pinView.canShowCallout = YES;
            if ([self.districtMap.legislators count] == 1) {                
                UIButton* rightButton = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
                [rightButton addTarget:self action:@selector(showLegislatorDetail:)
                      forControlEvents:UIControlEventTouchUpInside];
                pinView.rightCalloutAccessoryView = rightButton;
            }
        }
        else
            pinView.annotation = annotation;
        return pinView;
    }
    return nil;
}

- (void)stackOrPushViewController:(UIViewController *)viewController {
    if (!PSIsIpad()) {
        [self.navigationController pushViewController:viewController animated:YES];
        return;
    }
    [XAppDelegate.stackController pushViewController:viewController fromViewController:self animated:YES];
}

- (void)showLegislatorDetail:(id)sender {
    if ([self.districtMap.legislators count] == 1) {
        SLFLegislator *leg = [self.districtMap.legislators anyObject];
        if (leg && leg.legID) {
            LegislatorDetailViewController *vc = [[LegislatorDetailViewController alloc] initWithLegislatorID:leg.legID];
            [self stackOrPushViewController:vc];
            [vc release];
        }    
    }
}

@end
