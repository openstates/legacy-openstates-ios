//
//  MapMiniDetailViewController.m
//  Created by Gregory Combs on 8/16/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "MapMiniDetailViewController.h"
#import "SLFDataModels.h"
#import "SLFRestKitManager.h"
#import "TexLegeTheme.h"
#import "UtilityMethods.h"

#import "LocalyticsSession.h"
#import "UIColor-Expanded.h"

#import "TexLegeMapPins.h"
#import "DistrictPinAnnotationView.h"

@interface MapMiniDetailViewController (Private)
- (MKCoordinateRegion) unitedStatesRegion;
- (void) animateToAnnotation:(id<MKAnnotation>)annotation;
- (void) clearOverlaysExceptRecent;
- (void) resetMapViewWithAnimation:(BOOL)animated;
- (BOOL) region:(MKCoordinateRegion)region1 isEqualTo:(MKCoordinateRegion)region2;
@end

NSInteger colorIndex;
static MKCoordinateSpan kStandardZoomSpan = {2.f, 2.f};

@implementation MapMiniDetailViewController
@synthesize mapView;
@synthesize districtView;
@synthesize annotationActionCoord;
@synthesize resourcePath;
@synthesize resourceClass;
@synthesize region;

#pragma mark -
#pragma mark Initialization and Memory Management

- (NSString *)nibName {
	if ([UtilityMethods isIPadDevice])
		return @"MapMiniDetailViewController~ipad";
	else
		return @"MapMiniDetailViewController~iphone";
}

- (id)init {
    self = [super init];
    if (self) {
        self.resourceClass = [SLFDistrictMap class];
        self.region = [self unitedStatesRegion];
    }
    return self;
}

- (void) dealloc {
	self.mapView = nil;
    self.resourcePath = nil;
	[super dealloc];
}

- (void) didReceiveMemoryWarning {	
	[self clearOverlaysExceptRecent];
	[super didReceiveMemoryWarning];
}

- (void) viewDidLoad {
	[super viewDidLoad];
	
	colorIndex = 0;
	if (![UtilityMethods isIPadDevice])
		self.hidesBottomBarWhenPushed = YES;
	
	[self.view setBackgroundColor:[TexLegeTheme backgroundLight]];
	self.mapView.showsUserLocation = NO;
    self.mapView.region = self.region;
	self.navigationController.navigationBar.tintColor = [TexLegeTheme navbar];
	//self.navigationItem.title = @"District Location";
    
   /* if (!IsEmpty(self.mapView.annotations))
        [self.mapView setCenterCoordinate:[[self.mapView.annotations objectAtIndex:0] coordinate] animated:NO];
    else
        [self.mapView setCenterCoordinate:[self unitedStatesRegion].center animated:NO];*/
}

- (void) viewDidUnload {
    self.mapView = nil;
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
	[self.mapView removeOverlays:self.mapView.overlays];
	[super viewDidDisappear:animated];
}

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
    if ([detailObj isKindOfClass:[SLFDistrictMap class]]) {
        SLFDistrictMap *map = detailObj;
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

- (void)setDistrictMap:(SLFDistrictMap *)newMap {
    
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
        //[[NSNotificationCenter defaultCenter] postNotificationName:kNotifyTableDataUpdated object:self];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    [SLFRestKitManager showFailureAlertWithRequest:objectLoader error:error];
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


- (void) clearOverlaysExceptRecent {
	self.mapView.showsUserLocation = NO;
	
	NSMutableArray *toRemove = [[NSMutableArray alloc] init];
	if (toRemove) {
		[toRemove setArray:self.mapView.overlays];
		if ([toRemove count]>1) {
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
    /*if (![self region:self.mapView.region isEqualTo:[self unitedStatesRegion]]) { 
		[self performSelector:@selector(animateToUnitedStates) withObject:nil afterDelay:0.3];
		[self performSelector:@selector(animateToAnnotation:) withObject:annotation afterDelay:1.7];   
        return;
	}*/
    [self performSelector:@selector(animateToAnnotation:) withObject:annotation afterDelay:0.7];	
}

#pragma mark -
#pragma mark Properties


- (BOOL) region:(MKCoordinateRegion)region1 isEqualTo:(MKCoordinateRegion)region2 {
	MKMapPoint coord1 = MKMapPointForCoordinate(region1.center);
	MKMapPoint coord2 = MKMapPointForCoordinate(region2.center);
	BOOL coordsEqual = MKMapPointEqualToPoint(coord1, coord2);
    return coordsEqual;
}

#pragma mark -
#pragma mark Action Sheet

- (IBAction) annotationActionSheet:(id)sender {
	UIActionSheet *popupQuery = [[UIActionSheet alloc]
								 initWithTitle:nil
								 delegate:self
								 cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"StandardUI", @"Button to cancel something")
								 destructiveButtonTitle:nil
								 otherButtonTitles:NSLocalizedStringFromTable(@"Open in Google Maps", @"AppAlerts", @"Button to open google maps"), 
								 nil];
	
	
	popupQuery.actionSheetStyle = UIActionSheetStyleAutomatic;
	
	UIView *aView = sender;
	if (aView)
		[popupQuery showFromRect:aView.bounds inView:aView animated:YES];
	else
		[popupQuery showInView:self.mapView];
	[popupQuery release];
}

//- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	if (buttonIndex == 0) {
		// if you want driving directions, daddr is the destination, saddr is the origin
		// @"http://maps.google.com/maps?daddr=San+Francisco,+CA&saddr=cupertino"
		// [NSString stringWithFormat: @"http://maps.google.com/maps?q=%f,%f", loc.latitude, loc.longitude];
		
		NSString *urlString =  [NSString stringWithFormat:@"%@/maps?q=%f,%f",
								[UtilityMethods texLegeStringWithKeyPath:@"ExternalURLs.googleMapsWeb"],
							self.annotationActionCoord.latitude, self.annotationActionCoord.longitude];	
		
		NSURL *url = [NSURL URLWithString:[urlString urlSafeString]];
		[UtilityMethods openURLWithTrepidation:url];
	}
}


#pragma mark -
#pragma mark MapViewDelegate

/*
- (void)mapView:(MKMapView *)theMapView annotationView:(MKAnnotationView *)annotationView 
									calloutAccessoryControlTapped:(UIControl *)control {
	id <MKAnnotation> annotation = annotationView.annotation;
	if ([annotation isKindOfClass:[DistrictOfficeObj class]])
    {
		self.annotationActionCoord = annotation.coordinate;
		[self annotationActionSheet:control];		
	}		
}
*/

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    if ([annotation isKindOfClass:[SLFDistrictMap class]]) 
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
			
			pinView.rightCalloutAccessoryView = nil;
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
		myColor = [TexLegeTheme texasOrange];

		NSString *ovTitle = [overlay title];
		if (ovTitle && [ovTitle hasSubstring:stringForChamber(HOUSE, TLReturnFull) caseInsensitive:NO]) {
			if (self.mapView.mapType > MKMapTypeStandard)
				myColor = [UIColor cyanColor];
			else
				myColor = [TexLegeTheme texasGreen];
		}

		MKPolygonView *aView = nil;

		aView = [[[MKPolygonView alloc] initWithPolygon:(MKPolygon*)overlay] autorelease];		
		aView.fillColor = [myColor colorWithAlphaComponent:0.2];
        aView.strokeColor = [myColor colorWithAlphaComponent:0.7];
        aView.lineWidth = 3;
		
		self.districtView = aView;

        return aView;
    }
	
	else if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineView*    aView = [[[MKPolylineView alloc] initWithPolyline:(MKPolyline*)overlay] autorelease];
        aView.strokeColor = myColor;
        aView.lineWidth = 3;
        return aView;
    }
	
	return nil;
}



- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView {
	
	id<MKAnnotation> annotation = aView.annotation;
	if (!annotation || ![aView isSelected])
		return;
	
	
	if ([annotation isKindOfClass:[SLFDistrictMap class]]) {
        SLFDistrictMap *map = (SLFDistrictMap *)annotation;
        self.region = map.region;
        return;
    }
    [self animateToAnnotation:annotation];
        //[self.mapView setCenterCoordinate:annotation.coordinate animated:YES];
    
}


#pragma mark -
#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation { // Override to allow rotation. Default returns YES only for UIDeviceOrientationPortrait
	return YES;
}

@end
