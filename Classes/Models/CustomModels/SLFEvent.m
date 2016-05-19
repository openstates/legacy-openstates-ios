#import "SLFDataModels.h"
#import "SLFSortDescriptor.h"
#import "NSDate+SLFDateHelper.h"
#import "SLFEventsManager.h"
#import <SLFRestKit/RestKit.h>
#import <SLFRestKit/CoreData.h>
#import <EventKit/EventKit.h>

@implementation SLFEvent

+ (RKManagedObjectMapping *)mapping {
    RKManagedObjectMapping *mapping = [RKManagedObjectMapping mappingForClass:[self class] inManagedObjectStore:[RKObjectManager sharedManager].objectStore];
    mapping.primaryKeyAttribute = @"eventID";
    [mapping mapKeyPath:@"id" toAttribute:@"eventID"];
    [mapping mapKeyPath:@"state" toAttribute:@"stateID"];
    [mapping mapKeyPath:@"updated_at" toAttribute:@"dateUpdated"];
    [mapping mapKeyPath:@"created_at" toAttribute:@"dateCreated"];
    [mapping mapKeyPath:@"when" toAttribute:@"dateStart"];
    [mapping mapKeyPath:@"end" toAttribute:@"dateEnd"];
    [mapping mapKeyPath:@"timezone" toAttribute:@"timezone"];
    [mapping mapKeyPath:@"description" toAttribute:@"eventDescription"];
    [mapping mapKeyPath:@"link" toAttribute:@"link"];
    [mapping mapKeyPath:@"status" toAttribute:@"status"];
    [mapping mapKeyPath:@"notes" toAttribute:@"notes"];
    [mapping mapAttributes:@"session", @"type", @"location",  nil];
    return mapping;
}

+ (RKManagedObjectMapping *)mappingWithStateMapping:(RKManagedObjectMapping *)stateMapping {
    RKManagedObjectMapping *mapping = [[self class] mapping];
    [mapping connectStateToKeyPath:@"stateObj" withStateMapping:stateMapping];
    return mapping;
}

    // This is here because the JSON data has a keyPath "state" that conflicts with our core data relationship.
- (SLFState *)state {
    return self.stateObj;
}

+ (NSArray*)searchableAttributes {
    return [NSArray arrayWithObjects:@"eventDescription", @"location", @"notes", @"dayForDisplay", nil];
}

+ (NSArray *)sortDescriptors {
    NSSortDescriptor *dateDesc = [NSSortDescriptor sortDescriptorWithKey:@"dateStart" ascending:YES];
    NSSortDescriptor *nameDesc = [SLFSortDescriptor stringSortDescriptorWithKey:@"eventDescription" ascending:YES];
    NSSortDescriptor *locationDesc = [SLFSortDescriptor stringSortDescriptorWithKey:@"location" ascending:YES];
    return [NSArray arrayWithObjects:dateDesc, nameDesc, locationDesc, nil];
}

- (NSTimeZone *)eventTimeZone {
    if (self.timezone) {
        return [NSTimeZone timeZoneWithName:self.timezone];
    }
    return [NSTimeZone defaultTimeZone];
}

- (NSString *)dateStartForDisplay {
    return [self.dateStart stringWithLocalizationTemplate:@"MMMdhma z" timezone:[self eventTimeZone]];
}

- (NSString *)timeStartForDisplay {
    return [self.dateStart stringWithLocalizationTemplate:@"hma z" timezone:[self eventTimeZone]];
}

- (NSString *)dayForDisplay {
    return [self.dateStart stringWithLocalizationTemplate:@"MMMMdyyyy"];
}

- (NSString *)title {
    NSString *title = [self.eventDescription stringByReplacingOccurrencesOfString:@"Committee Meeting\n" withString:@""];
    if (SLFTypeNonEmptyStringOrNil(self.status))
        title = [title stringByAppendingFormat:@" (%@)", [self.status capitalizedString]];
    return title;
}

- (EKEvent *)ekEvent {
    SLFEventsManager *eventManager = [SLFEventsManager sharedManager];
    if (!self.dateStart || [self.dateStart equalsDefaultDate])
        return nil;
    EKEvent *event = nil;
    @try {
        event = [eventManager findOrCreateEventWithIdentifier:self.ekEventIdentifier];
        event.title = self.title;
        event.location = self.location;
        if (SLFTypeNonEmptyStringOrNil(self.notes))
            event.notes = self.notes;
        if (SLFTypeNonEmptyStringOrNil(self.link) && [event respondsToSelector:@selector(setURL:)])
            [event performSelector:@selector(setURL:) withObject:[NSURL URLWithString:self.link]];
        event.startDate = self.dateStart;
        if (!self.dateEnd) {
            event.endDate = [NSDate dateWithTimeInterval:SLF_HOURS_TO_SECONDS(1) sinceDate:self.dateStart];
            event.notes = NSLocalizedString(@"No end time was specified, so the default event duration is 1 hour.", @"");
        }
        self.ekEventIdentifier = event.eventIdentifier; // This may or may not be the appropriate time to do this.
    }
    @catch (NSException *exception) {
        RKLogError(@"There was an error while attempting to create an EKEvent from %@", [self description]);
    }

    return event;
}
@end
