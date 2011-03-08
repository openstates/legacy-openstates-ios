//
//  NotesViewController.h
//  TexLege
//
//  Created by Gregory Combs on 7/22/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//


#define kStaticNotes @"Notes"

@class LegislatorObj;

@interface NotesViewController : UIViewController {
	IBOutlet UITextView *notesText;
	IBOutlet UILabel *nameLabel;
	IBOutlet UINavigationItem *navTitle;
	IBOutlet UINavigationBar *navBar;
	UITableViewController *backViewController;
}
@property (nonatomic, retain) NSNumber *dataObjectID;
@property (nonatomic, assign) LegislatorObj *legislator;
@property (nonatomic, retain) IBOutlet UITextView *notesText;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UINavigationItem *navTitle;
@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;

@property (nonatomic, assign) UITableViewController *backViewController;

@end
