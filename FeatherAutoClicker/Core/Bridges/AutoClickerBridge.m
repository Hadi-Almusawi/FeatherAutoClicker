// This is AutoClickerBridge.m
// /Users/hadialmusawi/Desktop/FeatherAutoClicker/FeatherAutoClicker/Core/Bridges/AutoClickerBridge.m

#import "AutoClickerBridge.h"
#import <ApplicationServices/ApplicationServices.h>

@implementation AutoClickerBridge {
    NSTimer *clickTimer;
    BOOL isRandomized;
}

+ (instancetype)shared {
    static AutoClickerBridge *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)startClicking:(float)speed isRight:(BOOL)isRight {
    [self stopClicking];
    
    NSTimeInterval interval = 1.0 / speed;
    
    clickTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                target:self
                                              selector:@selector(handleClick:)
                                              userInfo:@{@"isRight": @(isRight)}
                                               repeats:YES];
}

- (void)stopClicking {
    [clickTimer invalidate];
    clickTimer = nil;
}

- (void)setRandomization:(BOOL)enabled {
    self.isRandomized = enabled;
}

- (void)handleClick:(NSTimer *)timer {
    BOOL isRight = [timer.userInfo[@"isRight"] boolValue];
    
    if (self.isRandomized) {
        // 10% chance of spike
        if (arc4random_uniform(100) < 10) {
            // 50/50 chance to either double click or skip
            if (arc4random_uniform(2) == 0) {
                // Double click by sending two clicks immediately
                [self performSingleClick:isRight];
                [self performSingleClick:isRight];
                return;
            } else {
                // Skip this click
                return;
            }
        }
    }
    
    [self performSingleClick:isRight];
}

- (void)performSingleClick:(BOOL)isRight {
    NSPoint currentLocation = [NSEvent mouseLocation];
    
    // Convert NSPoint to CGPoint with proper screen coordinates
    CGDirectDisplayID displayID = CGMainDisplayID();
    CGFloat screenHeight = CGDisplayPixelsHigh(displayID);
    
    CGPoint clickPoint = CGPointMake(currentLocation.x, 
                                   screenHeight - currentLocation.y);
    
    CGEventRef down = CGEventCreateMouseEvent(NULL,
                                            isRight ? kCGEventRightMouseDown : kCGEventLeftMouseDown,
                                            clickPoint,
                                            isRight ? kCGMouseButtonRight : kCGMouseButtonLeft);
    
    CGEventRef up = CGEventCreateMouseEvent(NULL,
                                          isRight ? kCGEventRightMouseUp : kCGEventLeftMouseUp,
                                          clickPoint,
                                          isRight ? kCGMouseButtonRight : kCGMouseButtonLeft);
    
    CGEventPost(kCGHIDEventTap, down);
    CGEventPost(kCGHIDEventTap, up);
    
    CFRelease(down);
    CFRelease(up);
}

- (BOOL)requestAccessibilityPermissions {
    return AXIsProcessTrusted();
}

- (void)showAccessibilityAlert {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Accessibility Access Required"];
    [alert setInformativeText:@"Please enable accessibility access in System Settings > Privacy & Security > Accessibility"];
    [alert addButtonWithTitle:@"Open Settings"];
    [alert addButtonWithTitle:@"Cancel"];
    
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        NSURL *url = [NSURL URLWithString:@"x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"];
        [[NSWorkspace sharedWorkspace] openURL:url];
    }
}

- (void)startClickingAtPoint:(NSPoint)point {
}

@end 