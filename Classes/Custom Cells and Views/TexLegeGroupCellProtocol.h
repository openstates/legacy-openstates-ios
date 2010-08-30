//
//  TexLegeGroupCellProtocol.h
//  TexLege
//
//  Created by Gregory Combs on 8/29/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DirectoryDetailInfo.h"

@protocol TexLegeGroupCellProtocol

@required
+ (UITableViewCellStyle)cellStyle;
+ (NSString*)cellIdentifier;
@property (nonatomic,retain) DirectoryDetailInfo *cellInfo;

@end

