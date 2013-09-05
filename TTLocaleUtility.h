//
//  TTLocaleUtility.h
//  baby monitor 5
//
//  Created by Jindrich Sarson on 28.10.10.
//  Copyright 2010 TappyTaps s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"

@interface TTLocaleUtility : NSObject {
    NSArray *supportedLanguages;

}

@property(nonatomic, retain) NSArray *supportedLanguages;

+(id)sharedTTLocaleUtility;
-(NSString*)currentLanguage;
-(NSString*)currentAndSupportedLanguage;
+(NSString*)myLang;



@end
