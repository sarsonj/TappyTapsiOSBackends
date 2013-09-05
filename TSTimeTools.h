//
//  TimeTools.h
//  Photo Datalogger
//
//  Created by Jindrich Sarson on 10/5/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TSTimeTools : NSObject {
	NSDateFormatter* dateFormatter;
	NSCalendar* _gregorianCalendar;
	NSString* currentLanguage;
}

+(TSTimeTools*)getInstance;

-(BOOL)isSameDay:(NSDate*)dat1 second:(NSDate*)dat2;
-(NSDate*)setDateComponents:(NSDate*)date hour:(int)hour minute:(int)minute second:(int)second;

-(NSString*)getNiceDateFrom:(NSDate*)start to:(NSDate*) end;
-(NSString*)getNiceTime:(NSDate*) date;
-(NSString*)getNiceDate:(NSDate*) date;
-(NSDate*)getRangeFrom:(NSDate*)date1 to:(NSDate*)date2;
-(int)getRangeInSecondsFrom:(NSDate*)date1 to:(NSDate*)date2;
-(NSString*)getShortNiceTimeRange:(NSDate*) date date2: (NSDate*) date;
-(NSString*)getHoursString:(int)count;
-(NSString*)getMinutesString:(int)count sh:(BOOL)sh;
-(NSString*)getSecondsString:(int)count  sh:(BOOL)sh;
-(NSString*)naturalTimeRangeHour:(int)hour minute:(int)minute second:(int)second;
-(NSString*)naturalTimeRangeHour:(int)sec;
-(NSString*)getHumanFriendlyDateName:(NSDate*)date;
-(NSString*)getHumanFriendlyDateName:(NSDate*)date extendedHumanFriendly:(BOOL)exHumanFriendly;
-(NSDate*)getCleanDate:(NSDate*) date;

-(NSDate*)getTimestampAfterTZOffset:(NSDate*)date tzOffset:(int)offset;
-(NSString*)getZuluTimestamp:(NSDate*)date tzOffset:(int)offset;

-(NSString *) md5:( NSString *)str;

-(NSDate *)fixDateByTimezone:(NSDate*)date timeZone:(int)tz;
	



@property (nonatomic, retain) NSString* currentLanguage;
@property (nonatomic, readonly) NSCalendar*  gregorianCalendar;


@end
