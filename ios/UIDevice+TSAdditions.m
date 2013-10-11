@implementation UIDevice( TSAdditions )

- ( NSUInteger )systemMajorVersion
{
    NSString * versionString;
    
    versionString = [ self systemVersion ];
    
    return ( NSUInteger )[ versionString doubleValue ];
}

@end