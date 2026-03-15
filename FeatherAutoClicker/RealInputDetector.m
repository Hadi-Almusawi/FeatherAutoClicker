// RealInputDetector.m
#import "RealInputDetector.h"

@implementation RealInputDetector {
    IOHIDManagerRef _hidManager;
}

+ (instancetype)shared {
    static RealInputDetector *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _hidManager = IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDOptionsTypeNone);
    }
    return self;
}

- (void)startMonitoring {
}

- (void)stopMonitoring {
    if (_hidManager) {
        IOHIDManagerClose(_hidManager, kIOHIDOptionsTypeNone);
        CFRelease(_hidManager);
        _hidManager = NULL;
    }
}

- (BOOL)isEventFromRealHardware:(CGEventRef)event {
    CGEventSourceRef source = CGEventCreateSourceFromEvent(event);
    CGEventSourceStateID state = CGEventSourceGetSourceStateID(source);
    CFRelease(source);
    
    return state != kCGEventSourceStateCombinedSessionState;
}

- (NSDictionary *)getCurrentMouseInfo {
    return @{
        @"vendorID": @(0x0000),
        @"productID": @(0x0000),
        @"name": @"Unknown Mouse"
    };
}

@end