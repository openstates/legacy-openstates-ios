//
//  NotesViewController.h
//  TexLege
//
//  Created by Gregory Combs on 7/22/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "Constants.h"

#define kStaticNotes @"Notes"

@class LegislatorObj;

@interface NotesViewController : UIViewController {
	UITableView *backView;

	@private
        LegislatorObj *legislator;
        UITextView *notesText;
        UILabel *nameLabel;
	
}

@property (nonatomic, retain) LegislatorObj *legislator;
@property (nonatomic, retain) IBOutlet UITextView *notesText;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;

@property (nonatomic, assign) UITableView *backView;

@end
