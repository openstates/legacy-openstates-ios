//
//  WnomObj.h
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

@class LegislatorObj;

@interface WnomObj :  RKManagedObject  
{
}

@property (nonatomic, retain) NSNumber * adjMean;
@property (nonatomic, retain) NSNumber * wnomID;
@property (nonatomic, retain) NSNumber * legislatorID;
@property (nonatomic, retain) NSString * updated;
@property (nonatomic, retain) NSNumber * wnomAdj;
@property (nonatomic, retain) NSNumber * session;
@property (nonatomic, retain) NSNumber * wnomStderr;
@property (nonatomic, retain) LegislatorObj * legislator;

@end



