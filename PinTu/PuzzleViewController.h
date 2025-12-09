//
//  PuzzleViewController.h
//  PinTu
//  Created by Codex on 2024/10/05.

#import <UIKit/UIKit.h>
#import "PinTu/PinTuView.h"

@interface PuzzleViewController : UIViewController

- (instancetype)initWithImage:(UIImage *)image;
- (instancetype)initWithImage:(UIImage *)image difficulty:(PinTuShuffleDifficulty)difficulty NS_DESIGNATED_INITIALIZER;

@end
