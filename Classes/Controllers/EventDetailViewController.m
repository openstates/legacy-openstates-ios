//
//  EventDetailViewController.m
//  Created by Gregory Combs on 7/31/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "EventDetailViewController.h"
#import "SLFDataModels.h"
#import "SLFRestKitManager.h"

@interface EventDetailViewController()
- (void)loadDataFromDataStoreWithID:(NSString *)objID;
@end

@implementation EventDetailViewController
@synthesize resourcePath;
@synthesize resourceClass;
@synthesize event;

- (id)initWithEventID:(NSString *)objID {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.resourceClass = [SLFEvent class];
        self.resourcePath = [NSString stringWithFormat:@"/events/%@", objID];
        [self loadDataFromDataStoreWithID:objID];
        [self loadData];
    }
    return self;
}

- (void)loadView {
    [super loadView];
	self.title = NSLocalizedString(@"Loading...", @"");
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadButtonWasPressed:)] autorelease];
}

- (void)dealloc {
    [[RKObjectManager sharedManager].requestQueue cancelRequestsWithDelegate:self];
	self.event = nil;
    self.resourcePath = nil;
    [super dealloc];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)reloadButtonWasPressed:(id)sender {
	[self loadData];
}

- (void)loadDataFromDataStoreWithID:(NSString *)objID {
	self.event = [SLFEvent findFirstByAttribute:@"eventID" withValue:objID];
}

- (void)loadData {
	if (self.resourcePath == NULL)
		return;	
	NSDictionary *queryParameters = [NSDictionary dictionaryWithObject:SUNLIGHT_APIKEY forKey:@"apikey"];
	NSString *pathToLoad = [self.resourcePath appendQueryParams:queryParameters];
    [[SLFRestKitManager sharedRestKit] loadObjectsAtResourcePath:pathToLoad delegate:self];
}

- (void)setEvent:(SLFEvent *)newObj {
	if (event)
        [event release];
	event = [newObj retain];
	if (newObj) {
		self.title = [NSString stringWithFormat:@"%@", newObj.dateStart];
        self.resourcePath = RKMakePathWithObject(@"/events/:eventID", newObj);
		[self loadData];
	}
}

#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObject:(id)object {
	[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"LastUpdatedAt"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	if (event)
        [event release];
	event = [object retain];
    self.title = [NSString stringWithFormat:@"%@", event.dateStart];
    if ([self isViewLoaded])
        [self.tableView reloadData];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
	UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:@"Error" 
                                                     message:[error localizedDescription] 
                                                    delegate:nil 
                                           cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
	[alert show];
	NSLog(@"Hit error: %@", error);
}


#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	if (self.event)
		return 1;
	return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSDate* lastUpdatedAt = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastUpdatedAt"];
	NSString* dateString = [NSDateFormatter localizedStringFromDate:lastUpdatedAt dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterMediumStyle];
	if (nil == dateString) {
		dateString = @"Never";
	}
	return [NSString stringWithFormat:@"Last Load: %@", dateString];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString* reuseIdentifier = @"Cell";
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (nil == cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier] autorelease];
		cell.textLabel.numberOfLines = 0;
	}
	if (self.event) {
        cell.textLabel.text = self.event.eventDescription;
        cell.detailTextLabel.text = [self.event.dateStart description];
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];	
}

@end
