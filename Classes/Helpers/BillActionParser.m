//
//  BillActionParser.m
//  Created by Gregory Combs on 6/12/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

/*

STAGE1:Introduced / Read 1st
	Committee Referral
STAGE2:Committee Favorable Report / Unfavorable (with or w/o amendments)
	Commitee report distributed
	Goes to calendars (house
	2nd reading
	3rd reading
STAGE3:Passage by chamber of origin
	Goes to opposing chamber
	read 1st time
	Commitee Referral
STAGE4:Committee favorable/Unfavorable in Opposing
	report printed
	2nd reading
	3rd reading
STAGE5:Passage by other chamber
	Conference committees
	*Bill Enrolled
	*Signed by Speaker & Lt. Gov
STAGE6:Sent to governor
	Governor signs / refuses to sign / vetoes
	Veto override by 2/3rds?
STAGE7:Bill becomes law / Bill does not become law

 Stages:
	Bills = 1-7
	Simple Resolutions	= 1-3 (2 is optional)
	Concur. Resolutions	= 1-5, 6&7 optional/unknown
	Joint Resolutions	= 1-5, 6 (sec of state), 7 (after voter approval)
	
 */
#import "BillActionParser.h"
#import "AppendingFlowView.h"
#import "SLFDataModels.h"
#import "NSString+SLFExtensions.h"

@interface BillActionParser()
- (AppendingFlowStage *)configureStage:(AppendingFlowStage *)stage forAction:(BillAction *)action inBill:(SLFBill *)bill;
- (BOOL)actionTypes:(NSSet *)actionTypes containWord:(NSString *)searchWord;
- (NSMutableArray *)prepStagesForBill:(SLFBill *)bill;
@end

@implementation BillActionParser

- (NSArray *)stagesForBill:(SLFBill *)bill {
	if (!bill)
		return nil;
	NSMutableArray *stages = [self prepStagesForBill:bill];
	for (AppendingFlowStage *stage in stages) {
		for (BillAction *action in bill.actions)
            [self configureStage:stage forAction:action inBill:bill];
	}
	return stages;
}	

- (NSMutableArray *)prepStagesForBill:(SLFBill *)bill {
    if (!bill || IsEmpty(bill.types))
        return nil;
    BillType billType = bill.billType;
	SLFChamber *billChamber = bill.chamberObj;
    SLFChamber *billOppChamber = billChamber.opposingChamber;
	NSString *committeeString = NSLocalizedString(@"Committee", @"");
	NSString *votedString = NSLocalizedString(@"Passed", @"");
	NSString *caption = nil;
	NSMutableArray *stages = [NSMutableArray array];
    [stages addObject:[AppendingFlowStage stageWithNumber:1 caption:NSLocalizedString(@"Filed", @"")]];
	caption = [NSString stringWithFormat:@"%@ %@", billChamber.shortName, committeeString];
    [stages addObject:[AppendingFlowStage stageWithNumber:2 caption:caption]];
	caption = [NSString stringWithFormat:@"%@ %@", billChamber.shortName, votedString];
    [stages addObject:[AppendingFlowStage stageWithNumber:3 caption:caption]];
	if (billType >= BillTypeConcurrentResolution) {
        if (billOppChamber) {
            caption = [NSString stringWithFormat:@"%@ %@", billOppChamber.shortName, committeeString];
            [stages addObject:[AppendingFlowStage stageWithNumber:4 caption:caption]];
            caption = [NSString stringWithFormat:@"%@ %@", billOppChamber.shortName, votedString];
            [stages addObject:[AppendingFlowStage stageWithNumber:5 caption:caption]];
        }
        [stages addObject:[AppendingFlowStage stageWithNumber:6 caption:NSLocalizedString(@"Governor Action", @"")]];
	}
	if (billType >= BillTypeJointResolution) {
        [stages addObject:[AppendingFlowStage stageWithNumber:7 caption:NSLocalizedString(@"Becomes Law", @"")]];
	}
    return stages;
}


- (AppendingFlowStage *)configureStage:(AppendingFlowStage *)stage forAction:(BillAction *)action inBill:(SLFBill *)bill {
        // We add a little extra "umph" for Texas bills to get better parsing results
	BOOL isTexasBill = [@"tx" isEqual:bill.stateID];
	SLFChamber *billChamber = bill.chamberObj;
    SLFChamber *billOppChamber = [billChamber opposingChamber];
	NSString *origChamber = billChamber.type;
 	NSString *oppChamber = billOppChamber ? billOppChamber.type : nil;
    NSString *actionName = action.action;
    NSString *actor = action.actor;
    NSSet *types = action.types;
    
        //STAGE1:Introduced / Read 1st in the original chamber
    if (stage.stageNumber == 1) {
        if ([self actionTypes:types containWord:@"bill:filed"] || [self actionTypes:types containWord:@"bill:introduced"] || [self actionTypes:types containWord:@"bill:reading:1"])
        {
            if ([stage shouldPromoteTypeTo:FlowStageReached]) {
                stage.stageType = FlowStageReached;
                return stage;
            }
        }
    }
    
        //STAGE2:Committee Favorable Report / Unfavorable (with or w/o amendments)
    if (stage.stageNumber == 2 && [origChamber isEqualToString:actor caseInsensitive:YES]) {
        
        if ([self actionTypes:types containWord:@"committee:referred"] && [stage shouldPromoteTypeTo:FlowStagePending]) {
            stage.stageType = FlowStagePending;
        }						
        
        if ([self actionTypes:types containWord:@"committee:passed"]) {
            if ([stage shouldPromoteTypeTo:FlowStageReached]) {
                stage.stageType = FlowStageReached;
                return stage;
            }
        }
        else if ([self actionTypes:types containWord:@"committee:failed"] || (isTexasBill && [actionName hasPrefix:@"Reported unfavorably"])) {
            
            if ([stage shouldPromoteTypeTo:FlowStageFailed]) {
                stage.stageType = FlowStageFailed;
                return stage;
            }
            
        }
    }
    
        //STAGE3:Passage by chamber of origin
    if (stage.stageNumber == 3 && [origChamber isEqualToString:actor caseInsensitive:YES]) {
        
        if ([stage shouldPromoteTypeTo:FlowStagePending] &&
            ([self actionTypes:types containWord:@"bill:reading:2"] || [self actionTypes:types containWord:@"bill:reading:3"])) {
            stage.stageType = FlowStagePending;
        }
        
        
        if ([self actionTypes:types containWord:@"bill:passed"]) {
            if ([stage shouldPromoteTypeTo:FlowStageReached]) {
                stage.stageType = FlowStageReached;
                return stage;
            }
        }
        else if ([self actionTypes:types containWord:@"bill:failed"] || [self actionTypes:types containWord:@"bill:withdrawn"] ) {
            if ([stage shouldPromoteTypeTo:FlowStageFailed]) {
                stage.stageType = FlowStageFailed;
                stage.caption = [NSString stringWithFormat:@"%@ %@", billChamber.shortName, NSLocalizedString(@"Failed", @"")];
                return stage;
            }
        }
    }
    
        //STAGE4:Committee favorable/Unfavorable in Opposing
    if (stage.stageNumber == 4 && oppChamber && [oppChamber isEqualToString:actor caseInsensitive:YES]) {
        
        if ([stage shouldPromoteTypeTo:FlowStagePending] && [self actionTypes:types containWord:@"committee:referred"]) {
            stage.stageType = FlowStagePending;
        }
        
        
        if ([self actionTypes:types containWord:@"committee:passed"]) {
            if ([stage shouldPromoteTypeTo:FlowStageReached]) {
                stage.stageType = FlowStageReached;
                return stage;
            }
        }
        else if ([self actionTypes:types containWord:@"committee:failed"] || (isTexasBill && [actionName hasPrefix:@"Reported unfavorably"])) {
            
            if ([stage shouldPromoteTypeTo:FlowStageFailed]) {
                stage.stageType = FlowStageFailed;
                return stage;
            }
        }
    }
    
        //STAGE5:Passage by opposing chamber
    if (stage.stageNumber == 5 && oppChamber && [oppChamber isEqualToString:actor caseInsensitive:YES]) {
        
        if ([self actionTypes:types containWord:@"bill:reading:2"] || [self actionTypes:types containWord:@"bill:reading:3"]) {
            if ([stage shouldPromoteTypeTo:FlowStagePending]) {						
                stage.stageType = FlowStagePending;
            }						
        }
        
        if ([self actionTypes:types containWord:@"bill:passed"]) {
            if ([stage shouldPromoteTypeTo:FlowStageReached]) {						
                stage.stageType = FlowStageReached;
                return stage;
            }						
            
        }
        else if ([self actionTypes:types containWord:@"bill:failed"] || [self actionTypes:types containWord:@"bill:withdrawn"]) {
            if ([stage shouldPromoteTypeTo:FlowStageFailed]) {						
                stage.stageType = FlowStageFailed;
                stage.caption = [NSString stringWithFormat:@"%@ %@", billOppChamber.shortName, NSLocalizedString(@"Failed", @"")];
                return stage;
            }						
            
        }
    }
    
        //STAGE6: Sent to Governor / Secretary of State
    if (stage.stageNumber == 6 && [@"executive" isEqualToString:actor caseInsensitive:YES]) {
        
        if ([self actionTypes:types containWord:@"governor:received"]) {
            if ([stage shouldPromoteTypeTo:FlowStagePending]) {						
                stage.stageType = FlowStagePending;
            }						
        }
        
        if ([self actionTypes:types containWord:@"governor:signed"] || [self actionTypes:types containWord:@"bill:veto_override:passed"] || (isTexasBill && ([actionName isEqualToString:@"Filed without the Governor's signature"]))) {
            
            if ([stage shouldPromoteTypeTo:FlowStageReached]) {						
                stage.stageType = FlowStageReached;
                if ([types containsObject:@"governor:signed"]) 
                    stage.caption = NSLocalizedString(@"Governor Signed", @"");
                else if ([actionName isEqualToString:@"Filed without the Governor's signature"])
                    stage.caption = NSLocalizedString(@"Filed w/o Gov.", @"");
                return stage;
            }						
        }
        else if ([self actionTypes:types containWord:@"governor:vetoed"]) {
            if ([stage shouldPromoteTypeTo:FlowStageFailed]) {						
                stage.stageType = FlowStageFailed;
                stage.caption = NSLocalizedString(@"Governor Vetoed", @"");
                return stage;
            }						
        }
    }
    
        //STAGE7: Bill Becomes Law / Doesn't
    if (stage.stageNumber == 7 && [@"executive" isEqualToString:actor caseInsensitive:YES]) {
        
        if (isTexasBill && [actionName isEqualToString:@"Filed with the Secretary of State"]){
            if ([stage shouldPromoteTypeTo:FlowStagePending]) {						
                stage.stageType = FlowStagePending;
                stage.caption = NSLocalizedString(@"Sent to SecState", @"");
            }						
        }
        
        if (isTexasBill && [actionName hasSubstring:@"effective" caseInsensitive:YES]) {
            if ([stage shouldPromoteTypeTo:FlowStageReached]) {						
                stage.stageType = FlowStageReached;
                if ([stage.caption isEqualToString:NSLocalizedString(@"Sent to SecState", @"")]) {
                    stage.caption = NSLocalizedString(@"Voters Passed", @"");
                }
                return stage;
            }				
        }				
    }
    return stage;
}

- (BOOL)actionTypes:(NSSet *)actionTypes containWord:(NSString *)searchWord {
    if (IsEmpty(actionTypes) || IsEmpty(searchWord))
        return NO;
    __block BOOL found = NO;
    searchWord = [searchWord lowercaseString];
    [actionTypes enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        if ([obj isKindOfClass:[GenericWord class]]) {
            NSString *word = [obj word];
            if (word && [word hasSubstring:searchWord caseInsensitive:YES]) {
                found = YES;
                *stop = YES;
            }
        }
    }];
    return found;
}



@end

