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

- (RKManagedObjectMapping *)mapStates;

- (RKManagedObjectMapping *)mapBills;

- (RKManagedObjectMapping *)mapDistricts;

- (RKManagedObjectMapping *)mapEvents;

- (RKManagedObjectMapping *)mapLegislators;

- (RKManagedObjectMapping *)mapCommittees;

- (RKManagedObjectMapping *)mapPositionsFromLegislatorsAndCommittees;


@end


@implementation SLFMappingsManager
@synthesize legislatorMapping;
@synthesize committeeMapping;
@synthesize positionMapping;
@synthesize eventMapping;
@synthesize billMapping;
@synthesize districtMapping;
@synthesize stateMapping;

- (id)init {
    if ((self = [super init])) {
        // Setup our object mappings    
        
        [self mapStates];
        [self mapDistricts];
        [self mapBills];
        [self mapEvents];
        [self mapLegislators];
        [self mapCommittees];
        [self mapPositionsFromLegislatorsAndCommittees];
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


- (RKManagedObjectMapping *)mapStates {
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






- (RKManagedObjectMapping *)mapDistricts {
    self.districtMapping = [RKManagedObjectMapping mappingForClass:[SLFDistrictMap class]];
    [districtMapping.dateFormatStrings addObject:@"yyyy-MM-dd HH:mm:ss"];
    [districtMapping mapKeyPath:@"external_id" toAttribute:@"externalID"];
    [districtMapping mapKeyPath:@"updated_at" toAttribute:@"dateUpdated"];
    [districtMapping mapKeyPath:@"created_at" toAttribute:@"dateCreated"];
    [districtMapping mapKeyPath:@"sources.url" toAttribute:@"sources"];
    [districtMapping mapKeyPath:@"set" toAttribute:@"boundarySet"];
    [districtMapping mapKeyPath:@"kind" toAttribute:@"boundaryKind"];
    [districtMapping mapKeyPath:@"resource_uri" toAttribute:@"resourceURL"];
    [districtMapping mapKeyPath:@"centroid.coordinates" toAttribute:@"centroidCoords"];
    [districtMapping mapAttributes:@"slug", @"name", @"shape", nil];
    districtMapping.primaryKeyAttribute = @"slug";

    return districtMapping;
}






- (RKManagedObjectMapping *)mapBills {
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








- (RKManagedObjectMapping *)mapEvents {
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




- (RKManagedObjectMapping *)mapLegislators {
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

    /*RKObjectRelationshipMapping *stateRelation = [RKObjectRelationshipMapping mappingFromKeyPath:@"legislators" 
                                                                                       toKeyPath:@"theState" 
                                                                                     withMapping:legislatorMapping];
    [self.stateMapping addRelationshipMapping:stateRelation];
    
    [legislatorMapping connectRelationship:@"theState" withObjectForPrimaryKeyAttribute:@"stateID"];
    */
    return legislatorMapping;
}




- (RKManagedObjectMapping *)mapCommittees {
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




- (RKManagedObjectMapping *)mapPositionsFromLegislatorsAndCommittees {
    self.positionMapping = [RKManagedObjectMapping mappingForClass:[SLFCommitteePosition class]];
    [positionMapping mapAttributes:@"posID", @"positionType",@"legID",@"legislatorName",@"committeeID",@"committeeName",nil];
    positionMapping.primaryKeyAttribute = @"posID";//necessary????

    RKObjectRelationshipMapping *comRelation = [RKObjectRelationshipMapping mappingFromKeyPath:@"members" 
                                                                                     toKeyPath:@"positions" 
                                                                                   withMapping:positionMapping];
    [self.committeeMapping addRelationshipMapping:comRelation];

    RKObjectRelationshipMapping *legRelation = [RKObjectRelationshipMapping mappingFromKeyPath:@"roles" 
                                                                                     toKeyPath:@"positions" 
                                                                                   withMapping:positionMapping];
    [self.legislatorMapping addRelationshipMapping:legRelation];

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


+ (inout id *)premapLegislator:(SLFLegislator *)legislator toComitteesWithData:(inout id *)mappableData {

    NSArray* origRolesArray = [*mappableData valueForKeyPath:@"roles"];	// array of dictionaries
    NSString *legID = [*mappableData objectForKey:@"leg_id"];			// this legislator's id
    NSString *legName = [*mappableData objectForKey:@"full_name"];		// ... etc.
    
    if (!legID)
        legID = legislator.legID;
    
    if (!legName)
        legName = legislator.fullName;
    
    NSMutableArray* newRolesArray = [[NSMutableArray alloc] 
									 initWithCapacity:[origRolesArray count]];
    
    int roleIndex = 0;
    for (NSDictionary* origRole in origRolesArray) {
        
        //NSString *term = [origRole objectForKey:@"term"];			// our legislative session/year
        NSString *comID = [origRole objectForKey:@"committee_id"];
        
        // we use these to create a unique committee position object id 
        if (!comID || !legID) // include term ??
            continue;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@ AND %K == %@", @"committeeID", comID, @"legID", legID];
        SLFCommitteePosition *position = [SLFCommitteePosition objectWithPredicate:predicate];
        
        if (!position) {		// we didn't find one already in core data, create one.
            position = [SLFCommitteePosition object];
            position.committeeID = comID;
            position.legID = legID;
        }
        
        // It doesn't hurt to just update these properties we know about anyway, I guess.
        position.legislatorName = legName;
        position.committeeName = [origRole objectForKey:@"committee"];	// committee's name
        position.positionType =	[origRole objectForKey:@"type"];		// member, or chairperson, etc.			
        
        //  This seems like a klunky way to generate a unique primary key ID, but the
        //  aggregation of these three attributes *should* be unique across everything.
        
        position.posID = [NSString stringWithFormat:@"%@|%@", comID, legID];	// include term?
        
        //  If it doesn't need to be unique across *everything*, then this could work?
        ////  position.posID = [NSString stringWithFormat:@"%i", roleIndex];
        
        // does this stuff even really *need* a primary key id anymore?  
        // I certainly dont use it on this particular committee position model/entity
        
        [newRolesArray addObject:position];
        
        roleIndex++;
    }
    
    [*mappableData removeObjectForKey:@"roles"];		//remove the old roles array from the legislator
    [*mappableData setObject:newRolesArray forKey:@"roles"];	// inject our modified roles array.
    [newRolesArray release];
    
    return mappableData;
}

+ (inout id *)premapCommittee:(SLFCommittee *)committee toLegislatorsWithData:(inout id *)mappableData {
    
    NSArray* origRolesArray = [*mappableData valueForKeyPath:@"members"];	// array of dictionaries
    NSString *comID = [*mappableData objectForKey:@"id"];                   // this legislator's id
    NSString *comName = [*mappableData objectForKey:@"committee"];          // ... etc.
    
    if (!comID)
        comID = committee.committeeID;
    
    if (!comName)
        comName = committee.committeeName;
    
    NSMutableArray* newRolesArray = [[NSMutableArray alloc] 
                                     initWithCapacity:[origRolesArray count]];
    
    int roleIndex = 0;
    for (NSDictionary* origRole in origRolesArray) {
        
        //NSString *term = [origRole objectForKey:@"term"];			// our legislative session/year
        NSString *legID = [origRole objectForKey:@"leg_id"];
        
        // we use these to create a unique committee position object id 
        if ([[NSNull null] isEqual:comID] || [[NSNull null] isEqual:legID]) // include term ??
            continue;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@ AND %K == %@", @"committeeID", comID, @"legID", legID];
        SLFCommitteePosition *position = [SLFCommitteePosition objectWithPredicate:predicate];
        
        if (!position) {		// we didn't find one already in core data, create one.
            position = [SLFCommitteePosition object];
            position.committeeID = comID;
            position.legID = legID;
        }
        
        // It doesn't hurt to just update these properties we know about anyway, I guess.
        position.legislatorName = [origRole objectForKey:@"name"];
        position.committeeName = comName;
        position.positionType =	[origRole objectForKey:@"role"];				// member, or chairperson, etc.			
        
        //  This seems like a klunky way to generate a unique primary key ID, but the
        //  aggregation of these three attributes *should* be unique across everything.
        
        position.posID = [NSString stringWithFormat:@"%@|%@", comID, legID];	// include term?
        
        //  If it doesn't need to be unique across *everything*, then this could work?
        ////  position.posID = [NSString stringWithFormat:@"%i", roleIndex];
        
        // does this stuff even really *need* a primary key id anymore?  
        // I certainly dont use it on this particular committee position model/entity
        
        [newRolesArray addObject:position];
        
        roleIndex++;
    }
    
    [*mappableData removeObjectForKey:@"members"];		//remove the old roles array from the legislator
    [*mappableData setObject:newRolesArray forKey:@"members"];	// inject our modified roles array.
    [newRolesArray release];
    return mappableData;
}













#if 0
- (void)exampleMappings {
    
    /*!
     Mapping by entity. Here we are configuring a mapping by targetting a Core Data entity with a specific
     name. This allows us to map back Twitter user objects directly onto NSManagedObject instances --
     there is no backing model class!
     */
    
     RKManagedObjectMapping* userMapping = [RKManagedObjectMapping mappingForEntityWithName:@"RKTUser"];
     userMapping.primaryKeyAttribute = @"userID";
     [userMapping mapKeyPath:@"id" toAttribute:@"userID"];
     [userMapping mapKeyPath:@"screen_name" toAttribute:@"screenName"];
     [userMapping mapAttributes:@"name", nil];
     
    
    /*!
     Map to a target object class -- just as you would for a non-persistent class. The entity is resolved
     for you using the Active Record pattern where the class name corresponds to the entity name within Core Data.
     Twitter status objects will be mapped onto RKTStatus instances.
     */
    RKManagedObjectMapping* statusMapping = [RKManagedObjectMapping mappingForClass:[RKTStatus class]];
    statusMapping.primaryKeyAttribute = @"statusID";
    [statusMapping mapKeyPathsToAttributes:@"id", @"statusID",
     @"created_at", @"createdAt",
     @"text", @"text",
     @"url", @"urlString",
     @"in_reply_to_screen_name", @"inReplyToScreenName",
     @"favorited", @"isFavorited", 
     nil];
    [statusMapping mapRelationship:@"user" withObjectMapping:userMapping];
    
    // Update date format so that we can parse Twitter dates properly
    // Wed Sep 29 15:31:08 +0000 2010
    [statusMapping.dateFormatStrings addObject:@"E MMM d HH:mm:ss Z y"];
    //											 2011-07-17 02:31:42
    [statusMapping.dateFormatStrings addObject:@"yyyy-MM-dd HH:mm:ss"];
    
    // Register our mappings with the provider
    [objectManager.mappingProvider setObjectMapping:statusMapping forKeyPath:@"status"];
    
    
}

#endif

@end
