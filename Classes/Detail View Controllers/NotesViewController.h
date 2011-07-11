//
//  NotesViewController.h
//  Created by Gregory Combs on 7/22/09.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//


#define kStaticNotes NSLocalizedStringFromTable(@"Notes", @"DataTableUI", @"Default entry for a custom notes field.")

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
