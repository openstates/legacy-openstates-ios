//
//  CommitteePositionObj.h
//  Created by Gregory Combs on 1/22/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>

@class CommitteeObj;
@class LegislatorObj;

@interface CommitteePositionObj :  RKManagedObject  
{
}

@property (nonatomic, retain) NSString * updated;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSNumber * legislatorID;
@property (nonatomic, retain) NSNumber * committeePositionID;
@property (nonatomic, retain) NSNumber * committeeId;
@property (nonatomic, retain) CommitteeObj * committee;
@property (nonatomic, retain) LegislatorObj * legislator;

@end



