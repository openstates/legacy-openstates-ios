//
//  SLFObjectCache.m
//  Created by Gregory Combs on 3/21/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFObjectCache.h"

#import "SLFDataModels.h"
#import "NSDate+Helper.h"
#import "UtilityMethods.h"

@implementation SLFObjectCache


- (NSArray*)fetchRequestsForResourcePath:(NSString*)resourcePath {
	
    NSCParameterAssert(resourcePath != NULL);    
    NSArray* pathComponents = [resourcePath componentsSeparatedByString:@"/"];
    if (IsEmpty(pathComponents))
        return nil;
	NSInteger componentsCount = [pathComponents count];    
    NSString *objectType = [pathComponents objectAtIndex:0];
    Class objectClass = nil;
    NSString *primaryKey = nil;
    NSString *stateIDKey = @"stateID";
    
    if ([@"metadata" isEqual:objectType]) {
        objectClass = [SLFState class];
        primaryKey = @"stateID";
    }
    else if ([@"legislators" isEqual:objectType]) {
        objectClass = [SLFLegislator class];
        primaryKey = @"legislatorID";
    }
    else if ([@"committees" isEqual:objectType]) {
        objectClass = [SLFCommittee class];
        primaryKey = @"committeeID";
    }
    else if ([@"districts" isEqual:objectType]) {
        objectClass = [SLFDistrictMap class];
        primaryKey = @"boundaryID";
        stateIDKey = @"abbrev"; //?????????????????????????????? WTF!!!!!
    }
    else if ([@"events" isEqual:objectType]) {
        objectClass = [SLFEvent class];
        primaryKey = @"eventID";
    }
    else if ([@"bills" isEqual:objectType]) {
        objectClass = [SLFBill class];
        primaryKey = @"billID";
    }
        
    NSMutableArray *fetchParameters = [NSMutableArray array];
    
    NSString *firstQueryWord = [pathComponents objectAtIndex:1];
    if ([firstQueryWord length] == 2 && [firstQueryWord isNumerical] == NO) {  // a state ID
        [fetchParameters addObject:[NSDictionary dictionaryWithObject:firstQueryWord forKey:<#(id)key#>        
    }
    
    for (NSInteger wordIndex=1; wordIndex<componentsCount; wordIndex++) {
        NSString *word = [pathComponents objectAtIndex:wordIndex];
        if ([word length] == 2) { // it's a stateID
            [fetchParameters addObject:[NSDictionary dictionaryWithObject:word forKey:@"stateID"]
        }
        if ([word hasPrefix:@"?"]) {
            NSDictionary *queryParameters = [UtilityMethods parametersOfQuery:word];
            
        }
    }
    

        if ([[paramsDict allKeys] containsObject:@"updated_since"]) {
            NSString* updatedString = [[paramsDict objectForKey:@"updated_since"] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
            NSDate *updatedDate = [NSDate dateFromString:updatedString];
            NSFetchRequest* request = [modelClass fetchRequest];
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"updated >= %@", updatedDate, nil];
            [request setPredicate:predicate];
            NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:primaryKey ascending:YES];
            [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            return [NSArray arrayWithObject:request];
        }
    }
    else {
        NSString* ID = params;
        NSFetchRequest* request = [modelClass fetchRequest];
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%@ = %@", primaryKey, ID, nil];
        [request setPredicate:predicate];
        NSSortDescriptor *one = [NSSortDescriptor sortDescriptorWithKey:primaryKey ascending:YES] ;
        [request setSortDescriptors:[NSArray arrayWithObjects:one, nil]];
        return [NSArray arrayWithObject:request];
        
    }

    
}

@end
