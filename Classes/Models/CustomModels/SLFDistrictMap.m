#import "SLFDataModels.h"
#import "TexLegeMapPins.h"
//#import "NSData_Base64Extensions.h"

@implementation SLFDistrictMap
@synthesize districtPolygon;
@synthesize region;

#pragma mark -
#pragma mark Manual Relationship Mapping

- (void)setStateID:(NSString *)newID {
    [self willChangeValueForKey:@"stateID"];
    [self setPrimitiveStateID:newID];
    [self didChangeValueForKey:@"stateID"];
    
    if (!newID)
        return;
    
    SLFState *tempState = [SLFState findFirstByAttribute:@"abbreviation" withValue:newID];
    self.state = tempState;
}

- (void)setBoundaryKind:(NSString *)newChamber {
    [self willChangeValueForKey:@"boundaryKind"];
    [self setPrimitiveBoundaryKind:newChamber];
    [self didChangeValueForKey:@"boundaryKind"];
    
    if (!newChamber)
        return;
    
    if ([newChamber isEqualToString:@"SLDU"])
        self.chamber = @"upper";
    else if ([newChamber isEqualToString:@"SLDL"])
        self.chamber = @"lower";    
}

- (void)setSlug:(NSString *)newSlug {
    
    [self willChangeValueForKey:@"slug"];
    [self setPrimitiveSlug:newSlug];
    [self didChangeValueForKey:@"slug"];
    

    NSString *newID = newSlug;
    if (!newID || ([newID length]<7))
        return;
    
    NSArray *words = [newID componentsSeparatedByString:@"-"];
    if (!words || ([words count]<2))
        return;
        
    NSString *newStateID = [words objectAtIndex:1];
    if (newStateID) {
        self.stateID = newStateID;
    }    
    
    if ([words containsObject:@"district"]) {
        NSInteger index = [words indexOfObject:@"district"];
        index++;
        
        if ([words count] >= index) {
            NSInteger num = [[words objectAtIndex:index] integerValue];
            if (num > 0) {
                self.districtNumber = [NSNumber numberWithInteger:num];
            }
        }
    }
}

//////////////////////////////////
#pragma mark -
#pragma mark MKAnnotation and MKOverlay

- (CLLocationCoordinate2D)centroid {
    CLLocationCoordinate2D centroid;
    
    NSNumber *lon = [self.centroidCoords objectAtIndex:0];
    NSNumber *lat = [self.centroidCoords objectAtIndex:1];
    if (lon && lat) {
        centroid = CLLocationCoordinate2DMake([lat doubleValue], [lon doubleValue]);
        if (NO == CLLocationCoordinate2DIsValid(centroid)) {
            RKLogDebug(@"Invalid Centroid: lon=%@ lat=%@", lon, lat);
        }
    }
    return centroid;
}

#pragma mark -
#pragma mark MKAnnotation Protocol

- (CLLocationCoordinate2D)coordinate {
    return [self centroid];
}

- (NSString *)title {
    return self.name;
}

- (NSString *)subtitle {
    NSMutableString * memberNames = [NSMutableString string];
    
    NSInteger index = 0;
    for (SLFLegislator *leg in self.legislators) {
        NSString *legName = [NSString stringWithFormat:@"%@ %@ (%@)", 
                             [leg chamberShortName], 
                             leg.fullName, 
                             [leg partyShortName]];        
        
        if (index > 0)
            [memberNames appendFormat:@", %@", legName];
        else
            [memberNames appendString:legName];
            
        index++;
    }
    
    return memberNames;
}

- (UIImage *)image {
    if ([self.legislators count] == 1) {
        SLFLegislator *leg = [self.legislators anyObject];
        if (leg && NO == [[NSNull null] isEqual:leg]) {
            if ([leg.party isEqualToString:stringForParty(DEMOCRAT, TLReturnFull)])
                return [UIImage imageNamed:@"bluestar.png"];
            else if ([leg.party isEqualToString:stringForParty(REPUBLICAN, TLReturnFull)])
                return [UIImage imageNamed:@"redstar.png"];
        }
    }
    return [UIImage imageNamed:@"silverstar.png"];
}


#pragma mark -
#pragma mark Polygons

- (MKPolygon *)polygonWithRingCoordinates:(NSArray *)inRing span:(MKCoordinateSpan *)spanRef interiorRings:(NSArray *)interiorRings {    
    
    NSUInteger pointsCount = [inRing count];
    
    if (pointsCount == 0)
        return nil;
    
    CLLocationCoordinate2D *cArray = calloc(pointsCount, sizeof(CLLocationCoordinate2D));
    NSUInteger index = 0;
    
    double minLat = 0.f;
    double minLon = 0.f;
    double maxLat = 0.f;
    double maxLon = 0.f;
    
    for (NSArray *coords in inRing) {
        
        NSNumber *lon = [coords objectAtIndex:0];
        NSNumber *lat = [coords objectAtIndex:1];
        if (lat && lon) {
            double latFloat = [lat doubleValue];
            double lonFloat = [lon doubleValue];
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(latFloat, lonFloat);
            if (CLLocationCoordinate2DIsValid(coord)) {
                
                if (index == 0) {
                    maxLat = latFloat;
                    minLat = latFloat;
                    
                    maxLon = lonFloat;
                    minLon = lonFloat;
                }
                else {
                    maxLat = fmax(maxLat,latFloat);
                    minLat = fmin(minLat,latFloat);
                    
                    maxLon = fmax(maxLon,lonFloat);
                    minLon = fmin(minLon,lonFloat);
                }
                
                
                cArray[index++] = coord;
                
            }
        }
    }
    
    if (spanRef) {
        CLLocationDegrees lonDelta = fabs(maxLon - minLon);
        CLLocationDegrees latDelta = fabs(maxLat - minLat);
        *spanRef = MKCoordinateSpanMake(latDelta, lonDelta);
    }
    
    MKPolygon *outRing = nil;
    if (index > 0) {
        
        if (!interiorRings) {
            outRing = [MKPolygon polygonWithCoordinates:cArray count:index];
        }
        else {
            outRing = [MKPolygon polygonWithCoordinates:cArray count:index interiorPolygons:interiorRings];
        }
    }
    
    free(cArray);
    cArray = NULL;
    
    return outRing;
}

- (MKPolygon *)polygonAndRegion:(MKCoordinateRegion *)regionRef {
    
    // If we've already cached a polygon in memory, return it rather than recalculate it.
    if (self.districtPolygon) {
        if (regionRef) {
            *regionRef = self.region;
        }
        return self.districtPolygon;
    }
    
    NSString *shapeType = [self.shape objectForKey:@"type"];
    if ( !shapeType || [shapeType isEqual:[NSNull null]] || NO == [shapeType isEqualToString:@"MultiPolygon"] )
        return nil;
    
    NSArray * rings = [[self.shape objectForKey:@"coordinates"] objectAtIndex:0];
    NSUInteger ringCount = [rings count];
    
    if (NO == (ringCount > 0))
        return nil;
    
    // Build the array of interior rings/holes/cutouts (if any)
    NSMutableArray *interiorRings = nil;
    if (ringCount > 1) {
        
        interiorRings = [[NSMutableArray alloc] initWithCapacity:ringCount-1];
        NSInteger index;
        
        for (index=1; index < ringCount; index++) {
            
            NSArray *ring = [rings objectAtIndex:index];
            if (!ring || [[NSNull null] isEqual:ring] || ![ring count])
                continue;
            
            MKPolygon *newPolygon = [self polygonWithRingCoordinates:ring span:nil interiorRings:nil];
            if (!newPolygon)
                continue;
            
            [interiorRings addObject:newPolygon];
        }
    }
    
    // now build the big polygon, adding in the cutouts/holes
    MKCoordinateSpan span;
    MKPolygon *mainPolygon = [self polygonWithRingCoordinates:[rings objectAtIndex:0] span:&span interiorRings:interiorRings];
    
    if (interiorRings) {
        [interiorRings release];
        interiorRings = nil;
    }
    
    if (mainPolygon) {
        mainPolygon.title = self.name;
        
        if (regionRef) {
            self.region = MKCoordinateRegionMake([self centroid], span);
            *regionRef = self.region;
        }
    }
    
    // We're caching the polygon to memory...
    self.districtPolygon = mainPolygon;
    return mainPolygon;
}

#pragma mark -
#pragma mark Base64

/*
- (void) setCoordinatesBase64:(NSString *)newCoords {
	NSString *key = @"coordinatesBase64";
	
	self.coordinatesData = [NSData dataWithBase64EncodedString:newCoords];
	
	[self willChangeValueForKey:key];
	[self setPrimitiveValue:nil forKey:key];
	[self didChangeValueForKey:key];
}
*/

@end
