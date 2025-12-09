//
//  CelebrationOverlayView.h
//  PinTu
//
//  Created by Codex on 2025/12/09.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CelebrationOverlayView : UIView

+ (void)presentInView:(UIView *)view
              message:(NSString *)message
               detail:(NSString *)detail
              confirm:(dispatch_block_t)confirmHandler;

@end

NS_ASSUME_NONNULL_END
