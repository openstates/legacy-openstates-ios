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
- (RKManagedObjectMapping *)generateMemberMapping;
- (RKManagedObjectMapping *)generateRoleMapping;
- (RKManagedObjectMapping *)generateSponsorMapping;
@end

@implementation SLFMappingsManager

- (void)registerMappings {
    RKObjectMappingProvider *provider = [[RKObjectManager sharedManager] mappingProvider];
    
    RKManagedObjectMapping *stateMapping = [self generateStateMapping];
    RKManagedObjectMapping *districtMapping = [self generateDistrictMapping];
    RKManagedObjectMapping *eventMapping = [self generateEventMapping];
    RKManagedObjectMapping *billMapping = [self generateBillMapping];
    RKManagedObjectMapping *legislatorMapping = [self generateLegislatorMapping];
    RKManagedObjectMapping *committeeMapping = [self generateCommitteeMapping];
    RKManagedObjectMapping *memberMapping = [self generateMemberMapping];
    RKManagedObjectMapping *roleMapping = [self generateRoleMapping];
    RKManagedObjectMapping *sponsorMapping = [self generateSponsorMapping];

        // Configuring Relationships
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
    [legislatorMapping hasMany:@"roles" withMapping:roleMapping];
    [committeeMapping hasMany:@"members" withMapping:memberMapping];
    [billMapping hasMany:@"sponsors" withMapping:sponsorMapping];
    
    [provider addObjectMapping:stateMapping];
    [provider addObjectMapping:districtMapping];
    [provider addObjectMapping:eventMapping];
    [provider addObjectMapping:billMapping];
    [provider addObjectMapping:committeeMapping];
    [provider addObjectMapping:legislatorMapping];
    [provider setMapping:roleMapping forKeyPath:@"roles"];
    [provider setMapping:memberMapping forKeyPath:@"members"];
    [provider setMapping:sponsorMapping forKeyPath:@"sponsors"];
}


- (RKManagedObjectMapping *)generateStateMapping {
    RKManagedObjectMapping *stateMapping = [RKManagedObjectMapping mappingForClass:[SLFState class]];
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
    return stateMapping;
}

- (RKManagedObjectMapping *)generateDistrictMapping {
    RKManagedObjectMapping *districtMapping = [RKManagedObjectMapping mappingForClass:[SLFDistrict class]];
    districtMapping.primaryKeyAttribute = @"boundaryID";
    [districtMapping mapKeyPath:@"abbr" toAttribute:@"stateID"];
    [districtMapping mapKeyPath:@"num_seats" toAttribute:@"numSeats"];
    [districtMapping mapKeyPath:@"region" toAttribute:@"regionDictionary"];
    [districtMapping mapKeyPath:@"boundary_id" toAttribute:@"boundaryID"];
    [districtMapping mapAttributes:@"name", @"chamber", @"shape", nil];
    return districtMapping;
}

- (RKManagedObjectMapping *)generateEventMapping {
    RKManagedObjectMapping *eventMapping = [RKManagedObjectMapping mappingForClass:[SLFEvent class]];
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
    RKManagedObjectMapping *billMapping = [RKManagedObjectMapping mappingForClass:[SLFBill class]];
    billMapping.primaryKeyAttribute = @"billID";
    [billMapping mapKeyPath:@"bill_id" toAttribute:@"billID"];
    [billMapping mapKeyPath:@"state" toAttribute:@"stateID"];
    [billMapping mapKeyPath:@"updated_at" toAttribute:@"dateUpdated"];
    [billMapping mapKeyPath:@"created_at" toAttribute:@"dateCreated"];
    [billMapping mapKeyPath:@"sources.url" toAttribute:@"sources"];
    [billMapping mapAttributes:@"session", @"subjects", @"votes", @"versions", 
            @"type", @"chamber", @"actions",@"documents", @"title",  nil];
    return billMapping;
}

- (RKManagedObjectMapping *)generateLegislatorMapping {
    RKManagedObjectMapping *legislatorMapping = [RKManagedObjectMapping mappingForClass:[SLFLegislator class]];
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
    [legislatorMapping mapAttributes:@"suffixes", @"party", @"level", @"district", @"country", @"chamber", @"active",nil];    
    return legislatorMapping;
}

- (RKManagedObjectMapping *)generateCommitteeMapping {
    RKManagedObjectMapping *committeeMapping = [RKManagedObjectMapping mappingForClass:[SLFCommittee class]];
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
    return committeeMapping;
}

- (RKManagedObjectMapping *)generateMemberMapping {
    RKManagedObjectMapping* memberMapping = [RKManagedObjectMapping mappingForClass:[CommitteeMember class]];
    [memberMapping mapKeyPath:@"leg_id" toAttribute:@"legID"];
    [memberMapping mapKeyPath:@"role" toAttribute:@"role"];
    [memberMapping mapKeyPath:@"name" toAttribute:@"legislatorName"];
    return memberMapping;
}

- (RKManagedObjectMapping *)generateRoleMapping {
    RKManagedObjectMapping* roleMapping = [RKManagedObjectMapping mappingForClass:[CommitteeRole class]];
    [roleMapping mapKeyPath:@"committee_id" toAttribute:@"committeeID"];
    [roleMapping mapKeyPath:@"type" toAttribute:@"role"];
    [roleMapping mapKeyPath:@"committee" toAttribute:@"committeeName"];
    return roleMapping;
}

- (RKManagedObjectMapping *)generateSponsorMapping {
    RKManagedObjectMapping* sponsorMapping = [RKManagedObjectMapping mappingForClass:[BillSponsor class]];
    [sponsorMapping mapKeyPath:@"leg_id" toAttribute:@"legID"];
    [sponsorMapping mapKeyPath:@"type" toAttribute:@"role"];
    [sponsorMapping mapKeyPath:@"name" toAttribute:@"legislatorName"];
    return sponsorMapping;
}

@end
