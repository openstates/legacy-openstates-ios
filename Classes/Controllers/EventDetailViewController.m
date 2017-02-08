//
//  EventDetailViewController.m
//  Created by Gregory Combs on 7/31/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "EventDetailViewController.h"
#import "SLFDataModels.h"
#import "SLFTheme.h"
#import "SLFMappingsManager.h"
#import "SLFRestKitManager.h"
#import "SLFReachable.h"
#import "NSDate+SLFDateHelper.h"
#import "SLFEventsManager.h"
#import "GenericDetailHeader.h"
#import "SLFLog.h"

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
        os_log_debug([SLFLog common], "Loading events from: %{public}s", resourcePath);
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
    self.screenName = @"Event Detail Screen";
}

- (void)configureTableController {
    self.tableController = [SLFImprovedRKTableController tableControllerForTableViewController:(UITableViewController*)self];
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
    __weak __typeof__(self) bself = self;
    RKTableSection *headerSection = [RKTableSection sectionUsingBlock:^(RKTableSection *section) {
        GenericDetailHeader *header = [[GenericDetailHeader alloc] initWithFrame:CGRectMake(0, 0, bself.tableView.width, 100)];
        section.headerTitle = @"";
        header.title = bself.event.title;
        if (SLFTypeNonEmptyStringOrNil(bself.event.type))
            header.subtitle = [[bself.event.type stringByReplacingOccurrencesOfString:@":" withString:@" "] capitalizedString];
        header.detail = bself.event.dateStartForDisplay;
        [header configure];
        section.headerHeight = header.height;
        section.headerView = header;
    }];
    [_tableController addSection:headerSection];
}

- (StyledCellMapping *)eventTableCellMapUsingSelectable:(BOOL)isSelectable {
    StyledCellMapping *cellMapping = [StyledCellMapping cellMapping];
    cellMapping.style = UITableViewCellStyleValue2;
    cellMapping.isSelectableCell = isSelectable;
    cellMapping.useAlternatingRowColors = NO;
    cellMapping.detailTextColor = [SLFAppearance cellTextColor];
    cellMapping.detailTextFont = SLFFont(14);
    cellMapping.textColor = [SLFAppearance cellSecondaryTextColor];
    cellMapping.textFont = SLFFont(12);
    return cellMapping;
}

- (void)configureEventInfo {
    __weak __typeof__(self) bself = self;
    @try {
        StyledCellMapping *cellMapping = [StyledCellMapping cellMapping];
        [bself.tableView registerClass:cellMapping.cellClass forCellReuseIdentifier:cellMapping.reuseIdentifier];
    }
    @catch (NSException *exception) {
    }
    NSMutableArray* tableItems  = [[NSMutableArray alloc] init];
    [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem* tableItem) {
        tableItem.cellMapping = [bself eventTableCellMapUsingSelectable:NO];
        tableItem.detailText = bself.event.location;
        tableItem.text = NSLocalizedString(@"Location",@"");
    }]];
    [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem* tableItem) {
        tableItem.cellMapping = [bself eventTableCellMapUsingSelectable:NO];
        tableItem.detailText = bself.event.dateStartForDisplay;
        tableItem.text = NSLocalizedString(@"Starts At",@"");
    }]];
    if (_event.dateEnd) {
        [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem* tableItem) {
            tableItem.cellMapping = [bself eventTableCellMapUsingSelectable:NO];
            tableItem.detailText = [bself.event.dateEnd stringWithDateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
            tableItem.text = NSLocalizedString(@"Ends At",@"");
        }]];
    }
    SLFAddTableControllerSectionWithTitle(_tableController, NSLocalizedString(@"Event Details", @""));
    NSUInteger sectionIndex = _tableController.sectionCount-1;
    [_tableController loadTableItems:tableItems inSection:sectionIndex];
}

- (void)configureAdditional {
    NSMutableArray *tableItems = [[NSMutableArray alloc] init];
    if (SLFTypeNonEmptyStringOrNil(_event.link))
        [tableItems addObject:[self webPageItemWithTitle:NSLocalizedString(@"Link",@"") subtitle:_event.link url:_event.link]];
    for (GenericAsset *source in _event.sources) {
        NSString *subtitle = source.name;
        if (!SLFTypeNonEmptyStringOrNil(subtitle))
            subtitle = source.url;
        [tableItems addObject:[self webPageItemWithTitle:NSLocalizedString(@"Web Resource", @"") subtitle:subtitle url:source.url]];
    }
    SLFAddTableControllerSectionWithTitle(_tableController, NSLocalizedString(@"Additional Info", @""));
    NSUInteger sectionIndex = _tableController.sectionCount-1;
    [_tableController loadTableItems:tableItems inSection:sectionIndex];
}

- (void)configureNotifications {
    NSMutableArray *tableItems = [[NSMutableArray alloc] init];
    __weak __typeof__(self) wSelf = self;
    [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem* tableItem) {
        __strong __typeof__(wSelf) sSelf = wSelf;

        tableItem.text = NSLocalizedString(@"iCal", @"");
        tableItem.detailText = NSLocalizedString(@"Schedule in Calendar",@"");
        StyledCellMapping *cellMapping = [sSelf eventTableCellMapUsingSelectable:YES];
        tableItem.cellMapping = cellMapping;

        __weak __typeof__(sSelf) wSelf = sSelf;

        cellMapping.onSelectCell = ^(void) {
            if (!wSelf)
                return;
            __strong __typeof__(wSelf) sSelf = wSelf;

            EKEvent *ekEvent = sSelf.event.ekEvent;
            if (!ekEvent)
                return;
            [[SLFEventsManager sharedManager] presentEventEditorForEvent:ekEvent fromParent:sSelf];
        };
    }]];
    if (SLFIsIOS5OrGreater()) {
        [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem* tableItem) {
            __strong __typeof__(wSelf) sSelf = wSelf;

            SLFEventsManager *eventManager = [SLFEventsManager sharedManager];
            tableItem.detailText = [eventManager eventCalendar].title;
            tableItem.text = NSLocalizedString(@"Calendar",@"");
            StyledCellMapping *cellMapping = [sSelf eventTableCellMapUsingSelectable:YES];
            tableItem.cellMapping = cellMapping;

            __weak __typeof__(sSelf) wSelf = sSelf;
            cellMapping.onSelectCell = ^(void) {
                if (!wSelf)
                    return;
                [eventManager presentCalendarChooserFromParent:wSelf];
            };
        }]];
    }
    [tableItems addObject:[RKTableItem tableItemUsingBlock:^(RKTableItem* tableItem) {
        __strong __typeof__(wSelf) sSelf = wSelf;

        tableItem.detailText = [NSString stringWithFormat:NSLocalizedString(@"Subscribe to all %@ events", @""), [sSelf.event.stateID uppercaseString]];
        tableItem.text = NSLocalizedString(@"Feed", @"");
        StyledCellMapping *cellMapping = [sSelf eventTableCellMapUsingSelectable:YES];
        tableItem.cellMapping = cellMapping;

        __weak __typeof__(sSelf) wSelf = sSelf;

        cellMapping.onSelectCell = ^(void) {
            NSString *feedAddress = wSelf.event.stateObj.eventsFeedAddress;
            NSURL *subscriptionURL = [NSURL URLWithString:feedAddress];
            if ([[SLFReachable sharedReachable] isURLReachable:subscriptionURL] && ([[UIApplication sharedApplication] canOpenURL:subscriptionURL]))
                [[UIApplication sharedApplication] openURL:subscriptionURL];
        };
    }]];
    SLFAddTableControllerSectionWithTitle(_tableController, NSLocalizedString(@"Event Alerts", @""));
    NSUInteger sectionIndex = _tableController.sectionCount-1;
    [_tableController loadTableItems:tableItems inSection:sectionIndex];
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
    StyledCellMapping *cellMapping = [self eventTableCellMapUsingSelectable:NO];
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
