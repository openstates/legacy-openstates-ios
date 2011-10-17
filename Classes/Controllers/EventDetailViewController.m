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
#import "MapViewController.h"
#import "AppDelegate.h"

@interface EventDetailViewController()
- (void)loadDataFromDataStoreWithID:(NSString *)objID;
@end

@implementation EventDetailViewController
@synthesize resourcePath;
@synthesize resourceClass;
@synthesize event;

- (id)initWithEventID:(NSString *)objID {
    self = [super init];
    if (self) {
        self.stackWidth = 500;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 65;
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
	NSString* reuseIdentifier = @"EventCell";
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
	if (nil == cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier] autorelease];
		cell.textLabel.numberOfLines = 0;
        cell.detailTextLabel.numberOfLines = 0;
        cell.textLabel.textColor = [SLFAppearance cellTextColor];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        UIFont *labelFont = [[SLFAppearance boldTen] fontWithSize:8];
        cell.detailTextLabel.font = labelFont;
        cell.textLabel.font = labelFont;
	}
	if (self.event) {
        cell.textLabel.text = self.event.eventDescription;
        cell.detailTextLabel.text = [self.event.dateStart description];
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];	
    MapViewController *vc = [[MapViewController alloc] initWithNibName:nil bundle:nil];
    [self stackOrPushViewController:vc];
    [vc release];
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section {
    return 26;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *aTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (!aTitle)
        return nil;
    CGFloat headerHeight = [self tableView:tableView heightForHeaderInSection:section];
    CGRect sectionFrame = CGRectMake(10, 6, tableView.width - 10, headerHeight-10);
    UILabel *label = [[UILabel alloc] initWithFrame:sectionFrame];
    label.textColor = [SLFAppearance tableSectionColor];
    label.shadowOffset = CGSizeMake(0, 1);
    label.shadowColor = [[UIColor whiteColor] colorWithAlphaComponent:.7];
    label.backgroundColor = [UIColor clearColor];
    label.font = [SLFAppearance boldFifteen];
    label.text = aTitle;
    
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, headerHeight)];
    sectionView.backgroundColor = [UIColor clearColor];
    [sectionView addSubview:label];
    [label release];
    return [sectionView autorelease];
}

@end
