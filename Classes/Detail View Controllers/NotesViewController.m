//
//  NotesViewController.m
//  TexLege
//
//  Created by Gregory Combs on 7/22/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import "NotesViewController.h"
#import "LegislatorObj.h"
#import "UtilityMethods.h"
#import "TexLegeTheme.h"
#import "LocalyticsSession.h"

@implementation NotesViewController

@synthesize legislator, notesText, nameLabel;
@synthesize backView, navBar, navTitle;


- (void)viewDidLoad {
	[super viewDidLoad];
	if ([UtilityMethods isIPadDevice]) {
		self.navBar.tintColor = [TexLegeTheme accent];
		self.navTitle.rightBarButtonItem = self.editButtonItem;
		self.contentSizeForViewInPopover = CGSizeMake(320.f, 320.f);
	}
	else {
		self.navigationItem.title = @"Notes";
		self.navigationItem.rightBarButtonItem = self.editButtonItem;
	}
}

- (void)viewDidUnload {
	self.navBar = nil;
	self.navTitle = nil;
	self.legislator = nil;
	self.notesText = nil;
	[super viewDidUnload];
}



- (void)viewWillAppear:(BOOL)animated {   
	[super viewWillAppear:animated];
    // Update the views appropriately
    self.nameLabel.text = [legislator shortNameForButtons];    
	if (self.legislator.notes.length == 0) {
		self.notesText.text = kStaticNotes;
	}
	else
		self.notesText.text = self.legislator.notes;    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Support all orientations except upside-down
    return YES;
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {

    [super setEditing:editing animated:animated];

    self.notesText.editable = editing;
	[self.navigationItem setHidesBackButton:editing animated:YES];

	[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"EDITING_NOTES"];
	
	/*
	 If editing is finished, update the recipe's instructions and save the managed object context.
	 */
	if (!editing) {
		if (![self.notesText.text isEqualToString:kStaticNotes]) {
			self.legislator.notes = self.notesText.text;
		}
		
		NSManagedObjectContext *context = self.legislator.managedObjectContext;
		NSError *error = nil;
		if (![context save:&error]) {
			// Handle error
			debug_NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		}
		[self.backView reloadData];

	}		
}


- (void)dealloc {
    [legislator release];
    [notesText release];
    [nameLabel release];
	self.navTitle = nil;
	self.navBar = nil;
    [super dealloc];
}

@end
