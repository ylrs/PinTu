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

static inline NSInteger PTRowForIndex(NSInteger index, NSInteger gridSize) {
    return index / gridSize;
}

static inline NSInteger PTColForIndex(NSInteger index, NSInteger gridSize) {
    return index % gridSize;
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
- (void)setupGridLines;
@end

@implementation PinTuView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _shouldShowIndices = NO;
        _hasCompleted = NO;
        _shuffleDifficulty = PinTuShuffleDifficultyHard;
        _gridSize = 4;
        imageWidth = frame.size.width/_gridSize;

        NSInteger totalTiles = _gridSize * _gridSize - 1;
        self.imageArrays = [[NSMutableArray alloc] initWithCapacity:totalTiles];
        for (NSInteger i = 0; i < totalTiles; i++) {
            ImageViewOne *imageView = [[ImageViewOne alloc] init];
            [self.imageArrays addObject:imageView];
        }

        imageFrames = [[NSMutableArray alloc] initWithCapacity:_gridSize * _gridSize];
        autoSolveOrder = [[NSMutableArray alloc] init];
        boardPositions = [[NSMutableArray alloc] initWithCapacity:_gridSize * _gridSize];
        blankIndex = _gridSize * _gridSize - 1;

        [self initImagesWith:imageWidth];
    }
    return self;
}

- (void)setGridSize:(NSInteger)gridSize
{
    if (gridSize < 3 || gridSize > 10) {
        return;
    }
    if (_gridSize == gridSize) {
        return;
    }

    _gridSize = gridSize;
    imageWidth = self.frame.size.width / _gridSize;

    for (ImageViewOne *view in self.imageArrays) {
        [view removeFromSuperview];
    }
    [self.imageArrays removeAllObjects];

    NSInteger totalTiles = _gridSize * _gridSize - 1;
    self.imageArrays = [[NSMutableArray alloc] initWithCapacity:totalTiles];
    for (NSInteger i = 0; i < totalTiles; i++) {
        ImageViewOne *imageView = [[ImageViewOne alloc] init];
        [self.imageArrays addObject:imageView];
    }

    [imageFrames removeAllObjects];
    [autoSolveOrder removeAllObjects];
    [boardPositions removeAllObjects];
    blankIndex = _gridSize * _gridSize - 1;

    for (UIView *subview in [self.subviews copy]) {
        [subview removeFromSuperview];
    }

    [self initImagesWith:imageWidth];
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

    NSInteger totalPositions = _gridSize * _gridSize;
    for (NSInteger position = 0; position < totalPositions; position++) {
        NSInteger col = PTColForIndex(position, _gridSize);
        NSInteger row = PTRowForIndex(position, _gridSize);
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
    [self setupGridLines];
}

- (void)setupGridLines
{
    for (NSInteger i = 1; i < _gridSize; i++) {
        CGFloat position = self.frame.size.width / _gridSize * i;

        UILabel *lineX = [[UILabel alloc] init];
        lineX.frame = CGRectMake(position, 0, 1, self.frame.size.height);
        lineX.backgroundColor = [UIColor grayColor];
        [self addSubview:lineX];

        UILabel *lineY = [[UILabel alloc] init];
        lineY.frame = CGRectMake(0, position, self.frame.size.width, 1);
        lineY.backgroundColor = [UIColor grayColor];
        [self addSubview:lineY];
    }
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
    CGFloat tileSide = minSide / (CGFloat)_gridSize;
    NSMutableArray *tiles = [NSMutableArray arrayWithCapacity:self.imageArrays.count];
    for (NSInteger index = 0; index < self.imageArrays.count; index++) {
        NSInteger col = PTColForIndex(index, _gridSize);
        NSInteger row = PTRowForIndex(index, _gridSize);
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
    if (self.imageArrays.count == 0 || imageFrames.count < _gridSize * _gridSize) {
        return;
    }
    [autoSolveOrder removeAllObjects];
    [self resetBoardToSolvedConfiguration];

    NSInteger shuffleSteps = [self shuffleStepCountForCurrentDifficulty];
    NSInteger lastDirection = -1;
    static const NSInteger rowAdjust[4] = { -1, 1, 0, 0 };
    static const NSInteger colAdjust[4] = { 0, 0, -1, 1 };

    for (NSInteger step = 0; step < shuffleSteps; step++) {
        NSInteger blankRow = PTRowForIndex(blankIndex, _gridSize);
        NSInteger blankCol = PTColForIndex(blankIndex, _gridSize);
        NSInteger candidateDirections[4];
        NSInteger candidateCount = 0;
        for (NSInteger dir = 0; dir < 4; dir++) {
            if (lastDirection != -1 && ((dir ^ 1) == lastDirection)) {
                continue;
            }
            NSInteger nextRow = blankRow + rowAdjust[dir];
            NSInteger nextCol = blankCol + colAdjust[dir];
            if (nextRow < 0 || nextRow >= _gridSize || nextCol < 0 || nextCol >= _gridSize) {
                continue;
            }
            candidateDirections[candidateCount++] = dir;
        }
        if (candidateCount == 0) {
            lastDirection = -1;
            continue;
        }
        NSInteger chosenDir = candidateDirections[arc4random_uniform((uint32_t)candidateCount)];
        NSInteger neighborIndex;
        if (chosenDir == 0) {
            neighborIndex = blankIndex - _gridSize;
        } else if (chosenDir == 1) {
            neighborIndex = blankIndex + _gridSize;
        } else if (chosenDir == 2) {
            neighborIndex = blankIndex - 1;
        } else {
            neighborIndex = blankIndex + 1;
        }

        if (neighborIndex < 0 || neighborIndex >= boardPositions.count) {
            continue;
        }

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

    NSInteger row = PTRowForIndex(currentPosition, _gridSize);
    NSInteger col = PTColForIndex(currentPosition, _gridSize);
    NSInteger targetPosition = NSNotFound;
    if (direction == UISwipeGestureRecognizerDirectionUp && row > 0) {
        targetPosition = currentPosition - _gridSize;
    } else if (direction == UISwipeGestureRecognizerDirectionDown && row < _gridSize - 1) {
        targetPosition = currentPosition + _gridSize;
    } else if (direction == UISwipeGestureRecognizerDirectionLeft && col > 0) {
        targetPosition = currentPosition - 1;
    } else if (direction == UISwipeGestureRecognizerDirectionRight && col < _gridSize - 1) {
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

- (void)prepareAutoSolveOrderAsyncWithCompletion:(void (^)(BOOL success))completion
{
    if (autoSolveOrder.count > 0) {
        if (completion) {
            completion(YES);
        }
        return;
    }

    if ([self isSolvedBoard]) {
        [self notifyCompletionIfNeeded];
        if (completion) {
            completion(NO);
        }
        return;
    }

    NSInteger totalCells = _gridSize * _gridSize;
    NSMutableArray<NSNumber *> *currentBoard = [NSMutableArray arrayWithCapacity:totalCells];
    for (NSInteger idx = 0; idx < boardPositions.count; idx++) {
        [currentBoard addObject:boardPositions[idx]];
    }
    NSInteger currentBlankIndex = blankIndex;
    NSInteger currentGridSize = _gridSize;

    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        int *board = malloc(sizeof(int) * totalCells);
        for (NSInteger idx = 0; idx < totalCells; idx++) {
            board[idx] = currentBoard[idx].intValue;
        }
        int blank = (int)MIN(MAX(currentBlankIndex, 0), totalCells - 1);

        NSArray<NSNumber *> *solutionMoves = nil;

        if (currentGridSize <= 4) {
            NSInteger threshold = [weakSelf manhattanDistanceForBoardValues:board length:(int)totalCells];
            if (threshold > 0) {
                const NSInteger maxThreshold = 80;
                while (threshold <= maxThreshold) {
                    NSMutableArray<NSNumber *> *path = [NSMutableArray array];
                    int *boardCopy = malloc(sizeof(int) * totalCells);
                    memcpy(boardCopy, board, sizeof(int) * totalCells);
                    NSInteger searchResult = [weakSelf idaSearchWithBoard:boardCopy
                                                                    blank:blank
                                                                    depth:0
                                                                threshold:(int)threshold
                                                                 lastMove:-1
                                                                     path:path];
                    free(boardCopy);
                    if (searchResult == -1) {
                        solutionMoves = [path copy];
                        break;
                    }
                    if (searchResult == NSIntegerMax) {
                        break;
                    }
                    threshold = searchResult;
                }
            }
        } else {
            solutionMoves = [weakSelf greedySolve:board blank:blank totalCells:(int)totalCells];
        }

        free(board);

        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                if (completion) {
                    completion(NO);
                }
                return;
            }

            [strongSelf->autoSolveOrder removeAllObjects];
            if (solutionMoves.count == 0) {
                if (completion) {
                    completion(NO);
                }
                return;
            }

            for (NSNumber *tileValue in solutionMoves) {
                NSInteger tileIndex = tileValue.integerValue - 1;
                if (tileIndex >= 0) {
                    [strongSelf->autoSolveOrder addObject:@(tileIndex)];
                }
            }

            if (completion) {
                completion(strongSelf->autoSolveOrder.count > 0);
            }
        });
    });
}

- (NSArray<NSNumber *> *)solveCurrentBoardState
{
    NSInteger totalCells = _gridSize * _gridSize;
    if (boardPositions.count < totalCells) {
        return @[];
    }

    int *board = malloc(sizeof(int) * totalCells);
    for (NSInteger idx = 0; idx < totalCells; idx++) {
        board[idx] = boardPositions[idx].intValue;
    }
    int blank = (int)MIN(MAX(blankIndex, 0), totalCells - 1);
    NSInteger threshold = [self manhattanDistanceForBoardValues:board length:(int)totalCells];
    if (threshold == 0) {
        free(board);
        return @[];
    }

    NSArray<NSNumber *> *result = @[];

    if (_gridSize <= 4) {
        const NSInteger maxThreshold = 80;
        while (threshold <= maxThreshold) {
            NSMutableArray<NSNumber *> *path = [NSMutableArray array];
            int *boardCopy = malloc(sizeof(int) * totalCells);
            memcpy(boardCopy, board, sizeof(int) * totalCells);
            NSInteger searchResult = [self idaSearchWithBoard:boardCopy
                                                  blank:blank
                                                  depth:0
                                              threshold:(int)threshold
                                               lastMove:-1
                                                   path:path];
            free(boardCopy);
            if (searchResult == -1) {
                result = [path copy];
                break;
            }
            if (searchResult == NSIntegerMax) {
                break;
            }
            threshold = searchResult;
        }
    } else {
        result = [self greedySolve:board blank:blank totalCells:(int)totalCells];
    }

    free(board);
    return result;
}

- (NSArray<NSNumber *> *)greedySolve:(int *)board blank:(int)blank totalCells:(int)totalCells
{
    NSMutableArray<NSNumber *> *moves = [NSMutableArray array];
    int currentBlank = blank;
    int maxMoves = totalCells * 100;
    int moveCount = 0;
    int lastMovedTile = -1;
    int noProgressCount = 0;

    int *workingBoard = malloc(sizeof(int) * totalCells);
    memcpy(workingBoard, board, sizeof(int) * totalCells);
    
    NSInteger lastDist = [self manhattanDistanceForBoardValues:workingBoard length:totalCells];

    while (moveCount < maxMoves) {
        NSInteger currentDist = [self manhattanDistanceForBoardValues:workingBoard length:totalCells];
        if (currentDist == 0) {
            break;
        }

        int blankRow = currentBlank / _gridSize;
        int blankCol = currentBlank % _gridSize;

        int bestMove = -1;
        NSInteger bestDist = NSIntegerMax;
        int bestTileValue = -1;

        static const int rowAdjust[4] = { -1, 1, 0, 0 };
        static const int colAdjust[4] = { 0, 0, -1, 1 };

        for (int dir = 0; dir < 4; dir++) {
            int nextRow = blankRow + rowAdjust[dir];
            int nextCol = blankCol + colAdjust[dir];

            if (nextRow < 0 || nextRow >= _gridSize || nextCol < 0 || nextCol >= _gridSize) {
                continue;
            }

            int neighborIndex = nextRow * _gridSize + nextCol;
            int tileValue = workingBoard[neighborIndex];

            if (tileValue == 0 || tileValue == lastMovedTile) {
                continue;
            }

            workingBoard[currentBlank] = tileValue;
            workingBoard[neighborIndex] = 0;

            NSInteger newDist = [self manhattanDistanceForBoardValues:workingBoard length:totalCells];

            if (newDist < bestDist) {
                bestDist = newDist;
                bestMove = neighborIndex;
                bestTileValue = tileValue;
            }

            workingBoard[neighborIndex] = tileValue;
            workingBoard[currentBlank] = 0;
        }

        if (bestMove == -1 || bestDist >= currentDist) {
            noProgressCount++;
            
            if (noProgressCount > 5) {
                int randomDir = arc4random_uniform(4);
                for (int attempt = 0; attempt < 4; attempt++) {
                    int dir = (randomDir + attempt) % 4;
                    int nextRow = blankRow + rowAdjust[dir];
                    int nextCol = blankCol + colAdjust[dir];

                    if (nextRow < 0 || nextRow >= _gridSize || nextCol < 0 || nextCol >= _gridSize) {
                        continue;
                    }

                    int neighborIndex = nextRow * _gridSize + nextCol;
                    int tileValue = workingBoard[neighborIndex];

                    if (tileValue != 0 && tileValue != lastMovedTile) {
                        bestMove = neighborIndex;
                        bestTileValue = tileValue;
                        break;
                    }
                }
                
                if (bestMove == -1) {
                    lastMovedTile = -1;
                    noProgressCount = 0;
                    continue;
                }
            } else {
                for (int dir = 0; dir < 4; dir++) {
                    int nextRow = blankRow + rowAdjust[dir];
                    int nextCol = blankCol + colAdjust[dir];

                    if (nextRow < 0 || nextRow >= _gridSize || nextCol < 0 || nextCol >= _gridSize) {
                        continue;
                    }

                    int neighborIndex = nextRow * _gridSize + nextCol;
                    int tileValue = workingBoard[neighborIndex];

                    if (tileValue != 0 && tileValue != lastMovedTile) {
                        bestMove = neighborIndex;
                        bestTileValue = tileValue;
                        break;
                    }
                }
            }
        } else {
            noProgressCount = 0;
        }

        if (bestMove == -1) {
            break;
        }

        workingBoard[currentBlank] = bestTileValue;
        workingBoard[bestMove] = 0;
        currentBlank = bestMove;
        lastMovedTile = bestTileValue;

        [moves addObject:@(bestTileValue)];
        moveCount++;
        
        if (currentDist == lastDist && noProgressCount > 20) {
            break;
        }
        lastDist = currentDist;
    }

    free(workingBoard);
    return [moves copy];
}

- (NSInteger)manhattanDistanceForState:(NSArray<NSNumber *> *)state
{
    if (!state || state.count == 0) {
        return 0;
    }
    NSInteger totalCells = _gridSize * _gridSize;
    int *board = malloc(sizeof(int) * totalCells);
    NSInteger length = MIN(totalCells, state.count);
    for (NSInteger idx = 0; idx < length; idx++) {
        board[idx] = state[idx].intValue;
    }
    NSInteger distance = [self manhattanDistanceForBoardValues:board length:(int)length];
    free(board);
    return distance;
}

- (NSInteger)idaSearchWithBoard:(int *)board
                          blank:(int)blank
                          depth:(int)depth
                      threshold:(int)threshold
                       lastMove:(int)lastMove
                           path:(NSMutableArray<NSNumber *> *)path
{
    NSInteger totalCells = _gridSize * _gridSize;
    NSInteger heuristic = [self manhattanDistanceForBoardValues:board length:(int)totalCells];
    NSInteger cost = depth + heuristic;
    if (cost > threshold) {
        return cost;
    }
    if (heuristic == 0) {
        return -1;
    }
    if (depth > 60) {
        return NSIntegerMax;
    }

    int blankRow = blank / _gridSize;
    int blankCol = blank % _gridSize;
    NSInteger minimum = NSIntegerMax;

    static const int rowAdjust[4] = { -1, 1, 0, 0 };
    static const int colAdjust[4] = { 0, 0, -1, 1 };

    for (int dir = 0; dir < 4; dir++) {
        int nextRow = blankRow + rowAdjust[dir];
        int nextCol = blankCol + colAdjust[dir];
        if (nextRow < 0 || nextRow >= _gridSize || nextCol < 0 || nextCol >= _gridSize) {
            continue;
        }
        int neighborIndex = nextRow * _gridSize + nextCol;
        if (neighborIndex < 0 || neighborIndex >= totalCells) {
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
        int currentRow = idx / _gridSize;
        int currentCol = idx % _gridSize;
        int targetRow = targetIndex / _gridSize;
        int targetCol = targetIndex % _gridSize;
        total += labs(currentRow - targetRow) + labs(currentCol - targetCol);
    }
    return total;
}

- (BOOL)isSolvedBoard
{
    NSInteger totalCells = _gridSize * _gridSize;
    if (boardPositions.count < totalCells) {
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
