//
//  PinTuView.h
//  TestDemo
//
//  Created by yw on 15/2/27.
//  Copyright (c) 2015年 YLRS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageViewOne.h"

@class PinTuView;

@protocol PinTuViewDelegate <NSObject>
- (void)pinTuViewDidComplete:(PinTuView *)puzzleView;
@end

typedef NS_ENUM(NSInteger, PinTuShuffleDifficulty) {
    PinTuShuffleDifficultySimple = 0,
    PinTuShuffleDifficultyHard,
    PinTuShuffleDifficultyHell
};

@interface PinTuView : UIView<ImageViewDelegate>
{
    float imageWidth;
    NSMutableArray *imageFrames;
    BOOL _shouldShowIndices;
    BOOL _hasCompleted;
    NSMutableArray<NSNumber *> *autoSolveOrder;
    NSMutableArray<NSNumber *> *boardPositions;
    NSInteger blankIndex;
}
@property(nonatomic,strong)NSMutableArray<ImageViewOne *> *imageArrays;
@property(nonatomic,weak)id<PinTuViewDelegate>completionDelegate;
@property (nonatomic, assign) PinTuShuffleDifficulty shuffleDifficulty;
@property (nonatomic, assign) NSInteger gridSize;
-(void)finish;
- (void)configureWithImage:(UIImage *)sourceImage;
- (void)showIndexOverlay:(BOOL)show;
- (void)resetAutoSolveProgress;
- (void)prepareAutoSolveOrderAsyncWithCompletion:(void (^)(BOOL success))completion;
- (void)performAutoSolveStepWithCompletion:(void (^)(BOOL hasMore))completion;
- (void)applyShuffleWithDifficulty:(PinTuShuffleDifficulty)difficulty;
+ (NSString *)displayNameForDifficulty:(PinTuShuffleDifficulty)difficulty;
@end
