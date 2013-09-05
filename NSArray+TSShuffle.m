//
//  NSArray+TSShuffle.m
//  mathgameballs
//
//  Created by Jindrich Sarson on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSArray+TSShuffle.h"


@implementation NSMutableArray (TSShuffle)

- (NSMutableArray*)shuffle
{
    NSUInteger count = [self count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        int nElements = count - i;
        int n = (arc4random() % nElements) + i;
        [self exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    return self;
}


@end
