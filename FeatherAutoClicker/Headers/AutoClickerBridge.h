// This is AutoClickerBridge.h

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface AutoClickerBridge : NSObject

@property (nonatomic, assign) float clickSpeed;
@property (nonatomic, assign) BOOL isRandomized;
@property (nonatomic, assign, readonly) BOOL isClicking;

+ (instancetype)shared;
- (void)startClicking:(float)speed isRight:(BOOL)isRight;
- (void)stopClicking;
- (void)setRandomization:(BOOL)enabled;
- (BOOL)requestAccessibilityPermissions;
- (void)showAccessibilityAlert;

@end

NS_ASSUME_NONNULL_END 