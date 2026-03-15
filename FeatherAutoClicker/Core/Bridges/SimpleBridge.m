// This is SimpleBridge.m
// /Users/hadialmusawi/Desktop/FeatherAutoClicker/FeatherAutoClicker/Core/Bridges/SimpleBridge.m
#import "SimpleBridge.h"
#import "RealInputDetector.h"

@interface SimpleBridge ()
@property (nonatomic, assign) BOOL isRecognizing;
@property (nonatomic, strong) NSEvent *mouseMonitor;
@property (nonatomic, assign) NSInteger holdTargetButtonNumber;
@property (nonatomic, copy) void (^holdDownHandler)(void);
@property (nonatomic, copy) void (^holdUpHandler)(void);
@end

@implementation SimpleBridge

+ (instancetype)shared {
    static SimpleBridge *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)printMessage {
    NSLog(@"obj c");
}

- (void)startRecognizingClick {
    if (self.isRecognizing) return;
    
    self.isRecognizing = YES;
    
    // Local monitor for when app is in focus
    self.mouseMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:
                        (NSEventMaskLeftMouseDown | 
                         NSEventMaskRightMouseDown | 
                         NSEventMaskOtherMouseDown)
                                                             handler:^NSEvent * _Nullable(NSEvent * event) {
        [self handleMouseEvent:event];
        return event;
    }];
    
    // Global monitor for when app is not in focus
    self.globalMouseMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:
                             (NSEventMaskLeftMouseDown | 
                              NSEventMaskRightMouseDown | 
                              NSEventMaskOtherMouseDown)
                                                                    handler:^(NSEvent * event) {
        [self handleMouseEvent:event];
    }];
}

- (void)stopRecognizingClick {
    if (!self.isRecognizing) return;
    
    self.isRecognizing = NO;
    
    if (self.mouseMonitor) {
        [NSEvent removeMonitor:self.mouseMonitor];
        self.mouseMonitor = nil;
    }
    
    if (self.globalMouseMonitor) {
        [NSEvent removeMonitor:self.globalMouseMonitor];
        self.globalMouseMonitor = nil;
    }
}

- (void)handleMouseEvent:(NSEvent *)event {
    switch (event.type) {
        case NSEventTypeLeftMouseDown:
            NSLog(@"Left mouse button clicked! (M1)");
            break;
            
        case NSEventTypeRightMouseDown:
            NSLog(@"Right mouse button clicked! (M2)");
            break;
            
        case NSEventTypeOtherMouseDown:
            switch (event.buttonNumber) {
                case 2:
                    NSLog(@"Middle mouse button clicked! (M3)");
                    break;
                case 3:
                    NSLog(@"Side button 1 clicked! (M4)");
                    break;
                case 4:
                    NSLog(@"Side button 2 clicked! (M5)");
                    break;
                default:
                    NSLog(@"Mouse button %ld clicked!", (long)event.buttonNumber);
                    break;
            }
            break;
            
        default:
            break;
    }
}

- (void)startMonitoringHold:(NSInteger)forButton onDown:(void (^)(void))downHandler onUp:(void (^)(void))upHandler {
    if (!AXIsProcessTrusted()) return;
    
    [self stopMonitoringHold];
    
    self.holdTargetButtonNumber = forButton;
    self.holdDownHandler = [downHandler copy];
    self.holdUpHandler = [upHandler copy];
    
    NSEventMask eventMask = NSEventMaskLeftMouseDown | NSEventMaskRightMouseDown | NSEventMaskOtherMouseDown |
                            NSEventMaskLeftMouseUp | NSEventMaskRightMouseUp | NSEventMaskOtherMouseUp;
    
    self.holdMouseMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:eventMask handler:^NSEvent *(NSEvent *event) {
        [self handleHoldEvent:event];
        return event;
    }];
    
    self.holdGlobalMouseMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:eventMask handler:^(NSEvent *event) {
        [self handleHoldEvent:event];
    }];
}

- (void)stopMonitoringHold {
    if (self.holdMouseMonitor) {
        [NSEvent removeMonitor:self.holdMouseMonitor];
        self.holdMouseMonitor = nil;
    }
    if (self.holdGlobalMouseMonitor) {
        [NSEvent removeMonitor:self.holdGlobalMouseMonitor];
        self.holdGlobalMouseMonitor = nil;
    }
    self.holdTargetButtonNumber = -1;
    self.holdDownHandler = nil;
    self.holdUpHandler = nil;
}

- (void)handleHoldEvent:(NSEvent *)event {
    if (!AXIsProcessTrusted()) return;
    
    NSInteger eventButtonNumber = -1;
    BOOL isDown = NO;
    
    switch (event.type) {
        case NSEventTypeLeftMouseDown:
            eventButtonNumber = 0;
            isDown = YES;
            break;
        case NSEventTypeLeftMouseUp:
            eventButtonNumber = 0;
            isDown = NO;
            break;
        case NSEventTypeRightMouseDown:
            eventButtonNumber = 1;
            isDown = YES;
            break;
        case NSEventTypeRightMouseUp:
            eventButtonNumber = 1;
            isDown = NO;
            break;
        case NSEventTypeOtherMouseDown:
            eventButtonNumber = event.buttonNumber;
            isDown = YES;
            break;
        case NSEventTypeOtherMouseUp:
            eventButtonNumber = event.buttonNumber;
            isDown = NO;
            break;
        default:
            break;
    }
    
    if (eventButtonNumber == self.holdTargetButtonNumber) {
        if (isDown && self.holdDownHandler) {
            self.holdDownHandler();
        } else if (!isDown && self.holdUpHandler) {
            self.holdUpHandler();
        }
    }
}

@end 