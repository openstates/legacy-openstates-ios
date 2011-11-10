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
- (RKManagedObjectMapping *)generateWordMapping;
- (RKManagedObjectMapping *)generateBillActionMapping;
- (RKManagedObjectMapping *)generateVoterMapping;
- (RKManagedObjectMapping *)generateRecordVoteMapping;
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
    RKManagedObjectMapping *actionMapping = [self generateBillActionMapping];
    RKManagedObjectMapping *voterMapping = [self generateVoterMapping];
    RKManagedObjectMapping *recordVoteMapping = [self generateRecordVoteMapping];
    RKManagedObjectMapping *wordMapping = [self generateWordMapping];

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
    [billMapping hasMany:@"actions" withMapping:actionMapping];
    [billMapping hasMany:@"alternateTitles" withMapping:wordMapping];
    [billMapping hasMany:@"subjects" withMapping:wordMapping];
    [billMapping hasMany:@"type" withMapping:wordMapping];
    [billMapping hasMany:@"votes" withMapping:recordVoteMapping];
    [recordVoteMapping mapKeyPath:@"no_votes" toRelationship:@"noVotes" withMapping:voterMapping];
    [recordVoteMapping mapKeyPath:@"yes_votes" toRelationship:@"yesVotes" withMapping:voterMapping];
    [recordVoteMapping mapKeyPath:@"other_votes" toRelationship:@"otherVotes" withMapping:voterMapping];
    [actionMapping hasMany:@"type" withMapping:wordMapping];
    
    [provider addObjectMapping:stateMapping];
    [provider addObjectMapping:districtMapping];
    [provider addObjectMapping:eventMapping];
    [provider addObjectMapping:billMapping];
    [provider addObjectMapping:committeeMapping];
    [provider addObjectMapping:legislatorMapping];
    [provider addObjectMapping:wordMapping];
    [provider addObjectMapping:actionMapping];
    [provider addObjectMapping:voterMapping];
    [provider addObjectMapping:recordVoteMapping];
    
    [provider setMapping:roleMapping forKeyPath:@"roles"];
    [provider setMapping:memberMapping forKeyPath:@"members"];
    [provider setMapping:sponsorMapping forKeyPath:@"sponsors"];
    [provider setMapping:actionMapping forKeyPath:@"actions"];
    [provider setMapping:wordMapping forKeyPath:@"actions.type"]; // as opposed to votes.type
    [provider setMapping:wordMapping forKeyPath:@"alternate_titles"];
    [provider setMapping:wordMapping forKeyPath:@"subjects"];
    [provider setMapping:recordVoteMapping forKeyPath:@"votes"];
    [provider setMapping:voterMapping forKeyPath:@"votes.no_votes"];
    [provider setMapping:voterMapping forKeyPath:@"votes.yes_votes"];
    [provider setMapping:voterMapping forKeyPath:@"votes.other_votes"];
}


- (RKManagedObjectMapping *)generateStateMapping {
    RKManagedObjectMapping *mapping = [RKManagedObjectMapping mappingForClass:[SLFState class]];
    mapping.primaryKeyAttribute = @"stateID";
    [mapping mapKeyPath:@"lower_chamber_name" toAttribute:@"lowerChamberName"];
    [mapping mapKeyPath:@"lower_chamber_title" toAttribute:@"lowerChamberTitle"];
    [mapping mapKeyPath:@"lower_chamber_term" toAttribute:@"lowerChamberTerm"];
    [mapping mapKeyPath:@"upper_chamber_name" toAttribute:@"upperChamberName"];
    [mapping mapKeyPath:@"upper_chamber_title" toAttribute:@"upperChamberTitle"];
    [mapping mapKeyPath:@"upper_chamber_term" toAttribute:@"upperChamberTerm"];
    [mapping mapKeyPath:@"session_details" toAttribute:@"sessionDetails"];
    [mapping mapKeyPath:@"legislature_name" toAttribute:@"legislatureName"];
    [mapping mapKeyPath:@"feature_flags" toAttribute:@"featureFlags"];
    [mapping mapKeyPath:@"latest_update" toAttribute:@"dateUpdated"];
    [mapping mapKeyPath:@"abbreviation" toAttribute:@"stateID"];
    [mapping mapAttributes:@"name", @"terms", @"level", nil];
    return mapping;
}

- (RKManagedObjectMapping *)generateDistrictMapping {
    RKManagedObjectMapping *mapping = [RKManagedObjectMapping mappingForClass:[SLFDistrict class]];
    mapping.primaryKeyAttribute = @"boundaryID";
    [mapping mapKeyPath:@"abbr" toAttribute:@"stateID"];
    [mapping mapKeyPath:@"num_seats" toAttribute:@"numSeats"];
    [mapping mapKeyPath:@"region" toAttribute:@"regionDictionary"];
    [mapping mapKeyPath:@"boundary_id" toAttribute:@"boundaryID"];
    [mapping mapAttributes:@"name", @"chamber", @"shape", nil];
    return mapping;
}

- (RKManagedObjectMapping *)generateEventMapping {
    RKManagedObjectMapping *mapping = [RKManagedObjectMapping mappingForClass:[SLFEvent class]];
    mapping.primaryKeyAttribute = @"eventID";
    [mapping mapKeyPath:@"id" toAttribute:@"eventID"];
    [mapping mapKeyPath:@"state" toAttribute:@"stateID"];
    [mapping mapKeyPath:@"updated_at" toAttribute:@"dateUpdated"];
    [mapping mapKeyPath:@"created_at" toAttribute:@"dateCreated"];
    [mapping mapKeyPath:@"when" toAttribute:@"dateStart"];
    [mapping mapKeyPath:@"end" toAttribute:@"dateEnd"];
    [mapping mapKeyPath:@"description" toAttribute:@"eventDescription"];
    [mapping mapKeyPath:@"+link" toAttribute:@"link"];
    [mapping mapKeyPath:@"sources.url" toAttribute:@"sources"];
    [mapping mapAttributes:@"session", @"participants", @"type", @"location",  nil];
    return mapping;
}

- (RKManagedObjectMapping *)generateLegislatorMapping {
    RKManagedObjectMapping *mapping = [RKManagedObjectMapping mappingForClass:[SLFLegislator class]];
    mapping.primaryKeyAttribute = @"legID";
    [mapping mapKeyPath:@"leg_id" toAttribute:@"legID"];
    [mapping mapKeyPath:@"state" toAttribute:@"stateID"];
    [mapping mapKeyPath:@"created_at" toAttribute:@"dateCreated"];
    [mapping mapKeyPath:@"updated_at" toAttribute:@"dateUpdated"];
    [mapping mapKeyPath:@"first_name" toAttribute:@"firstName"];
    [mapping mapKeyPath:@"full_name" toAttribute:@"fullName"];
    [mapping mapKeyPath:@"last_name" toAttribute:@"lastName"];
    [mapping mapKeyPath:@"middle_name" toAttribute:@"middleName"];
    [mapping mapKeyPath:@"nimsp_candidate_id" toAttribute:@"nimspCandidateID"];
    [mapping mapKeyPath:@"nimsp_id" toAttribute:@"nimspID"];
    [mapping mapKeyPath:@"photo_url" toAttribute:@"photoURL"];
    [mapping mapKeyPath:@"transparencydata_id" toAttribute:@"transparencyID"];
    [mapping mapKeyPath:@"votesmart_id" toAttribute:@"votesmartID"];
    [mapping mapKeyPath:@"sources.url" toAttribute:@"sources"];
    [mapping mapAttributes:@"suffixes", @"party", @"level", @"district", @"country", @"chamber", @"active",nil];    
    return mapping;
}

- (RKManagedObjectMapping *)generateCommitteeMapping {
    RKManagedObjectMapping *mapping = [RKManagedObjectMapping mappingForClass:[SLFCommittee class]];
    mapping.primaryKeyAttribute = @"committeeID";
    [mapping mapKeyPath:@"id" toAttribute:@"committeeID"];
    [mapping mapKeyPath:@"state" toAttribute:@"stateID"];
    [mapping mapKeyPath:@"created_at" toAttribute:@"dateCreated"];
    [mapping mapKeyPath:@"updated_at" toAttribute:@"dateUpdated"];
    [mapping mapKeyPath:@"parent_id" toAttribute:@"parentID"];
    [mapping mapKeyPath:@"votesmart_id" toAttribute:@"votesmartID"];
    [mapping mapKeyPath:@"committee" toAttribute:@"committeeName"];
    [mapping mapKeyPath:@"sources.url" toAttribute:@"sources"];
    [mapping mapAttributes:@"chamber", @"subcommittee", nil];
    return mapping;
}

- (RKManagedObjectMapping *)generateMemberMapping {
    RKManagedObjectMapping* mapping = [RKManagedObjectMapping mappingForClass:[CommitteeMember class]];
    [mapping mapKeyPath:@"leg_id" toAttribute:@"legID"];
    [mapping mapKeyPath:@"role" toAttribute:@"role"];
    [mapping mapKeyPath:@"name" toAttribute:@"legislatorName"];
    return mapping;
}

- (RKManagedObjectMapping *)generateRoleMapping {
    RKManagedObjectMapping* mapping = [RKManagedObjectMapping mappingForClass:[CommitteeRole class]];
    [mapping mapKeyPath:@"committee_id" toAttribute:@"committeeID"];
    [mapping mapKeyPath:@"type" toAttribute:@"role"];
    [mapping mapKeyPath:@"committee" toAttribute:@"committeeName"];
    return mapping;
}

- (RKManagedObjectMapping *)generateBillMapping {
    RKManagedObjectMapping *mapping = [RKManagedObjectMapping mappingForClass:[SLFBill class]];
    mapping.primaryKeyAttribute = @"billID";
    [mapping mapKeyPath:@"bill_id" toAttribute:@"billID"];
    [mapping mapKeyPath:@"state" toAttribute:@"stateID"];
    [mapping mapKeyPath:@"updated_at" toAttribute:@"dateUpdated"];
    [mapping mapKeyPath:@"created_at" toAttribute:@"dateCreated"];
    [mapping mapKeyPath:@"sources.url" toAttribute:@"sources"];
    [mapping mapAttributes:@"session", @"versions", @"chamber",@"documents", @"title",  nil];
    return mapping;
}

- (RKManagedObjectMapping *)generateRecordVoteMapping {
    RKManagedObjectMapping* mapping = [RKManagedObjectMapping mappingForClass:[BillRecordVote class]];
    mapping.primaryKeyAttribute = @"voteID";
    [mapping mapAttributes:@"date", /*@"type",*/ @"chamber", @"passed", @"session", @"motion", nil];
    [mapping mapKeyPath:@"vote_id" toAttribute:@"voteID"];
    [mapping mapKeyPath:@"+state" toAttribute:@"stateID"];
    [mapping mapKeyPath:@"+record" toAttribute:@"record"];
    [mapping mapKeyPath:@"+method" toAttribute:@"method"];
    [mapping mapKeyPath:@"yes_count" toAttribute:@"yesCount"];
    [mapping mapKeyPath:@"no_count" toAttribute:@"noCount"];
    [mapping mapKeyPath:@"other_count" toAttribute:@"otherCount"];
    [mapping mapKeyPath:@"bill_chamber" toAttribute:@"billChamber"];
    [mapping mapKeyPath:@"sources.url" toAttribute:@"sources"];
    mapping.setNilForMissingRelationships = NO;
    return mapping;
}

- (RKManagedObjectMapping *)generateVoterMapping {
    RKManagedObjectMapping* mapping = [RKManagedObjectMapping mappingForClass:[BillVoter class]];
    [mapping mapKeyPath:@"leg_id" toAttribute:@"legID"];
    [mapping mapKeyPath:@"name" toAttribute:@"legislatorName"];
    return mapping;
}

- (RKManagedObjectMapping *)generateBillActionMapping {
    RKManagedObjectMapping* mapping = [RKManagedObjectMapping mappingForClass:[BillAction class]];
    [mapping mapAttributes:@"date", @"action", @"actor", nil];
    [mapping mapKeyPath:@"+action_number" toAttribute:@"actionID"];
    [mapping mapKeyPath:@"+comment" toAttribute:@"comment"];
    return mapping;
}

- (RKManagedObjectMapping *)generateSponsorMapping {
    RKManagedObjectMapping* mapping = [RKManagedObjectMapping mappingForClass:[BillSponsor class]];
    [mapping mapKeyPath:@"leg_id" toAttribute:@"legID"];
    [mapping mapKeyPath:@"type" toAttribute:@"role"];
    [mapping mapKeyPath:@"name" toAttribute:@"legislatorName"];
    return mapping;
}

- (RKManagedObjectMapping *)generateWordMapping {
    RKManagedObjectMapping *mapping = [RKManagedObjectMapping mappingForClass:[SLFWord class]];
    [mapping mapKeyPath:@"" toAttribute:@"word"];
    return mapping;
}

@end
