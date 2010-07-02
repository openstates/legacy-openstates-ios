//
//  NotesViewController.m
//  TexLege
//
//  Created by Gregory Combs on 7/22/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "NotesViewController.h"
#import "LegislatorObj.h"

@implementation NotesViewController

@synthesize legislator, notesText, nameLabel;
@synthesize backView;


- (void)viewDidLoad {
    UINavigationItem *navigationItem = self.navigationItem;
    navigationItem.title = @"Notes";
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)viewWillAppear:(BOOL)animated {    
    // Update the views appropriately
    nameLabel.text = [legislator shortNameForButtons];    
	if (legislator.notes.length == 0) {
		notesText.text = kStaticNotes;
	}
	else
		notesText.text = legislator.notes;    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Support all orientations except upside-down
    return YES;
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {

    [super setEditing:editing animated:animated];

    notesText.editable = editing;
	[self.navigationItem setHidesBackButton:editing animated:YES];

	/*
	 If editing is finished, update the recipe's instructions and save the managed object context.
	 */
	if (!editing) {
		if (![notesText.text isEqualToString:kStaticNotes]) {
			legislator.notes = notesText.text;
			[backView reloadData];
		}
		
		NSManagedObjectContext *context = legislator.managedObjectContext;
		NSError *error = nil;
		if (![context save:&error]) {
			// Handle error
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			exit(-1);  // Fail
		}
	}		
}


- (void)dealloc {
    [legislator release];
    [notesText release];
    [nameLabel release];
    [super dealloc];
}

@end
