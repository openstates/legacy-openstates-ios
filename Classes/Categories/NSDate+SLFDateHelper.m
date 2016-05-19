//
//  NSDate+SLFDateHelper.m
//  Created by Greg Combs on 11/16/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "NSDate+SLFDateHelper.h"

@interface SLFDateHelper : NSObject
@property (nonatomic, strong) NSDateFormatter *standardFormatter;
@property (nonatomic, strong) NSDateFormatter *usFormatter;
@property (nonatomic, strong) NSDateFormatter *localizedFormatter;
@property (nonatomic, strong) NSLocale *deviceLocale;
@property (nonatomic, strong) NSCalendar *deviceCalendar;
@property (nonatomic, strong) NSLocale *usLocale;
@property (nonatomic, strong) NSCalendar *usCalendar;
+ (SLFDateHelper *)sharedHelper;
@end

@implementation SLFDateHelper
@synthesize standardFormatter = _standardFormatter;
@synthesize usFormatter = _usFormatter;
@synthesize localizedFormatter = _localizedFormatter;
@synthesize deviceLocale = _deviceLocale;
@synthesize deviceCalendar = _deviceCalendar;
@synthesize usLocale = _usLocale;
@synthesize usCalendar = _usCalendar;

+ (id)sharedHelper
{
    static dispatch_once_t pred;
    static SLFDateHelper *foo = nil;
    dispatch_once(&pred, ^{ foo = [[self alloc] init]; });
    return foo;
}

- (id)init {
    self=[super init];
    if (self) {
        _usCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        _usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        self.deviceCalendar = [NSCalendar autoupdatingCurrentCalendar];
        self.deviceLocale = [NSLocale autoupdatingCurrentLocale];
        _standardFormatter = [[NSDateFormatter alloc] init];
        _usFormatter = [[NSDateFormatter alloc] init];
        _usFormatter.locale = _usLocale;
        _usFormatter.calendar = _usCalendar;
        _localizedFormatter = [[NSDateFormatter alloc] init];
        _localizedFormatter.locale = _deviceLocale;
        _localizedFormatter.calendar = _deviceCalendar;
    }
    return self;
}


@end

@implementation NSDate (SLFDateHelper)

#pragma mark - Comparison

- (BOOL)isEarlierThanDate:(NSDate *)laterDate {
    return ([self compare:laterDate] == NSOrderedAscending); // increasing between now and later
}

- (BOOL)isLaterThanDate:(NSDate *)earlierDate {
    return ([self compare:earlierDate] == NSOrderedDescending); // decreasing between now and earlier
}

 - (BOOL)equalsDefaultDate {
    NSDateFormatter *formatter = [[SLFDateHelper sharedHelper] standardFormatter];
    BOOL equals = [self isEqualToDate:[formatter defaultDate]];
    return equals;
}

#pragma mark - User Friendly Presentation

- (NSString *)localWeekdayString {
    NSDateFormatter *formatter = [SLFDateHelper sharedHelper].localizedFormatter;
    [formatter setDateFormat:@"EEEE"];
    return [formatter stringFromDate:self];    
}

- (NSString *)stringDaysAgo {
    return [self stringDaysAgoAgainstMidnight:YES];
}

- (NSString *)stringDaysAgoAgainstMidnight:(BOOL)usingMidnight {
    NSUInteger daysAgo = (usingMidnight) ? [self daysAgoAgainstMidnight] : [self daysAgo];
        // Should really use doesRelativeDateFormatting whenever possible...
    NSString *text = nil;
    switch (daysAgo) {
        case 0:
            text = NSLocalizedString(@"Today",@"");
            break;
        case 1:
            text = NSLocalizedString(@"Yesterday",@"");
            break;
        default:
            text = [NSString stringWithFormat:NSLocalizedString(@"%d days ago",@""), daysAgo];
    }
    return text;
}

- (NSString *)stringForDisplayWithPrefix:(BOOL)prefixed {
    /* 
     * if the date is today, display 12-hour time with meridian,
     * if it is within the last 7 days, display weekday name (Friday)
     * if within the calendar year, display as Jan 23
     * else display as Nov 11, 2008
     */
    
    NSDateFormatter *formatter = [[SLFDateHelper sharedHelper] localizedFormatter];
    NSCalendar *calendar = formatter.calendar;
    NSDate *today = [NSDate date];
    NSDateComponents *offsetComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:today];
    NSDate *midnight = [calendar dateFromComponents:offsetComponents];
    NSString *prefix = nil;
    NSString *template = nil;
    NSString *dateFormat = nil;
        
    if ([self compare:midnight] == NSOrderedDescending) {
        template = @"hmma";
        if (prefixed)
            prefix = NSLocalizedString(@"'at' ", @"Prefix for time (at 11:30pm)");
    } else {
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay:-7];
        NSDate *lastweek = [calendar dateByAddingComponents:componentsToSubtract toDate:today options:0];
        if ([self compare:lastweek] == NSOrderedDescending)
            template = @"EEEE";  // Tuesday
        else {
            NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self];
            NSInteger thisYear = [offsetComponents year];
            NSInteger thatYear = [dateComponents year];            
            if (thatYear == thisYear)
                template = @"MMMd";
            else
                template = @"MMMdyyyy";
        }
        if (prefixed)
            prefix = NSLocalizedString(@"'on' ",@"Prefix for date (on Sept. 11)");
    }
    dateFormat = [NSDateFormatter dateFormatFromTemplate:template options:0 locale:formatter.locale];
    if (prefix)
        dateFormat = [prefix stringByAppendingString:dateFormat];
    formatter.dateFormat = dateFormat;
    return [formatter stringFromDate:self];
}

- (NSString *)stringForDisplay {
    return [self stringForDisplayWithPrefix:NO];
}

#pragma mark Date<->String Conversion

+ (NSString *)dateFormatString {
    return @"yyyy-MM-dd";
}

+ (NSString *)timeFormatString {
    return @"HH:mm:ss";
}

+ (NSString *)timestampFormat {
    return @"yyyy-MM-dd HH:mm:ss";
}

+ (NSDate *)dateFromString:(NSString *)string {
    return [NSDate dateFromString:string withFormat:[NSDate timestampFormat]];
}

+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format {
    NSDateFormatter *formatter = [SLFDateHelper sharedHelper].usFormatter;
    [formatter setDateFormat:format];
    return [formatter dateFromString:string];
}

- (NSString *)stringWithFormat:(NSString *)format localized:(BOOL)localized {
    SLFDateHelper *helper = [SLFDateHelper sharedHelper];
    NSDateFormatter *formatter = localized ? helper.localizedFormatter : helper.usFormatter;
    formatter.dateFormat = format;
    return [formatter stringFromDate:self];
}

- (NSString *)string {
    return [self timestampString];
}

- (NSString *)stringWithLocalizationTemplate:(NSString *)formatTemplate timezone:(NSTimeZone *)timezone {
    NSDateFormatter *formatter = [SLFDateHelper sharedHelper].localizedFormatter;
    if (timezone) {
        [formatter setTimeZone:timezone];
    } else {
        [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    }
    NSString *format = [NSDateFormatter dateFormatFromTemplate:formatTemplate options:0 locale:formatter.locale];
    formatter.dateFormat = format;
    return [formatter stringFromDate:self];

}

- (NSString *)stringWithLocalizationTemplate:(NSString *)formatTemplate {
    return [self stringWithLocalizationTemplate:formatTemplate timezone:nil];
}

- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle {
    NSDateFormatter *formatter = [SLFDateHelper sharedHelper].localizedFormatter;
    formatter.dateFormat = nil;
    formatter.dateStyle = dateStyle;
    formatter.timeStyle = timeStyle;
    return [formatter stringFromDate:self];
}

#pragma mark - Calendar Math

/*
 * This guy can be a little unreliable and produce unexpected results,
 * you're better off using daysAgoAgainstMidnight
 */
- (NSUInteger)daysAgo {
    NSCalendar *calendar = [SLFDateHelper sharedHelper].usCalendar;
    NSDateComponents *components = [calendar components:(NSCalendarUnitDay) fromDate:self toDate:[NSDate date] options:0];
    return [components day];
}

- (NSUInteger)daysAgoAgainstMidnight {
    NSDateFormatter *formatter = [SLFDateHelper sharedHelper].usFormatter;
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *midnight = [formatter dateFromString:[formatter stringFromDate:self]];
    return (int)[midnight timeIntervalSinceNow] / (60*60*24) *-1;
}

- (NSUInteger)weekday {
    NSCalendar *calendar = [SLFDateHelper sharedHelper].usCalendar;
    NSDateComponents *weekdayComponents = [calendar components:(NSCalendarUnitWeekday) fromDate:self];
    return [weekdayComponents weekday];
}

- (NSUInteger)year {
    NSCalendar *calendar = [SLFDateHelper sharedHelper].usCalendar;
    NSDateComponents *yearComponents = [calendar components:(NSCalendarUnitYear) fromDate:self];
    return [yearComponents year];
}

- (NSDate *)beginningOfWeek {
    NSCalendar *calendar = [SLFDateHelper sharedHelper].usCalendar;
    NSDate *beginningOfWeek = nil;
    BOOL isValid = [calendar rangeOfUnit:NSCalendarUnitWeekOfMonth startDate:&beginningOfWeek interval:NULL forDate:self];
    if (isValid) {
        return beginningOfWeek;
    } 
    NSDateComponents *weekdayComponents = [calendar components:NSCalendarUnitWeekday fromDate:self];
    
    /*
     Create a date components to represent the number of days to subtract from the current date.
     The weekday value for Sunday in the Gregorian calendar is 1, so subtract 1 from the number of days to subtract from the date in question. (If today is Sunday, subtract 0 days.)
     */
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    [componentsToSubtract setDay: 0 - ([weekdayComponents weekday] - 1)];
    beginningOfWeek = nil;
    beginningOfWeek = [calendar dateByAddingComponents:componentsToSubtract toDate:self options:0];
    
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:beginningOfWeek];
    return [calendar dateFromComponents:components];
}

- (NSDate *)beginningOfDay {
    NSCalendar *calendar = [[SLFDateHelper sharedHelper] usCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)  fromDate:self];
    return [calendar dateFromComponents:components];
}

- (NSDate *)endOfWeek {
    NSCalendar *calendar = [[SLFDateHelper sharedHelper] usCalendar];
    NSDateComponents *weekdayComponents = [calendar components:NSCalendarUnitWeekday fromDate:self];
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
        // to get the end of week for a particular date, add (7 - weekday) days
    [componentsToAdd setDay:(7 - [weekdayComponents weekday])];
    NSDate *endOfWeek = [calendar dateByAddingComponents:componentsToAdd toDate:self options:0];
    
    return endOfWeek;
}

- (NSDate *)dateByAddingDays:(NSInteger)days {
    NSCalendar *calendar = [[SLFDateHelper sharedHelper] usCalendar];
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
    [componentsToAdd setDay:days];
    NSDate *timeFrom = [calendar dateByAddingComponents:componentsToAdd toDate:self options:0];
    return timeFrom;
}

#pragma mark - Timestamps

- (NSString *)timestampString {
    return [self stringWithFormat:[NSDate timestampFormat] localized:NO];
}

+ (NSDate *)dateFromTimestampString:(NSString *)timestamp {
    return [NSDate dateFromString:timestamp withFormat:[NSDate timestampFormat]];
}

+ (NSDate *)localDateFromUTCTimestamp:(NSString *)utcString {
    if (!SLFTypeNonEmptyStringOrNil(utcString))
        return nil;
    NSDate *utcDate = [NSDate dateFromTimestampString:utcString];
    if (!utcDate)
        return nil;
    return [utcDate localDateConvertingFromOtherTimeZone:@"UTC"];
}

#pragma mark - Time Zone Conversion

- (NSDate *)localDateConvertingFromOtherTimeZone:(NSString *)tzAbbrev {
        // The date in your source timezone (eg. EST)   @"EST", @"CST", @"UTC", @"GMT"
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:tzAbbrev];
    NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:self];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:self];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    return [self dateByAddingTimeInterval:interval];    
}

@end
