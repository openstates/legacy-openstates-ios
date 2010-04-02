//
//  Legislator.h
//  TexLege
//
//  Created by Gregory Combs on 5/24/09.
//  Copyright 2009 University of Texas at Dallas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EXSharedObject.h"

// Legislative Chamber / Legislator Type
#define HOUSE 1
#define SENATE 2

// Political Party
#define DEMOCRAT 1
#define REPUBLICAN 2

@interface Legislator : EXSharedObject {	
	NSNumber *legislatorID;
	NSNumber *legtype;
	NSString *legtype_name;
	NSString *lastname;
	NSString *firstname;
	NSString *middlename;
	NSString *nickname;
	NSString *suffix;
	NSString *party_name;
	NSNumber *party_id;
	NSNumber *district;
	NSNumber *tenure;
	NSNumber *partisan_index;

	NSString *photo_name;
//	UIImage *leg_image;

	NSString *bio_url;
	NSString *notes;	
	NSString *gallery_desk;	


	NSString *cap_office;	
	NSString *staff;
	NSString *cap_phone;	
	NSString *cap_fax;	
	NSString *cap_phone2_name;	
	NSString *cap_phone2;	

	NSString *dist1_street;
	NSString *dist1_city;
	NSString *dist1_zip;
	NSString *dist1_phone;
	NSString *dist1_fax;
	
	NSString *dist2_street;
	NSString *dist2_city;
	NSString *dist2_zip;
	NSString *dist2_phone;
	NSString *dist2_fax;
	
	NSString *dist3_street;
	NSString *dist3_city;
	NSString *dist3_zip;
	NSString *dist3_phone1;
	NSString *dist3_fax;
	
	NSString *dist4_street;
	NSString *dist4_city;
	NSString *dist4_zip;
	NSString *dist4_phone1;
	NSString *dist4_fax;
	

	
}

- (id)initWithDictionary:(NSDictionary *)aDictionary;

@property (nonatomic, retain)NSNumber *legislatorID;
@property (nonatomic, retain)NSString *legtype_name;
@property (nonatomic, retain)NSNumber *legtype;
@property (nonatomic, retain)NSString *lastname;
@property (nonatomic, retain)NSString *firstname;
@property (nonatomic, retain)NSString *middlename;
@property (nonatomic, retain)NSString *nickname;
@property (nonatomic, retain)NSString *suffix;
@property (nonatomic, retain)NSString *party_name;
@property (nonatomic, retain)NSNumber *party_id;
@property (nonatomic, retain)NSNumber *district;
@property (nonatomic, retain)NSNumber *tenure;
@property (nonatomic, retain)NSNumber *partisan_index;
@property (nonatomic, retain)NSString *photo_name;
@property (nonatomic, retain)NSString *bio_url;
@property (nonatomic, retain)NSString *notes;	
@property (nonatomic, retain)NSString *gallery_desk;	

@property (nonatomic, retain)NSString *cap_office;	
@property (nonatomic, retain)NSString *staff;	
@property (nonatomic, retain)NSString *cap_phone;	
@property (nonatomic, retain)NSString *cap_fax;	
@property (nonatomic, retain)NSString *cap_phone2_name;	
@property (nonatomic, retain)NSString *cap_phone2;	

@property (nonatomic, retain)NSString *dist1_street;
@property (nonatomic, retain)NSString *dist1_city;
@property (nonatomic, retain)NSString *dist1_zip;
@property (nonatomic, retain)NSString *dist1_phone;
@property (nonatomic, retain)NSString *dist1_fax;

@property (nonatomic, retain)NSString *dist2_street;
@property (nonatomic, retain)NSString *dist2_city;
@property (nonatomic, retain)NSString *dist2_zip;
@property (nonatomic, retain)NSString *dist2_phone;
@property (nonatomic, retain)NSString *dist2_fax;

@property (nonatomic, retain)NSString *dist3_street;
@property (nonatomic, retain)NSString *dist3_city;
@property (nonatomic, retain)NSString *dist3_zip;
@property (nonatomic, retain)NSString *dist3_phone1;
@property (nonatomic, retain)NSString *dist3_fax;

@property (nonatomic, retain)NSString *dist4_street;
@property (nonatomic, retain)NSString *dist4_city;
@property (nonatomic, retain)NSString *dist4_zip;
@property (nonatomic, retain)NSString *dist4_phone1;
@property (nonatomic, retain)NSString *dist4_fax;

@property (retain) NSDate *date;
@property (retain) NSDate *primitiveDate;

@property (readonly) NSString *partyShortName;
@property (readonly) NSString *legTypeShortName;

//@property (nonatomic, retain)UIImage *legislatorImage;
@property (readonly) UIImage *legislatorImage;


@end
