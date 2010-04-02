//
//  Legislator.m
//  TexLege
//
//  Created by Gregory Combs on 5/24/09.
//  Copyright 2009 University of Texas at Dallas. All rights reserved.
//

#import "Legislator.h"


@implementation Legislator

@dynamic date, primitiveDate;

@synthesize legislatorID;
@synthesize legtype;
@synthesize legtype_name;
@synthesize lastname;
@synthesize firstname;
@synthesize middlename;
@synthesize nickname;
@synthesize suffix;
@synthesize party_name;
@synthesize party_id;
@synthesize district;
@synthesize tenure;
@synthesize partisan_index;

@synthesize photo_name;
//@synthesize leg_image;

@synthesize bio_url;
@synthesize notes;	
@synthesize gallery_desk;	


@synthesize cap_office;	
@synthesize staff;	
@synthesize cap_phone;	
@synthesize cap_fax;	
@synthesize cap_phone2_name;	
@synthesize cap_phone2;	

@synthesize dist1_street;
@synthesize dist1_city;
@synthesize dist1_zip;
@synthesize dist1_phone;
@synthesize dist1_fax;

@synthesize dist2_street;
@synthesize dist2_city;
@synthesize dist2_zip;
@synthesize dist2_phone;
@synthesize dist2_fax;

@synthesize dist3_street;
@synthesize dist3_city;
@synthesize dist3_zip;
@synthesize dist3_phone1;
@synthesize dist3_fax;

@synthesize dist4_street;
@synthesize dist4_city;
@synthesize dist4_zip;
@synthesize dist4_phone1;
@synthesize dist4_fax;

- (id)init {
	if (self = [super init]) {
		//self.primitiveDate = [NSDate date];

		self.legislatorID = [[NSNumber alloc] initWithLong:99999];
		self.legtype = [[NSNumber alloc] initWithInt:1];
		self.legtype_name = [[NSString alloc] initWithString:@"Representative"];
		self.lastname = [[NSString alloc] initWithString:@"LastName"];
		self.firstname = [[NSString alloc] initWithString:@"FirstName"];
		self.middlename = [[NSString alloc] initWithString:@"MiddleName"];
		self.nickname = [[NSString alloc] initWithString:@"NickName"];
		self.suffix = [[NSString alloc] initWithString:@"SuffixName"];
		self.party_name = [[NSString alloc] initWithString:@"Republican"];
		self.party_id = [[NSNumber alloc] initWithInt:2];
		self.district = [[NSNumber alloc] initWithInt:999];
		self.tenure = [[NSNumber alloc] initWithInt:0];
		self.partisan_index = [[NSNumber alloc] initWithFloat:1.0];
		
		self.photo_name = [[NSString alloc] initWithString:@"photo_name.jpg"];
		//	UIImage *leg_image;
		
		self.bio_url = [[NSString alloc] initWithString:@"http://www.engadget.com/"];
		self.notes = [[NSString alloc] initWithString:@"No notes here."];
		self.gallery_desk = [[NSString alloc] initWithString:@"Spkr's Desk"];
		
		
		self.cap_office = [[NSString alloc] initWithString:@"2E.553"];
		self.staff = [[NSString alloc] initWithString:@"Happy Helper"];
		self.cap_phone = [[NSString alloc] initWithString:@"512-555-1212"];	
		self.cap_fax = [[NSString alloc] initWithString:@"512-555-1213"];
		self.cap_phone2_name = [[NSString alloc] initWithString:@"Toll Free"];
		self.cap_phone2 = [[NSString alloc] initWithString:@"866-977-WORD"];	
		
		self.dist1_street = [[NSString alloc] initWithString:@"123 Jump Street"];
		self.dist1_city = [[NSString alloc] initWithString:@"Yoakum"];
		self.dist1_zip = [[NSString alloc] initWithString:@"77777-7777"];
		self.dist1_phone = [[NSString alloc] initWithString:@"972-444-1121"];
		self.dist1_fax = [[NSString alloc] initWithString:@"972-444-1123"];
		
		self.dist2_street =[[NSString alloc] initWithString: @"999 Check It"];
		self.dist2_city = [[NSString alloc] initWithString:@"Drillsville"];
		self.dist2_zip = [[NSString alloc] initWithString:@"87777-7777"];
		self.dist2_phone = [[NSString alloc] initWithString:@"222-444-1121"];
		self.dist2_fax = [[NSString alloc] initWithString:@"222-444-1123"];
		
		self.dist3_street = [[NSString alloc] initWithString:@"232 Flyby Way"];
		self.dist3_city = [[NSString alloc] initWithString:@"Muleshoe"];
		self.dist3_zip = [[NSString alloc] initWithString:@"99999-7777"];
		self.dist3_phone1 = [[NSString alloc] initWithString:@"806-444-1121"];
		self.dist3_fax = [[NSString alloc] initWithString:@"806-444-1123"];
		
		self.dist4_street = [[NSString alloc] initWithString:@"7644 Chalk Mountain Street"];
		self.dist4_city = [[NSString alloc] initWithString:@"Glenrose"];
		self.dist4_zip = [[NSString alloc] initWithString:@"75555-7777"];
		self.dist4_phone1 = [[NSString alloc] initWithString:@"855-444-1121"];
		self.dist4_fax = [[NSString alloc] initWithString:@"855-444-1123"];
	
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary *)aDictionary {
	if ([self init]) {
		//self.primitiveDate = [NSDate date];
		
		self.legislatorID = [aDictionary valueForKey:@"legislatorID"];
		self.legtype = [aDictionary valueForKey:@"legtype"];
		self.legtype_name = [aDictionary valueForKey:@"legtype_name"];
		self.lastname = [aDictionary valueForKey:@"lastname"];
		self.firstname = [aDictionary valueForKey:@"firstname"];
		self.middlename = [aDictionary valueForKey:@"middlename"];
		self.nickname = [aDictionary valueForKey:@"nickname"];
		self.suffix = [aDictionary valueForKey:@"suffix"];
		self.party_name = [aDictionary valueForKey:@"party_name"];
		self.party_id = [aDictionary valueForKey:@"party_id"];
		self.district = [aDictionary valueForKey:@"district"];
		self.tenure = [aDictionary valueForKey:@"tenure"];
		self.partisan_index = [aDictionary valueForKey:@"partisan_index"];
		
		self.photo_name = [aDictionary valueForKey:@"photo_name"];
//		self.leg_image = [aDictionary valueForKey:@"leg_image"];
		
		self.bio_url = [aDictionary valueForKey:@"bio_url"];
		self.notes = [aDictionary valueForKey:@"notes"];	
		self.gallery_desk = [aDictionary valueForKey:@"gallery_desk"];	
		
		
		self.cap_office = [aDictionary valueForKey:@"cap_office"];	
		self.staff = [aDictionary valueForKey:@"staff"];	
		self.cap_phone = [aDictionary valueForKey:@"cap_phone"];	
		self.cap_fax = [aDictionary valueForKey:@"cap_fax"];	
		self.cap_phone2_name = [aDictionary valueForKey:@"cap_phone2_name"];	
		self.cap_phone2 = [aDictionary valueForKey:@"cap_phone2"];	
		
		self.dist1_street = [aDictionary valueForKey:@"dist1_street"];
		self.dist1_city = [aDictionary valueForKey:@"dist1_city"];
		self.dist1_zip = [aDictionary valueForKey:@"dist1_zip"];
		self.dist1_phone = [aDictionary valueForKey:@"dist1_phone"];
		self.dist1_fax = [aDictionary valueForKey:@"dist1_fax"];
		
		self.dist2_street = [aDictionary valueForKey:@"dist2_street"];
		self.dist2_city = [aDictionary valueForKey:@"dist2_city"];
		self.dist2_zip = [aDictionary valueForKey:@"dist2_zip"];
		self.dist2_phone = [aDictionary valueForKey:@"dist2_phone"];
		self.dist2_fax = [aDictionary valueForKey:@"dist2_fax"];
		
		self.dist3_street = [aDictionary valueForKey:@"dist3_street"];
		self.dist3_city = [aDictionary valueForKey:@"dist3_city"];
		self.dist3_zip = [aDictionary valueForKey:@"dist3_zip"];
		self.dist3_phone1 = [aDictionary valueForKey:@"dist3_phone1"];
		self.dist3_fax = [aDictionary valueForKey:@"dist3_fax"];
		
		self.dist4_street = [aDictionary valueForKey:@"dist4_street"];
		self.dist4_city = [aDictionary valueForKey:@"dist4_city"];
		self.dist4_zip = [aDictionary valueForKey:@"dist4_zip"];
		self.dist4_phone1 = [aDictionary valueForKey:@"dist4_phone1"];
		self.dist4_fax = [aDictionary valueForKey:@"dist4_fax"];
		
	}
	return self;
}


- (UIImage *)legislatorImage {
	return [UIImage imageNamed:photo_name];
}

- (NSString *)partyShortName {
	NSString *shortName;
	if (party_id.intValue == DEMOCRAT) // Democrat
		shortName = @"D";
	else if (party_id.intValue == REPUBLICAN) // Republican
		shortName = @"R";
	else // don't know the party?
		shortName = @"I";
	return shortName;
}

- (NSString *)legTypeShortName {
	NSString *shortName;
	if (legtype.intValue == HOUSE) // Representative
		shortName = @"Rep.";
	else if (legtype.intValue == SENATE) // Senator
		shortName = @"Sen.";
	else // don't know the party?
		shortName = @"";
	return shortName;
}


- (void)dealloc {
	[legislatorID release];
	[legtype release];
	[legtype_name release];
	[lastname release];
	[firstname release];
	[middlename release];
	[nickname release];
	[suffix release];
	[party_name release];
	[party_id release];
	[district release];
	[tenure release];
	[partisan_index release];
	
	[photo_name release];
//	[leg_image release];
	
	[bio_url release];
	[notes release];	
	[gallery_desk release];	
	
	
	[cap_office release];	
	[staff release];	
	[cap_phone release];	
	[cap_fax release];	
	[cap_phone2_name release];	
	[cap_phone2 release];	
	
	[dist1_street release];
	[dist1_city release];
	[dist1_zip release];
	[dist1_phone release];
	[dist1_fax release];
	
	[dist2_street release];
	[dist2_city release];
	[dist2_zip release];
	[dist2_phone release];
	[dist2_fax release];
	
	[dist3_street release];
	[dist3_city release];
	[dist3_zip release];
	[dist3_phone1 release];
	[dist3_fax release];
	
	[dist4_street release];
	[dist4_city release];
	[dist4_zip release];
	[dist4_phone1 release];
	[dist4_fax release];

	[super dealloc];
}


- (NSString*)description {
	return [NSString stringWithFormat: @"%@, %@ (%@-%d)", lastname, firstname, self.partyShortName, district];
}


@end
