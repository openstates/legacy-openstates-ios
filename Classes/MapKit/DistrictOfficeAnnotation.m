
//
//  DistrictOfficeAnnotation.h
//  TexLege
//
//  Created by Gregory Combs on 7/27/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "DistrictOfficeAnnotation.h"
#import "LegislatorObj.h"
#import	"BSKmlResult.h"
#import "TexLegeAppDelegate.h"

@implementation DistrictOfficeAnnotation
@synthesize legislator;

@synthesize pinColorIndex, regionDict, addressDict;

-(id)initWithBSKmlResult:(BSKmlResult*) kmlResult {
	self = [super init];
	
	if (self != nil) {		
		self.regionDict = [NSDictionary dictionaryWithObjectsAndKeys:
						   [NSNumber numberWithDouble:kmlResult.latitude], @"latitude",
						   [NSNumber numberWithDouble:kmlResult.longitude], @"longitude",
						   [NSNumber numberWithDouble:kmlResult.coordinateSpan.latitudeDelta], @"spanLat",
						   [NSNumber numberWithDouble:kmlResult.coordinateSpan.longitudeDelta], @"spanLon", nil];
						   
		
		self.addressDict = kmlResult.addressDict;
		
		self.pinColorIndex = [NSNumber numberWithInteger:MKPinAnnotationColorPurple]; 
	}
	
	return self;
}

- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init])
    {
		NSURL *uriRepresentation = [coder decodeObjectForKey:@"legObjectID"];
		NSManagedObjectID *legislatorID = [[TexLegeAppDelegate appDelegate].persistentStoreCoordinator 
										   managedObjectIDForURIRepresentation:uriRepresentation];
		NSManagedObjectContext *mContext = [[TexLegeAppDelegate appDelegate] managedObjectContext];
		if (mContext && legislatorID) {
			NSManagedObject *object = [mContext objectWithID:legislatorID];
			if (object && [object isKindOfClass:[LegislatorObj class]])
				self.legislator = (LegislatorObj*)object;
		}
		
        self.pinColorIndex = [coder decodeObjectForKey:@"pinColorIndex"];
        self.regionDict = [coder decodeObjectForKey:@"regionDict"];
        self.addressDict = [coder decodeObjectForKey:@"addressDict"];
		
    }
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:[[self.legislator objectID] URIRepresentation]	forKey:@"legObjectID"];
    [coder encodeObject:self.pinColorIndex	forKey:@"pinColorIndex"];
	[coder encodeObject:self.regionDict		forKey:@"regionDict"];
	[coder encodeObject:self.addressDict	forKey:@"addressDict"];
	
}

- (void)dealloc {	
	self.legislator = nil;
	self.pinColorIndex = nil;
	self.regionDict = nil;
	self.addressDict = nil;
	
	[super dealloc];
}

#pragma mark -
#pragma mark LegislatorObj Accessor Properties

- (NSNumber*)chamber {
	return legislator.legtype;
}

- (NSNumber*)districtNumber {
	return legislator.district;
}

#pragma mark -
#pragma mark MKAnnotation properties

- (NSString *)title
{
	if (!self.legislator)
		return @"";
	
    return [self.legislator legProperName];
}

- (UIImage *)image {
	if (!self.legislator)
		return [UIImage imageNamed:@"slider_star.png"];
	else if ([self.legislator.party_id integerValue] == DEMOCRAT)
		return [UIImage imageNamed:@"bluestar.png"];
	else //if ([self.legislator.party_id integerValue] == REPUBLICAN)
		return [UIImage imageNamed:@"redstar.png"];
}

// optional
- (NSString *)subtitle
{
	//debug_NSLog(@"addressDict: %@", self.addressDict);
	NSString *formattedString = [self.addressDict objectForKey:@"formattedAddress"];
	NSString *componentString = [self.addressDict objectForKey:@"address"];
	
	if (!formattedString && !componentString)
		return nil;

	NSInteger formattedLength = [formattedString length];
	NSRange range = [formattedString rangeOfString:@","];
	if (range.length > 0 && range.location != NSNotFound && range.location < formattedLength)
		formattedString = [formattedString substringToIndex:range.location];
	
	if (formattedString && [formattedString length])
		return formattedString;
	else {
		debug_NSLog(@"formatted address not found, using component address: %@", componentString);
		return componentString;
	}
}

- (CLLocationCoordinate2D) coordinate {
	CLLocationCoordinate2D tempCoord = {[[self.regionDict valueForKey:@"latitude"] doubleValue],
										[[self.regionDict valueForKey:@"longitude"] doubleValue]};
	return tempCoord;
}

- (MKCoordinateSpan) span {
	return MKCoordinateSpanMake([[self.regionDict valueForKey:@"spanLat"] doubleValue],
								[[self.regionDict valueForKey:@"spanLon"] doubleValue]);
}

- (MKCoordinateRegion)region {
	return MKCoordinateRegionMake(self.coordinate, self.span);
}

@end
