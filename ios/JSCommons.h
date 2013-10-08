//
//  JSCommons.h
//  Photo Datalogger
//
//  Created by Jindrich Sarson on 4.8.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

@interface JSCommons : NSObject {
	BOOL binSleepMode;
}

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED	
-(BOOL)hasMultitasking;
-(BOOL)hasFilesharing;

+ (JSCommons *)getInstance;

-(BOOL)inSleepMode;

- (NSString *)sanitizeFileNameString:(NSString *)fileName;

-(NSString*)appId;
-(BOOL)isSilent;
-(void)playSound:(NSString*)file type:(NSString*)type;

#endif

- (void)storeOldUUID;

- (NSString *)oldUUID;

- (NSString *)currentUUID;

-(void)alert:(NSString*)title text:(NSString*)text;

@end
