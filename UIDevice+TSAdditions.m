#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED

@implementation UIDevice( TSAdditions )

- ( NSUInteger )systemMajorVersion
{
    NSString * versionString;
    
    versionString = [ self systemVersion ];
    
    return ( NSUInteger )[ versionString doubleValue ];
}

@end

#endif