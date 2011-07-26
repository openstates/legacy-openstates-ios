//
//  MultiSelectCellController.h
//  MultiRowSelect
//
//  Created by Matt Gallagher on 11/01/09.
//  Copyright 2008 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <UIKit/UIKit.h>
#import "CellController.h"

@interface MultiSelectCellController : NSObject <CellController>
{
}

- (id)initWithLabel:(NSString *)newLabel;
- (void)clearSelectionForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@property (nonatomic,copy)      NSString *label;
@property (nonatomic)           BOOL selected;
@property (nonatomic,retain)    NSDictionary *dataObject;

@end
