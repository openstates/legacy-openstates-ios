
//
//  CustomAnnotation.h
//  TexLege
//
//  Created by Gregory Combs on 7/27/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "CustomAnnotation.h"
#import	"BSKmlResult.h"
#import "TexLegeAppDelegate.h"

@implementation CustomAnnotation

@synthesize pinColorIndex, regionDict, addressDict, title, subtitle, imageName;

-(id)initWithBSKmlResult:(BSKmlResult*) kmlResult {
	self = [super init];
	
	if (self != nil) {		
		self.regionDict = [NSDictionary dictionaryWithObjectsAndKeys:
						   [NSNumber numberWithDouble:kmlResult.latitude], @"latitude",
						   [NSNumber numberWithDouble:kmlResult.longitude], @"longitude",
						   [NSNumber numberWithDouble:kmlResult.coordinateSpan.latitudeDelta], @"spanLat",
						   [NSNumber numberWithDouble:kmlResult.coordinateSpan.longitudeDelta], @"spanLon", nil];
						   
		
		self.addressDict = kmlResult.addressDict;
		
		self.pinColorIndex = [NSNumber numberWithInteger:MKPinAnnotationColorGreen]; 
		self.imageName = @"silverstar.png";
	}
	
	return self;
}

- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init])
    {
        self.title = [coder decodeObjectForKey:@"title"];
        self.subtitle = [coder decodeObjectForKey:@"subtitle"];
        self.imageName = [coder decodeObjectForKey:@"imageName"];
        self.pinColorIndex = [coder decodeObjectForKey:@"pinColorIndex"];
        self.regionDict = [coder decodeObjectForKey:@"regionDict"];
        self.addressDict = [coder decodeObjectForKey:@"addressDict"];
		
    }
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:self.title		forKey:@"title"];
	[coder encodeObject:self.subtitle	forKey:@"subtitle"];
	[coder encodeObject:self.imageName	forKey:@"imageName"];
    [coder encodeObject:self.pinColorIndex	forKey:@"pinColorIndex"];
	[coder encodeObject:self.regionDict		forKey:@"regionDict"];
	[coder encodeObject:self.addressDict	forKey:@"addressDict"];
	
}

- (void)dealloc {	
	self.title = nil;
	self.subtitle = nil;
	self.imageName = nil;
	self.pinColorIndex = nil;
	self.regionDict = nil;
	self.addressDict = nil;
	
	[super dealloc];
}

#pragma mark -
#pragma mark MKAnnotation properties

- (UIImage *)image {
	if (!self.imageName || ![self.imageName length])
		return [UIImage imageNamed:@"silverstar.png"];
	else 
		return [UIImage imageNamed:self.imageName];
}

- (NSString *)title {
	if (title)
		return title;
	else
		return @"Searched Location";
}

// optional
- (NSString *)subtitle
{
	if (subtitle)
		return subtitle;
	
	//debug_NSLog(@"addressDict: %@", self.addressDict);
	NSString *formattedString = [self.addressDict objectForKey:@"formattedAddress"];
	NSString *componentString = [self.addressDict objectForKey:@"address"];
	
	if (!formattedString && !componentString)
		return nil;

	/*
	 NSInteger formattedLength = [formattedString length];
	NSRange strRange = NSMakeRange(NSNotFound, 0);
	if (formattedString && formattedLength)
		strRange = [formattedString rangeOfString:@","];
	if (strRange.length > 0 && strRange.location < formattedLength)
		formattedString = [formattedString substringToIndex:strRange.location];
	*/
	if (formattedString && [formattedString length])
		return formattedString;
	else {
		//debug_NSLog(@"formatted address not found, using component address: %@", componentString);
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
