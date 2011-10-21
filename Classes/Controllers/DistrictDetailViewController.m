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
#import "SLFAlertView.h"
#import "DistrictPinAnnotationView.h"
#import "DistrictSearchOperation.h"

@interface DistrictDetailViewController()
- (void)loadDataFromDataStoreWithID:(NSString *)objID;
- (void)loadDataWithResourcePath:(NSString *)path;
@property (nonatomic,retain) DistrictSearchOperation *searchOperation;
@end

@implementation DistrictDetailViewController
@synthesize resourceClass;
@synthesize districtMap;
@synthesize mapView;
@synthesize searchOperation;

- (id)initWithDistrictMapID:(NSString *)objID {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.resourceClass = [SLFDistrict class];
        [self loadDataFromDataStoreWithID:objID];
        if (!self.districtMap)
            [self loadDataWithResourcePath:[NSString stringWithFormat:@"/districts/boundary/%@", objID]];    // DON'T REALLY LOAD UNLESS WE HAVE TO
    }
    return self;
}

- (void)dealloc {
    [[RKObjectManager sharedManager].requestQueue cancelRequestsWithDelegate:self];
	self.districtMap = nil;
    self.searchOperation = nil;
    [super dealloc];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)loadDataFromDataStoreWithID:(NSString *)objID {
	self.districtMap = [SLFDistrict findFirstByAttribute:@"boundaryID" withValue:objID];
}

- (void)loadDataWithResourcePath:(NSString *)path {
	if (IsEmpty(path))
		return;	
	NSDictionary *queryParameters = [NSDictionary dictionaryWithObject:SUNLIGHT_APIKEY forKey:@"apikey"];
	NSString *pathToLoad = [path appendQueryParams:queryParameters];
    [[SLFRestKitManager sharedRestKit] loadObjectsAtResourcePath:pathToLoad delegate:self];
}

- (void)setDistrictMap:(SLFDistrict *)newObj {
	if (districtMap)
        [districtMap release];
	districtMap = [newObj retain];
	if (districtMap) {
            //self.title = newObj.title;
		[self loadDataWithResourcePath:RKMakePathWithObject(@"/districts/boundary/:boundaryID", newObj)];
	}
}

#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObject:(id)object {    
    if (!object || ![object isKindOfClass:self.resourceClass])
        return;
	if (districtMap)
        [districtMap release];
	districtMap = [object retain];
        //self.title = districtMap.title;
    if (!districtMap || ![self isViewLoaded])
        return;
    [self.mapView addAnnotation:districtMap];
    [self moveMapToRegion:districtMap.region];
    MKPolygon *polygon = [districtMap polygonFactory];
    if (polygon)
        [self.mapView addOverlay:polygon];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    [SLFRestKitManager showFailureAlertWithRequest:objectLoader error:error];
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
    if ([annotation isKindOfClass:self.resourceClass])
    {
        DistrictPinAnnotationView *pinView = (DistrictPinAnnotationView*)[aMapView dequeueReusableAnnotationViewWithIdentifier:DistrictPinAnnotationViewReuseIdentifier];
        if (!pinView)
            pinView = [DistrictPinAnnotationView districtPinViewWithAnnotation:annotation identifier:DistrictPinAnnotationViewReuseIdentifier];
        else
            pinView.annotation = annotation;
        [pinView setPinColorWithAnnotation:annotation];
        
        if ([self.districtMap.legislators count] == 1) {                
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:self action:@selector(showLegislatorDetail:) forControlEvents:UIControlEventTouchUpInside];
            pinView.rightCalloutAccessoryView = rightButton;
        }

        return pinView;
    }
    return [super mapView:aMapView viewForAnnotation:annotation];
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

- (void)beginBoundarySearchForCoordininate:(CLLocationCoordinate2D)coordinate {
    self.searchOperation = [DistrictSearchOperation searchOperationForCoordinate:coordinate 
                                             successBlock:^(NSArray *results) {
                                                 if (!IsEmpty(results)) {
                                                     NSString *districtID = [results objectAtIndex:0]; // only do the first
                                                     [self loadDataFromDataStoreWithID:districtID];
                                                 }
                                                 self.searchOperation = nil;
                                             }
                                             failureBlock:^(NSString *message, DistrictSearchOperationFailOption failOption) {
                                                 if (failOption == DistrictSearchOperationFailOptionLog)
                                                     RKLogError(@"%@", message);
                                                 else
                                                     [SLFAlertView showWithTitle:NSLocalizedString(@"Geolocation Error", @"") message:message buttonTitle:NSLocalizedString(@"OK", @"")];
                                                 self.searchOperation = nil;
                                             }];
}
@end
