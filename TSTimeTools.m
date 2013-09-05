//
//  TimeTools.m
//  Photo Datalogger
//
//  Created by Jindrich Sarson on 10/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TSTimeTools.h"

#import <Security/Security.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>



@implementation TSTimeTools

@synthesize currentLanguage, gregorianCalendar = _gregorianCalendar;

static TSTimeTools* sharedTimeToolsInstance;


/* gets current time - formated according regional settings */



-(NSCalendar*)gregorianCalendar {
	if (_gregorianCalendar != nil) {
		[_gregorianCalendar setTimeZone:[NSTimeZone defaultTimeZone]];
	}
	return _gregorianCalendar;
}


/* get only date components from date (not time) */
-(NSDate*)getCleanDate:(NSDate*) date{
	NSDateComponents *to = [[NSDateComponents alloc] init];
	NSDateComponents *from = [self.gregorianCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
	[to setDay:[from day]];
	[to setMonth:[from month]];	
	[to setYear:[from year]];
//	[_gregorianCalendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSDate *retDate = [self.gregorianCalendar dateFromComponents:to];
	[to release];
	return retDate;
}


/*
 * Returns YES, if date with same day */
-(BOOL)isSameDay:(NSDate*)dat1 second:(NSDate*)dat2 {
	NSDateComponents *d1 = [self.gregorianCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:dat1];
	NSDateComponents *d2 = [self.gregorianCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:dat2];
	if (([d1 day] != [d2 day]) || ([d1 month] != [d2 month])) {
		return NO;
	} else {
		return YES;
	}
}

/* returns YES, if same hour & minute */
-(BOOL)isSameMinute:(NSDate*)dat1 second:(NSDate*)dat2 {
	NSDateComponents *d1 = [self.gregorianCalendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:dat1];
	NSDateComponents *d2 = [self.gregorianCalendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:dat2];
	return ([d1 minute] == [d2 minute] && [d1 hour] == [d2 hour]);
}


-(NSDate*)setDateComponents:(NSDate*)date hour:(int)hour minute:(int)minute second:(int)second {
	NSDateComponents *to = [[NSDateComponents alloc] init];
	NSDateComponents *from = [self.gregorianCalendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
	[to setDay:[from day]];
	[to setMonth:[from month]];	
	[to setYear:[from year]];
	[to setHour:hour];
	[to setMinute:minute];	
	[to setSecond:second];
	NSDate *retDate = [self.gregorianCalendar dateFromComponents:to];
	[to release];
	return retDate;
}
		

		

-(int)getRangeInSecondsFrom:(NSDate*)date1 to:(NSDate*)date2 {
	NSUInteger unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	NSDateComponents *components = [self.gregorianCalendar components:unitFlags
														fromDate:date1
														  toDate:date2 options:0];
	return [components hour]*3600 + [components minute]*60 + [components second];
}

/*
-(NSString*)getHumanFriendlyDateName:(NSDate*)date extendedHumanFriendly:(BOOL)exHumanFriendly {
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    return [dateFormatter stringFromDate:date];
}
*/

-(NSString*)getHumanFriendlyDateName:(NSDate*)date extendedHumanFriendly:(BOOL)exHumanFriendly {
	NSUInteger unitFlags = (NSDayCalendarUnit);
	NSDateComponents *components = [self.gregorianCalendar components:unitFlags
                                                             fromDate:[self getCleanDate:date] toDate:[NSDate dateWithTimeIntervalSinceNow:0] options:0];
	int diff= [components day];
	if (diff == 0) {
		return NSLocalizedString(@"today",@"");
	} else if (diff == 1) {
		return NSLocalizedString(@"yesterday",@"");
	} else {
        if (exHumanFriendly && diff < 8) {
            return [NSString stringWithFormat:NSLocalizedString(@"daysago", @""), diff];
        } else {
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
            return [dateFormatter stringFromDate:date];
        }
	}    
}




-(NSString*)getHumanFriendlyDateName:(NSDate*)date {
    return [self getHumanFriendlyDateName:date extendedHumanFriendly: NO];
}
	

	// converts date to zulu timestamp (valid for XML)


-(NSString*)getZuluTimestampNew:(NSDate *)date {
	NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	[outputFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[outputFormatter setDateFormat:@"y-MM-dd'T'HH:mm:ss'Z'"];
	NSString *toRet = [outputFormatter stringFromDate:date];
	[outputFormatter release];
	return toRet;	
}

-(NSString*)getZuluTimestamp:(NSDate*)date tzOffset:(int)offset {
	NSDate* fixedDate = [self getTimestampAfterTZOffset:date tzOffset:offset];
	NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	[outputFormatter setDateFormat:@"y-MM-dd'T'HH:mm:ss'Z'"];
	NSString *toRet = [outputFormatter stringFromDate:fixedDate];
	[outputFormatter release];
	return toRet;
}

-(NSDate*)getTimestampAfterTZOffset:(NSDate*)date tzOffset:(int)offset {
	NSTimeInterval interval = [date timeIntervalSinceReferenceDate];
	interval -= offset;
	NSDate* fixedDate = [NSDate dateWithTimeIntervalSinceReferenceDate:interval];
	return fixedDate;
}

-(NSString*)getNiceDateFrom:(NSDate*)start to:(NSDate*) end {
	NSDate *currentDate = [NSDate dateWithTimeIntervalSinceNow:0];
	NSString *timeName;
	NSString *dayName;
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	[dateFormatter setDateFormat:@"HH"];
	int startHour = [[dateFormatter stringFromDate:start] intValue];
	int endHour = [[dateFormatter stringFromDate:end] intValue];
	
	int currentHour = [[dateFormatter stringFromDate:currentDate] intValue];
	
	BOOL night = NO;
	// detect, when activity occurs
	if (((startHour >= 17)) && ((endHour <= 23) && (endHour >= 17))) {
		timeName = NSLocalizedString(@"evening",@"");
	} else if (((startHour >= 17) || (startHour < 4)) && ((endHour < 10) || (endHour >= 17))) {
		timeName = NSLocalizedString(@"night",@"");
		night = YES;
	} else if ((startHour >=4) && (startHour < 12) && (endHour < 13)) {
		timeName = NSLocalizedString(@"morning",@"");
	} else if ((startHour >= 12) && (startHour < 17) && (endHour < 22) && (endHour >= 12)) {
		timeName = NSLocalizedString(@"afternoon",@"");
	} else {
		timeName = @"";
	}
	// detect which day occurrs
	NSUInteger unitFlags = (NSDayCalendarUnit);
	NSDateComponents *components = [self.gregorianCalendar components:unitFlags
														fromDate:[self getCleanDate:end] toDate:[NSDate dateWithTimeIntervalSinceNow:0] options:0];
	int diff= [components day];
	
	//	NSInteger days = [components day];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	if (([[dateFormatter dateFormat] isEqual:@"h:mm a"])) {
		if (!night) {
			[dateFormatter setDateFormat:@"h:mm"];
		} else {
			[dateFormatter setDateFormat:@"h:mma"];
		}
	}
	
	NSString *fromString = [dateFormatter stringFromDate:start];
	NSString *toString = [dateFormatter stringFromDate:end];
	
	
	if ((diff == 0) && ((night == NO) || (currentHour < 17))) {
		dayName = NSLocalizedString(@"this",@"");
	} else if ((diff == 0) && ((night == YES) && (currentHour >= 17))) {
		dayName = NSLocalizedString(@"last",@"");
	} else if ((diff == 1) && (night == NO)) {
		dayName = NSLocalizedString(@"last",@"");
	} else {
		[dateFormatter setDateStyle:NSDateFormatterShortStyle];
		[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
		dayName = [dateFormatter stringFromDate:end];
	}
	
	return [NSString stringWithFormat:@"%@%@ (%@ - %@)", dayName, timeName, fromString, toString];
}

/*
 Nice format of time
 */ 

-(NSString*)getNiceTime:(NSDate*) date {
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	NSString* str = [dateFormatter stringFromDate:date];
	return str;
}

-(NSString*)getNiceDate:(NSDate*) date {
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	NSString* str = [dateFormatter stringFromDate:date];
	return str;
}


-(NSString*)getShortNiceTime:(NSDate*) date {
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	NSString* str = [dateFormatter stringFromDate:date];
	return str;
}

-(NSString*)getShortNiceTimeDate:(NSDate*) date {
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	NSString* str = [dateFormatter stringFromDate:date];
	return str;
}


-(NSString*)getShortNiceTimeRange:(NSDate*) date date2: (NSDate*) date2 {
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	if ([self isSameMinute:date second:date2]) {
		return [dateFormatter stringFromDate:date];
	} else {
		return [NSString stringWithFormat:@"%@ - %@", [dateFormatter stringFromDate:date], [dateFormatter stringFromDate:date2]];
	}
}


-(NSDate*)getRangeFrom:(NSDate*)date1 to:(NSDate*)date2 {
	NSUInteger unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	NSDateComponents *components = [self.gregorianCalendar components:unitFlags
														fromDate:date1
														  toDate:date2 options:0];
	//	NSString *str = [NSString stringWithFormat:@"%02i:%02i:%02i", [components hour], [components minute], [components second]];
	//	return str;
	return [self naturalTimeRangeHour:[components hour] minute:[components minute] second:[components second]];
	/*	[dateFormatter setTimeStyle:NSDateFormatterFullStyle];
	 [dateFormatter setDateStyle:NSDateFormatterNoStyle];
	 */
}


-(NSString*)getHoursString:(int)count {
	if ([currentLanguage isEqualToString:@"de"]) {
		if (count == 1) {
			return @"Stunde";
		} else {
			return @"Stunden";
		}	
	} else if ([currentLanguage isEqualToString:@"cs"]) {
		if (count == 1) {
			return @"hod.";
		} else if ((count > 1) && (count < 5)) {
			return @"hod.";
		} else {
			return @"hod.";
		}
		
	} else {
		if (count == 1) {
			return @"hour";
		} else {
			return @"hours";
		}
	}
	
}
-(NSString*)getMinutesString:(int)count sh:(BOOL)sh {
	
	if ([currentLanguage isEqualToString:@"de"]) {
		if (count == 1) {
			if (sh) {
				return @"Min.";
			} else {
				return @"Minuten";
			}
		} else {
			if (sh) {
				return @"Min.";
			} else {
				return @"Minuten";
			}
			
		}	
	} else if ([currentLanguage isEqualToString:@"cs"]) {
		if (count == 1) {
			return @"min.";
		} else if ((count > 1) && (count < 5)) {
			return @"min.";
		} else {
			return @"min.";
		}
	} else {
		if (count == 1) {
			return @"minute";
		} else {
			return @"minutes";
		}
	}
}

-(NSString*)getSecondsString:(int)count  sh:(BOOL)sh{
	if ([currentLanguage isEqualToString:@"de"]) {
		if (count == 1) {
			if (sh) {
				return @"Sek.";
			} else {
				return @"Sekunde";
			}
			
		} else {
			if (sh) {
				return @"Sek.";
			} else {
				return @"Sekunden";
			}
		}
	} else if ([currentLanguage isEqualToString:@"cs"]) {
		if (count == 1) {
			return @"s";
		} else if ((count > 1) && (count < 5)) {
			return @"s";
		} else {
			return @"s";
		}
	} else {
		if (count == 1) {
			return @"second";
		} else {
			return @"seconds";
		}
	}
}


-(NSString*)naturalTimeRangeHour:(int)sec {
	int hour = sec / 3600;
	int min = (sec % 3600) / 60;
	int ss = sec - (sec / 3600) % 60;
	return [self fuzzuTimeRangeHour:hour minute:min second:ss];
}

-(NSString*)fuzzuTimeRangeHour:(int)hour minute:(int)minute second:(int)second {
	NSString* toRet;
	if ((hour == 0) && (minute == 0)) {
		if (second <= 10) {
			toRet = [NSString stringWithFormat:@"%@ %i %@", NSLocalizedString(@"less than",@""),10, [self getSecondsString:30 sh:NO]];
		} else if (second <= 30) {
			toRet = [NSString stringWithFormat:@"%@ %i %@", NSLocalizedString(@"less than",@""),30, [self getSecondsString:30 sh:NO]];
		} else if (second > 30) {
			toRet = [NSString stringWithFormat:@"%@ %i %@", NSLocalizedString(@"less than",@""),1, [self getMinutesString:1 sh:NO]];
		}
	} else if (hour == 0) {
		if (second > 30) {
			minute += 1;
		}
		toRet = [NSString stringWithFormat:@"%i %@", minute, [self getMinutesString:minute sh:NO]];
	} else {
		if (second > 30) {
			minute += 1;
		}		
		toRet = [NSString stringWithFormat:@"%i %@ %@ %i %@", hour, [self getHoursString:hour], NSLocalizedString(@"and", @""), minute, [self getMinutesString:minute sh:YES]];
	}
	return toRet;
}


-(NSString*)naturalTimeRangeHour:(int)hour minute:(int)minute second:(int)second {
	NSString* toRet;
	if ((hour == 0) && (minute == 0)) {
		toRet = [NSString stringWithFormat:@"%i %@", second, [self getSecondsString:second sh:NO]];
	} else if (hour == 0) {
		if (second > 30) {
			minute += 1;
		}
		toRet = [NSString stringWithFormat:@"%i %@", minute, [self getMinutesString:minute sh:NO]];
	} else {
		if (second > 30) {
			minute += 1;
		}		
		toRet = [NSString stringWithFormat:@"%i %@ %@ %i %@", hour, [self getHoursString:hour], NSLocalizedString(@"and", @""), minute, [self getMinutesString:minute sh:YES]];
	}
	return toRet;
}
-(NSString*)getNiceTimeRangeFrom:(NSDate*)created to:(NSDate*)finished {
	NSUInteger unitFlags = NSMinuteCalendarUnit;
	NSDateComponents *components = [self.gregorianCalendar components:unitFlags
														fromDate:created
														  toDate:finished options:0];
	NSString* toRet;
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	if ([components minute] > 20) {
		
		toRet = [NSString stringWithFormat:@"%@ %@ %@ %@",NSLocalizedString(@"from", @""),[dateFormatter stringFromDate:created],NSLocalizedString(@"to", @""),[dateFormatter stringFromDate:finished]];
	} else {
		toRet = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"from", @""),[dateFormatter stringFromDate:created]];
	}
	return toRet;
}


-(NSDate*)fixCurDate:(NSDate*)date origTz:(float)tzorg currTz: (float)tzcurr {
	NSTimeInterval interval = [date timeIntervalSinceReferenceDate];
	interval = interval + (tzorg - tzcurr);
	return [NSDate dateWithTimeIntervalSinceReferenceDate:interval];
}

	// check current timezone and if another, that TZ assigned to date, change date to be same, as in TZ grabbed
-(NSDate *)fixDateByTimezone:(NSDate*)date timeZone:(int)tz {
	NSTimeZone* destinationTimeZone = [NSTimeZone systemTimeZone];
	
	NSInteger sourceGMTOffset = [destinationTimeZone secondsFromGMTForDate:date];
	NSInteger destinationGMTOffset = tz;
	NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
	
	NSDate* destinationDate = [[[NSDate alloc] initWithTimeInterval:interval sinceDate:date] autorelease];
	return destinationDate;
}


-(NSString*)md5:( NSString *)str
{
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, strlen(cStr), result );
	return [NSString stringWithFormat:
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
	];
} 


-(NSString*)getCurrentLanguage {
	return currentLanguage;
}


-(id) init {
	self = [super init];
	
	dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setAMSymbol:@"am"];
	[dateFormatter setPMSymbol:@"pm"];
	
	_gregorianCalendar = [[NSCalendar alloc]
						 initWithCalendarIdentifier:NSGregorianCalendar];
	currentLanguage = [[[NSLocale preferredLanguages] objectAtIndex:0] retain];	
    sharedTimeToolsInstance = self;
	return self;
}

+(TSTimeTools*)getInstance {
	@synchronized (self) {
		if (!sharedTimeToolsInstance) {
			[[TSTimeTools alloc] init];
		}
	}
	return sharedTimeToolsInstance;
}

+(id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedTimeToolsInstance == nil) {
            sharedTimeToolsInstance = [super allocWithZone:zone];
            return sharedTimeToolsInstance;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

-(id)copyWithZone:(NSZone *)zone {
    return self;
}

-(id)retain {
	return self;
}

-(unsigned)retainCount {
    return UINT_MAX;  //denotes an object that cannot be release
}

-(void)release {
    //do nothing    
}


-(id)autorelease {
    return self;    
}



@end
