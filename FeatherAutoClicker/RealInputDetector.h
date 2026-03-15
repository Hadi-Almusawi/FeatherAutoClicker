// this is RealInputDetector.h
// /Users/hadialmusawi/Desktop/FeatherAutoClicker/FeatherAutoClicker/RealInputDetector.h

#import <Foundation/Foundation.h>
#import <IOKit/hid/IOHIDLib.h>
#import <CoreGraphics/CoreGraphics.h>

@interface RealInputDetector : NSObject

@property (nonatomic, readonly) BOOL isRealInput;
@property (nonatomic, readonly) NSString *deviceName;
@property (nonatomic, readonly) BOOL isGamingMouse;

+ (instancetype)shared;
- (void)startMonitoring;
- (void)stopMonitoring;
- (BOOL)isEventFromRealHardware:(CGEventRef)event;
- (NSDictionary *)getCurrentMouseInfo;

@end 