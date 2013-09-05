//
//  TTGuiTools.m
//  babymonitor
//
//  Created by sarsonj on 11/5/10.
//  Copyright 2010 TappyTaps s.r.o. All rights reserved.
//

#import "TTGuiTools.h"


@implementation TTGuiTools




+(void)alert:(NSString*)title message:(NSString*)msg {
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: title message: msg delegate: self cancelButtonTitle: NSLocalizedString(@"Ok",@"") otherButtonTitles: nil];
	[alert show];
	[alert release];
#else
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:NSLocalizedString(@"Ok",@"")];
        
        [alert setMessageText:title];
        [alert setInformativeText:msg];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
        [alert release];
    });
#endif
}



@end
