//
//  PinTuView.m
//  TestDemo
//
//  Created by yw on 15/2/27.
//  Copyright (c) 2015年 YLRS. All rights reserved.
//

#import "PinTuView.h"
#import <stdlib.h>
#import <string.h>

static inline NSInteger PTRowForIndex(NSInteger index) {
    return index / 4;
}

static inline NSInteger PTColForIndex(NSInteger index) {
    return index % 4;
}

@interface PinTuView ()
- (CGRect)frameForBoardIndex:(NSInteger)index;
- (void)resetBoardToSolvedConfiguration;
- (NSInteger)positionOfTileValue:(NSInteger)value;
- (BOOL)prepareAutoSolveOrder;
- (NSArray<NSNumber *> *)solveCurrentBoardState;
- (NSInteger)manhattanDistanceForState:(NSArray<NSNumber *> *)state;
- (BOOL)isSolvedBoard;
- (void)notifyCompletionIfNeeded;
- (NSInteger)idaSearchWithBoard:(int *)board blank:(int)blank depth:(int)depth threshold:(int)threshold lastMove:(int)lastMove path:(NSMutableArray<NSNumber *> *)path;
- (NSInteger)manhattanDistanceForBoardValues:(const int *)board length:(int)length;
@end

@implementation PinTuView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _shouldShowIndices = NO;
        _hasCompleted = NO;
        _shuffleDifficulty = PinTuShuffleDifficultyHard;
        imageWidth = frame.size.width/4.0f;
        self.image1  = [[ImageViewOne alloc] init];
        self.image2  = [[ImageViewOne alloc] init];
        self.image3  = [[ImageViewOne alloc] init];
        self.image4  = [[ImageViewOne alloc] init];
        self.image5  = [[ImageViewOne alloc] init];
        self.image6  = [[ImageViewOne alloc] init];
        self.image7  = [[ImageViewOne alloc] init];
        self.image8  = [[ImageViewOne alloc] init];
        self.image9  = [[ImageViewOne alloc] init];
        self.image10 = [[ImageViewOne alloc] init];
        self.image11 = [[ImageViewOne alloc] init];
        self.image12 = [[ImageViewOne alloc] init];
        self.image13 = [[ImageViewOne alloc] init];
        self.image14 = [[ImageViewOne alloc] init];
        self.image15 = [[ImageViewOne alloc] init];
        self.image16 = [[ImageViewOne alloc] init];
        
        imageFrames = [[NSMutableArray alloc] initWithCapacity:16];
        autoSolveOrder = [[NSMutableArray alloc] init];
        boardPositions = [[NSMutableArray alloc] initWithCapacity:16];
        blankIndex = 15;
        
        self.imageArrays = @[
            self.image1, self.image2, self.image3, self.image4,
            self.image5, self.image6, self.image7, self.image8,
            self.image9, self.image10, self.image11, self.image12,
            self.image13, self.image14, self.image15
        ];
        [self initImagesWith:imageWidth];
    }
    return self;
}

-(void)finish
{
    for (NSInteger idx = 0; idx < self.imageArrays.count; idx++) {
        ImageViewOne *image = self.imageArrays[idx];
        image.frame = [self frameForBoardIndex:idx];
    }
    [self resetBoardToSolvedConfiguration];
    _hasCompleted = NO;
    [self checkComplete];
}

-(void)initImagesWith:(float)width
{
    _hasCompleted = NO;
    [autoSolveOrder removeAllObjects];
    [imageFrames removeAllObjects];
    
    NSInteger totalPositions = 16;
    for (NSInteger position = 0; position < totalPositions; position++) {
        NSInteger col = PTColForIndex(position);
        NSInteger row = PTRowForIndex(position);
        CGRect frame = CGRectMake(col * width, row * width, width, width);
        [imageFrames addObject:NSStringFromCGRect(frame)];
        if (position < self.imageArrays.count) {
            ImageViewOne *image = self.imageArrays[position];
            image.delegate = self;
            image.frame = frame;
            image.tag = position;
            if (!image.superview) {
                [self addSubview:image];
            }
            [image setLabelName:[NSString stringWithFormat:@"%ld", (long)position + 1]];
            [image setLabelHidden:!_shouldShowIndices];
        }
    }
    
    [self resetBoardToSolvedConfiguration];
    
    UILabel *lineX1 = [[UILabel alloc] init];
    lineX1.frame = CGRectMake(self.frame.size.width/4.0f, 0, 1, self.frame.size.height);
    lineX1.backgroundColor = [UIColor grayColor];
    [self addSubview:lineX1];
    
    UILabel *lineX2 = [[UILabel alloc] init];
    lineX2.frame = CGRectMake(self.frame.size.width/2.0f, 0, 1, self.frame.size.height);
    lineX2.backgroundColor = [UIColor grayColor];
    [self addSubview:lineX2];

    UILabel *lineX3 = [[UILabel alloc] init];
    lineX3.frame = CGRectMake(self.frame.size.width/4.0f*3.0f, 0, 1, self.frame.size.height);
    lineX3.backgroundColor = [UIColor grayColor];
    [self addSubview:lineX3];

    UILabel *lineY1 = [[UILabel alloc] init];
    lineY1.frame = CGRectMake(0, self.frame.size.height/4.0f, self.frame.size.width, 1);
    lineY1.backgroundColor = [UIColor grayColor];
    [self addSubview:lineY1];
    
    UILabel *lineY2 = [[UILabel alloc] init];
    lineY2.frame = CGRectMake(0, self.frame.size.height/2.0f, self.frame.size.width, 1);
    lineY2.backgroundColor = [UIColor grayColor];
    [self addSubview:lineY2];
    
    UILabel *lineY3 = [[UILabel alloc] init];
    lineY3.frame = CGRectMake(0, self.frame.size.height/4.0f*3.0f, self.frame.size.width, 1);
    lineY3.backgroundColor = [UIColor grayColor];
    [self addSubview:lineY3];
}

- (void)configureWithImage:(UIImage *)sourceImage
{
    if (!sourceImage) {
        return;
    }
    _hasCompleted = NO;
    [self resetBoardToSolvedConfiguration];
    [autoSolveOrder removeAllObjects];
    
    NSArray *tileImages = [self tileImagesFromSource:sourceImage];
    if (tileImages.count != self.imageArrays.count) {
        return;
    }
    for (NSInteger index = 0; index < self.imageArrays.count; index++) {
        ImageViewOne *tileView = self.imageArrays[index];
        UIImage *tileImage = tileImages[index];
        [tileView setTileImage:tileImage];
        [tileView setLabelHidden:!_shouldShowIndices];
    }
}

- (NSArray *)tileImagesFromSource:(UIImage *)sourceImage
{
    CGImageRef cgImage = sourceImage.CGImage;
    if (!cgImage) {
        return @[];
    }
    size_t pixelWidth = CGImageGetWidth(cgImage);
    size_t pixelHeight = CGImageGetHeight(cgImage);
    size_t minSide = MIN(pixelWidth, pixelHeight);
    if (minSide == 0) {
        return @[];
    }
    CGRect squareRect = CGRectMake((pixelWidth - minSide)/2.0f, (pixelHeight - minSide)/2.0f, minSide, minSide);
    CGFloat tileSide = minSide / 4.0f;
    NSMutableArray *tiles = [NSMutableArray arrayWithCapacity:self.imageArrays.count];
    for (NSInteger index = 0; index < self.imageArrays.count; index++) {
        NSInteger col = PTColForIndex(index);
        NSInteger row = PTRowForIndex(index);
        CGRect tileRect = CGRectMake(squareRect.origin.x + col * tileSide,
                                     squareRect.origin.y + row * tileSide,
                                     tileSide,
                                     tileSide);
        CGImageRef tileRef = CGImageCreateWithImageInRect(cgImage, tileRect);
        if (tileRef) {
            UIImage *tileImage = [UIImage imageWithCGImage:tileRef scale:sourceImage.scale orientation:sourceImage.imageOrientation];
            [tiles addObject:tileImage];
            CGImageRelease(tileRef);
        } else {
            [tiles addObject:[[UIImage alloc] init]];
        }
    }
    return tiles;
}

-(void)showIndexOverlay:(BOOL)show
{
    _shouldShowIndices = show;
    for (NSInteger index = 0; index < self.imageArrays.count; index++) {
        ImageViewOne *tileView = self.imageArrays[index];
        [tileView setLabelHidden:!show];
        [tileView setLabelName:[NSString stringWithFormat:@"%ld", (long)index + 1]];
    }
}

- (void)applyShuffleWithDifficulty:(PinTuShuffleDifficulty)difficulty
{
    self.shuffleDifficulty = difficulty;
    [self shuffleTiles];
}

+ (NSString *)displayNameForDifficulty:(PinTuShuffleDifficulty)difficulty
{
    switch (difficulty) {
        case PinTuShuffleDifficultySimple:
            return @"简单";
        case PinTuShuffleDifficultyHard:
            return @"困难";
        case PinTuShuffleDifficultyHell:
            return @"地狱";
    }
    return @"未知";
}

- (NSInteger)shuffleStepCountForCurrentDifficulty
{
    switch (self.shuffleDifficulty) {
        case PinTuShuffleDifficultySimple:
            return 20;
        case PinTuShuffleDifficultyHard:
            return 160;
        case PinTuShuffleDifficultyHell:
            return 320;
    }
    return 160;
}

- (void)shuffleTiles
{
    if (self.imageArrays.count == 0 || imageFrames.count < 16) {
        return;
    }
    [autoSolveOrder removeAllObjects];
    [self resetBoardToSolvedConfiguration];
    
    NSInteger shuffleSteps = [self shuffleStepCountForCurrentDifficulty];
    NSInteger lastDirection = -1;
    static const NSInteger offsets[4] = { -4, 4, -1, 1 };
    static const NSInteger rowAdjust[4] = { -1, 1, 0, 0 };
    static const NSInteger colAdjust[4] = { 0, 0, -1, 1 };
    
    for (NSInteger step = 0; step < shuffleSteps; step++) {
        NSInteger blankRow = PTRowForIndex(blankIndex);
        NSInteger blankCol = PTColForIndex(blankIndex);
        NSInteger candidateDirections[4];
        NSInteger candidateCount = 0;
        for (NSInteger dir = 0; dir < 4; dir++) {
            if (lastDirection != -1 && ((dir ^ 1) == lastDirection)) {
                continue;
            }
            NSInteger nextRow = blankRow + rowAdjust[dir];
            NSInteger nextCol = blankCol + colAdjust[dir];
            if (nextRow < 0 || nextRow > 3 || nextCol < 0 || nextCol > 3) {
                continue;
            }
            candidateDirections[candidateCount++] = dir;
        }
        if (candidateCount == 0) {
            lastDirection = -1;
            continue;
        }
        NSInteger chosenDir = candidateDirections[arc4random_uniform((uint32_t)candidateCount)];
        NSInteger neighborIndex = blankIndex + offsets[chosenDir];
        NSNumber *tileNumber = boardPositions[neighborIndex];
        if (!tileNumber || tileNumber.integerValue == 0) {
            continue;
        }
        boardPositions[blankIndex] = tileNumber;
        boardPositions[neighborIndex] = @(0);
        blankIndex = neighborIndex;
        lastDirection = chosenDir;
    }
    
    if ([self isSolvedBoard]) {
        NSInteger neighborIndex = blankIndex - 1;
        if (neighborIndex >= 0 && neighborIndex < boardPositions.count) {
            NSNumber *tileNumber = boardPositions[neighborIndex];
            boardPositions[blankIndex] = tileNumber;
            boardPositions[neighborIndex] = @(0);
            blankIndex = neighborIndex;
        }
    }
    
    for (NSInteger position = 0; position < boardPositions.count; position++) {
        NSInteger tileValue = boardPositions[position].integerValue;
        if (tileValue <= 0 || tileValue > self.imageArrays.count) {
            continue;
        }
        ImageViewOne *tile = self.imageArrays[tileValue - 1];
        tile.frame = [self frameForBoardIndex:position];
    }
    _hasCompleted = NO;
}

- (BOOL)isSolvedPermutation:(NSArray<NSNumber *> *)permutation
{
    for (NSInteger i = 0; i < permutation.count; i++) {
        if (permutation[i].integerValue != i) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)isSolvablePermutation:(NSArray<NSNumber *> *)permutation
{
    NSInteger inversions = 0;
    for (NSInteger i = 0; i < permutation.count; i++) {
        NSInteger valueI = permutation[i].integerValue;
        for (NSInteger j = i + 1; j < permutation.count; j++) {
            NSInteger valueJ = permutation[j].integerValue;
            if (valueI > valueJ) {
                inversions++;
            }
        }
    }
    NSInteger blankRowFromBottom = 1;
    return ((inversions + blankRowFromBottom) % 2 == 0);
}

-(void)resetAutoSolveProgress
{
    _hasCompleted = NO;
    [autoSolveOrder removeAllObjects];
}

-(void)performAutoSolveStepWithCompletion:(void (^)(BOOL hasMore))completion
{
    if (![self prepareAutoSolveOrder]) {
        if (completion) {
            completion(NO);
        }
        return;
    }
    
    NSNumber *tileIdentifier = autoSolveOrder.firstObject;
    if (!tileIdentifier) {
        if (completion) {
            completion(NO);
        }
        return;
    }
    [autoSolveOrder removeObjectAtIndex:0];
    
    NSInteger tileArrayIndex = tileIdentifier.integerValue;
    if (tileArrayIndex < 0 || tileArrayIndex >= self.imageArrays.count) {
        if (autoSolveOrder.count == 0) {
            [self prepareAutoSolveOrder];
        }
        if (completion) {
            completion(autoSolveOrder.count > 0);
        }
        return;
    }
    
    NSInteger tileValue = tileArrayIndex + 1;
    NSInteger tilePosition = [self positionOfTileValue:tileValue];
    if (tilePosition == NSNotFound) {
        if (autoSolveOrder.count == 0) {
            [self prepareAutoSolveOrder];
        }
        if (completion) {
            completion(autoSolveOrder.count > 0);
        }
        return;
    }
    NSInteger targetPosition = blankIndex;
    if (targetPosition == NSNotFound) {
        if (completion) {
            completion(NO);
        }
        return;
    }
    
    ImageViewOne *tile = self.imageArrays[tileArrayIndex];
    CGRect targetFrame = [self frameForBoardIndex:targetPosition];
    __weak typeof(self) weakSelf = self;
    [self bringSubviewToFront:tile];
    [UIView animateWithDuration:0.28 animations:^{
        tile.frame = targetFrame;
    } completion:^(BOOL finished) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                if (completion) {
                    completion(NO);
                }
                return;
            }
            strongSelf->boardPositions[targetPosition] = @(tileValue);
            strongSelf->boardPositions[tilePosition] = @(0);
            strongSelf->blankIndex = tilePosition;
            
            BOOL solved = [strongSelf isSolvedBoard];
            if (solved) {
                [strongSelf notifyCompletionIfNeeded];
            } else if (strongSelf->autoSolveOrder.count == 0) {
                [strongSelf prepareAutoSolveOrder];
            }
            BOOL hasMore = !solved && strongSelf->autoSolveOrder.count > 0;
            if (completion) {
                completion(hasMore);
            }
        }];
}

-(void)getDirection:(UISwipeGestureRecognizerDirection)direction Tag:(NSInteger)tag
{
    if (tag < 0 || tag >= (NSInteger)self.imageArrays.count) {
        return;
    }
    NSInteger tileValue = tag + 1;
    NSInteger currentPosition = [self positionOfTileValue:tileValue];
    if (currentPosition == NSNotFound) {
        return;
    }
    
    NSInteger row = PTRowForIndex(currentPosition);
    NSInteger col = PTColForIndex(currentPosition);
    NSInteger targetPosition = NSNotFound;
    if (direction == UISwipeGestureRecognizerDirectionUp && row > 0) {
        targetPosition = currentPosition - 4;
    } else if (direction == UISwipeGestureRecognizerDirectionDown && row < 3) {
        targetPosition = currentPosition + 4;
    } else if (direction == UISwipeGestureRecognizerDirectionLeft && col > 0) {
        targetPosition = currentPosition - 1;
    } else if (direction == UISwipeGestureRecognizerDirectionRight && col < 3) {
        targetPosition = currentPosition + 1;
    } else {
        return;
    }
    
    if (targetPosition != blankIndex) {
        return;
    }
    
    ImageViewOne *image = self.imageArrays[tag];
    CGRect targetFrame = [self frameForBoardIndex:targetPosition];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.1 animations:^{
        image.frame = targetFrame;
    } completion:^(BOOL finished) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        strongSelf->boardPositions[targetPosition] = @(tileValue);
        strongSelf->boardPositions[currentPosition] = @(0);
        strongSelf->blankIndex = currentPosition;
        [strongSelf resetAutoSolveProgress];
        [strongSelf checkComplete];
    }];
}

-(void)checkComplete
{
    if (_hasCompleted) {
        return;
    }
    if (![self isSolvedBoard]) {
        return;
    }
    [self notifyCompletionIfNeeded];
}

#pragma mark - Helpers

- (CGRect)frameForBoardIndex:(NSInteger)index
{
    if (index < 0 || index >= imageFrames.count) {
        return CGRectZero;
    }
    return CGRectFromString(imageFrames[index]);
}

- (void)resetBoardToSolvedConfiguration
{
    [boardPositions removeAllObjects];
    for (NSInteger idx = 0; idx < self.imageArrays.count; idx++) {
        [boardPositions addObject:@(idx + 1)];
    }
    [boardPositions addObject:@(0)];
    blankIndex = boardPositions.count - 1;
}

- (NSInteger)positionOfTileValue:(NSInteger)value
{
    for (NSInteger idx = 0; idx < boardPositions.count; idx++) {
        if (boardPositions[idx].integerValue == value) {
            return idx;
        }
    }
    return NSNotFound;
}

- (BOOL)prepareAutoSolveOrder
{
    if (autoSolveOrder.count > 0) {
        return YES;
    }
    [autoSolveOrder removeAllObjects];
    NSArray<NSNumber *> *solutionMoves = [self solveCurrentBoardState];
    if (solutionMoves.count == 0) {
        if ([self isSolvedBoard]) {
            [self notifyCompletionIfNeeded];
        }
        return NO;
    }
    for (NSNumber *tileValue in solutionMoves) {
        NSInteger tileIndex = tileValue.integerValue - 1;
        if (tileIndex >= 0) {
            [autoSolveOrder addObject:@(tileIndex)];
        }
    }
    return autoSolveOrder.count > 0;
}

- (NSArray<NSNumber *> *)solveCurrentBoardState
{
    if (boardPositions.count < 16) {
        return @[];
    }
    int board[16];
    for (NSInteger idx = 0; idx < 16; idx++) {
        board[idx] = boardPositions[idx].intValue;
    }
    int blank = (int)MIN(MAX(blankIndex, 0), 15);
    NSInteger threshold = [self manhattanDistanceForBoardValues:board length:16];
    if (threshold == 0) {
        return @[];
    }
    
    const NSInteger maxThreshold = 120;
    while (threshold <= maxThreshold) {
        NSMutableArray<NSNumber *> *path = [NSMutableArray array];
        int boardCopy[16];
        memcpy(boardCopy, board, sizeof(board));
        NSInteger result = [self idaSearchWithBoard:boardCopy
                                              blank:blank
                                              depth:0
                                          threshold:(int)threshold
                                           lastMove:-1
                                               path:path];
        if (result == -1) {
            return [path copy];
        }
        if (result == NSIntegerMax) {
            break;
        }
        threshold = result;
    }
    return @[];
}

- (NSInteger)manhattanDistanceForState:(NSArray<NSNumber *> *)state
{
    if (!state || state.count == 0) {
        return 0;
    }
    int board[16] = {0};
    NSInteger length = MIN((NSInteger)16, state.count);
    for (NSInteger idx = 0; idx < length; idx++) {
        board[idx] = state[idx].intValue;
    }
    return [self manhattanDistanceForBoardValues:board length:(int)length];
}

- (NSInteger)idaSearchWithBoard:(int *)board
                          blank:(int)blank
                          depth:(int)depth
                      threshold:(int)threshold
                       lastMove:(int)lastMove
                           path:(NSMutableArray<NSNumber *> *)path
{
    NSInteger heuristic = [self manhattanDistanceForBoardValues:board length:16];
    NSInteger cost = depth + heuristic;
    if (cost > threshold) {
        return cost;
    }
    if (heuristic == 0) {
        return -1;
    }
    if (depth > 120) {
        return NSIntegerMax;
    }
    
    static const int neighborOffsets[4] = { -4, 4, -1, 1 };
    static const int rowAdjust[4] = { -1, 1, 0, 0 };
    static const int colAdjust[4] = { 0, 0, -1, 1 };
    int blankRow = blank / 4;
    int blankCol = blank % 4;
    NSInteger minimum = NSIntegerMax;
    
    for (int dir = 0; dir < 4; dir++) {
        int nextRow = blankRow + rowAdjust[dir];
        int nextCol = blankCol + colAdjust[dir];
        if (nextRow < 0 || nextRow > 3 || nextCol < 0 || nextCol > 3) {
            continue;
        }
        int neighborIndex = blank + neighborOffsets[dir];
        if (neighborIndex < 0 || neighborIndex >= 16) {
            continue;
        }
        int tileValue = board[neighborIndex];
        if (tileValue == 0) {
            continue;
        }
        if (tileValue == lastMove) {
            continue;
        }
        
        board[blank] = tileValue;
        board[neighborIndex] = 0;
        [path addObject:@(tileValue)];
        
        NSInteger searchResult = [self idaSearchWithBoard:board
                                                   blank:neighborIndex
                                                   depth:depth + 1
                                               threshold:threshold
                                                lastMove:tileValue
                                                    path:path];
        if (searchResult == -1) {
            return -1;
        }
        if (searchResult < minimum) {
            minimum = searchResult;
        }
        
        [path removeLastObject];
        board[neighborIndex] = tileValue;
        board[blank] = 0;
    }
    return minimum;
}

- (NSInteger)manhattanDistanceForBoardValues:(const int *)board length:(int)length
{
    NSInteger total = 0;
    for (int idx = 0; idx < length; idx++) {
        int value = board[idx];
        if (value == 0) {
            continue;
        }
        int targetIndex = value - 1;
        int currentRow = idx / 4;
        int currentCol = idx % 4;
        int targetRow = targetIndex / 4;
        int targetCol = targetIndex % 4;
        total += labs(currentRow - targetRow) + labs(currentCol - targetCol);
    }
    return total;
}

- (BOOL)isSolvedBoard
{
    if (boardPositions.count < 16) {
        return NO;
    }
    if (blankIndex != boardPositions.count - 1) {
        return NO;
    }
    for (NSInteger idx = 0; idx < self.imageArrays.count; idx++) {
        if (boardPositions[idx].integerValue != idx + 1) {
            return NO;
        }
    }
    return YES;
}

- (void)notifyCompletionIfNeeded
{
    if (_hasCompleted) {
        return;
    }
    _hasCompleted = YES;
    if (self.completionDelegate && [self.completionDelegate respondsToSelector:@selector(pinTuViewDidComplete:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.completionDelegate pinTuViewDidComplete:self];
        });
    }
}

@end
