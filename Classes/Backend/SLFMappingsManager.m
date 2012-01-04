//
//  SLFMappingsManager.m
//  Created by Gregory Combs on 7/31/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFMappingsManager.h"
#import "SLFDataModels.h"

@implementation SLFMappingsManager

- (void)registerMappings {
    RKObjectMappingProvider *provider = [[RKObjectManager sharedManager] mappingProvider];
    [RKManagedObjectMapping addDefaultDateFormatterForString:@"yyyy-MM-dd HH:mm:ss" inTimeZone:nil];

    RKManagedObjectMapping *stateMapping = [SLFState mapping];
    RKManagedObjectMapping *districtMapping = [SLFDistrict mappingWithStateMapping:stateMapping];
    RKManagedObjectMapping *eventMapping = [SLFEvent mappingWithStateMapping:stateMapping];
    RKManagedObjectMapping *billMapping = [SLFBill mappingWithStateMapping:stateMapping];
    RKManagedObjectMapping *legislatorMapping = [SLFLegislator mappingWithStateMapping:stateMapping];
    RKManagedObjectMapping *committeeMapping = [SLFCommittee mappingWithStateMapping:stateMapping];
    RKManagedObjectMapping *memberMapping = [CommitteeMember mapping];
    RKManagedObjectMapping *roleMapping = [CommitteeRole mapping];
    RKManagedObjectMapping *sponsorMapping = [BillSponsor mapping];
    RKManagedObjectMapping *actionMapping = [BillAction mapping];
    RKManagedObjectMapping *voterMapping = [BillVoter mapping];
    RKManagedObjectMapping *recordVoteMapping = [BillRecordVote mapping];
    RKManagedObjectMapping *wordMapping = [GenericWord mapping];
    RKManagedObjectMapping *sourceMapping = [GenericAsset mapping];
    RKManagedObjectMapping *participantMapping = [EventParticipant mapping];
    
    [recordVoteMapping hasMany:@"sources" withMapping:sourceMapping];
    [recordVoteMapping mapKeyPath:@"no_votes" toRelationship:@"noVotes" withMapping:voterMapping];
    [recordVoteMapping mapKeyPath:@"yes_votes" toRelationship:@"yesVotes" withMapping:voterMapping];
    [recordVoteMapping mapKeyPath:@"other_votes" toRelationship:@"otherVotes" withMapping:voterMapping];
    [districtMapping hasMany:@"legislators" withMapping:legislatorMapping];
    [legislatorMapping hasMany:@"roles" withMapping:roleMapping];
    [legislatorMapping hasMany:@"sources" withMapping:sourceMapping];
    [committeeMapping hasMany:@"members" withMapping:memberMapping];
    [committeeMapping hasMany:@"sources" withMapping:sourceMapping];
    [actionMapping mapKeyPath:@"type" toRelationship:@"types" withMapping:wordMapping];
    [eventMapping hasMany:@"sources" withMapping:sourceMapping];
    [eventMapping hasMany:@"participants" withMapping:participantMapping];
    [billMapping hasMany:@"actions" withMapping:actionMapping];
    [billMapping hasMany:@"alternateTitles" withMapping:wordMapping];
    [billMapping hasMany:@"documents" withMapping:sourceMapping];
    [billMapping hasMany:@"sources" withMapping:sourceMapping];
    [billMapping hasMany:@"sponsors" withMapping:sponsorMapping];
    [billMapping hasMany:@"subjects" withMapping:wordMapping];
    [billMapping mapKeyPath:@"type" toRelationship:@"types" withMapping:wordMapping];
    [billMapping hasMany:@"versions" withMapping:sourceMapping];
    [billMapping hasMany:@"votes" withMapping:recordVoteMapping];
        
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
    [provider addObjectMapping:sourceMapping];
    [provider addObjectMapping:participantMapping];
    [provider addObjectMapping:memberMapping];
    [provider addObjectMapping:roleMapping];
    [provider addObjectMapping:sponsorMapping];
    [provider addObjectMapping:wordMapping];
        
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
    [provider setMapping:sourceMapping forKeyPath:@"sources"];
    [provider setMapping:sourceMapping forKeyPath:@"versions"];
    [provider setMapping:sourceMapping forKeyPath:@"documents"];
    [provider setMapping:participantMapping forKeyPath:@"participants"];
}

@end
