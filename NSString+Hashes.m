//
// Created by sarsonj on 08.04.13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CommonCrypto/CommonDigest.h>
#import "NSString+Hashes.h"


@implementation NSString (Hashes)


- (NSString *)sha1 {
    const char *cStr = [self UTF8String];
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(cStr, strlen(cStr), result);
    NSString *s = [NSString  stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4],
            result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12],
            result[13], result[14], result[15],
            result[16], result[17], result[18], result[19]
    ];
    return s;
}

-(int)lenWithoutLeadingTrailingWhitespaces {
    return [[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length];
}


@end