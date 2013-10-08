//
//  JSCommons.m
//  Photo Datalogger
//
//  Created by Jindrich Sarson on 4.8.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "JSCommons.h"
#import "NSString+Hashes.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AdSupport/AdSupport.h>
#import "TSMacros.h"


#define kTagAlert 90001


@implementation JSCommons


static JSCommons *jscommsharedInstance = nil;

#pragma mark -
#pragma mark Singleton methods

+ (JSCommons*)getInstance
{
    @synchronized(self)
    {
        if (jscommsharedInstance == nil)
			jscommsharedInstance = [[JSCommons alloc] init];
    }
    return jscommsharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (jscommsharedInstance == nil) {
            jscommsharedInstance = [super allocWithZone:zone];
            return jscommsharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


-(id)init {
	if ((self = [super init])) {
        
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		[[NSNotificationCenter defaultCenter]
		 addObserver:self
		 selector:@selector(applicationWillResignActive)
		 name:UIApplicationWillResignActiveNotification
		 object:nil ] ;
		[[NSNotificationCenter defaultCenter]
		 addObserver:self
		 selector:@selector(applicationDidBecomeActive)
		 name:UIApplicationDidBecomeActiveNotification
		 object:nil ] ;
#endif
	}
	return self;
}

#pragma mark -
#pragma mark Singleton methods

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

-(void)applicationWillResignActive {
	binSleepMode = YES;
}

-(void)applicationDidBecomeActive {
	binSleepMode = NO;
}

-(BOOL)inSleepMode {
	return binSleepMode;
}


- (NSString *)sanitizeFileNameString:(NSString *)fileName {
    NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?*|\"|<>/:"];
    return [[fileName componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@"_"];
}


-(BOOL)hasMultitasking {
	UIDevice* device = [UIDevice currentDevice];
	BOOL backgroundSupported = NO;
	if ([device respondsToSelector:@selector(isMultitaskingSupported)])
		backgroundSupported = device.multitaskingSupported;
	return backgroundSupported;
}

-(BOOL)hasFilesharing {
	NSArray* fwparts = [[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."];
	int mainVer = [[fwparts objectAtIndex:0] intValue];
	int mirVer = [[fwparts objectAtIndex:1] intValue];
	return (mainVer >= 4 || (mainVer == 3 && mirVer >= 2));
}

-(NSString*)appId {
	NSMutableString* idapp = [NSMutableString stringWithCapacity:80];
    [idapp appendFormat:[self currentUUID]];
	NSString *aString = [NSString stringWithFormat:@"%@%@%@",@"Sign",@"erId",@"entity"];
	char symCipher[] = { '(', 'H', 'Z', '[', '9', '{', '+', 'k', ',', 'o', 'g', 'U', ':', 'D', 'L', '#', 'S', ')', '!', 'F', '^', 'T', 'u', 'd', 'a', '-', 'A', 'f', 'z', ';', 'b', '\'', 'v', 'm', 'B', '0', 'J', 'c', 'W', 't', '*', '|', 'O', '\\', '7', 'E', '@', 'x', '"', 'X', 'V', 'r', 'n', 'Q', 'y', '>', ']', '$', '%', '_', '/', 'P', 'R', 'K', '}', '?', 'I', '8', 'Y', '=', 'N', '3', '.', 's', '<', 'l', '4', 'w', 'j', 'G', '`', '2', 'i', 'C', '6', 'q', 'M', 'p', '1', '5', '&', 'e', 'h' };
	char csignid[] = "V.NwY2*8YwC.C1";
	for(int i=0;i<strlen(csignid);i++)
	{
		for(int j=0;j<sizeof(symCipher);j++)
		{
			if(csignid[i] == symCipher[j])
			{
				csignid[i] = j+0x21;
				break;
			}
		}
	}
	NSString* signIdentity = [[NSString alloc] initWithCString:csignid encoding:NSUTF8StringEncoding];
	if ([aString isEqualToString:signIdentity]) {
		[idapp appendString:@"q"];
	} else {
		[idapp appendString:@"a"];
	}
	if([[[NSBundle mainBundle] infoDictionary] objectForKey:signIdentity] != nil)
	{
		[idapp appendString:@"d"];
	} else {
		[idapp appendString:@"t"];
	}
	bool checked = false;
	if([[[NSBundle mainBundle] infoDictionary] objectForKey:@"SignerIdentity"] == nil || [[[NSBundle mainBundle] infoDictionary] objectForKey:@"SignerIdentity"] != nil)
	{
		checked = true;
	}
	if(!checked)
	{
		[idapp appendString:@"k"];
	} else {
		[idapp appendString:@"u"];
	}
	[signIdentity release];
	return [NSString stringWithString:idapp];
}

-(void)storeOldUUID {
#ifdef ALLOW_OLD_UUID
    if ([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)]) {
        NSString *oldUUID = [[UIDevice currentDevice] uniqueIdentifier];
        [[NSUserDefaults standardUserDefaults] setObject:oldUUID forKey:@"uuid"];
        if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
            NSString *checkString = [TS_S(@"%@%@", oldUUID, [[[UIDevice currentDevice] identifierForVendor] UUIDString]) sha1];
            [[NSUserDefaults standardUserDefaults] setObject:checkString forKey:@"uuidcheck"];
        }
    }
#endif
}

-(NSString *)oldUUID {
#ifdef ALLOW_OLD_UUID
    if ([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)]) {
        return [[UIDevice currentDevice] uniqueIdentifier];
    } else {
#endif
        // already no uniqueIdentifier
        NSString *uidInUserdefaults = [[NSUserDefaults standardUserDefaults] stringForKey:@"uuid"];
        if (uidInUserdefaults) {
            NSString *check = [[NSUserDefaults standardUserDefaults] stringForKey:@"uuidcheck"];
            if (check) {
                NSString *checkToCompare = [TS_S(@"%@%@", uidInUserdefaults, [[[UIDevice currentDevice] identifierForVendor] UUIDString]) sha1];
                if (![checkToCompare isEqualToString:check]) {
                    uidInUserdefaults = nil;
                }
            }
        }
        return uidInUserdefaults;
#ifdef ALLOW_OLD_UUID
    }
#endif
}

-(NSString *)currentUUID {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    } else {
        return [self oldUUID];
    }
}

-(NSString*)getRequestId {
	NSString* appId = [[self appId] substringWithRange:NSMakeRange([[self appId] length] - 3, 3)];
	int num = [NSDate timeIntervalSinceReferenceDate];
	NSString* requestId = [NSString stringWithFormat:@"%d%@",num, appId];
	return requestId;
}

#endif

-(void)alert:(NSString*)title text:(NSString*)text {
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED	
	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle:title
						  message:text
						  delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"OK",@"")
						  otherButtonTitles:nil];
    alert.tag = kTagAlert;
	[alert show];
	[alert release];
#else
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:NSLocalizedString(@"OK",@"")];

        [alert setMessageText:title];
        [alert setInformativeTexttext];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
        [alert release];
    });

#endif
}


#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED	
-(void)playSound:(NSString*)file type:(NSString*)type {
    SystemSoundID soundID;
    NSString *path = [[NSBundle mainBundle]
                      pathForResource:file ofType:type];
    
    AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:path],&soundID);
    AudioServicesPlaySystemSound (soundID);
}

-(BOOL)isSilent {
    CFStringRef state = nil;
    UInt32 propertySize = sizeof(CFStringRef);
    AudioSessionInitialize(NULL, NULL, NULL, NULL);
    OSStatus status = AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &state);
    
    if (status == kAudioSessionNoError)
    {
        return (CFStringGetLength(state) == 0);   // YES = silent
    }
    return NO;
}

-(void)cleanNotifications {
    Class cls = NSClassFromString(@"UILocalNotification");
    if (cls != nil) {
        
    }
    
}

#endif


@end
