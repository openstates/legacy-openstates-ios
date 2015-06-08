//
//  SLFStandardGroupCell.h
//  Created by Gregory Combs on 8/29/10.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "SLFTableCellProtocol.h"

@class TableCellDataObject;
@interface SLFStandardGroupCell : UITableViewCell <SLFTableCellProtocol> {
}
+ (SLFStandardGroupCell *)standardCellWithIdentifier:(NSString *)cellIdentifier;

@end
