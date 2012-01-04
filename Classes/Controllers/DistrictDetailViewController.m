//
//  DistrictDetailViewController.m
//  Created by Gregory Combs on 7/31/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
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
#import "DistrictSearch.h"
#import "MultiRowCalloutAnnotationView.h"
#import "SLFActionPathRegistry.h"

@interface DistrictDetailViewController()
- (void)loadMapWithID:(NSString *)objID;
- (void)loadDataWithResourcePath:(NSString *)path;
- (BOOL)isUpperDistrictWithID:(NSString *)objID;
- (BOOL)isUpperDistrict:(SLFDistrict *)obj;
- (void)setUpperOrLowerDistrict:(SLFDistrict *)districtMap;
@property (nonatomic,retain) DistrictSearch *districtSearch;
@end

@implementation DistrictDetailViewController
@synthesize resourceClass;
@synthesize upperDistrict;
@synthesize lowerDistrict;
@synthesize districtSearch;
@synthesize onSavePersistentActionPath = _onSavePersistentActionPath;

- (id)initWithDistrictMapID:(NSString *)objID {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.resourceClass = [SLFDistrict class];
        [self loadMapWithID:objID];
    }
    return self;
}

- (void)dealloc {
    [[RKObjectManager sharedManager].requestQueue cancelRequestsWithDelegate:self];
    self.upperDistrict = nil;
    self.lowerDistrict = nil;
    self.districtSearch = nil;
    [super dealloc];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)loadMapWithID:(NSString *)objID {
    if (IsEmpty(objID))
        return;
    SLFDistrict *district = [SLFDistrict findFirstByAttribute:@"boundaryID" withValue:objID];
    if (district)
        [self setUpperOrLowerDistrict:district];
    [self loadDataWithResourcePath:[NSString stringWithFormat:@"/districts/boundary/%@", objID]];    // DON'T REALLY LOAD UNLESS WE HAVE TO
}

- (void)setUpperOrLowerDistrict:(SLFDistrict *)newObj {
    if (!newObj)
        return;
    if ([self isUpperDistrict:newObj])
        self.upperDistrict = newObj;
    else
        self.lowerDistrict = newObj;
    if (self.onSavePersistentActionPath) {
        _onSavePersistentActionPath(self.actionPath);
        self.onSavePersistentActionPath = nil;
    }
}

- (NSString *)actionPath {
    SLFDistrict *district = self.lowerDistrict;
    if (!district)
        district = self.upperDistrict;
    return [[self class] actionPathForObject:district];
}

+ (NSString *)actionPathForObject:(id)object {
    NSString *pattern = [SLFActionPathRegistry patternForClass:[self class]];
    if (!pattern)
        return nil;
    if (!object)
        return pattern;
    return RKMakePathWithObjectAddingEscapes(pattern, object, NO);
}

- (void)setOnSavePersistentActionPath:(SLFPersistentActionsSaveBlock)onSavePersistentActionPath {
    if (_onSavePersistentActionPath) {
        Block_release(_onSavePersistentActionPath);
        _onSavePersistentActionPath = nil;
    }
    _onSavePersistentActionPath = Block_copy(onSavePersistentActionPath);
}

- (void)reconfigureForDistrict:(SLFDistrict *)district {
    [self setUpperOrLowerDistrict:district];
    if (![self isViewLoaded])
        return;
    [self.mapView addAnnotation:district];
    [self moveMapToRegion:district.region];
    MKPolygon *polygon = [district polygonFactory];
    if (polygon)
        [self.mapView addOverlay:polygon];
}

- (void)loadDataWithResourcePath:(NSString *)path {
    if (IsEmpty(path))
        return;    
    NSDictionary *queryParameters = [NSDictionary dictionaryWithObject:SUNLIGHT_APIKEY forKey:@"apikey"];
    NSString *pathToLoad = [path appendQueryParams:queryParameters];
    [[SLFRestKitManager sharedRestKit] loadObjectsAtResourcePath:pathToLoad delegate:self withTimeout:SLF_HOURS_TO_SECONDS(7*24)];
}

#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObject:(id)object {    
    if (!object || ![object isKindOfClass:self.resourceClass])
        return;
    SLFDistrict *district = object;
    [self reconfigureForDistrict:district];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    self.onSavePersistentActionPath = nil;
    [SLFRestKitManager showFailureAlertWithRequest:objectLoader error:error];
}

- (SLFDistrict *)districtMapForPolygon:(MKPolygon *)polygon {
    if (!polygon)
        return nil;
    NSString *boundaryID = [polygon subtitle];
    if (IsEmpty(boundaryID)) {
        if (self.upperDistrict && polygon.pointCount == self.upperDistrict.polygonFactory.pointCount)
            return self.upperDistrict;
        return self.lowerDistrict;
    }
    return [SLFDistrict findFirstByAttribute:@"boundaryID" withValue:boundaryID];
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolygon class]])
    {
        SLFDistrict *district = [self districtMapForPolygon:(MKPolygon*)overlay];
        MKPolygonView *aView = [[[MKPolygonView alloc] initWithPolygon:(MKPolygon*)overlay] autorelease];
        if (district && [self isUpperDistrict:district])
            aView.fillColor = [[UIColor orangeColor] colorWithAlphaComponent:0.2];
        else 
            aView.fillColor = [[UIColor greenColor] colorWithAlphaComponent:0.2];
        aView.strokeColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.7];
        aView.lineWidth = 2;
        return aView;
    }
    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id <MKAnnotation>)annotation { 
    MKAnnotationView *annotationView = [super mapView:aMapView viewForAnnotation:annotation];
    if (annotationView && [annotationView isKindOfClass:[MultiRowCalloutAnnotationView class]]) {
        MultiRowCalloutAnnotationView *multiView = (MultiRowCalloutAnnotationView *)annotationView;
		__block __typeof__(self) bself = self;
        multiView.onCalloutAccessoryTapped = ^(MultiRowCalloutCell *cell, UIControl *control, NSDictionary *userData) {
            NSString *legID = [userData valueForKey:@"legID"];
            NSString *path = [SLFActionPathNavigator navigationPathForController:[LegislatorDetailViewController class] withResourceID:legID];
            if (!IsEmpty(path))
                [SLFActionPathNavigator navigateToPath:path skipSaving:NO fromBase:bself popToRoot:NO];
        };
        return multiView;
    }
    return annotationView;
}

- (void)beginBoundarySearchForCoordininate:(CLLocationCoordinate2D)coordinate {
    __block __typeof__(self) bself = self;
    self.districtSearch = [DistrictSearch districtSearchForCoordinate:coordinate 
                                             successBlock:^(NSArray *results) {
                                                 for (NSString *districtID in results)
                                                     [bself loadMapWithID:districtID];
                                                 bself.districtSearch = nil;
                                             }
                                             failureBlock:^(NSString *message, DistrictSearchFailOption failOption) {
                                                 if (failOption == DistrictSearchFailOptionLog)
                                                     RKLogError(@"%@", message);
                                                 else
                                                     [SLFAlertView showWithTitle:NSLocalizedString(@"Geolocation Error", @"") message:message buttonTitle:NSLocalizedString(@"OK", @"")];
                                                 bself.districtSearch = nil;
                                             }];
}

- (BOOL)isUpperDistrictWithID:(NSString *)objID {
    if (!IsEmpty(objID) && [objID hasPrefix:@"sldu"])
        return YES;
    return NO;
}

- (BOOL)isUpperDistrict:(SLFDistrict *)obj {
    if ([self isUpperDistrictWithID:obj.boundaryID] || [obj.chamberObj.type isEqualToString:SLFChamberUpperType])
        return YES;
    return NO;
}
@end
