//
//  TTPausableTimer.h
//  baby monitor 5
//
//  Created by Jindrich Sarson on 22.10.10.
//  Copyright 2010 TappyTaps s.r.o.. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Works as a classic timer, but supports pause / resume
 */

@interface TTPausableTimer : NSObject {
	NSTimer* timer;
	float period;
	id target;
	SEL selector;
	id userInfo;
	BOOL paused;
}

+ (TTPausableTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds target:(id)target selector:(SEL)aSelector userInfo:(id)userInfo;
-(void)pause;
-(void)resume;

- (void)invalidate;


@property(nonatomic, retain) NSTimer* timer;

@end
