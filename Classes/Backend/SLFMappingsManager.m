//
//  SLFMappingsManager.m
//  Created by Gregory Combs on 7/31/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFMappingsManager.h"
#import "SLFDataModels.h"

@interface SLFMappingsManager()
- (RKManagedObjectMapping *)generateStateMapping;
- (RKManagedObjectMapping *)generateDistrictMapping;
- (RKManagedObjectMapping *)generateEventMapping;
- (RKManagedObjectMapping *)generateBillMapping;
- (RKManagedObjectMapping *)generateLegislatorMapping;
- (RKManagedObjectMapping *)generateCommitteeMapping;
- (RKManagedObjectMapping *)generatePositionMapping;
- (void)connectRelationshipMappings;
+ (SLFCommitteePosition *)findOrCreatePositionWithStateID:(NSString *)stateID
                                            committeeName:(NSString *)comName
                                              committeeID:(NSString *)comID
                                           legislatorName:(NSString *)legName
                                             legislatorID:(NSString *)legID
                                                 roleType:(NSString *)roleType;

@end

@implementation SLFMappingsManager
@synthesize stateMapping;
@synthesize districtMapping;
@synthesize billMapping;
@synthesize eventMapping;
@synthesize legislatorMapping;
@synthesize committeeMapping;
@synthesize positionMapping;

- (id)init {
    if ((self = [super init])) {
        [self generateStateMapping];
        [self generateDistrictMapping];
        [self generateEventMapping];
        [self generateBillMapping];
        [self generateLegislatorMapping];
        [self generateCommitteeMapping];
        [self generatePositionMapping];
        [self connectRelationshipMappings];
    }
    return self;
}

- (void)dealloc {
    self.legislatorMapping = nil;
    self.committeeMapping = nil;
    self.positionMapping = nil;
    self.eventMapping = nil;
    self.billMapping = nil;
    self.districtMapping = nil;
    self.stateMapping = nil;
    [super dealloc];
}

- (void)registerMappingsWithProvider:(RKObjectMappingProvider *)provider {
    [provider setMapping:stateMapping forKeyPath:@"metadata"];
    [provider setMapping:districtMapping forKeyPath:@"districts"];
    [provider setMapping:eventMapping forKeyPath:@"events"];
    [provider setMapping:billMapping forKeyPath:@"bills"];
    [provider setMapping:committeeMapping forKeyPath:@"committees"];
    [provider setMapping:legislatorMapping forKeyPath:@"legislators"];
    [provider setMapping:positionMapping forKeyPath:@"positions"];
}


- (void)connectRelationshipMappings {
    [stateMapping hasMany:@"legislators" withMapping:legislatorMapping];
    [stateMapping hasMany:@"committees" withMapping:committeeMapping];
    [stateMapping hasMany:@"events" withMapping:eventMapping];
    [stateMapping hasMany:@"districtMaps" withMapping:districtMapping];
    [stateMapping hasMany:@"bills" withMapping:billMapping];

    [districtMapping hasOne:@"state" withMapping:stateMapping];
    [districtMapping connectRelationship:@"state" withObjectForPrimaryKeyAttribute:@"stateID"];

    [eventMapping hasOne:@"stateObj" withMapping:stateMapping];
    [eventMapping connectRelationship:@"stateObj" withObjectForPrimaryKeyAttribute:@"stateID"];

    [billMapping hasOne:@"stateObj" withMapping:stateMapping];
    [billMapping connectRelationship:@"stateObj" withObjectForPrimaryKeyAttribute:@"stateID"];
    
    [legislatorMapping hasOne:@"stateObj" withMapping:stateMapping];
    [legislatorMapping connectRelationship:@"stateObj" withObjectForPrimaryKeyAttribute:@"stateID"];
    
    [committeeMapping hasOne:@"stateObj" withMapping:stateMapping];
    [committeeMapping connectRelationship:@"stateObj" withObjectForPrimaryKeyAttribute:@"stateID"];
    
    [districtMapping hasMany:@"legislators" withMapping:legislatorMapping];
        //TODO: [districtMapping connectRelationship:@"legislators" withObjectForPrimaryKeyAttribute:@"legID"];

        // TODO: Investigate using custom mapping to ONLY create a unique primary key, then handle connecting relationships as outlined below.
    [committeeMapping addRelationshipMapping:[RKObjectRelationshipMapping mappingFromKeyPath:@"members" toKeyPath:@"positions" withMapping:positionMapping]];
    [legislatorMapping addRelationshipMapping:[RKObjectRelationshipMapping mappingFromKeyPath:@"roles" toKeyPath:@"positions" withMapping:positionMapping]];    

    [positionMapping connectRelationship:@"legislator" withObjectForPrimaryKeyAttribute:@"legID"];
    [positionMapping connectRelationship:@"committee" withObjectForPrimaryKeyAttribute:@"committeeID"];

    
    /*
     // TODO: investigate alternative mappings
    
    [billMapping connectRelationship:@"legislators" withObjectForPrimaryKeyAttribute:@"legID"];
    [legislatorMapping connectRelationship:@"roles" withObjectForPrimaryKeyAttribute:@"legID"];
    [committeeMapping connectRelationship:@"members" withObjectForPrimaryKeyAttribute:@"legID"];
     */

}

- (RKManagedObjectMapping *)generateStateMapping {
    self.stateMapping = [RKManagedObjectMapping mappingForClass:[SLFState class]];
    stateMapping.primaryKeyAttribute = @"stateID";
    [stateMapping mapKeyPath:@"lower_chamber_name" toAttribute:@"lowerChamberName"];
    [stateMapping mapKeyPath:@"lower_chamber_title" toAttribute:@"lowerChamberTitle"];
    [stateMapping mapKeyPath:@"lower_chamber_term" toAttribute:@"lowerChamberTerm"];
    [stateMapping mapKeyPath:@"upper_chamber_name" toAttribute:@"upperChamberName"];
    [stateMapping mapKeyPath:@"upper_chamber_title" toAttribute:@"upperChamberTitle"];
    [stateMapping mapKeyPath:@"upper_chamber_term" toAttribute:@"upperChamberTerm"];
    [stateMapping mapKeyPath:@"session_details" toAttribute:@"sessionDetails"];
    [stateMapping mapKeyPath:@"legislature_name" toAttribute:@"legislatureName"];
    [stateMapping mapKeyPath:@"feature_flags" toAttribute:@"featureFlags"];
    [stateMapping mapKeyPath:@"latest_update" toAttribute:@"dateUpdated"];
    [stateMapping mapKeyPath:@"abbreviation" toAttribute:@"stateID"];
    [stateMapping mapAttributes:@"name", @"terms", @"level", nil];
    stateMapping.setNilForMissingRelationships = NO;
    return stateMapping;
}

- (RKManagedObjectMapping *)generateDistrictMapping {
    self.districtMapping = [RKManagedObjectMapping mappingForClass:[SLFDistrict class]];
    districtMapping.primaryKeyAttribute = @"boundaryID";
    [districtMapping mapKeyPath:@"abbr" toAttribute:@"stateID"];
    [districtMapping mapKeyPath:@"num_seats" toAttribute:@"numSeats"];
    [districtMapping mapKeyPath:@"region" toAttribute:@"regionDictionary"];
    [districtMapping mapKeyPath:@"boundary_id" toAttribute:@"boundaryID"];
    [districtMapping mapAttributes:@"name", @"chamber", @"shape", nil];
    districtMapping.setNilForMissingRelationships = NO;
    return districtMapping;
}

- (RKManagedObjectMapping *)generateEventMapping {
    self.eventMapping = [RKManagedObjectMapping mappingForClass:[SLFEvent class]];
    eventMapping.primaryKeyAttribute = @"eventID";
    [eventMapping mapKeyPath:@"id" toAttribute:@"eventID"];
    [eventMapping mapKeyPath:@"state" toAttribute:@"stateID"];
    [eventMapping mapKeyPath:@"updated_at" toAttribute:@"dateUpdated"];
    [eventMapping mapKeyPath:@"created_at" toAttribute:@"dateCreated"];
    [eventMapping mapKeyPath:@"when" toAttribute:@"dateStart"];
    [eventMapping mapKeyPath:@"end" toAttribute:@"dateEnd"];
    [eventMapping mapKeyPath:@"description" toAttribute:@"eventDescription"];
    [eventMapping mapKeyPath:@"+link" toAttribute:@"link"];
    [eventMapping mapKeyPath:@"sources.url" toAttribute:@"sources"];
    [eventMapping mapAttributes:@"session", @"participants", @"type", @"location",  nil];
    return eventMapping;
}

- (RKManagedObjectMapping *)generateBillMapping {
    self.billMapping = [RKManagedObjectMapping mappingForClass:[SLFBill class]];
    billMapping.primaryKeyAttribute = @"billID";
    [billMapping mapKeyPath:@"bill_id" toAttribute:@"billID"];
    [billMapping mapKeyPath:@"state" toAttribute:@"stateID"];
    [billMapping mapKeyPath:@"updated_at" toAttribute:@"dateUpdated"];
    [billMapping mapKeyPath:@"created_at" toAttribute:@"dateCreated"];
    [billMapping mapKeyPath:@"sources.url" toAttribute:@"sources"];
    [billMapping mapAttributes:@"session", @"subjects", @"votes", @"versions", 
            @"type", @"chamber", @"sponsors", @"actions",@"documents", @"title",  nil];
    return billMapping;
}

- (RKManagedObjectMapping *)generateLegislatorMapping {
    self.legislatorMapping = [RKManagedObjectMapping mappingForClass:[SLFLegislator class]];
    legislatorMapping.primaryKeyAttribute = @"legID";
    [legislatorMapping mapKeyPath:@"leg_id" toAttribute:@"legID"];
    [legislatorMapping mapKeyPath:@"state" toAttribute:@"stateID"];
    [legislatorMapping mapKeyPath:@"created_at" toAttribute:@"dateCreated"];
    [legislatorMapping mapKeyPath:@"updated_at" toAttribute:@"dateUpdated"];
    [legislatorMapping mapKeyPath:@"first_name" toAttribute:@"firstName"];
    [legislatorMapping mapKeyPath:@"full_name" toAttribute:@"fullName"];
    [legislatorMapping mapKeyPath:@"last_name" toAttribute:@"lastName"];
    [legislatorMapping mapKeyPath:@"middle_name" toAttribute:@"middleName"];
    [legislatorMapping mapKeyPath:@"nimsp_candidate_id" toAttribute:@"nimspCandidateID"];
    [legislatorMapping mapKeyPath:@"nimsp_id" toAttribute:@"nimspID"];
    [legislatorMapping mapKeyPath:@"photo_url" toAttribute:@"photoURL"];
    [legislatorMapping mapKeyPath:@"transparencydata_id" toAttribute:@"transparencyID"];
    [legislatorMapping mapKeyPath:@"votesmart_id" toAttribute:@"votesmartID"];
    [legislatorMapping mapKeyPath:@"sources.url" toAttribute:@"sources"];
    [legislatorMapping mapAttributes:@"suffixes", @"party", @"level", @"district", @"country", @"chamber", @"active", nil];
        //legislatorMapping.setNilForMissingRelationships = NO;
    return legislatorMapping;
}

- (RKManagedObjectMapping *)generateCommitteeMapping {
    self.committeeMapping = [RKManagedObjectMapping mappingForClass:[SLFCommittee class]];
    committeeMapping.primaryKeyAttribute = @"committeeID";
    [committeeMapping mapKeyPath:@"id" toAttribute:@"committeeID"];
    [committeeMapping mapKeyPath:@"state" toAttribute:@"stateID"];
    [committeeMapping mapKeyPath:@"created_at" toAttribute:@"dateCreated"];
    [committeeMapping mapKeyPath:@"updated_at" toAttribute:@"dateUpdated"];
    [committeeMapping mapKeyPath:@"parent_id" toAttribute:@"parentID"];
    [committeeMapping mapKeyPath:@"votesmart_id" toAttribute:@"votesmartID"];
    [committeeMapping mapKeyPath:@"committee" toAttribute:@"committeeName"];
    [committeeMapping mapKeyPath:@"sources.url" toAttribute:@"sources"];
    [committeeMapping mapAttributes:@"chamber", @"subcommittee", nil];
        //committeeMapping.setNilForMissingRelationships = NO;
    return committeeMapping;
}

- (RKManagedObjectMapping *)generatePositionMapping {
    self.positionMapping = [RKManagedObjectMapping mappingForClass:[SLFCommitteePosition class]];
    positionMapping.primaryKeyAttribute = @"posID";
    [positionMapping mapAttributes:@"posID", @"positionType",@"legID",@"legislatorName",@"committeeID",@"committeeName",nil];
        //positionMapping.setNilForMissingRelationships = NO;
    return positionMapping;
}

////////////////////////////////////
#pragma EXTREME UGLINESS BEGINS HERE

+ (inout id *)premapLegislator:(SLFLegislator *)legislator withMappableData:(inout id *)mappableData {
    NSArray* origRolesArray = [*mappableData valueForKeyPath:@"roles"];
    NSString *legID = [*mappableData objectForKey:@"leg_id"];
    NSString *legName = [*mappableData objectForKey:@"full_name"];
    NSString *stateID = [*mappableData objectForKey:@"state"];
    
    if (!legID)
        legID = legislator.legID;
    
    if (!legName)
        legName = legislator.fullName;
    
    if (!stateID)
        stateID = legislator.stateID;

    NSMutableArray* newRolesArray = [[NSMutableArray alloc] initWithCapacity:[origRolesArray count]];
    for (NSDictionary* origRole in origRolesArray) {
        NSString *comID = [origRole objectForKey:@"committee_id"];
        NSString *comName = [origRole objectForKey:@"committee"];
        NSString *roleType = [origRole objectForKey:@"type"];
        SLFCommitteePosition *pos = [SLFMappingsManager findOrCreatePositionWithStateID:stateID
                                                                          committeeName:comName
                                                                            committeeID:comID
                                                                         legislatorName:legName
                                                                           legislatorID:legID
                                                                               roleType:roleType];
        if (pos) {
            [newRolesArray addObject:pos];
        } else {
            RKLogDebug(@"Unable to create or find committee position with role: %@", origRole);
        }
    }
    
    // remove old array, and inject our modified array.
    [*mappableData removeObjectForKey:@"roles"];
    [*mappableData setObject:newRolesArray forKey:@"roles"];	
    [newRolesArray release];
    return mappableData;
}


+ (inout id *)premapCommittee:(SLFCommittee *)committee withMappableData:(inout id *)mappableData {
    NSArray* origRolesArray = [*mappableData valueForKeyPath:@"members"];
    NSString *comID = [*mappableData objectForKey:@"id"];   
    NSString *comName = [*mappableData objectForKey:@"committee"];
    NSString *stateID = [*mappableData objectForKey:@"state"];
    
    if (!comID)
        comID = committee.committeeID;
    if (!comName)
        comName = committee.committeeName;
    if (!stateID)
        stateID = committee.stateID;

    NSMutableArray* newRolesArray = [[NSMutableArray alloc] initWithCapacity:[origRolesArray count]];
    for (NSDictionary* origRole in origRolesArray) {
        NSString *legID = [origRole objectForKey:@"leg_id"];
        NSString *legName = [origRole objectForKey:@"name"];
        NSString *roleType = [origRole objectForKey:@"role"];
        
        SLFCommitteePosition *pos = [SLFMappingsManager findOrCreatePositionWithStateID:stateID
                                                                          committeeName:comName
                                                                            committeeID:comID
                                                                         legislatorName:legName
                                                                           legislatorID:legID
                                                                               roleType:roleType];
        if (pos) {
            [newRolesArray addObject:pos];
        } else {
            RKLogDebug(@"Unable to create or find committee position with role: %@", origRole);
        }        
    }
    
    // remove old array, and inject our modified array.
    [*mappableData removeObjectForKey:@"members"];
    [*mappableData setObject:newRolesArray forKey:@"members"];
    [newRolesArray release];
    return mappableData;
}

+ (SLFCommitteePosition *)findOrCreatePositionWithStateID:(NSString *)stateID
                                            committeeName:(NSString *)comName
                                              committeeID:(NSString *)comID
                                           legislatorName:(NSString *)legName
                                             legislatorID:(NSString *)legID
                                                 roleType:(NSString *)roleType
{
    if ( IsEmpty(comID) || IsEmpty(legID) ) {
        return nil;
    }
    
    //  generate a unique ID, the aggregated value of these attributes must be unique across everything.
    NSString *compositePrimaryKey = [NSString stringWithFormat:@"%@|%@|%@", stateID, comID, legID];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(posID LIKE[cd] %@) OR (committeeID LIKE[cd] %@ AND legID LIKE[cd] %@)", compositePrimaryKey, comID, legID];
    SLFCommitteePosition *position = [SLFCommitteePosition findFirstWithPredicate:predicate];
    
    BOOL foundExistingPosition = (position != NULL);
    
    RKLogTrace(@"-----------------------------");
    
    if (foundExistingPosition) {
        RKLogTrace(@"FOUND = %@", compositePrimaryKey);
    } else {
        position = [SLFCommitteePosition object];
        position.committeeID = comID;
        position.legID = legID;
    }
    
    // Found or not, we can update these properties we know about anyway.
    position.posID = compositePrimaryKey;
    position.legislatorName = legName;
    position.committeeName = comName;
    position.positionType =	roleType;		
    
    if (!position.legislator) {
        SLFLegislator *legislator = [SLFLegislator findFirstByAttribute:@"legID" withValue:legID];
        if (legislator)
            position.legislator = legislator;
    }

    if (!position.committee) {
        SLFCommittee *committee = [SLFCommittee findFirstByAttribute:@"committeeID" withValue:comID];
        if (committee)
            position.committee = committee;
    }
    
    if (!foundExistingPosition) {
        RKLogDebug(@"NOT FOUND: %@", position);
    }
    RKLogTrace(@"-----------------------------");
    
    return position;
}


@end
