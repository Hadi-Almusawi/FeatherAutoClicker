// This is SimpleBridge.h
// /Users/hadialmusawi/Desktop/FeatherAutoClicker/FeatherAutoClicker/Core/Bridges/SimpleBridge.h

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface SimpleBridge : NSObject

+ (instancetype)shared;
- (void)printMessage;
- (void)startRecognizingClick;
- (void)stopRecognizingClick;
- (void)startMonitoringHold:(NSInteger)forButton onDown:(void (^)(void))downHandler onUp:(void (^)(void))upHandler;
- (void)stopMonitoringHold;
- (void)handleHoldEvent:(NSEvent *)event;

@property (nonatomic, strong) NSEvent *globalMouseMonitor;
@property (nonatomic, strong) NSEvent *holdMouseMonitor;
@property (nonatomic, strong) NSEvent *holdGlobalMouseMonitor;

@end

NS_ASSUME_NONNULL_END 