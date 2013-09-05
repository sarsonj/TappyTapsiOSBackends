//
//  TTLocaleUtility.m
//  baby monitor 5
//
//  Created by Jindrich Sarson on 28.10.10.
//  Copyright 2010 TappyTaps s.r.o. All rights reserved.
//

#import "TTLocaleUtility.h"


@implementation TTLocaleUtility

static NSString* currentLanguage;

SYNTHESIZE_SINGLETON_FOR_CLASS(TTLocaleUtility)
@synthesize supportedLanguages;


+(NSString*)myLang {
    if (currentLanguage == nil) {
        currentLanguage = [NSLocale preferredLanguages][0];
    }
    return currentLanguage;
}

-(NSString*)currentLanguage {
	return  [NSLocale preferredLanguages][0];
}

- (NSString *)currentAndSupportedLanguage {
    NSString *tmpLng = [self currentLanguage];
    if ([supportedLanguages containsObject:tmpLng]) {
        return tmpLng;
    } else {
        return @"en";
    }
}




@end
