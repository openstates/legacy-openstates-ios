#if NEEDS_TO_INITIALIZE_DATABASE == 1
//
//  DistrictMapImporter.m
//  TexLege
//
//  Created by Gregory Combs on 8/25/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "DistrictMapImporter.h"
#import "DistrictMap.h"
#import "DistrictMapDataSource.h"

// This framework was imported so we could use the kCFURLErrorNotConnectedToInternet error code.
#import <CFNetwork/CFNetwork.h>

#pragma mark DistrictMapImporter (Private) 

@interface DistrictMapImporter (Private)
- (void)addDistrictMapsToList:(NSArray *)districtMaps;
- (void)handleError:(NSError *)error;
@end

#pragma mark -
#pragma mark DistrictMapImporter

@implementation DistrictMapImporter

@synthesize dataSource;
@synthesize districtMapList;
@synthesize districtMapFeedConnection;
@synthesize districtMapData;
@synthesize currentDistrictMapObject;
@synthesize currentParsedCharacterData;
@synthesize currentParseBatch;
@synthesize currentChamber;


- (void)dealloc {
    [districtMapFeedConnection cancel];
    [districtMapFeedConnection release];
    
    [districtMapData release];

    [districtMapList release];
    [currentDistrictMapObject release];
    [currentParsedCharacterData release];
    [currentParseBatch release];
    
    [super dealloc];
}

- (id) initWithChamber:(NSInteger)theChamber dataSource:(DistrictMapDataSource *)theDataSource {
	if (self=[super init]) {
		self.districtMapList = [NSMutableArray array];

		self.currentChamber = theChamber;
		self.dataSource = theDataSource;
		
		// Use NSURLConnection to asynchronously download the data. This means the main thread will not
		// be blocked - the application will remain responsive to the user. 
		//
		// IMPORTANT! The main thread of the application should never be blocked!
		// Also, avoid synchronous network access on any thread.
		//
		//static NSString *feedURLString = @"http://districtMap.usgs.gov/eqcenter/catalogs/7day-M2.5.xml";
		
		NSString *kmlFile = nil;
		if (theChamber == SENATE)
			kmlFile = @"planS01188";
		else
			kmlFile = @"planH01369";
				
		
		NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
		NSString *feedString = [thisBundle pathForResource:kmlFile ofType:@"kml"];
		
		NSURL *feedURL = [NSURL fileURLWithPath:feedString];
		NSURLRequest *districtMapURLRequest = [NSURLRequest requestWithURL:feedURL];
		self.districtMapFeedConnection =
					[[[NSURLConnection alloc] initWithRequest:districtMapURLRequest delegate:self] autorelease];
		
		// Test the validity of the connection object. The most likely reason for the connection object
		// to be nil is a malformed URL, which is a programmatic error easily detected during development.
		// If the URL is more dynamic, then you should implement a more flexible validation technique,
		// and be able to both recover from errors and communicate problems to the user in an
		// unobtrusive manner.
		NSAssert(self.districtMapFeedConnection != nil, @"Failure to create URL connection.");
		
		// Start the status bar network activity indicator. We'll turn it off when the connection
		// finishes or experiences an error.
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		
	}
	return self;
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

// The following are delegate methods for NSURLConnection. Similar to callback functions, this is
// how the connection object, which is working in the background, can asynchronously communicate back
// to its delegate on the thread from which it was started - in this case, the main thread.
//
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // check for HTTP status code for proxy authentication failures
    // anything in the 200 to 299 range is considered successful,
    // also make sure the MIMEType is correct:
    //
	//NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
	self.districtMapData = [NSMutableData data];
#if 0
    if ((([httpResponse statusCode]/100) == 2) && [[response MIMEType] isEqual:@"application/atom+xml"]) {
        self.districtMapData = [NSMutableData data];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:
								  NSLocalizedString(@"HTTP Error",
													@"Error message displayed when receving a connection error.")
															 forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"HTTP" code:[httpResponse statusCode] userInfo:userInfo];
        [self handleError:error];
    }
#endif
	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [districtMapData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    if ([error code] == kCFURLErrorNotConnectedToInternet) {
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo =
		[NSDictionary dictionaryWithObject:
		 NSLocalizedString(@"No Connection Error",
						   @"Error message displayed when not connected to the Internet.")
									forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
                                                         code:kCFURLErrorNotConnectedToInternet
                                                     userInfo:userInfo];
        [self handleError:noConnectionError];
    } else {
        // otherwise handle the error generically
        [self handleError:error];
    }
    self.districtMapFeedConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.districtMapFeedConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    // Spawn a thread to fetch the districtMap data so that the UI is not blocked while the
    // application parses the XML data.
    //
    // IMPORTANT! - Don't access UIKit objects on secondary threads.
    //
    [NSThread detachNewThreadSelector:@selector(parseDistrictMapData:)
                             toTarget:self
                           withObject:districtMapData];
    // districtMapData will be retained by the thread until parseDistrictMapData: has finished
    // executing, so we no longer need a reference to it in the main thread.
    self.districtMapData = nil;
}

- (void)parseDistrictMapData:(NSData *)data {
    // You must create a autorelease pool for all secondary threads.
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    self.currentParseBatch = [NSMutableArray array];
    self.currentParsedCharacterData = [NSMutableString string];
    //
    // It's also possible to have NSXMLParser download the data, by passing it a URL, but this is
    // not desirable because it gives less control over the network, particularly in responding to
    // connection errors.
    //
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    [parser parse];
	
    // depending on the total number of districtMaps parsed, the last batch might not have been a
    // "full" batch, and thus not been part of the regular batch transfer. So, we check the count of
    // the array and, if necessary, send it to the main thread.
    //
    if ([self.currentParseBatch count] > 0) {
        [self performSelectorOnMainThread:@selector(addDistrictMapsToList:)
                               withObject:self.currentParseBatch
                            waitUntilDone:NO];
    }
    self.currentParseBatch = nil;
    self.currentDistrictMapObject = nil;
    self.currentParsedCharacterData = nil;
    [parser release];        
    [pool drain];
}

// Handle errors in the download or the parser by showing an alert to the user. This is a very
// simple way of handling the error, partly because this application does not have any offline
// functionality for the user. Most real applications should handle the error in a less obtrusive
// way and provide offline functionality to the user.
//
- (void)handleError:(NSError *)error {
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView =
	[[UIAlertView alloc] initWithTitle:
	 NSLocalizedString(@"Error Title",
					   @"Title for alert displayed when download or parse error occurs.")
							   message:errorMessage
							  delegate:nil
					 cancelButtonTitle:@"OK"
					 otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

// The secondary (parsing) thread calls addToDistrictMapList: on the main thread with batches of
// parsed objects. The batch size is set via the kSizeOfDistrictMapBatch constant.
//
- (void)addDistrictMapsToList:(NSArray *)districtMaps {
    
    assert([NSThread isMainThread]);
	
	debug_NSLog(@"Adding district map to datasource");
    [self.districtMapList addObjectsFromArray:districtMaps];
	
    // insert the districtMaps into our rootViewController's data source (for KVO purposes)
	if (self.dataSource)
		[self.dataSource insertDistrictMaps:districtMaps];
}


#pragma mark -
#pragma mark Parser constants

// Change this number to something more reasonable for testing (like 40, or 3)
static const const NSUInteger kMaximumNumberOfDistrictMapsToParse = 200;

// When an DistrictMap object has been fully constructed, it must be passed to the main thread and
// the table view in RootViewController must be reloaded to display it. It may not be efficient to do
// this for every DistrictMap object - the overhead in communicating between the threads and reloading
// the table can exceed the benefit to the user. Instead, we pass the objects in batches, sized by the
// constant below. In your application, the optimal batch size will vary 
// depending on the amount of data in the object and other factors, as appropriate.
static NSUInteger const kSizeOfDistrictMapBatch = 2;

// Reduce potential parsing errors by using string constants declared in a single place.
static NSString * const kEntryElementName = @"Placemark";
static NSString * const kTitleElementName = @"SimpleData";
static NSString * const kTitleAttributeName = @"District";   // + value of attribute key="District"
static NSString * const kGeoRSSPointElementName = @"coordinates";

#pragma mark -
#pragma mark NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
	attributes:(NSDictionary *)attributeDict {
    // If the number of parsed districtMaps is greater than
    // kMaximumNumberOfDistrictMapsToParse, abort the parse.
    
    if (parsedDistrictMapsCounter >= kMaximumNumberOfDistrictMapsToParse) {
        // Use the flag didAbortParsing to distinguish between this deliberate stop
        // and other parser errors.
        //
        didAbortParsing = YES;
        [parser abortParsing];
    }
    if ([elementName isEqualToString:kEntryElementName]) {
        DistrictMap *districtMap = [[DistrictMap alloc] init];
        self.currentDistrictMapObject = districtMap;
        [districtMap release];
		self.currentDistrictMapObject.chamber = [NSNumber numberWithInteger:currentChamber];
    } else if (([elementName isEqualToString:kTitleElementName] 
				&& [[attributeDict valueForKey:@"name"] isEqualToString:kTitleAttributeName])||
               [elementName isEqualToString:kGeoRSSPointElementName] ) {
        // For the 'title', 'updated', or 'georss:point' element begin accumulating parsed character data.
        // The contents are collected in parser:foundCharacters:.
        accumulatingParsedCharacterData = YES;
        // The mutable string needs to be reset to empty.
        [currentParsedCharacterData setString:@""];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {     
    if ([elementName isEqualToString:kEntryElementName]) {
        [self.currentParseBatch addObject:self.currentDistrictMapObject];
        parsedDistrictMapsCounter++;
        if ([self.currentParseBatch count] >= kSizeOfDistrictMapBatch) //kMaximumNumberOfDistrictMapsToParse)
		{
            [self performSelectorOnMainThread:@selector(addDistrictMapsToList:)
                                   withObject:self.currentParseBatch
                                waitUntilDone:NO];
            self.currentParseBatch = [NSMutableArray array];
        }
    } 
	else if ([elementName isEqualToString:kTitleElementName]) {
		NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
		[f setNumberStyle:NSNumberFormatterDecimalStyle];
		self.currentDistrictMapObject.district = [f numberFromString:self.currentParsedCharacterData];
		[f release];
	}
	else if ([elementName isEqualToString:kGeoRSSPointElementName]) {
        // The georss:point element contains the latitude and longitude of the districtMap epicenter.
        // 18.6477 -66.7452
        //
		NSError *error=NULL;
		static NSString *matchPattern = @"(-?[0-9.]+),(-?[0-9.]+)";
		NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:matchPattern options:NSRegularExpressionCaseInsensitive error:&error];
		//NSUInteger numMatches = [regex numberOfMatchesInString:self.currentParsedCharacterData options:0 range:NSMakeRange(0, [self.currentParsedCharacterData length])];
		
		NSArray *matches = [regex matchesInString:self.currentParsedCharacterData
										  options:0
											range:NSMakeRange(0, [self.currentParsedCharacterData length])];
		
		//		CLLocationCoordinate2D coords[numMatches];
		//		int i=0;
		double lon, lat;
		NSMutableArray *coordArray = [[NSMutableArray alloc] init];
		
		for (NSTextCheckingResult *match in matches) {
			//NSRange matchRange = [match range];
			NSRange firstHalfRange = [match rangeAtIndex:1];
			NSRange secondHalfRange = [match rangeAtIndex:2];
			lon = [[self.currentParsedCharacterData substringWithRange:firstHalfRange] doubleValue];
			lat = [[self.currentParsedCharacterData substringWithRange:secondHalfRange] doubleValue];
			NSDictionary *coordDict = [NSDictionary dictionaryWithObjectsAndKeys:
									   [NSNumber numberWithDouble:lat], @"latitude",
									   [NSNumber numberWithDouble:lon], @"longitude", nil];
			//coords[i++] = CLLocationCoordinate2DMake(lat,lng);
			[coordArray addObject:coordDict];			
		}
		[self.currentDistrictMapObject setCoordinatesCArrayWithDictArray:coordArray];
		[coordArray release];
		
		[self.currentDistrictMapObject setComplete:YES];		
    }
    // Stop accumulating parsed character data. We won't start again until specific elements begin.
    accumulatingParsedCharacterData = NO;
}

// This method is called by the parser when it find parsed character data ("PCDATA") in an element.
// The parser is not guaranteed to deliver all of the parsed character data for an element in a single
// invocation, so it is necessary to accumulate character data until the end of the element is reached.
//
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (accumulatingParsedCharacterData) {
        // If the current element is one whose content we care about, append 'string'
        // to the property that holds the content of the current element.
        //
        [self.currentParsedCharacterData appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    // If the number of districtMap records received is greater than kMaximumNumberOfDistrictMapsToParse,
    // we abort parsing.  The parser will report this as an error, but we don't want to treat it as
    // an error. The flag didAbortParsing is how we distinguish real errors encountered by the parser.
    //
    if (didAbortParsing == NO) {
        // Pass the error to the main thread for handling.
        [self performSelectorOnMainThread:@selector(handleError:) withObject:parseError waitUntilDone:NO];
    }
}

@end
#endif

