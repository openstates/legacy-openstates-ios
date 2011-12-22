#import "SLFDataModels.h"
#import "SLFSortDescriptor.h"

@interface SLFDistrict()
- (MKPolygon *)polygonRingWithCoordinates:(NSArray *)ringCoords interiorRings:(NSArray *)interiorRings;
@end

@implementation SLFDistrict
@synthesize districtPolygon;
@synthesize region;

+ (RKManagedObjectMapping *)mapping {
    RKManagedObjectMapping *mapping = [RKManagedObjectMapping mappingForClass:[self class] inManagedObjectStore:[RKObjectManager sharedManager].objectStore];
    mapping.primaryKeyAttribute = @"boundaryID";
    [mapping mapKeyPath:@"abbr" toAttribute:@"stateID"];
    [mapping mapKeyPath:@"num_seats" toAttribute:@"numSeats"];
    [mapping mapKeyPath:@"region" toAttribute:@"regionDictionary"];
    [mapping mapKeyPath:@"boundary_id" toAttribute:@"boundaryID"];
    [mapping mapAttributes:@"name", @"chamber", @"shape", nil];
    return mapping;
}

+ (RKManagedObjectMapping *)mappingWithStateMapping:(RKManagedObjectMapping *)stateMapping {
    RKManagedObjectMapping *mapping = [[self class] mapping];
    [mapping connectStateToKeyPath:@"state" withStateMapping:stateMapping];
    return mapping;
}

+ (NSArray*)searchableAttributes {
    return [NSArray arrayWithObjects:@"name", nil];
}

- (NSNumber *)districtNumber {
    return [NSNumber numberWithInt:[self.name integerValue]];
}

- (SLFChamber *)chamberObj {
    return [SLFChamber chamberWithType:self.chamber forState:self.state];
}

+ (NSArray *)sortDescriptors {
    NSSortDescriptor *nameDesc = [SLFSortDescriptor stringSortDescriptorWithKey:@"name" ascending:YES];
    NSSortDescriptor *chamberDesc = [NSSortDescriptor sortDescriptorWithKey:@"chamber" ascending:YES];
    return [NSArray arrayWithObjects:nameDesc, chamberDesc, nil];
}
    
#pragma mark -
#pragma mark MKAnnotation Protocol

- (CLLocationCoordinate2D)coordinate {
    return self.region.center;
}

- (MKCoordinateRegion) region {
    CLLocationDegrees latDelta = [[self.regionDictionary objectForKey:@"lat_delta"] doubleValue];
    CLLocationDegrees lonDelta = [[self.regionDictionary objectForKey:@"lon_delta"] doubleValue];
    MKCoordinateSpan distanceToCenter = MKCoordinateSpanMake(latDelta,lonDelta);
    CLLocationDegrees latitude = [[self.regionDictionary objectForKey:@"center_lat"] doubleValue];
    CLLocationDegrees longitude = [[self.regionDictionary objectForKey:@"center_lon"] doubleValue];
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(latitude, longitude);
    if (NO == CLLocationCoordinate2DIsValid(center))
        RKLogDebug(@"Invalid Centroid: lat=%lf lon=%lf", latitude, longitude);
    return MKCoordinateRegionMake(center, distanceToCenter);
}

- (NSArray *)calloutCells {
    if (IsEmpty(self.legislators))
        return nil;
    return [self valueForKeyPath:@"legislators.calloutCell"];
}

- (NSString *)title {
    return [NSString stringWithFormat:@"%@ %@ %@ %@", self.state.name, self.chamberObj.shortName, @"District", self.name];
}

- (NSString *)subtitle {
    NSMutableString * memberNames = [NSMutableString string];
    NSString *chamberName = self.chamberObj.shortName;
    NSInteger index = 0;
    for (SLFLegislator *leg in self.legislators) {
        NSString *legName = [NSString stringWithFormat:@"%@ %@ (%@)", chamberName, leg.fullName, leg.partyObj.initial];        
        if (index > 0)
            [memberNames appendFormat:@", %@", legName];
        else
            [memberNames appendString:legName];
        index++;
    }
    return memberNames;
}

- (SLFParty *)party {
    SLFParty *aParty = [Independent independent];
    if (self.legislators && [self.legislators count] == 1) {
        SLFLegislator *leg = [self.legislators anyObject];
        if (leg && ![[NSNull null] isEqual:leg])
            aParty = leg.partyObj;
    }
    return aParty;
}

- (UIImage *)image {
    return self.party.image;
}

- (NSUInteger)pinColorIndex {
    return self.party.pinColorIndex;
}

+ (NSString *)estimatedBoundaryIDForDistrict:(NSString *)district chamber:(SLFChamber *)chamberObj {
    NSParameterAssert(chamberObj != NULL);
    NSString *chamberName = [chamberObj.shortName lowercaseString];
    NSString *boundaryCode = chamberObj.isUpperChamber ? @"sldu" : @"sldl";
    if ([chamberName hasPrefix:@"senate"] || [chamberName hasPrefix:@"house"])
        chamberName = [NSString stringWithFormat:@"state-%@", chamberName];
    return [[NSString stringWithFormat:@"%@-%@-%@-district-%@", boundaryCode, chamberObj.stateID, chamberName, district] lowercaseString];    
}

#pragma mark -
#pragma mark Polygons

- (MKPolygon *)polygonFactory {
        // If we've already cached a polygon in memory, return it rather than recalculate it.
    if (self.districtPolygon)
        return self.districtPolygon;
    NSArray *rings = [self shape];
    if(IsEmpty(rings)) {
        RKLogError(@"District %@ shape is empty or has no rings.", self.boundaryID);
        return nil;
    }
    NSUInteger ringCount = [rings count];
    MKPolygon *tempPolygon = nil;
    NSInteger index = ringCount - 1;
    NSMutableArray *interiorRings = (ringCount > 1 ? [[NSMutableArray alloc] initWithCapacity:index] : nil);
    for (NSArray *ring in [rings reverseObjectEnumerator]) {
        if (IsEmpty(ring)) {
            RKLogError(@"District %@ shape has null or malformed content.", self.boundaryID);
            break;
        }
        BOOL isInnerRing = (index > 0);
        if (isInnerRing) {
            tempPolygon = [self polygonRingWithCoordinates:ring interiorRings:nil];
            if (!tempPolygon)
                continue;
            [interiorRings addObject:tempPolygon];                
        }
        else
            tempPolygon = [self polygonRingWithCoordinates:ring interiorRings:interiorRings];
        index--;
    }
    SLFRelease(interiorRings);
    if (!tempPolygon)
        return nil;
    tempPolygon.title = self.name;    
    tempPolygon.subtitle = self.boundaryID;
    self.districtPolygon = tempPolygon;
    return tempPolygon;
}

- (MKPolygon *)polygonRingWithCoordinates:(NSArray *)ringCoords interiorRings:(NSArray *)interiorRings {    
    NSUInteger numberOfCoordinates = [ringCoords count];
    RKLogDebug(@"number of coordinates: %d", numberOfCoordinates);
    if (numberOfCoordinates == 0)
        return nil;
    CLLocationCoordinate2D *cArray = calloc(numberOfCoordinates, sizeof(CLLocationCoordinate2D));
    NSUInteger index = 0;
    for (NSArray *coords in ringCoords) {
        NSNumber *lon = [coords objectAtIndex:0];
        NSNumber *lat = [coords objectAtIndex:1];
        if (!lat || !lon)
            continue;
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([lat doubleValue], [lon doubleValue]);
        if (CLLocationCoordinate2DIsValid(coord)) {
            cArray[index++] = coord;
        }
    }
    MKPolygon *outRing = nil;
    if (index > 0) {
        if (!interiorRings)
            outRing = [MKPolygon polygonWithCoordinates:cArray count:index];
        else
            outRing = [MKPolygon polygonWithCoordinates:cArray count:index interiorPolygons:interiorRings];
    }
    free(cArray);
    cArray = NULL;
    return outRing;
}

@end
