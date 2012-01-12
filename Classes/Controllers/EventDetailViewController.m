//
//  EventDetailViewController.m
//  Created by Gregory Combs on 7/31/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "EventDetailViewController.h"
#import "SLFDataModels.h"
#import "SLFTheme.h"
#import "SLFMappingsManager.h"
#import "SLFRestKitManager.h"
#import "SLFReachable.h"
#import "SVWebViewController.h"
#import "NSDate+SLFDateHelper.h"
#import "SLFEventsManager.h"
#import "GenericDetailHeader.h"

@interface EventDetailViewController()
- (void)reconfigureForEvent:(SLFEvent *)event;
- (void)configureTableController;
- (void)configureTableItems;
- (void)configureTableHeader;
- (void)configureEventInfo;
- (void)configureParticipants;
- (void)configureAdditional;
- (void)configureNotifications;
- (RKTableViewCellMapping *)participantCellMap;
@end

@implementation EventDetailViewController
@synthesize event = _event;
@synthesize tableController = _tableController;

- (id)initWithResourcePath:(NSString *)resourcePath {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.stackWidth = 500;
        RKLogDebug(@"Loading resource path for event: %@", resourcePath);
        [[SLFRestKitManager sharedRestKit] loadObjectsAtResourcePath:resourcePath delegate:self withTimeout:SLF_HOURS_TO_SECONDS(1)];
    }
    return self;
}

- (id)initWithEventID:(NSString *)eventID {
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:SUNLIGHT_APIKEY,@"apikey", eventID, @"eventID", nil];
    NSString *resourcePath = RKMakePathWithObject(@"/events/:eventID?apikey=:apikey", queryParams);
    self = [self initWithResourcePath:resourcePath];
    return self;
}

- (id)initWithEvent:(SLFEvent *)event {
    self = [self initWithEventID:event.eventID];
    if (self) {
        self.event = event;
    }
    return self;
}

- (void)dealloc {
    [[RKObjectManager sharedManager].requestQueue cancelRequestsWithDelegate:self];
	self.event = nil;
    self.tableController = nil;
    [super dealloc];
}

- (void)viewDidUnload {
    [[RKObjectManager sharedManager].requestQueue cancelRequestsWithDelegate:self];
    self.tableController = nil;
    [super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureTableController];
	self.title = NSLocalizedString(@"Loading...", @"");
}

- (void)configureTableController {
    self.tableController = [RKTableController tableControllerForTableViewController:(UITableViewController*)self];
    _tableController.delegate = self;
    _tableController.variableHeightRows = YES;
    _tableController.objectManager = [RKObjectManager sharedManager];
    _tableController.pullToRefreshEnabled = NO;
    [_tableController mapObjectsWithClass:[EventParticipant class] toTableCellsWithMapping:[self participantCellMap]];
}

- (NSString *)actionPath {
    return [[self class] actionPathForObject:self.event];
}

- (void)reconfigureForEvent:(SLFEvent *)event {
    self.event = event;
    if (!event || !self.tableController)
        return;
    self.title = event.title;
    [self configureTableItems];
}

- (void)configureTableItems {
    [_tableController removeAllSections:NO];
    [self configureTableHeader];
    [self configureEventInfo];     
    [self configureParticipants];
    [self configureAdditional];
    [self configureNotifications];
}

- (void)configureTableHeader {
    __block __typeof__(self) bself = self;
    RKTableSection *headerSection = [RKTableSection sectionUsingBlock:^(RKTableSection *section) {
        GenericDetailHeader *header = [[GenericDetailHeader alloc] initWithFrame:CGRectMake(0, 0, bself.tableView.width, 100)];
        section.headerTitle = @"";
        header.title = bself.event.title;
        if (!IsEmpty(bself.event.type))
            header.subtitle = [[bself.event.type stringByReplacingOccurrencesOfString:@":" withString:@" "] capitalizedString];
        header.detail = bself.event.dateStartForDisplay;
        [header configure];
        section.headerHeight = header.height;
        section.headerView = header;
        [header release];
    }];
    [_tableController addSection:headerSection];
}

- (RKTableViewCellMapping *)eventTableCellMap {
    StaticSubtitleCellMapping *cellMapping = [StaticSubtitleCellMapping cellMapping];
    cellMapping.style = UITableViewCellStyleValue2;
    cellMapping.onCellWillAppearForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath* indexPath) {
        cell.detailTextLabel.textColor = [SLFAppearance cellTextColor];
        cell.detailTextLabel.font = SLFFont(14);
        cell.textLabel.textColor = [SLFAppearance cellSecondaryTextColor];
        cell.textLabel.font = SLFFont(12);
        SLFAlternateCellForIndexPath(cell, indexPath);
        cell.detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
    };
    return cellMapping;
}

- (void)configureEventInfo {
    RKTableViewCellMapping *cellMapping = [self eventTableCellMap];
    __block __typeof__(self) bself = self;
    NSMutableArray* tableItems  = [[NSMutableArray alloc] init];
    [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem* tableItem) {
        tableItem.cellMapping = cellMapping;
        tableItem.detailText = bself.event.location;
        tableItem.text = NSLocalizedString(@"Location",@"");
    }]];
    [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem* tableItem) {
        tableItem.cellMapping = cellMapping;
        tableItem.detailText = bself.event.dateStartForDisplay;
        tableItem.text = NSLocalizedString(@"Starts At",@"");
    }]];
    if (_event.dateEnd) {
        [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem* tableItem) {
            tableItem.cellMapping = cellMapping;
            tableItem.detailText = [bself.event.dateEnd stringWithDateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
            tableItem.text = NSLocalizedString(@"Ends At",@"");
        }]];
    }
    SLFAddTableControllerSectionWithTitle(_tableController, NSLocalizedString(@"Event Details", @""));
    NSUInteger sectionIndex = _tableController.sectionCount-1;
    [_tableController loadTableItems:tableItems inSection:sectionIndex];
    [tableItems release];
}

- (void)configureAdditional {
    NSMutableArray *tableItems = [[NSMutableArray alloc] init];
    if (!IsEmpty(_event.link))
        [tableItems addObject:[self webPageItemWithTitle:@"Link" subtitle:_event.link url:_event.link]];
    for (GenericAsset *source in _event.sources) {
        NSString *subtitle = source.name;
        if (IsEmpty(subtitle))
            subtitle = source.url;
        [tableItems addObject:[self webPageItemWithTitle:NSLocalizedString(@"Web Resource", @"") subtitle:subtitle url:source.url]];
    }
    SLFAddTableControllerSectionWithTitle(_tableController, NSLocalizedString(@"Additional Info", @""));
    NSUInteger sectionIndex = _tableController.sectionCount-1;
    [_tableController loadTableItems:tableItems inSection:sectionIndex];
    [tableItems release];
}

- (void)configureNotifications {
    NSMutableArray *tableItems = [[NSMutableArray alloc] init];
    __block __typeof__(self) bself = self;
    [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem* tableItem) {
        tableItem.text = NSLocalizedString(@"iCal", @"");
        tableItem.detailText = NSLocalizedString(@"Schedule this event in Calendar",@"");
        RKTableViewCellMapping *cellMapping = [bself eventTableCellMap];
        tableItem.cellMapping = cellMapping;
        cellMapping.selectionStyle = UITableViewCellSelectionStyleBlue;
        cellMapping.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cellMapping.onSelectCell = ^(void) {
            EKEvent *ekEvent = bself.event.ekEvent;
            if (!ekEvent)
                return;
            [[SLFEventsManager sharedManager] presentEventEditorForEvent:ekEvent fromParent:bself];
        };
    }]];
    if (SLFIsIOS5OrGreater()) {
        [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem* tableItem) {
            SLFEventsManager *eventManager = [SLFEventsManager sharedManager];
            tableItem.detailText = [eventManager eventCalendar].title;
            tableItem.text = NSLocalizedString(@"Calendar",@"");
            RKTableViewCellMapping *cellMapping = [bself eventTableCellMap];
            tableItem.cellMapping = cellMapping;
            if (!SLFIsIOS5OrGreater())
                return;
            cellMapping.selectionStyle = UITableViewCellSelectionStyleBlue;
            cellMapping.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cellMapping.onSelectCell = ^(void) {
                [eventManager presentCalendarChooserFromParent:bself];
            };
        }]];
    }
    [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem* tableItem) {
        tableItem.detailText = [NSString stringWithFormat:NSLocalizedString(@"Subscribe to all %@ events", @""), bself.event.stateObj.name];
        tableItem.text = NSLocalizedString(@"ICS Feed", @"");
        RKTableViewCellMapping *cellMapping = [bself eventTableCellMap];
        tableItem.cellMapping = cellMapping;
        cellMapping.selectionStyle = UITableViewCellSelectionStyleBlue;
        cellMapping.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cellMapping.onSelectCell = ^(void) {
            NSString *feedAddress = bself.event.stateObj.eventsFeedAddress;
            NSURL *subscriptionURL = [NSURL URLWithString:feedAddress];
            if ([[SLFReachable sharedReachable] isURLReachable:subscriptionURL] && ([[UIApplication sharedApplication] canOpenURL:subscriptionURL]))
                [[UIApplication sharedApplication] openURL:subscriptionURL];
        };
    }]];
    SLFAddTableControllerSectionWithTitle(_tableController, NSLocalizedString(@"Event Alerts", @""));
    NSUInteger sectionIndex = _tableController.sectionCount-1;
    [_tableController loadTableItems:tableItems inSection:sectionIndex];
    [tableItems release];
}

- (void)calendarDidChange:(EKCalendar *)calendar {
    [self configureTableItems];
    [self.tableView reloadData];
}

- (void)eventWasEdited:(EKEvent *)event {
    if (event)
        self.event.ekEventIdentifier = event.eventIdentifier;
}

- (void)configureParticipants {
    SLFAddTableControllerSectionWithTitle(_tableController, NSLocalizedString(@"Participants", @""));
    NSUInteger sectionIndex = _tableController.sectionCount-1;
    [_tableController loadObjects:_event.participants.allObjects inSection:sectionIndex];    
}

- (RKTableViewCellMapping *)participantCellMap {
    RKTableViewCellMapping *cellMapping = [self eventTableCellMap];
    [cellMapping mapKeyPath:@"type" toAttribute:@"textLabel.text"];
    [cellMapping mapKeyPath:@"name" toAttribute:@"detailTextLabel.text"];
    return cellMapping;
}

#pragma mark - Object Loader

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
    self.title = NSLocalizedString(@"Load Error", @"");
    [SLFRestKitManager showFailureAlertWithRequest:objectLoader error:error];
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObject:(id)object {
    SLFEvent *event = nil;
    if (object && [object isKindOfClass:[SLFEvent class]]) {
        event = object;
    }
    [self reconfigureForEvent:event];
}

@end
