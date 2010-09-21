#if NEEDS_TO_PARSE_KMLMAPS == 1

//
//  DistrictMapImporter.h
//  TexLege
//
//  Created by Gregory Combs on 8/25/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DistrictMap.h"
#import "DistrictMapDataSource.h"

@interface DistrictMapImporter : NSObject <NSXMLParserDelegate>{
    NSMutableArray *districtMapList;
	
    // for downloading the xml data
    NSURLConnection *districtMapFeedConnection;
    NSMutableData *districtMapData;
	
    // these variables are used during parsing
    DistrictMap *currentDistrictMapObject;
    NSMutableArray *currentParseBatch;
    NSUInteger parsedDistrictMapsCounter;
    NSMutableString *currentParsedCharacterData;
    BOOL accumulatingParsedCharacterData;
    BOOL didAbortParsing;
}

@property (nonatomic, retain) NSMutableArray *districtMapList;

@property (nonatomic, retain) NSURLConnection *districtMapFeedConnection;
@property (nonatomic, retain) NSMutableData *districtMapData;

@property (nonatomic, retain) DistrictMap *currentDistrictMapObject;
@property (nonatomic, retain) NSMutableString *currentParsedCharacterData;
@property (nonatomic, retain) NSMutableArray *currentParseBatch;
@property (nonatomic, retain) DistrictMapDataSource *dataSource;
@property (nonatomic) NSInteger currentChamber;
- (id) initWithChamber:(NSInteger)theChamber dataSource:(DistrictMapDataSource *)theDataSource;
@end
#endif
