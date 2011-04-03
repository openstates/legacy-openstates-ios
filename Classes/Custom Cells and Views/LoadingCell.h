//
//  LoadingCell.h
//  TexLege
//
//  Created by Gregory Combs on 4/3/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
	LOADING_IDLE = 0,
	LOADING_ACTIVE,
	LOADING_NO_NET
} LoadingStatusCodes;


@interface LoadingCell : UITableViewCell {

}

+ (LoadingCell *)loadingCellWithStatus:(NSInteger)loadingStatus tableView:(UITableView *)tableView;

@end
