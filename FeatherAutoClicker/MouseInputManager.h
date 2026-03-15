// this is MouseInputManager.h
// /Users/hadialmusawi/Desktop/FeatherAutoClicker/FeatherAutoClicker/MouseInputManager.h

#import <Foundation/Foundation.h>
#import <IOKit/hid/IOHIDManager.h>

@interface MouseInputManager : NSObject

@property (nonatomic, readonly) double rawDX;
@property (nonatomic, readonly) double rawDY;
@property (nonatomic, readonly) BOOL button1;
@property (nonatomic, readonly) BOOL button2;
@property (nonatomic, readonly) float scrollWheel;
@property (nonatomic, readonly) NSInteger pollRate;  // Mouse refresh rate in Hz

+ (instancetype)shared;
- (void)startMonitoring;
- (void)stopMonitoring;

@end 