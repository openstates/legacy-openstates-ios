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
#import "StateMetaLoader.h"
#import "TexLegeLibrary.h"
#import "UtilityMethods.h"
#import "AppendingFlowView.h"
#import "SLFDataModels.h"

@implementation BillActionParser

- (id)init {
	if ((self = [super init])) {

	}
	return self;
}


- (NSMutableDictionary *)prepStagesForBill:(SLFBill *)bill {
	/*
	 Bills = 1-7
	 Simple Resolutions	= 1-3 (2 is optional)
	 Concur. Resolutions	= 1-5, 6&7 optional/unknown
	 Joint Resolutions	= 1-5, 6 (sec of state), 7 (after voter approval)
	 */

	SLFChamber *billChamber = bill.chamberObj;
    SLFChamber *billOppChamber = [billChamber opposingChamber];
	
	BillType billType = -1;
	
	if ([bill.type containsObject:@"bill"])
		billType = BillTypeBill;
	else if ([bill.type containsObject:@"concurrent resolution"])
		billType = BillTypeConcurrentResolution;
	else if ([bill.type containsObject:@"joint resolution"])
		billType = BillTypeJointResolution;
	else //if ([type containsObject:@"resolution"])
		billType = BillTypeSimpleResolution;
	
	AppendingFlowStage *stage1=nil,*stage2=nil,*stage3=nil,*stage4=nil,*stage5=nil,*stage6=nil,*stage7=nil;
	NSMutableArray *stageKeys = [[NSMutableArray alloc] initWithObjects:
								 @"1", @"2", @"3", nil];
	
	NSString *committeeString = NSLocalizedStringFromTable(@"Committee", @"DataTableUI", @"Cell title, preceded by the chamber name, like 'House Committe'");
	NSString *votedString = NSLocalizedStringFromTable(@"Passed", @"DataTableUI", @"Whether a bill passed/failed");
	//NSString *failedString = NSLocalizedStringFromTable(@"Failed", @"DataTableUI", @"Whether a bill passed/failed");
	
	NSMutableDictionary *stages = [[NSMutableDictionary alloc] init];
	NSString *tempStr = nil;

	// Stage 1
	tempStr = NSLocalizedStringFromTable(@"Filed", @"DataTableUI", @"A bill was filed");
	stage1 = [[AppendingFlowStage alloc] initWithStage:1 caption:tempStr];
	[stages setObject:stage1 forKey:@"1"];
	
	// Stage 2
	NSString *thisCham = billChamber.shortName;
	tempStr = [NSString stringWithFormat:@"%@ %@", thisCham, committeeString];
	stage2 = [[AppendingFlowStage alloc] initWithStage:2 caption:tempStr];
	[stages setObject:stage2 forKey:@"2"];
	
	// Stage 3
	tempStr = [NSString stringWithFormat:@"%@ %@",thisCham, votedString];
	stage3 = [[AppendingFlowStage alloc] initWithStage:3 caption:tempStr];
	[stages setObject:stage3 forKey:@"3"];
	
	NSString *stageNum = nil;
	
	if (billType >= BillTypeConcurrentResolution) {
		NSString *thatCham = billOppChamber.shortName;
		
		// Stage 4
		stageNum = @"4";
		[stageKeys addObject:stageNum];
		
		tempStr = [NSString stringWithFormat:@"%@ %@", thatCham, committeeString];
		stage4 = [[AppendingFlowStage alloc] initWithStage:[stageNum integerValue] caption:tempStr];
		[stages setObject:stage4 forKey:stageNum];
		
		// Stage 5
		stageNum = @"5";
		[stageKeys addObject:stageNum];
		
		tempStr = [NSString stringWithFormat:@"%@ %@", thatCham, votedString];
		stage5 = [[AppendingFlowStage alloc] initWithStage:[stageNum integerValue] caption:tempStr];
		[stages setObject:stage5 forKey:stageNum];

		stageNum = @"6";
		[stageKeys addObject:stageNum];

		tempStr = NSLocalizedStringFromTable(@"Governor Action", @"DataTableUI", @"Short (very short) title to indicate a bill has passed and will become a law");
		stage6 = [[AppendingFlowStage alloc] initWithStage:[stageNum integerValue] caption:tempStr];
		[stages setObject:stage6 forKey:stageNum];
		
	}
	
	if (billType >= BillTypeJointResolution) {
		stageNum = @"7";
		[stageKeys addObject:stageNum];
		
		tempStr = NSLocalizedStringFromTable(@"Becomes Law", @"DataTableUI", @"Short (very short) title to indicate a bill has passed and will become a law");
		stage7 = [[AppendingFlowStage alloc] initWithStage:[stageNum integerValue] caption:tempStr];
		[stages setObject:stage7 forKey:stageNum];
	}
	
	NSMutableDictionary *results = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									stages, @"stages",
									stageKeys, @"keys", 
									[NSNumber numberWithInteger:billType], @"billType",
									nil];
	[stages release];
	[stageKeys release];

	
	nice_release(stage1);
	nice_release(stage2);
	nice_release(stage3);
	nice_release(stage4);
	nice_release(stage5);
	nice_release(stage6);
	nice_release(stage7);

	return results;
}

- (NSMutableDictionary *)parseStagesForBill:(SLFBill *)bill {
	if (!bill)
		return nil;
	
	// We add a little extra "umph" for Texas bills to get better parsing results
	BOOL texasCentricParser = [@"tx" isEqual:bill.stateID];
	
	SLFChamber *billChamber = bill.chamberObj;
    SLFChamber *billOppChamber = [billChamber opposingChamber];
	NSInteger origChamber = billChamber.typeValue;
 	NSInteger oppChamber = billOppChamber.typeValue;
	
	NSMutableDictionary *results = [self prepStagesForBill:bill];
	
	NSMutableDictionary *stages = [results objectForKey:@"stages"];
	NSMutableArray *stageKeys = [results objectForKey:@"keys"];
	//BillType billType = [[results objectForKey:@"billType"] integerValue];

	for (NSString *stageKey in stageKeys) {
		AppendingFlowStage *stage = [stages objectForKey:stageKey];

		for (NSMutableDictionary *action in bill.actions) {
			NSString *actionStr = [action objectForKey:@"action"];
			NSString *actor = [action objectForKey:@"actor"];
			NSInteger actChamber = [billChamber typeValueForKnownType:actor];
			NSArray *types = [action objectForKey:@"type"];
			
			// BILL IS IN ORIGINAL CHAMBER
			//STAGE1:Introduced / Read 1st
			if (stage.stageNumber == 1) {
				if ([types containsObject:@"bill:filed"] )//||	 @"bill:introduced" ???
					{
						 
						 if ([stage shouldPromoteTypeTo:FlowStageReached]) {
							 stage.stageType = FlowStageReached;
							 break;
						 }
					 }
			}
			
			//STAGE2:Committee Favorable Report / Unfavorable (with or w/o amendments)
			if (stage.stageNumber == 2 && actChamber == origChamber) {
					
				if ([types containsObject:@"committee:referred"] &&
					[stage shouldPromoteTypeTo:FlowStagePending]) {
					stage.stageType = FlowStagePending;
				}						
				
				
				if ([types containsObject:@"committee:passed:favorable"] ||
					[types containsObject:@"committee:passed"]) {
						
						if ([stage shouldPromoteTypeTo:FlowStageReached]) {
							stage.stageType = FlowStageReached;
							break;
						}
					}
				else if ([types containsObject:@"committee:failed"] ||
						 (texasCentricParser && 
						  [actionStr hasPrefix:@"Reported unfavorably"])) {
							 
							 if ([stage shouldPromoteTypeTo:FlowStageFailed]) {
								 stage.stageType = FlowStageFailed;
								 break;
							 }
							 
						 }
			}
			
			//STAGE3:Passage by chamber of origin
			if (stage.stageNumber == 3 && actChamber == origChamber) {
				
				if ([stage shouldPromoteTypeTo:FlowStagePending] &&
					([types containsObject:@"bill:reading:2"] ||
					 [types containsObject:@"bill:reading:3"])) {
						stage.stageType = FlowStagePending;
					}
				
				
				if ([types containsObject:@"bill:passed"]) {
						 
						 if ([stage shouldPromoteTypeTo:FlowStageReached]) {
							 stage.stageType = FlowStageReached;
							 break;
						 }
					 }
				else if ([types containsObject:@"bill:failed"] ||
						 [types containsObject:@"bill:withdrawn"] ) {
																	   
					if ([stage shouldPromoteTypeTo:FlowStageFailed]) {
						stage.stageType = FlowStageFailed;
						break;
					}
				}
			}
			
			//STAGE4:Committee favorable/Unfavorable in Opposing
			if (stage.stageNumber == 4 && actChamber == oppChamber) {

					if ([stage shouldPromoteTypeTo:FlowStagePending] &&
						[types containsObject:@"committee:referred"]) {						
							stage.stageType = FlowStagePending;
						}
					
					
					if ([types containsObject:@"committee:passed:favorable"] ||
						[types containsObject:@"committee:passed"]) {
							
							if ([stage shouldPromoteTypeTo:FlowStageReached]) {
								stage.stageType = FlowStageReached;
								break;
							}
						}
					else if ([types containsObject:@"committee:failed"] ||
							 (texasCentricParser && 
							  [actionStr hasPrefix:@"Reported unfavorably"])) {
								 
								 if ([stage shouldPromoteTypeTo:FlowStageFailed]) {
									 stage.stageType = FlowStageFailed;
									 break;
								 }
							 }
				}
				
			//STAGE5:Passage by opposing chamber
			if (stage.stageNumber == 5 && actChamber == oppChamber) {
					
					if ([types containsObject:@"bill:reading:2"] ||
						[types containsObject:@"bill:reading:3"]) {
						
						if ([stage shouldPromoteTypeTo:FlowStagePending]) {						
							stage.stageType = FlowStagePending;
						}						
					}
					
					if ([types containsObject:@"bill:passed"]) {
							
							 if ([stage shouldPromoteTypeTo:FlowStageReached]) {						
								 stage.stageType = FlowStageReached;
								 break;
							 }						
							 
						}
					else if ([types containsObject:@"bill:failed"] ||
							 [types containsObject:@"bill:withdrawn"]) {
							   
						if ([stage shouldPromoteTypeTo:FlowStageFailed]) {						
							stage.stageType = FlowStageFailed;
							break;
						}						
						
					}
				}
				
			//STAGE6: Sent to Governor / Secretary of State
			if (stage.stageNumber == 6 && actChamber == CHAMBER_EXEC) {
				
				if ([types containsObject:@"governor:received"]) {
						
						if ([stage shouldPromoteTypeTo:FlowStagePending]) {						
							stage.stageType = FlowStagePending;
						}						
					}
				
				if ([types containsObject:@"governor:signed"] ||
					[types containsObject:@"bill:veto_override:passed"] || 
					(texasCentricParser && 
					 ([actionStr isEqualToString:@"Filed without the Governor's signature"]))) {
						 
						 if ([stage shouldPromoteTypeTo:FlowStageReached]) {						
							 stage.stageType = FlowStageReached;
							 if ([types containsObject:@"governor:signed"]) 
								 stage.caption = NSLocalizedStringFromTable(@"Governor Signed", @"DataTableUI", @"");
							 else if ([actionStr isEqualToString:@"Filed without the Governor's signature"])
								 stage.caption = NSLocalizedStringFromTable(@"Filed w/o Gov.", @"DataTableUI", @"");
							 break;
						 }						
					 }
				else if ([types containsObject:@"governor:vetoed"] ||
						 [types containsObject:@"governor:vetoed:line-item"] ) {
							 
							 if ([stage shouldPromoteTypeTo:FlowStageFailed]) {						
								 stage.stageType = FlowStageFailed;
								 stage.caption = NSLocalizedStringFromTable(@"Governor Vetoed", @"DataTableUI", @"");
								 break;
							 }						
						 }
			}
			
			//STAGE7: Bill Becomes Law / Doesn't
			if (stage.stageNumber == 7 && actChamber == CHAMBER_EXEC) {
				
				if (texasCentricParser && 
					[actionStr isEqualToString:@"Filed with the Secretary of State"]){
					
					if ([stage shouldPromoteTypeTo:FlowStagePending]) {						
						stage.stageType = FlowStagePending;
						stage.caption = NSLocalizedStringFromTable(@"Sent to SecState", @"DataTableUI", @"");
					}						
				}
				
				if (texasCentricParser && 
					([actionStr hasPrefix:@"Effective"] ||
					 [actionStr hasSubstring:@"effective date" caseInsensitive:YES])) {
						
						if ([stage shouldPromoteTypeTo:FlowStageReached]) {						
							stage.stageType = FlowStageReached;
							if ([stage.caption isEqualToString:NSLocalizedStringFromTable(@"Sent to SecState", @"DataTableUI", @"")]) {
								stage.caption = NSLocalizedStringFromTable(@"Voters Passed", @"DataTableUI", @"");
							}
							break;
						}				
					}				
			}
		}
	}

	return stages;
}	
@end

