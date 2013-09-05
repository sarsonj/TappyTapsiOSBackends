//
//  NSDictionary+TTSExtension.h
//  mathgameballs
//
//  Created by Jindrich Sarson on 3/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDictionary (TTSExtension)

-(float)floatOrDefaultForKey:(id)key default:(float)def;
-(int)intOrDefaultForKey:(id)key default:(int)def;


@end
