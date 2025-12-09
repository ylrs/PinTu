//
//  DifficultySelectionView.h
//  PinTu
//
//  Created by Codex on 2025/12/09.
//

#import <UIKit/UIKit.h>
#import "PinTu/PinTuView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^DifficultySelectionHandler)(PinTuShuffleDifficulty difficulty);

@interface DifficultySelectionView : UIView

+ (void)presentInView:(UIView *)view
   defaultDifficulty:(PinTuShuffleDifficulty)defaultDifficulty
           selection:(DifficultySelectionHandler)selectionHandler
              cancel:(dispatch_block_t _Nullable)cancelHandler;

@end

NS_ASSUME_NONNULL_END
