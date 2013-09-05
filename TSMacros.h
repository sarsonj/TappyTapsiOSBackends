//
//  TSMacros.h
//  mathgameballs
//
//  Created by Jindrich Sarson on 4/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#define CGPointMiddle(position, size) CGPointMake(position.x - size.width / 2.0, position.y - size.height / 2.0)

#define CCH(obj, y) obj.contentSize.height - y

#define _(str) NSLocalizedString(str, @"")

// check persistent boolean
#define pbool(str) ([[NSUserDefaults standardUserDefaults] integerForKey:str] == 1)

#define TS_S(_str, ...)      [NSString stringWithFormat: _str, ##__VA_ARGS__]