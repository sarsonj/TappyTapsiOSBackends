//
//  TTPausableTimer.m
//  baby monitor 5
//
//  Created by Jindrich Sarson on 22.10.10.
//  Copyright 2010 TappyTaps s.r.o.. All rights reserved.
//

#import "TTPausableTimer.h"


@implementation TTPausableTimer

@synthesize timer;

+ (TTPausableTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds target:(id)target selector:(SEL)aSelector userInfo:(id)userInfo {
	TTPausableTimer *timer = [[[TTPausableTimer alloc] init] autorelease];
	timer->period = seconds;
	timer->target = target;
	timer->selector = aSelector;
	timer->userInfo = userInfo;
	timer->paused = YES;
	[timer resume];
	return timer;
}

-(void)scheduleTimerByObjData {
	self.timer = [NSTimer scheduledTimerWithTimeInterval:self->period target:self->target selector:self->selector userInfo:self->userInfo repeats:YES];
	
}


-(void)pause {
	if (!paused) {
		[self.timer invalidate];
		self.timer = nil;
		paused = YES;
	}
}

-(void)resume {
	if (paused) {
		[self scheduleTimerByObjData];
		paused = NO;		
	}
}

-(void)invalidate {
    [self.timer invalidate];
    self.timer = nil;
    paused = YES;
}

-(void)dealloc {
    [super dealloc];
	if (!paused) {
		[self.timer invalidate];
	}
}

@end
