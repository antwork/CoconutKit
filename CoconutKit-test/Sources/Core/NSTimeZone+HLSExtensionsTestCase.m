//
//  NSTimeZone+HLSExtensionsTestCase.m
//  CoconutKit-test
//
//  Created by Samuel Défago on 06.09.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "NSTimeZone+HLSExtensionsTestCase.h"

@interface NSTimeZone_HLSExtensionsTestCase ()

@property (nonatomic, retain) NSCalendar *calendar;
@property (nonatomic, retain) NSTimeZone *timeZoneZurich;
@property (nonatomic, retain) NSTimeZone *timeZoneTahiti;
@property (nonatomic, retain) NSDate *date1;
@property (nonatomic, retain) NSDate *date2;
@property (nonatomic, retain) NSDate *date3;
@property (nonatomic, retain) NSDate *date4;
@property (nonatomic, retain) NSDate *date5;

@end

@implementation NSTimeZone_HLSExtensionsTestCase

#pragma mark Object creation and destruction

- (void)dealloc
{
    self.calendar = nil;
    self.date1 = nil;
    self.date2 = nil;
    self.date3 = nil;
    self.date4 = nil;
    self.date5 = nil;
    self.timeZoneZurich = nil;
    self.timeZoneTahiti = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize calendar = m_calendar;

@synthesize timeZoneZurich = m_timeZoneZurich;

@synthesize timeZoneTahiti = m_timeZoneTahiti;

@synthesize date1 = m_date1;

@synthesize date2 = m_date2;

@synthesize date3 = m_date3;

@synthesize date4 = m_date4;

@synthesize date5 = m_date5;

#pragma mark Test setup and tear down

- (void)setUpClass
{
    [super setUpClass];
    
    // Europe/Zurich uses CEST during summer, between 1:00 UTC on the last Sunday of March and until 1:00 on the last Sunday of October. 
    // CET is used for the rest of the year. Pacific/Tahiti does not use daylight saving times. In summary:
    //   - when Europe/Zurich uses CET (UTC+1): Zurich is 11 hours ahead of Tahiti (UTC-10)
    //   - when Europe/Zurich uses CEST (UTC+2): Zurich is 12 hours ahead of Tahiti (UTC-10)
    self.calendar = [NSCalendar currentCalendar];
    self.timeZoneZurich = [NSTimeZone timeZoneWithName:@"Europe/Zurich"];
    self.timeZoneTahiti = [NSTimeZone timeZoneWithName:@"Pacific/Tahiti"];
    
    // The two dates below correspond to days which are different whether we are in the Zurich time zone or in the Tahiti time zone
    // Date corresponding to the beginning of the year
    
    // For Europe/Zurich, this corresponds to 2012-01-01 08:23:00 (CET, UTC+1); for Pacific/Tahiti to 2011-12-31 21:23:00 (UTC-10)
    self.date1 = [NSDate dateWithTimeIntervalSinceReferenceDate:347095380.];
    
    // Date corresponding to March 1st on a leap year
    // For Europe/Zurich, this corresponds to 2012-03-01 06:12:00 (CET, UTC+1); for Pacific/Tahiti to 2012-02-29 19:12:00 (UTC-10)
    self.date2 = [NSDate dateWithTimeIntervalSinceReferenceDate:352271520.];
    
    // The three dates below are used to test the CET -> CEST transition in the Europe/Zurich time zone
    
    // For Europe/Zurich, this corresponds to 2012-03-25 01:00:00 (CET, UTC+1); for Pacific/Tahiti to 2012-03-24 14:00:00 (UTC-10). This
    // is one hour before the transition occurs
    self.date3 = [NSDate dateWithTimeIntervalSinceReferenceDate:354326400.];
    
    // For Europe/Zurich, this corresponds to 2012-03-25 03:00:00 (CEST, UTC+2); for Pacific/Tahiti to 2012-03-24 15:00:00 (UTC-10). This
    // is the exact time at which the transition occurs (i.e. the first date in CEST)
    self.date4 = [NSDate dateWithTimeIntervalSinceReferenceDate:354330000.];
    
    // For Europe/Zurich, this corresponds to 2012-03-26 05:00:00 (CEST, UTC+2); for Pacific/Tahiti to 2012-03-25 17:00:00 (UTC-10). This
    // is about a day after the CET -> CEST transition has occurred
    self.date5 = [NSDate dateWithTimeIntervalSinceReferenceDate:354423600.];
}

#pragma mark Tests

- (void)testOffsetFromTimeZoneForDate
{
    GHAssertEquals([self.timeZoneZurich offsetFromTimeZone:self.timeZoneTahiti forDate:self.date1], 11. * 60. * 60., @"Incorrect offset");
    GHAssertEquals([self.timeZoneZurich offsetFromTimeZone:self.timeZoneTahiti forDate:self.date2], 11. * 60. * 60., @"Incorrect toffset");
    GHAssertEquals([self.timeZoneZurich offsetFromTimeZone:self.timeZoneTahiti forDate:self.date3], 11. * 60. * 60., @"Incorrect offset");
    GHAssertEquals([self.timeZoneZurich offsetFromTimeZone:self.timeZoneTahiti forDate:self.date4], 12. * 60. * 60., @"Incorrect offset");
    GHAssertEquals([self.timeZoneZurich offsetFromTimeZone:self.timeZoneTahiti forDate:self.date5], 12. * 60. * 60., @"Incorrect offset");
}

- (void)testDateWithSameComponentsAsDatefromTimeZone
{
    // To compare components, we cannot use CoconutKit methods (since they are ulitmately implemented using the methods we
    // are testing!). We therefore use the system calendar and time zone here
    NSTimeZone *timeZone = [self.calendar timeZone];
    
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    
    NSDate *dateFromZurich1 = [timeZone dateWithSameComponentsAsDate:self.date1 fromTimeZone:self.timeZoneZurich];
    NSDateComponents *dateComponentsFromZurich1 = [self.calendar components:unitFlags fromDate:dateFromZurich1];
    GHAssertEquals([dateComponentsFromZurich1 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsFromZurich1 month], 1, @"Incorrect month");
    GHAssertEquals([dateComponentsFromZurich1 day], 1, @"Incorrect day");
    GHAssertEquals([dateComponentsFromZurich1 hour], 8, @"Incorrect hour");
    GHAssertEquals([dateComponentsFromZurich1 minute], 23, @"Incorrect minute");
    
    NSDate *dateFromZurich2 = [timeZone dateWithSameComponentsAsDate:self.date2 fromTimeZone:self.timeZoneZurich];
    NSDateComponents *dateComponentsFromZurich2 = [self.calendar components:unitFlags fromDate:dateFromZurich2];
    GHAssertEquals([dateComponentsFromZurich2 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsFromZurich2 month], 3, @"Incorrect month");
    GHAssertEquals([dateComponentsFromZurich2 day], 1, @"Incorrect day");
    GHAssertEquals([dateComponentsFromZurich2 hour], 6, @"Incorrect hour");
    GHAssertEquals([dateComponentsFromZurich2 minute], 12, @"Incorrect minute");

    NSDate *dateFromZurich3 = [timeZone dateWithSameComponentsAsDate:self.date3 fromTimeZone:self.timeZoneZurich];
    NSDateComponents *dateComponentsFromZurich3 = [self.calendar components:unitFlags fromDate:dateFromZurich3];
    GHAssertEquals([dateComponentsFromZurich3 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsFromZurich3 month], 3, @"Incorrect month");
    GHAssertEquals([dateComponentsFromZurich3 day], 25, @"Incorrect day");
    GHAssertEquals([dateComponentsFromZurich3 hour], 1, @"Incorrect hour");
    
    NSDate *dateFromZurich4 = [timeZone dateWithSameComponentsAsDate:self.date4 fromTimeZone:self.timeZoneZurich];
    NSDateComponents *dateComponentsFromZurich4 = [self.calendar components:unitFlags fromDate:dateFromZurich4];
    GHAssertEquals([dateComponentsFromZurich4 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsFromZurich4 month], 3, @"Incorrect month");
    GHAssertEquals([dateComponentsFromZurich4 day], 25, @"Incorrect day");
    GHAssertEquals([dateComponentsFromZurich4 hour], 3, @"Incorrect hour");
    
    NSDate *dateFromZurich5 = [timeZone dateWithSameComponentsAsDate:self.date5 fromTimeZone:self.timeZoneZurich];
    NSDateComponents *dateComponentsFromZurich5 = [self.calendar components:unitFlags fromDate:dateFromZurich5];
    GHAssertEquals([dateComponentsFromZurich5 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsFromZurich5 month], 3, @"Incorrect month");
    GHAssertEquals([dateComponentsFromZurich5 day], 26, @"Incorrect day");
    GHAssertEquals([dateComponentsFromZurich5 hour], 5, @"Incorrect hour");
    
    NSDate *dateFromTahiti1 = [timeZone dateWithSameComponentsAsDate:self.date1 fromTimeZone:self.timeZoneTahiti];
    NSDateComponents *dateComponentsFromTahiti1 = [self.calendar components:unitFlags fromDate:dateFromTahiti1];
    GHAssertEquals([dateComponentsFromTahiti1 year], 2011, @"Incorrect year");
    GHAssertEquals([dateComponentsFromTahiti1 month], 12, @"Incorrect month");
    GHAssertEquals([dateComponentsFromTahiti1 day], 31, @"Incorrect day");
    GHAssertEquals([dateComponentsFromTahiti1 hour], 21, @"Incorrect hour");
    GHAssertEquals([dateComponentsFromTahiti1 minute], 23, @"Incorrect minute");
    
    NSDate *dateFromTahiti2 = [timeZone dateWithSameComponentsAsDate:self.date2 fromTimeZone:self.timeZoneTahiti];
    NSDateComponents *dateComponentsFromTahiti2 = [self.calendar components:unitFlags fromDate:dateFromTahiti2];
    GHAssertEquals([dateComponentsFromTahiti2 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsFromTahiti2 month], 2, @"Incorrect month");
    GHAssertEquals([dateComponentsFromTahiti2 day], 29, @"Incorrect day");
    GHAssertEquals([dateComponentsFromTahiti2 hour], 19, @"Incorrect hour");
    GHAssertEquals([dateComponentsFromTahiti2 minute], 12, @"Incorrect minute");
    
    NSDate *dateFromTahiti3 = [timeZone dateWithSameComponentsAsDate:self.date3 fromTimeZone:self.timeZoneTahiti];
    NSDateComponents *dateComponentsFromTahiti3 = [self.calendar components:unitFlags fromDate:dateFromTahiti3];
    GHAssertEquals([dateComponentsFromTahiti3 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsFromTahiti3 month], 3, @"Incorrect month");
    GHAssertEquals([dateComponentsFromTahiti3 day], 24, @"Incorrect day");
    GHAssertEquals([dateComponentsFromTahiti3 hour], 14, @"Incorrect hour");
    
    NSDate *dateFromTahiti4 = [timeZone dateWithSameComponentsAsDate:self.date4 fromTimeZone:self.timeZoneTahiti];
    NSDateComponents *dateComponentsFromTahiti4 = [self.calendar components:unitFlags fromDate:dateFromTahiti4];
    GHAssertEquals([dateComponentsFromTahiti4 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsFromTahiti4 month], 3, @"Incorrect month");
    GHAssertEquals([dateComponentsFromTahiti4 day], 24, @"Incorrect day");
    GHAssertEquals([dateComponentsFromTahiti4 hour], 15, @"Incorrect hour");
    
    NSDate *dateFromTahiti5 = [timeZone dateWithSameComponentsAsDate:self.date5 fromTimeZone:self.timeZoneTahiti];
    NSDateComponents *dateComponentsFromTahiti5 = [self.calendar components:unitFlags fromDate:dateFromTahiti5];
    GHAssertEquals([dateComponentsFromTahiti5 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsFromTahiti5 month], 3, @"Incorrect month");
    GHAssertEquals([dateComponentsFromTahiti5 day], 25, @"Incorrect day");
    GHAssertEquals([dateComponentsFromTahiti5 hour], 17, @"Incorrect hour");
}

- (void)testDateByAddingTimeIntervalToDate
{
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    
    NSDate *dateZurich1 = [self.timeZoneZurich dateByAddingTimeInterval:10. * 60. * 60. toDate:self.date1];
    NSDateComponents *dateComponentsZurich1 = [self.calendar components:unitFlags fromDate:dateZurich1 inTimeZone:self.timeZoneZurich];
    GHAssertEquals([dateComponentsZurich1 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsZurich1 month], 1, @"Incorrect month");
    GHAssertEquals([dateComponentsZurich1 day], 1, @"Incorrect day");
    GHAssertEquals([dateComponentsZurich1 hour], 18, @"Incorrect hour");
    GHAssertEquals([dateComponentsZurich1 minute], 23, @"Incorrect minute");
    
    NSDate *dateZurich2 = [self.timeZoneZurich dateByAddingTimeInterval:-4. * 60. * 60. toDate:self.date2];
    NSDateComponents *dateComponentsZurich2 = [self.calendar components:unitFlags fromDate:dateZurich2 inTimeZone:self.timeZoneZurich];
    GHAssertEquals([dateComponentsZurich2 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsZurich2 month], 3, @"Incorrect month");
    GHAssertEquals([dateComponentsZurich2 day], 1, @"Incorrect day");
    GHAssertEquals([dateComponentsZurich2 hour], 2, @"Incorrect hour");
    GHAssertEquals([dateComponentsZurich2 minute], 12, @"Incorrect minute");
    
    NSDate *dateZurich3 = [self.timeZoneZurich dateByAddingTimeInterval:5. * 60. * 60. toDate:self.date3];
    NSDateComponents *dateComponentsZurich3 = [self.calendar components:unitFlags fromDate:dateZurich3 inTimeZone:self.timeZoneZurich];
    GHAssertEquals([dateComponentsZurich3 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsZurich3 month], 3, @"Incorrect month");
    GHAssertEquals([dateComponentsZurich3 day], 25, @"Incorrect day");
    GHAssertEquals([dateComponentsZurich3 hour], 6, @"Incorrect hour");
    
    NSDate *dateZurich4 = [self.timeZoneZurich dateByAddingTimeInterval:-2. * 60. * 60. toDate:self.date4];
    NSDateComponents *dateComponentsZurich4 = [self.calendar components:unitFlags fromDate:dateZurich4 inTimeZone:self.timeZoneZurich];
    GHAssertEquals([dateComponentsZurich4 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsZurich4 month], 3, @"Incorrect month");
    GHAssertEquals([dateComponentsZurich4 day], 25, @"Incorrect day");
    GHAssertEquals([dateComponentsZurich4 hour], 1, @"Incorrect hour");
    
    NSDate *dateZurich5 = [self.timeZoneZurich dateByAddingTimeInterval:5. * 60. * 60. toDate:self.date5];
    NSDateComponents *dateComponentsZurich5 = [self.calendar components:unitFlags fromDate:dateZurich5 inTimeZone:self.timeZoneZurich];
    GHAssertEquals([dateComponentsZurich5 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsZurich5 month], 3, @"Incorrect month");
    GHAssertEquals([dateComponentsZurich5 day], 26, @"Incorrect day");
    GHAssertEquals([dateComponentsZurich5 hour], 10, @"Incorrect hour");
    
    NSDate *dateTahiti1 = [self.timeZoneTahiti dateByAddingTimeInterval:10. * 60. * 60. toDate:self.date1];
    NSDateComponents *dateComponentsTahiti1 = [self.calendar components:unitFlags fromDate:dateTahiti1 inTimeZone:self.timeZoneTahiti];
    GHAssertEquals([dateComponentsTahiti1 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsTahiti1 month], 1, @"Incorrect month");
    GHAssertEquals([dateComponentsTahiti1 day], 1, @"Incorrect day");
    GHAssertEquals([dateComponentsTahiti1 hour], 7, @"Incorrect hour");
    GHAssertEquals([dateComponentsTahiti1 minute], 23, @"Incorrect minute");
    
    NSDate *dateTahiti2 = [self.timeZoneTahiti dateByAddingTimeInterval:-4. * 60. * 60. toDate:self.date2];
    NSDateComponents *dateComponentsTahiti2 = [self.calendar components:unitFlags fromDate:dateTahiti2 inTimeZone:self.timeZoneTahiti];
    GHAssertEquals([dateComponentsTahiti2 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsTahiti2 month], 2, @"Incorrect month");
    GHAssertEquals([dateComponentsTahiti2 day], 29, @"Incorrect day");
    GHAssertEquals([dateComponentsTahiti2 hour], 15, @"Incorrect hour");
    GHAssertEquals([dateComponentsTahiti2 minute], 12, @"Incorrect minute");
    
    NSDate *dateTahiti3 = [self.timeZoneTahiti dateByAddingTimeInterval:5. * 60. * 60. toDate:self.date3];
    NSDateComponents *dateComponentsTahiti3 = [self.calendar components:unitFlags fromDate:dateTahiti3 inTimeZone:self.timeZoneTahiti];
    GHAssertEquals([dateComponentsTahiti3 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsTahiti3 month], 3, @"Incorrect month");
    GHAssertEquals([dateComponentsTahiti3 day], 24, @"Incorrect day");
    GHAssertEquals([dateComponentsTahiti3 hour], 19, @"Incorrect hour");
    
    NSDate *dateTahiti4 = [self.timeZoneTahiti dateByAddingTimeInterval:-2. * 60. * 60. toDate:self.date4];
    NSDateComponents *dateComponentsTahiti4 = [self.calendar components:unitFlags fromDate:dateTahiti4 inTimeZone:self.timeZoneTahiti];
    GHAssertEquals([dateComponentsTahiti4 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsTahiti4 month], 3, @"Incorrect month");
    GHAssertEquals([dateComponentsTahiti4 day], 24, @"Incorrect day");
    GHAssertEquals([dateComponentsTahiti4 hour], 13, @"Incorrect hour");
    
    NSDate *dateTahiti5 = [self.timeZoneTahiti dateByAddingTimeInterval:5. * 60. * 60. toDate:self.date5];
    NSDateComponents *dateComponentsTahiti5 = [self.calendar components:unitFlags fromDate:dateTahiti5 inTimeZone:self.timeZoneTahiti];
    GHAssertEquals([dateComponentsTahiti5 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsTahiti5 month], 3, @"Incorrect month");
    GHAssertEquals([dateComponentsTahiti5 day], 25, @"Incorrect day");
    GHAssertEquals([dateComponentsTahiti5 hour], 22, @"Incorrect hour");
}

- (void)testDateByAddingNumberOfDaysToDate
{
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    
    NSDate *dateZurich1 = [self.timeZoneZurich dateByAddingNumberOfDays:5 toDate:self.date1];
    NSDateComponents *dateComponentsZurich1 = [self.calendar components:unitFlags fromDate:dateZurich1 inTimeZone:self.timeZoneZurich];
    GHAssertEquals([dateComponentsZurich1 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsZurich1 month], 1, @"Incorrect month");
    GHAssertEquals([dateComponentsZurich1 day], 6, @"Incorrect day");
    GHAssertEquals([dateComponentsZurich1 hour], 8, @"Incorrect hour");
    GHAssertEquals([dateComponentsZurich1 minute], 23, @"Incorrect minute");
    
    NSDate *dateZurich2 = [self.timeZoneZurich dateByAddingNumberOfDays:-3 toDate:self.date2];
    NSDateComponents *dateComponentsZurich2 = [self.calendar components:unitFlags fromDate:dateZurich2 inTimeZone:self.timeZoneZurich];
    GHAssertEquals([dateComponentsZurich2 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsZurich2 month], 2, @"Incorrect month");
    GHAssertEquals([dateComponentsZurich2 day], 27, @"Incorrect day");
    GHAssertEquals([dateComponentsZurich2 hour], 6, @"Incorrect hour");
    GHAssertEquals([dateComponentsZurich2 minute], 12, @"Incorrect minute");
    
    NSDate *dateZurich3 = [self.timeZoneZurich dateByAddingNumberOfDays:2 toDate:self.date3];
    NSDateComponents *dateComponentsZurich3 = [self.calendar components:unitFlags fromDate:dateZurich3 inTimeZone:self.timeZoneZurich];
    GHAssertEquals([dateComponentsZurich3 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsZurich3 month], 3, @"Incorrect month");
    GHAssertEquals([dateComponentsZurich3 day], 27, @"Incorrect day");
    GHAssertEquals([dateComponentsZurich3 hour], 1, @"Incorrect hour");
    
    NSDate *dateZurich4 = [self.timeZoneZurich dateByAddingNumberOfDays:2 toDate:self.date4];
    NSDateComponents *dateComponentsZurich4 = [self.calendar components:unitFlags fromDate:dateZurich4 inTimeZone:self.timeZoneZurich];
    GHAssertEquals([dateComponentsZurich4 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsZurich4 month], 3, @"Incorrect month");
    GHAssertEquals([dateComponentsZurich4 day], 27, @"Incorrect day");
    GHAssertEquals([dateComponentsZurich4 hour], 3, @"Incorrect hour");
    
    NSDate *dateZurich5 = [self.timeZoneZurich dateByAddingNumberOfDays:2 toDate:self.date5];
    NSDateComponents *dateComponentsZurich5 = [self.calendar components:unitFlags fromDate:dateZurich5 inTimeZone:self.timeZoneZurich];
    GHAssertEquals([dateComponentsZurich5 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsZurich5 month], 3, @"Incorrect month");
    GHAssertEquals([dateComponentsZurich5 day], 28, @"Incorrect day");
    GHAssertEquals([dateComponentsZurich5 hour], 5, @"Incorrect hour");
    
    NSDate *dateTahiti1 = [self.timeZoneTahiti dateByAddingNumberOfDays:5 toDate:self.date1];
    NSDateComponents *dateComponentsTahiti1 = [self.calendar components:unitFlags fromDate:dateTahiti1 inTimeZone:self.timeZoneTahiti];
    GHAssertEquals([dateComponentsTahiti1 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsTahiti1 month], 1, @"Incorrect month");
    GHAssertEquals([dateComponentsTahiti1 day], 5, @"Incorrect day");
    GHAssertEquals([dateComponentsTahiti1 hour], 21, @"Incorrect hour");
    GHAssertEquals([dateComponentsTahiti1 minute], 23, @"Incorrect minute");
    
    NSDate *dateTahiti2 = [self.timeZoneTahiti dateByAddingNumberOfDays:-3 toDate:self.date2];
    NSDateComponents *dateComponentsTahiti2 = [self.calendar components:unitFlags fromDate:dateTahiti2 inTimeZone:self.timeZoneTahiti];
    GHAssertEquals([dateComponentsTahiti2 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsTahiti2 month], 2, @"Incorrect month");
    GHAssertEquals([dateComponentsTahiti2 day], 26, @"Incorrect day");
    GHAssertEquals([dateComponentsTahiti2 hour], 19, @"Incorrect hour");
    GHAssertEquals([dateComponentsTahiti2 minute], 12, @"Incorrect minute");
    
    NSDate *dateTahiti3 = [self.timeZoneTahiti dateByAddingNumberOfDays:2 toDate:self.date3];
    NSDateComponents *dateComponentsTahiti3 = [self.calendar components:unitFlags fromDate:dateTahiti3 inTimeZone:self.timeZoneTahiti];
    GHAssertEquals([dateComponentsTahiti3 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsTahiti3 month], 3, @"Incorrect month");
    GHAssertEquals([dateComponentsTahiti3 day], 26, @"Incorrect day");
    GHAssertEquals([dateComponentsTahiti3 hour], 14, @"Incorrect hour");
    
    NSDate *dateTahiti4 = [self.timeZoneTahiti dateByAddingNumberOfDays:2 toDate:self.date4];
    NSDateComponents *dateComponentsTahiti4 = [self.calendar components:unitFlags fromDate:dateTahiti4 inTimeZone:self.timeZoneTahiti];
    GHAssertEquals([dateComponentsTahiti4 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsTahiti4 month], 3, @"Incorrect month");
    GHAssertEquals([dateComponentsTahiti4 day], 26, @"Incorrect day");
    GHAssertEquals([dateComponentsTahiti4 hour], 15, @"Incorrect hour");
    
    NSDate *dateTahiti5 = [self.timeZoneTahiti dateByAddingNumberOfDays:2 toDate:self.date5];
    NSDateComponents *dateComponentsTahiti5 = [self.calendar components:unitFlags fromDate:dateTahiti5 inTimeZone:self.timeZoneTahiti];
    GHAssertEquals([dateComponentsTahiti5 year], 2012, @"Incorrect year");
    GHAssertEquals([dateComponentsTahiti5 month], 3, @"Incorrect month");
    GHAssertEquals([dateComponentsTahiti5 day], 27, @"Incorrect day");
    GHAssertEquals([dateComponentsTahiti5 hour], 17, @"Incorrect hour");
}

- (void)testTimeIntervalBetweenDateAndDate
{
    NSTimeInterval timeIntervalZurich43 = [self.timeZoneZurich timeIntervalBetweenDate:self.date4 andDate:self.date3];
    GHAssertEquals(timeIntervalZurich43, 2. * 60. * 60., @"Incorrect time interval");
    
    NSTimeInterval timeIntervalZurich53 = [self.timeZoneZurich timeIntervalBetweenDate:self.date5 andDate:self.date3];
    GHAssertEquals(timeIntervalZurich53, 28. * 60. * 60., @"Incorrect time interval");
    
    NSTimeInterval timeIntervalZurich54 = [self.timeZoneZurich timeIntervalBetweenDate:self.date5 andDate:self.date4];
    GHAssertEquals(timeIntervalZurich54, 26. * 60. * 60., @"Incorrect time interval");
    
    NSTimeInterval timeIntervalTahiti43 = [self.timeZoneTahiti timeIntervalBetweenDate:self.date4 andDate:self.date3];
    GHAssertEquals(timeIntervalTahiti43, 1. * 60. * 60., @"Incorrect time interval");
    
    NSTimeInterval timeIntervalTahiti53 = [self.timeZoneTahiti timeIntervalBetweenDate:self.date5 andDate:self.date3];
    GHAssertEquals(timeIntervalTahiti53, 27. * 60. * 60., @"Incorrect time interval");
    
    NSTimeInterval timeIntervalTahiti54 = [self.timeZoneTahiti timeIntervalBetweenDate:self.date5 andDate:self.date4];
    GHAssertEquals(timeIntervalTahiti54, 26. * 60. * 60., @"Incorrect time interval");
}

@end
