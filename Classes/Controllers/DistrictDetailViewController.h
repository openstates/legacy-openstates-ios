//
//  DistrictDetailViewController.h
//  Created by Gregory Combs on 7/31/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <RestKit/RestKit.h>
#import "MapViewController.h"

@class SLFDistrict;
@interface DistrictDetailViewController : MapViewController <RKObjectLoaderDelegate, SLFPerstentActionsProtocol>

@property (nonatomic,retain) SLFDistrict *upperDistrict;
@property (nonatomic,retain) SLFDistrict *lowerDistrict;
@property (nonatomic,assign) Class resourceClass;

- (id)initWithDistrictMapID:(NSString *)objID;
@end
