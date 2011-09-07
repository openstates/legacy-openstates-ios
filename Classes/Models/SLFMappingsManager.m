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
#import "UtilityMethods.h"

@interface SLFMappingsManager()
- (RKManagedObjectMapping *)generateStateMapping;
- (RKManagedObjectMapping *)generateDistrictMapping;
- (RKManagedObjectMapping *)generateBillMapping;
- (RKManagedObjectMapping *)generateEventMapping;
- (RKManagedObjectMapping *)generateLegislatorMapping;
- (RKManagedObjectMapping *)generateCommitteeMapping;
- (RKManagedObjectMapping *)generatePositionMapping;
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
        [self generateBillMapping];
        [self generateEventMapping];
        [self generateLegislatorMapping];
        [self generateCommitteeMapping];
        [self generatePositionMapping];
        [self generateDistrictMapping];
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

- (RKManagedObjectMapping *)generateStateMapping {
    self.stateMapping = [RKManagedObjectMapping mappingForClass:[SLFState class]];
    [stateMapping.dateFormatStrings addObject:@"yyyy-MM-dd HH:mm:ss"];
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
    [stateMapping mapAttributes:@"abbreviation", @"name", @"terms", @"level", nil];
    stateMapping.primaryKeyAttribute = @"abbreviation";
    return stateMapping;
}

- (RKManagedObjectMapping *)generateDistrictMapping {
    self.districtMapping = [RKManagedObjectMapping mappingForClass:[SLFDistrictMap class]];
    [districtMapping.dateFormatStrings addObject:@"yyyy-MM-dd HH:mm:ss"];
    [districtMapping mapKeyPath:@"abbr" toAttribute:@"stateID"];
    [districtMapping mapKeyPath:@"num_seats" toAttribute:@"numSeats"];
    [districtMapping mapKeyPath:@"region" toAttribute:@"regionDictionary"];
    [districtMapping mapKeyPath:@"boundary_id" toAttribute:@"boundaryID"];
    [districtMapping mapAttributes:@"name", @"chamber", @"shape", nil];
    districtMapping.primaryKeyAttribute = @"boundaryID";
    districtMapping.setNilForMissingRelationships = NO; // some queries omit legislators array, don't clear our stored info.
    [districtMapping hasMany:@"legislators" withMapping:self.legislatorMapping];
    return districtMapping;
}

- (RKManagedObjectMapping *)generateBillMapping {
    self.billMapping = [RKManagedObjectMapping mappingForClass:[SLFBill class]];
    [billMapping.dateFormatStrings addObject:@"yyyy-MM-dd HH:mm:ss"];
    [billMapping mapKeyPath:@"bill_id" toAttribute:@"billID"];
    [billMapping mapKeyPath:@"state" toAttribute:@"stateID"];
    [billMapping mapKeyPath:@"updated_at" toAttribute:@"dateUpdated"];
    [billMapping mapKeyPath:@"created_at" toAttribute:@"dateCreated"];
    [billMapping mapKeyPath:@"sources.url" toAttribute:@"sources"];
    [billMapping mapAttributes:@"session", @"subjects", @"votes", @"versions", 
                                     @"type", @"chamber", @"sponsors", @"actions",@"documents", @"title",  nil];
    billMapping.primaryKeyAttribute = @"billID";
    return billMapping;
}

- (RKManagedObjectMapping *)generateEventMapping {
    self.eventMapping = [RKManagedObjectMapping mappingForClass:[SLFEvent class]];
    [eventMapping.dateFormatStrings addObject:@"yyyy-MM-dd HH:mm:ss"];
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
    eventMapping.primaryKeyAttribute = @"eventID";
    return eventMapping;
}

- (RKManagedObjectMapping *)generateLegislatorMapping {
    self.legislatorMapping = [RKManagedObjectMapping mappingForClass:[SLFLegislator class]];
    [legislatorMapping.dateFormatStrings addObject:@"yyyy-MM-dd HH:mm:ss"];
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
    legislatorMapping.primaryKeyAttribute = @"legID";
#warning Can we directly map/hydrate relationships with stateIDs?
    return legislatorMapping;
}

- (RKManagedObjectMapping *)generateCommitteeMapping {
    self.committeeMapping = [RKManagedObjectMapping mappingForClass:[SLFCommittee class]];
    [committeeMapping.dateFormatStrings addObject:@"yyyy-MM-dd HH:mm:ss"]; 
    [committeeMapping mapKeyPath:@"id" toAttribute:@"committeeID"];
    [committeeMapping mapKeyPath:@"state" toAttribute:@"stateID"];
    [committeeMapping mapKeyPath:@"created_at" toAttribute:@"dateCreated"];
    [committeeMapping mapKeyPath:@"updated_at" toAttribute:@"dateUpdated"];
    [committeeMapping mapKeyPath:@"parent_id" toAttribute:@"parentID"];
    [committeeMapping mapKeyPath:@"votesmart_id" toAttribute:@"votesmartID"];
    [committeeMapping mapKeyPath:@"committee" toAttribute:@"committeeName"];
    [committeeMapping mapKeyPath:@"sources.url" toAttribute:@"sources"];
    [committeeMapping mapAttributes:@"chamber", @"subcommittee", nil];
    committeeMapping.primaryKeyAttribute = @"committeeID";
    return committeeMapping;
}

- (RKManagedObjectMapping *)generatePositionMapping {
    self.positionMapping = [RKManagedObjectMapping mappingForClass:[SLFCommitteePosition class]];
    [positionMapping mapAttributes:@"posID", @"positionType",@"legID",@"legislatorName",@"committeeID",@"committeeName",nil];
    positionMapping.primaryKeyAttribute = @"posID";
    [self.committeeMapping addRelationshipMapping:[RKObjectRelationshipMapping mappingFromKeyPath:@"members" toKeyPath:@"positions" withMapping:positionMapping]];
    [self.legislatorMapping addRelationshipMapping:[RKObjectRelationshipMapping mappingFromKeyPath:@"roles" toKeyPath:@"positions" withMapping:positionMapping]];
    return positionMapping;
}

- (RKObjectMappingProvider *)registerMappingsWithProvider:(RKObjectMappingProvider *)provider {
    [provider setMapping:stateMapping forKeyPath:@"state"];
    [provider setMapping:committeeMapping forKeyPath:@"committee"];
    [provider setMapping:legislatorMapping forKeyPath:@"legislator"];
    [provider setMapping:positionMapping forKeyPath:@"position"];
    [provider setMapping:billMapping forKeyPath:@"bill"];
    [provider setMapping:eventMapping forKeyPath:@"event"];
    [provider setMapping:districtMapping forKeyPath:@"districtMap"];
    return provider;
}

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

    NSMutableArray* newRolesArray = [[NSMutableArray alloc] 
									 initWithCapacity:[origRolesArray count]];
    
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
                //pos.legislator = legislator;
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

    NSMutableArray* newRolesArray = [[NSMutableArray alloc] 
                                     initWithCapacity:[origRolesArray count]];
    
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
                //pos.committee = committee;
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
    
    //  To generate a unique primary key ID, the aggregated value of these attributes must be unique across everything.
    NSString *posID = [NSString stringWithFormat:@"%@|%@|%@", stateID, comID, legID];
    NSString *predString = [NSString stringWithFormat:@"(posID LIKE[cd] '%@') OR (committeeID LIKE[cd] '%@' AND legID LIKE[cd] '%@')", posID, comID, legID];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predString];
    SLFCommitteePosition *position = [SLFCommitteePosition findFirstWithPredicate:predicate];
    
    BOOL foundExistingPosition = (position != NULL);
    
    RKLogTrace(@"-----------------------------");
    
    if (foundExistingPosition) {
        RKLogTrace(@"FOUND = %@", posID);
    } else {
        position = [SLFCommitteePosition object];
        position.committeeID = comID;
        position.legID = legID;
    }
    
    // Found or not, we can update these properties we know about anyway.
    position.posID = posID;
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
