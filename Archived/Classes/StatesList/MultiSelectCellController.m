//
//  MultiSelectCellController.m
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

#import "MultiSelectCellController.h"
#import "MultiSelectTableViewCell.h"
#import "TexLegeTheme.h"

@implementation MultiSelectCellController
@synthesize selected;
@synthesize label;
@synthesize dataObject;

//
// init
//
// Init method for the object.
//
- (id)initWithLabel:(NSString *)newLabel
{
	self = [super init];
	if (self != nil)
	{
		label = [newLabel copy];
	}
	return self;
}

//
// dealloc
//
// Releases instance memory.
//
- (void)dealloc
{
    self.label = nil;
    self.dataObject = nil;
	[super dealloc];
}

//
// clearSelectionForTableView:
//
// Clears the selection for the given table
//
- (void)clearSelectionForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
	if (selected)
	{
		[self tableView:tableView didSelectRowAtIndexPath:indexPath];
		selected = NO;
	}
}

//
// tableView:didSelectRowAtIndexPath:
//
// Marks the current row if editing is enabled.
//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
	if (tableView.isEditing)
	{
		selected = !selected;
				
        NSIndexPath *cellIndex = nil;
        MultiSelectTableViewCell *cell = nil;
        
        if ([tableView.delegate respondsToSelector:@selector(indexPathForCellController:)])
            cellIndex = [tableView.delegate performSelector:@selector(indexPathForCellController:) withObject:self];
        
        if (indexPath)
            cell = (MultiSelectTableViewCell *)[tableView cellForRowAtIndexPath:cellIndex];
		
		if (!cell)
			return;     // Stops here if the row is not visible
		
		if (selected)
		{
            UIImage *imageOn = [UIImage imageNamed:@"StarButtonGreen"];
            cell.accessoryView = [[[UIImageView alloc] initWithImage:imageOn] autorelease];
		}
		else
		{
            UIImage *imageOff = [UIImage imageNamed:@"StarButtonRim"];
            cell.accessoryView = [[[UIImageView alloc] initWithImage:imageOff] autorelease];
		}
	}
}

//
// tableView:cellForRowAtIndexPath:
//
// Constructs and configures the MultiSelectTableViewCell for this row.
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    BOOL useDark = (indexPath.row % 2 == 0);

    NSString *cellID = [NSString stringWithFormat:@"MultiSelectCell_%d", self.selected];
    
	MultiSelectTableViewCell *cell = (MultiSelectTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    
	if (!cell)
	{
        cell = [[[MultiSelectTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
        cell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                
		cell.detailTextLabel.font =			[TexLegeTheme boldTwelve];
		cell.textLabel.font =				[TexLegeTheme boldFifteen];
		cell.detailTextLabel.textColor = 	[TexLegeTheme indexText];
		cell.textLabel.textColor =			[TexLegeTheme textDark];
        
		cell.textLabel.adjustsFontSizeToFitWidth =	YES;
        
		cell.detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
		cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
		cell.detailTextLabel.minimumFontSize = 12.0f;
		
		//DisclosureQuartzView *qv = [[DisclosureQuartzView alloc] initWithFrame:CGRectMake(0.f, 0.f, 28.f, 28.f)];
		//cell.accessoryView = qv;
		//[qv release];
        

	}
    cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];        
    
	cell.textLabel.text = self.label;
	
    if ([tableView isEditing])
        cell.selectionStyle =UITableViewCellSelectionStyleNone;
    else
        cell.selectionStyle =UITableViewCellSelectionStyleBlue;
    
	if (selected)
	{
        UIImage *imageOn = [UIImage imageNamed:@"StarButtonGreen"];

        cell.accessoryView = [[[UIImageView alloc] initWithImage:imageOn] autorelease];

	}
	else
	{
        if ([tableView isEditing]) {
            UIImage *imageOff = [UIImage imageNamed:@"StarButtonRim"];
            cell.accessoryView = [[[UIImageView alloc] initWithImage:imageOff] autorelease];
        }
        else
            cell.accessoryView = nil;

	}
    

	
	return cell;
}

@end
