//
//  LegislatorsListing.h
//  TexLege
//
//  Created by Gregory Combs on 5/24/09.
//  Copyright 2009 University of Texas at Dallas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Legislator.h"
#import "EXContainer.h"

@interface LegislatorsListing : NSObject {

	NSMutableDictionary *legislatorDictionary;

	NSMutableDictionary *houseDictionary;
	NSMutableDictionary *senateDictionary;
	NSMutableDictionary *nameIndexesDictionary;
	
	NSArray *legislatorNameIndexArray;
	NSArray *legislatorHouseArray;
	NSArray *legislatorSenateArray;	
	
	
	EXContainer* container;
	NSArray* resultSet;
	
}

@property (nonatomic,retain) NSMutableDictionary *legislatorDictionary;		// key is legislatorID
@property (nonatomic,retain) NSMutableDictionary *houseDictionary;			// key is first letter of last name
@property (nonatomic,retain) NSMutableDictionary *senateDictionary;			// key is first letter of last name
@property (nonatomic,retain) NSMutableDictionary *nameIndexesDictionary;	// key is first letter of last name

@property (nonatomic,retain) NSArray *legislatorNameIndexArray;
@property (nonatomic,retain) NSArray *legislatorHouseArray;
@property (nonatomic,retain) NSArray *legislatorSenateArray;

- (EXContainer*)container;

+ (LegislatorsListing*)sharedLegislators;

- (NSArray *)legislatorsWithInitialLetter:(NSString*)aKey;
- (NSArray *)legislatorsWithInitialLetter:(NSString*)aKey forChamber:(NSNumber*)aChamber;


@end
