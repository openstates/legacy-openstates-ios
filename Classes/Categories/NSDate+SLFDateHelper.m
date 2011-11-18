//
//  NSDate+SLFDateHelper.m
//  Created by Greg Combs on 11/16/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "NSDate+SLFDateHelper.h"

@interface SLFDateHelper : NSObject
@property (nonatomic, retain) NSDateFormatter *modFormatter;
@property (nonatomic, retain) NSDateFormatter *standardFormatter;
@property (nonatomic, retain) NSCalendar *calendar;
+ (SLFDateHelper *)sharedHelper;
@end

@implementation SLFDateHelper
@synthesize standardFormatter = t_formatter;
@synthesize calendar = t_calendar;
@synthesize modFormatter = t_modFormatter;

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
        t_formatter = [[NSDateFormatter alloc] init];
        t_modFormatter = [[NSDateFormatter alloc] init];
        t_calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    }
    return self;
}

- (void)dealloc {
    self.modFormatter = nil;
    self.standardFormatter = nil;
    self.calendar = nil;
    [super dealloc];
}

@end

@implementation NSDate (SLFDateHelper)

#pragma mark - Comparison

- (BOOL)isEarlierThanDate:(NSDate *)laterDate {
    return ([self compare:laterDate] != NSOrderedDescending); // sooner is before later
}

 - (BOOL)equalsDefaultDate {
    NSDateFormatter *formatter = [[SLFDateHelper sharedHelper] standardFormatter];
    BOOL equals = [self isEqualToDate:[formatter defaultDate]];
    return equals;
}

#pragma mark - User Friendly Presentation

- (NSString *)localWeekdayString {
    NSCalendar *gregorian = [[SLFDateHelper sharedHelper] calendar];
    NSDateFormatter *weekdayFormatter = [[SLFDateHelper sharedHelper] modFormatter];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [weekdayFormatter setCalendar:gregorian];
    [weekdayFormatter setLocale:usLocale];
    [weekdayFormatter setDateFormat:@"EEEE"];
    NSString *weekday = [weekdayFormatter stringFromDate:self];
    if (usLocale) [usLocale release], usLocale = nil;
    
    return weekday;
}

- (NSString *)stringDaysAgo {
    return [self stringDaysAgoAgainstMidnight:YES];
}

- (NSString *)stringDaysAgoAgainstMidnight:(BOOL)usingMidnight {
    NSUInteger daysAgo = (usingMidnight) ? [self daysAgoAgainstMidnight] : [self daysAgo];
    NSString *text = nil;
    switch (daysAgo) {
        case 0:
            text = @"Today";
            break;
        case 1:
            text = @"Yesterday";
            break;
        default:
            text = [NSString stringWithFormat:@"%d days ago", daysAgo];
    }
    return text;
}

- (NSString *)stringForDisplayWithPrefix:(NSString *)prefixed {
    /* 
     * if the date is today, display 12-hour time with meridian,
     * if it is within the last 7 days, display weekday name (Friday)
     * if within the calendar year, display as Jan 23
     * else display as Nov 11, 2008
     */
    
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [[SLFDateHelper sharedHelper] calendar];
    NSDateComponents *offsetComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:today];
    
    NSDate *midnight = [calendar dateFromComponents:offsetComponents];
    NSDateFormatter *displayFormatter = [[SLFDateHelper sharedHelper] modFormatter];
    NSString *displayString = nil;
    
    if ([self compare:midnight] == NSOrderedDescending) {
        if (prefixed) {
            [displayFormatter setDateFormat:@"'at' h:mm a"]; // at 11:30 am
        } else {
            [displayFormatter setDateFormat:@"h:mm a"]; // 11:30 am
        }
    } else {
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        [componentsToSubtract setDay:-7];
        NSDate *lastweek = [calendar dateByAddingComponents:componentsToSubtract toDate:today options:0];
        [componentsToSubtract release];
        if ([self compare:lastweek] == NSOrderedDescending) {
            [displayFormatter setDateFormat:@"EEEE"]; // Tuesday
        } else {
            NSInteger thisYear = [offsetComponents year];
            
            NSDateComponents *dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self];
            NSInteger thatYear = [dateComponents year];            
            if (thatYear >= thisYear) {
                [displayFormatter setDateFormat:@"MMM d"];
            } else {
                [displayFormatter setDateFormat:@"MMM d, yyyy"];
            }
        }
        if (prefixed) {
            NSString *dateFormat = [displayFormatter dateFormat];
            NSString *prefix = @"'on' ";
            [displayFormatter setDateFormat:[prefix stringByAppendingString:dateFormat]];
        }
    }
    displayString = [displayFormatter stringFromDate:self];
    return displayString;
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

+ (NSString *)timestampFormatString {
    return @"yyyy-MM-dd HH:mm:ss";
}

+ (NSDate *)dateFromString:(NSString *)string {
    return [NSDate dateFromString:string withFormat:[NSDate timestampFormatString]];
}

+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format {
    NSDateFormatter *inputFormatter = [[SLFDateHelper sharedHelper] modFormatter];
    [inputFormatter setDateFormat:format];
    NSDate *date = [inputFormatter dateFromString:string];
    return date;
}

- (NSString *)stringWithFormat:(NSString *)format {
    NSDateFormatter *outputFormatter = [[SLFDateHelper sharedHelper] modFormatter];
    [outputFormatter setDateFormat:format];
    NSString *timestamp_str = [outputFormatter stringFromDate:self];
    return timestamp_str;
}

- (NSString *)string {
    return [self stringWithFormat:[NSDate timestampFormatString]];
}

- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle {
    NSDateFormatter *outputFormatter = [[SLFDateHelper sharedHelper] modFormatter];
    [outputFormatter setDateStyle:dateStyle];
    [outputFormatter setTimeStyle:timeStyle];
    NSString *outputString = [outputFormatter stringFromDate:self];
    return outputString;
}

#pragma mark - Calendar Math

/*
 * This guy can be a little unreliable and produce unexpected results,
 * you're better off using daysAgoAgainstMidnight
 */
- (NSUInteger)daysAgo {
    NSCalendar *calendar = [[SLFDateHelper sharedHelper] calendar];
    NSDateComponents *components = [calendar components:(NSDayCalendarUnit) fromDate:self toDate:[NSDate date] options:0];
    return [components day];
}

- (NSUInteger)daysAgoAgainstMidnight {
    NSDateFormatter *mdf = [[SLFDateHelper sharedHelper] modFormatter];
    [mdf setDateFormat:@"yyyy-MM-dd"];
    NSDate *midnight = [mdf dateFromString:[mdf stringFromDate:self]];
    
    return (int)[midnight timeIntervalSinceNow] / (60*60*24) *-1;
}

- (NSUInteger)weekday {
    NSCalendar *calendar = [[SLFDateHelper sharedHelper] calendar];
    NSDateComponents *weekdayComponents = [calendar components:(NSWeekdayCalendarUnit) fromDate:self];
    return [weekdayComponents weekday];
}

- (NSUInteger)year {
    NSCalendar *calendar = [[SLFDateHelper sharedHelper] calendar];
    NSDateComponents *yearComponents = [calendar components:(NSYearCalendarUnit) fromDate:self];
    return [yearComponents year];
}

- (NSDate *)beginningOfWeek {
        // largely borrowed from "Date and Time Programming Guide for Cocoa"
        // we'll use the default calendar and hope for the best
    
    NSCalendar *calendar = [[SLFDateHelper sharedHelper] calendar];
    NSDate *beginningOfWeek = nil;
    BOOL ok = [calendar rangeOfUnit:NSWeekCalendarUnit startDate:&beginningOfWeek
                           interval:NULL forDate:self];
    if (ok) {
        return beginningOfWeek;
    } 
    NSDateComponents *weekdayComponents = [calendar components:NSWeekdayCalendarUnit fromDate:self];
    
    /*
     Create a date components to represent the number of days to subtract from the current date.
     The weekday value for Sunday in the Gregorian calendar is 1, so subtract 1 from the number of days to subtract from the date in question.    (If today's Sunday, subtract 0 days.)
     */
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    [componentsToSubtract setDay: 0 - ([weekdayComponents weekday] - 1)];
    beginningOfWeek = nil;
    beginningOfWeek = [calendar dateByAddingComponents:componentsToSubtract toDate:self options:0];
    [componentsToSubtract release];
    
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:beginningOfWeek];
    return [calendar dateFromComponents:components];
}

- (NSDate *)beginningOfDay {
    NSCalendar *calendar = [[SLFDateHelper sharedHelper] calendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)  fromDate:self];
    return [calendar dateFromComponents:components];
}

- (NSDate *)endOfWeek {
    NSCalendar *calendar = [[SLFDateHelper sharedHelper] calendar];
    NSDateComponents *weekdayComponents = [calendar components:NSWeekdayCalendarUnit fromDate:self];
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
        // to get the end of week for a particular date, add (7 - weekday) days
    [componentsToAdd setDay:(7 - [weekdayComponents weekday])];
    NSDate *endOfWeek = [calendar dateByAddingComponents:componentsToAdd toDate:self options:0];
    [componentsToAdd release];
    
    return endOfWeek;
}

- (NSDate *)dateByAddingDays:(NSInteger)days {
    NSCalendar *calendar = [[SLFDateHelper sharedHelper] calendar];
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
    [componentsToAdd setDay:days];
    NSDate *timeFrom = [calendar dateByAddingComponents:componentsToAdd toDate:self options:0];
    [componentsToAdd release];
    return timeFrom;
}

#pragma mark - Timestamps

- (NSString *)timestampString {
    NSString *stampString = [self stringWithFormat:[NSDate timestampFormatString]];
    return stampString;
}

+ (NSDate *)dateFromTimestampString:(NSString *)timestamp {
    NSDate *aDate = [NSDate dateFromString:timestamp withFormat:[NSDate timestampFormatString]];
    return aDate;
}

+ (NSDate *)localDateFromUTCTimestamp:(NSString *)utcString {
    if (IsEmpty(utcString))
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