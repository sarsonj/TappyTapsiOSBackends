//
//  NSDictionary+TTSExtension.m
//  mathgameballs
//
//  Created by Jindrich Sarson on 3/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSDictionary+TTSExtension.h"


@implementation NSDictionary (TTSExtension)


-(float)floatOrDefaultForKey:(id)key default:(float)def {
    id obj = [self objectForKey:key];
    if (obj == nil) {
        return def;
    } else {
        return [obj floatValue];
    }
}


-(int)intOrDefaultForKey:(id)key default:(int)def {
    id obj = [self objectForKey:key];
    if (obj == nil) {
        return def;
    } else {
        return [obj intValue];
    }

}


@end
