//
//  HuaRongDaoViewController.m
//  PinTu
//
//  Created by Codex on 2025/01/22.
//

#import "HuaRongDaoViewController.h"
#import "CelebrationOverlayView.h"

static const NSInteger kHRDRowCount = 5;
static const NSInteger kHRDColumnCount = 4;
static const CGFloat kHRDDefaultBorderWidth = 4.0f;
static const NSInteger kHRDDirectionCount = 4;
static const NSInteger kHRDDirectionRows[4] = {-1, 1, 0, 0};
static const NSInteger kHRDDirectionCols[4] = {0, 0, -1, 1};

static NSString *HRDStateKeyForCoords(const NSInteger *coords,
                                      NSInteger pieceCount,
                                      const NSInteger *widths,
                                      const NSInteger *heights)
{
    const NSInteger cellCount = kHRDRowCount * kHRDColumnCount;
    char buffer[cellCount];
    for (NSInteger idx = 0; idx < cellCount; idx++) {
        buffer[idx] = '.';
    }
    for (NSInteger pieceIndex = 0; pieceIndex < pieceCount; pieceIndex++) {
        NSInteger row = coords[pieceIndex * 2];
        NSInteger col = coords[pieceIndex * 2 + 1];
        NSInteger width = widths[pieceIndex];
        NSInteger height = heights[pieceIndex];
        for (NSInteger r = 0; r < height; r++) {
            for (NSInteger c = 0; c < width; c++) {
                NSInteger cellIndex = (row + r) * kHRDColumnCount + (col + c);
                if (cellIndex >= 0 && cellIndex < cellCount) {
                    buffer[cellIndex] = (char)('A' + pieceIndex);
                }
            }
        }
    }
    return [[NSString alloc] initWithBytes:buffer
                                    length:(NSUInteger)cellCount
                                  encoding:NSASCIIStringEncoding];
}

static BOOL HRDCanMovePiece(const NSInteger *coords,
                            NSInteger pieceIndex,
                            NSInteger dRow,
                            NSInteger dCol,
                            NSInteger pieceCount,
                            const NSInteger *widths,
                            const NSInteger *heights)
{
    NSInteger row = coords[pieceIndex * 2];
    NSInteger col = coords[pieceIndex * 2 + 1];
    NSInteger width = widths[pieceIndex];
    NSInteger height = heights[pieceIndex];
    NSInteger newRow = row + dRow;
    NSInteger newCol = col + dCol;
    if (newRow < 0 || newCol < 0) {
        return NO;
    }
    if (newRow + height > kHRDRowCount || newCol + width > kHRDColumnCount) {
        return NO;
    }
    NSInteger newBottom = newRow + height - 1;
    NSInteger newRight = newCol + width - 1;
    for (NSInteger idx = 0; idx < pieceCount; idx++) {
        if (idx == pieceIndex) {
            continue;
        }
        NSInteger otherRow = coords[idx * 2];
        NSInteger otherCol = coords[idx * 2 + 1];
        NSInteger otherWidth = widths[idx];
        NSInteger otherHeight = heights[idx];
        NSInteger otherBottom = otherRow + otherHeight - 1;
        NSInteger otherRight = otherCol + otherWidth - 1;
        BOOL separatedVertically = (newRow > otherBottom) || (newBottom < otherRow);
        BOOL separatedHorizontally = (newCol > otherRight) || (newRight < otherCol);
        if (!(separatedVertically || separatedHorizontally)) {
            return NO;
        }
    }
    return YES;
}

static BOOL HRDIsGoal(const NSInteger *coords)
{
    return (coords[0] == 3 && coords[1] == 1);
}

typedef NS_ENUM(NSInteger, HRDPanAxis) {
    HRDPanAxisNone = 0,
    HRDPanAxisHorizontal,
    HRDPanAxisVertical
};

@interface HRDPieceModel : NSObject
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSInteger col;
@property (nonatomic, assign) NSInteger originalRow;
@property (nonatomic, assign) NSInteger originalCol;
@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation HRDPieceModel
@end

@interface HuaRongDaoViewController ()
@property (nonatomic, strong) UIView *boardContainer;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UIButton *resetButton;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *autoSolveButton;
@property (nonatomic, strong) UIActivityIndicatorView *autoSolveIndicator;
@property (nonatomic, strong) NSMutableArray<HRDPieceModel *> *pieces;
@property (nonatomic, strong) NSMutableArray<NSMutableArray *> *grid;
@property (nonatomic, assign) CGFloat cellSize;
@property (nonatomic, assign) BOOL hasLayedOutSubviews;
@property (nonatomic, strong, nullable) HRDPieceModel *activePiece;
@property (nonatomic, assign) CGPoint activePieceStartCenter;
@property (nonatomic, assign) NSInteger allowedPositiveRowSteps;
@property (nonatomic, assign) NSInteger allowedNegativeRowSteps;
@property (nonatomic, assign) NSInteger allowedPositiveColSteps;
@property (nonatomic, assign) NSInteger allowedNegativeColSteps;
@property (nonatomic, assign) HRDPanAxis panAxis;
@property (nonatomic, assign) BOOL hasShownVictory;
@property (nonatomic, assign) BOOL autoSolving;
@property (nonatomic, strong, nullable) NSArray<NSDictionary *> *pendingAutoSolveMoves;
@property (nonatomic, strong) dispatch_queue_t solverQueue;
@end

@implementation HuaRongDaoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.96f alpha:1.0f];
    self.pieces = [NSMutableArray array];
    self.solverQueue = dispatch_queue_create("com.pintu.huarongdao.solver", DISPATCH_QUEUE_SERIAL);
    [self buildEmptyGrid];
    [self configureInterface];
    [self configurePieces];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    UIEdgeInsets safeInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeInsets = self.view.safeAreaInsets;
    }
    
    CGFloat viewWidth = CGRectGetWidth(self.view.bounds);
    CGFloat viewHeight = CGRectGetHeight(self.view.bounds);
    
    CGFloat topPadding = safeInsets.top + 16.0f;
    CGFloat horizontalMargin = 20.0f;
    
    CGFloat buttonHeight = 44.0f;
    CGFloat buttonWidth = 112.0f;
    self.backButton.frame = CGRectMake(horizontalMargin, topPadding, buttonWidth, buttonHeight);
    
    self.resetButton.frame = CGRectMake(viewWidth - horizontalMargin - buttonWidth, topPadding, buttonWidth, buttonHeight);
    
    CGFloat buttonSpacing = 12.0f;
    CGFloat autoOriginX = CGRectGetMinX(self.resetButton.frame) - buttonSpacing - buttonWidth;
    if (autoOriginX < horizontalMargin) {
        autoOriginX = horizontalMargin;
    }
    self.autoSolveButton.frame = CGRectMake(autoOriginX, topPadding, buttonWidth, buttonHeight);
    
    if (CGRectGetMaxX(self.backButton.frame) > autoOriginX - buttonSpacing) {
        CGFloat adjustedBackWidth = autoOriginX - buttonSpacing - horizontalMargin;
        if (adjustedBackWidth > 60.0f) {
            self.backButton.frame = CGRectMake(horizontalMargin, topPadding, adjustedBackWidth, buttonHeight);
        }
    }
    
    if (self.autoSolveIndicator) {
        self.autoSolveIndicator.center = CGPointMake(CGRectGetWidth(self.autoSolveButton.bounds) / 2.0f,
                                                     CGRectGetHeight(self.autoSolveButton.bounds) / 2.0f);
    }
    
    CGFloat titleX = CGRectGetMaxX(self.backButton.frame) + 12.0f;
    CGFloat titleWidth = viewWidth - titleX - (viewWidth - CGRectGetMinX(self.resetButton.frame)) - 12.0f;
    self.titleLabel.frame = CGRectMake(titleX, topPadding, titleWidth, buttonHeight);
    
    CGFloat buttonsBottom = MAX(CGRectGetMaxY(self.backButton.frame), CGRectGetMaxY(self.autoSolveButton.frame));
    
    CGFloat boardTop = buttonsBottom + 16.0f;
    CGFloat availableHeight = viewHeight - boardTop - safeInsets.bottom - 80.0f;
    CGFloat availableWidth = viewWidth - horizontalMargin * 2.0f;
    CGFloat cellSize = floor(MIN(availableWidth / (CGFloat)kHRDColumnCount, availableHeight / (CGFloat)kHRDRowCount));
    cellSize = MAX(cellSize, 48.0f);
    
    CGFloat boardWidth = cellSize * (CGFloat)kHRDColumnCount;
    CGFloat boardHeight = cellSize * (CGFloat)kHRDRowCount;
    CGFloat boardX = (viewWidth - boardWidth) / 2.0f;
    self.boardContainer.frame = CGRectMake(boardX, boardTop, boardWidth, boardHeight);
    
    CGFloat hintTop = CGRectGetMaxY(self.boardContainer.frame) + 20.0f;
    self.hintLabel.frame = CGRectMake(horizontalMargin,
                                      hintTop,
                                      viewWidth - horizontalMargin * 2.0f,
                                      44.0f);
    
    BOOL cellSizeChanged = fabs(cellSize - self.cellSize) > 0.1f;
    self.cellSize = cellSize;
    if (cellSizeChanged || !self.hasLayedOutSubviews) {
        [self layoutPiecesAnimated:NO];
        self.hasLayedOutSubviews = YES;
    }
}

#pragma mark - Interface configuration

- (void)configureInterface
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = @"三国华容道";
    titleLabel.font = [self mainTitleFont];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor colorWithRed:0.23f green:0.26f blue:0.35f alpha:1.0f];
    [self.view addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    backButton.layer.cornerRadius = 12.0f;
    backButton.layer.masksToBounds = YES;
    backButton.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.9f];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor colorWithRed:0.17f green:0.24f blue:0.55f alpha:1.0f] forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont systemFontOfSize:17.0f weight:UIFontWeightSemibold];
    [backButton addTarget:self action:@selector(handleBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    self.backButton = backButton;
    
    UIButton *autoButton = [UIButton buttonWithType:UIButtonTypeSystem];
    autoButton.layer.cornerRadius = 12.0f;
    autoButton.layer.masksToBounds = YES;
    autoButton.backgroundColor = [UIColor colorWithRed:0.12f green:0.53f blue:0.32f alpha:1.0f];
    [autoButton setTitle:@"自动过关" forState:UIControlStateNormal];
    [autoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    autoButton.titleLabel.font = [UIFont systemFontOfSize:17.0f weight:UIFontWeightSemibold];
    [autoButton addTarget:self action:@selector(handleAutoSolveTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:autoButton];
    self.autoSolveButton = autoButton;
    
    UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    resetButton.layer.cornerRadius = 12.0f;
    resetButton.layer.masksToBounds = YES;
    resetButton.backgroundColor = [UIColor colorWithRed:0.23f green:0.48f blue:0.95f alpha:1.0f];
    [resetButton setTitle:@"重新布局" forState:UIControlStateNormal];
    [resetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    resetButton.titleLabel.font = [UIFont systemFontOfSize:17.0f weight:UIFontWeightSemibold];
    [resetButton addTarget:self action:@selector(handleReset) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resetButton];
    self.resetButton = resetButton;
    
    UIView *board = [[UIView alloc] initWithFrame:CGRectZero];
    board.backgroundColor = [UIColor colorWithWhite:0.94f alpha:1.0f];
    board.layer.cornerRadius = 22.0f;
    board.layer.masksToBounds = YES;
    board.layer.borderWidth = 2.0f;
    board.layer.borderColor = [UIColor colorWithWhite:0.85f alpha:1.0f].CGColor;
    [self.view addSubview:board];
    self.boardContainer = board;
    
    UIActivityIndicatorView *indicator = nil;
    if (@available(iOS 13.0, *)) {
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    } else {
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        indicator.color = [UIColor whiteColor];
    }
    indicator.hidesWhenStopped = YES;
    indicator.userInteractionEnabled = NO;
    [autoButton addSubview:indicator];
    self.autoSolveIndicator = indicator;
    
    UILabel *hint = [[UILabel alloc] initWithFrame:CGRectZero];
    hint.textAlignment = NSTextAlignmentCenter;
    hint.text = @"目标：让曹操移动到底部中央出口";
    hint.font = [UIFont systemFontOfSize:16.0f weight:UIFontWeightMedium];
    hint.textColor = [UIColor colorWithWhite:0.25f alpha:1.0f];
    hint.numberOfLines = 2;
    [self.view addSubview:hint];
    self.hintLabel = hint;
}

- (void)configurePieces
{
    [self.pieces removeAllObjects];
    NSArray<NSDictionary *> *definitions = @[
        @{@"identifier": @"cao",   @"title": @"曹操", @"width": @2, @"height": @2, @"row": @0, @"col": @1,
          @"color": [UIColor colorWithRed:0.95f green:0.35f blue:0.32f alpha:1.0f]},
        @{@"identifier": @"zhang", @"title": @"张飞", @"width": @1, @"height": @2, @"row": @0, @"col": @0,
          @"color": [UIColor colorWithRed:0.27f green:0.46f blue:0.90f alpha:1.0f]},
        @{@"identifier": @"zhao",  @"title": @"赵云", @"width": @1, @"height": @2, @"row": @0, @"col": @3,
          @"color": [UIColor colorWithRed:0.42f green:0.76f blue:0.55f alpha:1.0f]},
        @{@"identifier": @"ma",    @"title": @"马超", @"width": @1, @"height": @2, @"row": @2, @"col": @0,
          @"color": [UIColor colorWithRed:0.96f green:0.73f blue:0.26f alpha:1.0f]},
        @{@"identifier": @"huang", @"title": @"黄忠", @"width": @1, @"height": @2, @"row": @2, @"col": @3,
          @"color": [UIColor colorWithRed:0.66f green:0.41f blue:0.86f alpha:1.0f]},
        @{@"identifier": @"guan",  @"title": @"关羽", @"width": @2, @"height": @1, @"row": @2, @"col": @1,
          @"color": [UIColor colorWithRed:0.26f green:0.74f blue:0.88f alpha:1.0f]},
        @{@"identifier": @"bing1", @"title": @"兵",   @"width": @1, @"height": @1, @"row": @3, @"col": @1,
          @"color": [UIColor colorWithRed:0.90f green:0.52f blue:0.36f alpha:1.0f]},
        @{@"identifier": @"bing2", @"title": @"兵",   @"width": @1, @"height": @1, @"row": @3, @"col": @2,
          @"color": [UIColor colorWithRed:0.90f green:0.52f blue:0.36f alpha:1.0f]},
        @{@"identifier": @"bing3", @"title": @"兵",   @"width": @1, @"height": @1, @"row": @4, @"col": @0,
          @"color": [UIColor colorWithRed:0.90f green:0.52f blue:0.36f alpha:1.0f]},
        @{@"identifier": @"bing4", @"title": @"兵",   @"width": @1, @"height": @1, @"row": @4, @"col": @3,
          @"color": [UIColor colorWithRed:0.90f green:0.52f blue:0.36f alpha:1.0f]}
    ];
    
    for (NSDictionary *definition in definitions) {
        HRDPieceModel *piece = [self pieceFromDefinition:definition];
        if (!piece) {
            continue;
        }
        [self.boardContainer addSubview:piece.view];
        [self.pieces addObject:piece];
    }
    [self rebuildGrid];
    [self layoutPiecesAnimated:NO];
}

- (NSString *)imageAssetNameForIdentifier:(NSString *)identifier
{
    static NSDictionary<NSString *, NSString *> *mapping;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mapping = @{
            @"cao": @"caocao",
            @"zhang": @"zhangfei",
            @"zhao": @"zhaoyun",
            @"ma": @"machao",
            @"huang": @"huangzhong",
            @"guan": @"guanyu",
            @"bing1": @"bing",
            @"bing2": @"bing",
            @"bing3": @"bing",
            @"bing4": @"bing"
        };
    });
    NSString *name = mapping[identifier];
    return name;
}

- (NSArray<NSString *> *)solverPieceOrder
{
    return @[@"cao",
             @"zhang",
             @"zhao",
             @"ma",
             @"huang",
             @"guan",
             @"bing1",
             @"bing2",
             @"bing3",
             @"bing4"];
}

- (HRDPieceModel *)pieceWithIdentifier:(NSString *)identifier
{
    if (identifier.length == 0) {
        return nil;
    }
    for (HRDPieceModel *piece in self.pieces) {
        if ([piece.identifier isEqualToString:identifier]) {
            return piece;
        }
    }
    return nil;
}

- (UIFont *)overlayTitleFont
{
    static UIFont *cachedFont = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray<NSString *> *preferredNames = @[@"STKaitiSC-Bold", @"STKaiti-SC-Bold", @"KaitiSC", @"Kaiti-SC", @"KaiTi"];
        for (NSString *fontName in preferredNames) {
            UIFont *font = [UIFont fontWithName:fontName size:30.0f];
            if (font) {
                cachedFont = font;
                break;
            }
        }
        if (!cachedFont) {
            cachedFont = [UIFont fontWithName:@"STKaiti" size:30.0f];
        }
        if (!cachedFont) {
            cachedFont = [UIFont boldSystemFontOfSize:30.0f];
        }
    });
    return cachedFont;
}

- (UIFont *)mainTitleFont
{
    static UIFont *cachedFont = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray<NSString *> *preferredNames = @[@"STKaitiSC-Bold", @"STKaiti-SC-Bold", @"KaitiSC", @"Kaiti-SC", @"KaiTi"];
        for (NSString *fontName in preferredNames) {
            UIFont *font = [UIFont fontWithName:fontName size:30.0f];
            if (font) {
                cachedFont = font;
                break;
            }
        }
        if (!cachedFont) {
            cachedFont = [UIFont fontWithName:@"STKaiti" size:30.0f];
        }
        if (!cachedFont) {
            cachedFont = [UIFont boldSystemFontOfSize:28.0f];
        }
    });
    return cachedFont;
}

- (UIColor *)borderColorForPieceColor:(UIColor *)color
{
    CGFloat hue = 0, saturation = 0, brightness = 0, alpha = 0;
    if ([color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
        CGFloat adjustedSaturation = MIN(1.0f, saturation * 0.85f + 0.15f);
        CGFloat adjustedBrightness = MIN(1.0f, brightness * 0.55f + 0.35f);
        return [UIColor colorWithHue:hue
                           saturation:adjustedSaturation
                           brightness:adjustedBrightness
                                alpha:0.95f];
    }
    CGFloat red = 0, green = 0, blue = 0;
    if ([color getRed:&red green:&green blue:&blue alpha:&alpha]) {
        CGFloat mixFactor = 0.7f;
        return [UIColor colorWithRed:MIN(1.0f, red * mixFactor + 0.2f)
                               green:MIN(1.0f, green * mixFactor + 0.2f)
                                blue:MIN(1.0f, blue * mixFactor + 0.2f)
                               alpha:0.95f];
    }
    return [UIColor colorWithRed:0.96f green:0.78f blue:0.28f alpha:0.95f];
}

- (HRDPieceModel *)pieceFromDefinition:(NSDictionary *)dictionary
{
    NSString *identifier = dictionary[@"identifier"];
    NSString *title = dictionary[@"title"];
    NSNumber *widthNumber = dictionary[@"width"];
    NSNumber *heightNumber = dictionary[@"height"];
    NSNumber *rowNumber = dictionary[@"row"];
    NSNumber *colNumber = dictionary[@"col"];
    UIColor *color = dictionary[@"color"];
    if (![identifier isKindOfClass:[NSString class]] ||
        ![title isKindOfClass:[NSString class]] ||
        ![widthNumber isKindOfClass:[NSNumber class]] ||
        ![heightNumber isKindOfClass:[NSNumber class]] ||
        ![rowNumber isKindOfClass:[NSNumber class]] ||
        ![colNumber isKindOfClass:[NSNumber class]] ||
        ![color isKindOfClass:[UIColor class]]) {
        return nil;
    }
    
    HRDPieceModel *piece = [[HRDPieceModel alloc] init];
    piece.identifier = identifier;
    piece.title = title;
    piece.width = widthNumber.integerValue;
    piece.height = heightNumber.integerValue;
    piece.row = rowNumber.integerValue;
    piece.col = colNumber.integerValue;
    piece.originalRow = piece.row;
    piece.originalCol = piece.col;
    piece.color = color;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = color;
    view.layer.cornerRadius = 4.0f;
    view.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.25f].CGColor;
    view.layer.shadowOpacity = 0.35f;
    view.layer.shadowOffset = CGSizeMake(0, 5.0f);
    view.layer.shadowRadius = 6.0f;
    view.layer.borderWidth = kHRDDefaultBorderWidth;
    view.layer.borderColor = [self borderColorForPieceColor:color].CGColor;
    
    NSString *assetName = [self imageAssetNameForIdentifier:identifier];
    UIImage *pieceImage = assetName.length > 0 ? [UIImage imageNamed:assetName] : nil;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:pieceImage];
    imageView.frame = view.bounds;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.layer.cornerRadius = view.layer.cornerRadius;
    imageView.layer.masksToBounds = YES;
    imageView.hidden = (pieceImage == nil);
    [view addSubview:imageView];
    
    CGFloat overlayHeight = 54.0f;
    UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(view.bounds) - overlayHeight, CGRectGetWidth(view.bounds), overlayHeight)];
    overlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.58f];
    overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    overlay.userInteractionEnabled = NO;
    [view addSubview:overlay];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = title;
    titleLabel.font = [self overlayTitleFont];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor = 0.7f;
    titleLabel.numberOfLines = 1;
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [overlay addSubview:titleLabel];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePiecePan:)];
    [view addGestureRecognizer:pan];
    piece.view = view;
    piece.imageView = imageView;
    piece.overlayView = overlay;
    piece.titleLabel = titleLabel;
    if (pieceImage) {
        view.backgroundColor = [UIColor clearColor];
    }
    return piece;
}

- (void)buildEmptyGrid
{
    self.grid = [NSMutableArray arrayWithCapacity:kHRDRowCount];
    for (NSInteger row = 0; row < kHRDRowCount; row++) {
        NSMutableArray *rowArray = [NSMutableArray arrayWithCapacity:kHRDColumnCount];
        for (NSInteger col = 0; col < kHRDColumnCount; col++) {
            [rowArray addObject:[NSNull null]];
        }
        [self.grid addObject:rowArray];
    }
}

- (void)rebuildGrid
{
    [self buildEmptyGrid];
    for (HRDPieceModel *piece in self.pieces) {
        [self occupyGridWithPiece:piece];
    }
}

- (void)occupyGridWithPiece:(HRDPieceModel *)piece
{
    if (!piece) {
        return;
    }
    for (NSInteger r = 0; r < piece.height; r++) {
        for (NSInteger c = 0; c < piece.width; c++) {
            NSInteger row = piece.row + r;
            NSInteger col = piece.col + c;
            if (row >= 0 && row < kHRDRowCount && col >= 0 && col < kHRDColumnCount) {
                self.grid[row][col] = piece;
            }
        }
    }
}

- (void)removePieceFromGrid:(HRDPieceModel *)piece
{
    if (!piece) {
        return;
    }
    for (NSInteger r = 0; r < piece.height; r++) {
        for (NSInteger c = 0; c < piece.width; c++) {
            NSInteger row = piece.row + r;
            NSInteger col = piece.col + c;
            if (row >= 0 && row < kHRDRowCount && col >= 0 && col < kHRDColumnCount) {
                self.grid[row][col] = (HRDPieceModel *)[NSNull null];
            }
        }
    }
}

- (CGRect)frameForPiece:(HRDPieceModel *)piece
{
    CGFloat size = self.cellSize;
    CGFloat originX = (CGFloat)piece.col * size;
    CGFloat originY = (CGFloat)piece.row * size;
    CGFloat width = (CGFloat)piece.width * size;
    CGFloat height = (CGFloat)piece.height * size;
    return CGRectMake(originX, originY, width, height);
}

- (void)layoutPiecesAnimated:(BOOL)animated
{
    if (self.cellSize <= 0.0f) {
        return;
    }
    void (^layoutBlock)(void) = ^{
        for (HRDPieceModel *piece in self.pieces) {
            [self applyLayoutToPiece:piece];
        }
    };
    if (animated) {
        [UIView animateWithDuration:0.25f
                              delay:0
             usingSpringWithDamping:0.85f
              initialSpringVelocity:0.7f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:layoutBlock
                         completion:nil];
    } else {
        layoutBlock();
    }
}

- (void)applyLayoutToPiece:(HRDPieceModel *)piece
{
    if (!piece) {
        return;
    }
    piece.view.frame = [self frameForPiece:piece];
    CGFloat cornerRadius = 4.0f;
    piece.view.layer.cornerRadius = cornerRadius;
    piece.view.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:piece.view.bounds cornerRadius:cornerRadius].CGPath;
    piece.imageView.layer.cornerRadius = cornerRadius;
    piece.view.layer.borderWidth = kHRDDefaultBorderWidth;
    piece.view.layer.borderColor = [self borderColorForPieceColor:piece.color].CGColor;
    
    CGRect bounds = piece.view.bounds;
    CGFloat minSide = MIN(bounds.size.width, bounds.size.height);
    CGFloat overlayHeight = MAX(32.0f, MIN(68.0f, minSide * 0.38f));
    piece.overlayView.frame = CGRectMake(0,
                                         bounds.size.height - overlayHeight,
                                         bounds.size.width,
                                         overlayHeight);
    if (@available(iOS 11.0, *)) {
        piece.overlayView.layer.cornerRadius = cornerRadius;
        piece.overlayView.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
    } else {
        piece.overlayView.layer.cornerRadius = 0.0f;
    }
    piece.overlayView.layer.masksToBounds = YES;
    piece.titleLabel.frame = CGRectInset(piece.overlayView.bounds, 12.0f, 6.0f);
    [piece.view bringSubviewToFront:piece.overlayView];
}

#pragma mark - Gesture handling

- (void)handlePiecePan:(UIPanGestureRecognizer *)gesture
{
    UIView *view = gesture.view;
    HRDPieceModel *piece = [self pieceForView:view];
    if (!piece) {
        return;
    }
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.activePiece = piece;
        self.activePieceStartCenter = view.center;
        self.panAxis = HRDPanAxisNone;
        [self removePieceFromGrid:piece];
        self.allowedPositiveRowSteps = [self availableStepsForPiece:piece rowDelta:1 colDelta:0];
        self.allowedNegativeRowSteps = [self availableStepsForPiece:piece rowDelta:-1 colDelta:0];
        self.allowedPositiveColSteps = [self availableStepsForPiece:piece rowDelta:0 colDelta:1];
        self.allowedNegativeColSteps = [self availableStepsForPiece:piece rowDelta:0 colDelta:-1];
        return;
    }
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        if (self.activePiece != piece) {
            return;
        }
        CGPoint translation = [gesture translationInView:self.boardContainer];
        if (self.panAxis == HRDPanAxisNone) {
            CGFloat absX = fabs(translation.x);
            CGFloat absY = fabs(translation.y);
            if (absX > absY && absX > 3.0f) {
                self.panAxis = HRDPanAxisHorizontal;
            } else if (absY > absX && absY > 3.0f) {
                self.panAxis = HRDPanAxisVertical;
            } else {
                return;
            }
        }
        CGPoint clampedTranslation = [self clampedTranslationForTranslation:translation];
        view.center = CGPointMake(self.activePieceStartCenter.x + clampedTranslation.x,
                                  self.activePieceStartCenter.y + clampedTranslation.y);
        return;
    }
    
    if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        CGPoint translation = [gesture translationInView:self.boardContainer];
        CGPoint clampedTranslation = [self clampedTranslationForTranslation:translation];
        NSInteger steps = [self stepsFromTranslation:clampedTranslation axis:self.panAxis];
        if (steps != 0 && self.panAxis == HRDPanAxisHorizontal) {
            piece.col += steps;
        } else if (steps != 0 && self.panAxis == HRDPanAxisVertical) {
            piece.row += steps;
        }
        
        [self occupyGridWithPiece:piece];
        self.activePiece = nil;
        HRDPanAxis finishedAxis = self.panAxis;
        self.panAxis = HRDPanAxisNone;
        [gesture setTranslation:CGPointZero inView:self.boardContainer];
        
        BOOL didMove = steps != 0;
        [UIView animateWithDuration:0.18f
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
            view.frame = [self frameForPiece:piece];
        } completion:^(BOOL finished) {
            if (finishedAxis != HRDPanAxisNone && didMove) {
                [self checkVictoryCondition];
            }
        }];
        return;
    }
}

- (CGPoint)clampedTranslationForTranslation:(CGPoint)translation
{
    CGPoint result = translation;
    CGFloat tile = self.cellSize;
    if (self.panAxis == HRDPanAxisHorizontal) {
        CGFloat maxPositive = (CGFloat)self.allowedPositiveColSteps * tile;
        CGFloat maxNegative = (CGFloat)self.allowedNegativeColSteps * tile;
        result.y = 0.0f;
        if (result.x > maxPositive) {
            result.x = maxPositive;
        }
        if (result.x < -maxNegative) {
            result.x = -maxNegative;
        }
    } else if (self.panAxis == HRDPanAxisVertical) {
        CGFloat maxPositive = (CGFloat)self.allowedPositiveRowSteps * tile;
        CGFloat maxNegative = (CGFloat)self.allowedNegativeRowSteps * tile;
        result.x = 0.0f;
        if (result.y > maxPositive) {
            result.y = maxPositive;
        }
        if (result.y < -maxNegative) {
            result.y = -maxNegative;
        }
    } else {
        result = CGPointZero;
    }
    return result;
}

- (NSInteger)stepsFromTranslation:(CGPoint)translation axis:(HRDPanAxis)axis
{
    if (axis == HRDPanAxisNone) {
        return 0;
    }
    CGFloat distance = (axis == HRDPanAxisHorizontal) ? translation.x : translation.y;
    if (fabs(distance) < self.cellSize * 0.35f) {
        return 0;
    }
    NSInteger maxPositive = (axis == HRDPanAxisHorizontal) ? self.allowedPositiveColSteps : self.allowedPositiveRowSteps;
    NSInteger maxNegative = (axis == HRDPanAxisHorizontal) ? self.allowedNegativeColSteps : self.allowedNegativeRowSteps;
    NSInteger tentative = (NSInteger)llround(distance / self.cellSize);
    if (tentative > maxPositive) {
        tentative = maxPositive;
    }
    if (-tentative > maxNegative) {
        tentative = -maxNegative;
    }
    return tentative;
}

- (NSInteger)availableStepsForPiece:(HRDPieceModel *)piece rowDelta:(NSInteger)rowDelta colDelta:(NSInteger)colDelta
{
    if (!piece || (rowDelta == 0 && colDelta == 0)) {
        return 0;
    }
    NSInteger steps = 0;
    NSInteger nextRow = piece.row + rowDelta;
    NSInteger nextCol = piece.col + colDelta;
    while ([self canPlacePiece:piece atRow:nextRow col:nextCol]) {
        steps++;
        nextRow += rowDelta;
        nextCol += colDelta;
    }
    return steps;
}

- (BOOL)canPlacePiece:(HRDPieceModel *)piece atRow:(NSInteger)row col:(NSInteger)col
{
    NSInteger maxRow = row + piece.height - 1;
    NSInteger maxCol = col + piece.width - 1;
    if (row < 0 || col < 0 || maxRow >= kHRDRowCount || maxCol >= kHRDColumnCount) {
        return NO;
    }
    for (NSInteger r = 0; r < piece.height; r++) {
        for (NSInteger c = 0; c < piece.width; c++) {
            id occupant = self.grid[row + r][col + c];
            if (occupant == [NSNull null]) {
                continue;
            }
            if (occupant != piece) {
                return NO;
            }
        }
    }
    return YES;
}

- (NSArray<NSDictionary *> *)computeAutoSolveMovesWithCoords:(NSArray<NSNumber *> *)coords
                                                      sizes:(NSArray<NSValue *> *)sizes
                                                      order:(NSArray<NSString *> *)order
{
    NSInteger pieceCount = order.count;
    if (coords.count != pieceCount * 2 || sizes.count != pieceCount) {
        return @[];
    }
    NSInteger widths[pieceCount];
    NSInteger heights[pieceCount];
    for (NSInteger idx = 0; idx < pieceCount; idx++) {
        CGSize size = [sizes[idx] CGSizeValue];
        widths[idx] = (NSInteger)lround(size.width);
        heights[idx] = (NSInteger)lround(size.height);
    }
    
    NSInteger initialCoords[pieceCount * 2];
    for (NSInteger idx = 0; idx < pieceCount * 2; idx++) {
        initialCoords[idx] = coords[idx].integerValue;
    }
    
    if (HRDIsGoal(initialCoords)) {
        return @[];
    }
    
    NSString *initialKey = HRDStateKeyForCoords(initialCoords, pieceCount, widths, heights);
    if (!initialKey) {
        return @[];
    }
    
    NSMutableArray<NSArray<NSNumber *> *> *queue = [NSMutableArray array];
    NSMutableArray<NSString *> *keys = [NSMutableArray array];
    [queue addObject:[coords copy]];
    [keys addObject:initialKey];
    NSMutableSet<NSString *> *visited = [NSMutableSet setWithObject:initialKey];
    NSMutableDictionary<NSString *, NSDictionary *> *parentMap = [NSMutableDictionary dictionary];
    
    NSUInteger head = 0;
    while (head < queue.count) {
        NSArray<NSNumber *> *state = queue[head];
        NSString *stateKey = keys[head];
        head++;
        
        NSInteger stateCoords[pieceCount * 2];
        for (NSInteger idx = 0; idx < pieceCount * 2; idx++) {
            stateCoords[idx] = state[idx].integerValue;
        }
        
        if (HRDIsGoal(stateCoords)) {
            NSMutableArray<NSDictionary *> *moves = [NSMutableArray array];
            NSString *cursorKey = stateKey;
            while (![cursorKey isEqualToString:initialKey]) {
                NSDictionary *info = parentMap[cursorKey];
                if (!info) {
                    break;
                }
                NSDictionary *move = info[@"move"];
                if (move) {
                    [moves addObject:move];
                }
                cursorKey = info[@"parent"];
            }
            NSArray<NSDictionary *> *reversed = [[moves reverseObjectEnumerator] allObjects];
            return reversed;
        }
        
        for (NSInteger pieceIndex = 0; pieceIndex < pieceCount; pieceIndex++) {
            for (NSInteger direction = 0; direction < kHRDDirectionCount; direction++) {
                NSInteger dRow = kHRDDirectionRows[direction];
                NSInteger dCol = kHRDDirectionCols[direction];
                if (!HRDCanMovePiece(stateCoords, pieceIndex, dRow, dCol, pieceCount, widths, heights)) {
                    continue;
                }
                NSInteger nextCoords[pieceCount * 2];
                for (NSInteger idx = 0; idx < pieceCount * 2; idx++) {
                    nextCoords[idx] = stateCoords[idx];
                }
                nextCoords[pieceIndex * 2] += dRow;
                nextCoords[pieceIndex * 2 + 1] += dCol;
                NSString *nextKey = HRDStateKeyForCoords(nextCoords, pieceCount, widths, heights);
                if (!nextKey || [visited containsObject:nextKey]) {
                    continue;
                }
                NSMutableArray<NSNumber *> *nextState = [state mutableCopy];
                nextState[pieceIndex * 2] = @(stateCoords[pieceIndex * 2] + dRow);
                nextState[pieceIndex * 2 + 1] = @(stateCoords[pieceIndex * 2 + 1] + dCol);
                [queue addObject:[nextState copy]];
                [keys addObject:nextKey];
                [visited addObject:nextKey];
                NSDictionary *moveInfo = @{
                    @"identifier": order[pieceIndex],
                    @"row": @(dRow),
                    @"col": @(dCol)
                };
                parentMap[nextKey] = @{@"parent": stateKey, @"move": moveInfo};
            }
        }
    }
    return @[];
}

- (HRDPieceModel *)pieceForView:(UIView *)view
{
    for (HRDPieceModel *piece in self.pieces) {
        if (piece.view == view) {
            return piece;
        }
    }
    return nil;
}

#pragma mark - Actions

- (void)handleBack
{
    if (self.autoSolving) {
        [self cancelAutoSolve];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleReset
{
    if (self.autoSolving) {
        [self cancelAutoSolve];
    }
    [self resetBoardAnimated:YES];
}

- (void)handleAutoSolveTapped
{
    if (self.autoSolving) {
        return;
    }
    [self beginAutoSolve];
}

- (void)setControlsEnabled:(BOOL)enabled
{
    self.backButton.enabled = enabled;
    self.resetButton.enabled = enabled;
    self.autoSolveButton.enabled = enabled;
    self.backButton.alpha = enabled ? 1.0f : 0.6f;
    self.resetButton.alpha = enabled ? 1.0f : 0.6f;
    self.autoSolveButton.alpha = enabled ? 1.0f : 0.6f;
}

- (void)beginAutoSolve
{
    NSArray<NSString *> *order = [self solverPieceOrder];
    NSMutableArray<NSNumber *> *coords = [NSMutableArray arrayWithCapacity:order.count * 2];
    NSMutableArray<NSValue *> *sizes = [NSMutableArray arrayWithCapacity:order.count];
    for (NSString *identifier in order) {
        HRDPieceModel *piece = [self pieceWithIdentifier:identifier];
        if (!piece) {
            [self presentAutoSolveFailureWithMessage:@"无法找到所有棋子，自动过关已取消。"];
            return;
        }
        [coords addObject:@(piece.row)];
        [coords addObject:@(piece.col)];
        [sizes addObject:[NSValue valueWithCGSize:CGSizeMake(piece.width, piece.height)]];
    }
    
    NSInteger firstRow = coords.count >= 2 ? coords[0].integerValue : 0;
    NSInteger firstCol = coords.count >= 2 ? coords[1].integerValue : 0;
    if (firstRow == 3 && firstCol == 1) {
        [self presentAutoSolveFailureWithMessage:@"已经到达终点，无需再次自动过关。"];
        return;
    }
    
    self.autoSolving = YES;
    [self setControlsEnabled:NO];
    [self.autoSolveIndicator startAnimating];
    self.boardContainer.userInteractionEnabled = NO;
    
    NSArray<NSNumber *> *coordsCopy = [coords copy];
    NSArray<NSValue *> *sizesCopy = [sizes copy];
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.solverQueue, ^{
        @autoreleasepool {
            NSArray<NSDictionary *> *moves = [weakSelf computeAutoSolveMovesWithCoords:coordsCopy
                                                                                  sizes:sizesCopy
                                                                                  order:order];
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (!strongSelf || !strongSelf.autoSolving) {
                    return;
                }
                if (moves.count == 0) {
                    [strongSelf finishAutoSolveWithSuccess:NO message:@"未能找到通往终点的路径。"];
                    return;
                }
                strongSelf.pendingAutoSolveMoves = moves;
                [strongSelf runAutoSolveMoveAtIndex:0];
            });
        }
    });
}

- (void)cancelAutoSolve
{
    self.autoSolving = NO;
    self.pendingAutoSolveMoves = nil;
    [self.autoSolveIndicator stopAnimating];
    [self setControlsEnabled:YES];
    self.boardContainer.userInteractionEnabled = YES;
}

- (void)finishAutoSolveWithSuccess:(BOOL)success message:(NSString *)message
{
    [self.autoSolveIndicator stopAnimating];
    self.autoSolving = NO;
    self.pendingAutoSolveMoves = nil;
    [self setControlsEnabled:YES];
    self.boardContainer.userInteractionEnabled = YES;
    if (success) {
        [self checkVictoryCondition];
    } else if (message.length > 0) {
        [self presentAutoSolveFailureWithMessage:message];
    }
}

- (void)presentAutoSolveFailureWithMessage:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)runAutoSolveMoveAtIndex:(NSUInteger)index
{
    if (!self.autoSolving) {
        return;
    }
    NSArray<NSDictionary *> *moves = self.pendingAutoSolveMoves;
    if (moves.count == 0 || index >= moves.count) {
        [self finishAutoSolveWithSuccess:YES message:nil];
        return;
    }
    NSDictionary *move = moves[index];
    NSString *identifier = move[@"identifier"];
    NSInteger dRow = [move[@"row"] integerValue];
    NSInteger dCol = [move[@"col"] integerValue];
    __weak typeof(self) weakSelf = self;
    [self performProgrammaticMoveForIdentifier:identifier
                                       rowDelta:dRow
                                        colDelta:dCol
                                      completion:^(BOOL success) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || !strongSelf.autoSolving) {
            return;
        }
        if (!success) {
            [strongSelf finishAutoSolveWithSuccess:NO message:@"执行自动移动时失败。"];
            return;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [strongSelf runAutoSolveMoveAtIndex:index + 1];
        });
    }];
}

- (void)performProgrammaticMoveForIdentifier:(NSString *)identifier
                                    rowDelta:(NSInteger)rowDelta
                                     colDelta:(NSInteger)colDelta
                                   completion:(void (^)(BOOL success))completion
{
    HRDPieceModel *piece = [self pieceWithIdentifier:identifier];
    if (!piece) {
        if (completion) {
            completion(NO);
        }
        return;
    }
    if (![self canMovePiece:piece byRow:rowDelta col:colDelta]) {
        if (completion) {
            completion(NO);
        }
        return;
    }
    [self removePieceFromGrid:piece];
    piece.row += rowDelta;
    piece.col += colDelta;
    [self occupyGridWithPiece:piece];
    [UIView animateWithDuration:0.5f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
        [self applyLayoutToPiece:piece];
    } completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
    }];
}

- (BOOL)canMovePiece:(HRDPieceModel *)piece byRow:(NSInteger)rowDelta col:(NSInteger)colDelta
{
    if (!piece) {
        return NO;
    }
    NSInteger newRow = piece.row + rowDelta;
    NSInteger newCol = piece.col + colDelta;
    if (newRow < 0 || newCol < 0) {
        return NO;
    }
    if (newRow + piece.height > kHRDRowCount || newCol + piece.width > kHRDColumnCount) {
        return NO;
    }
    NSInteger newBottom = newRow + piece.height - 1;
    NSInteger newRight = newCol + piece.width - 1;
    for (HRDPieceModel *other in self.pieces) {
        if (other == piece) {
            continue;
        }
        NSInteger otherRow = other.row;
        NSInteger otherCol = other.col;
        NSInteger otherBottom = otherRow + other.height - 1;
        NSInteger otherRight = otherCol + other.width - 1;
        BOOL separatedVertically = (newRow > otherBottom) || (newBottom < otherRow);
        BOOL separatedHorizontally = (newCol > otherRight) || (newRight < otherCol);
        if (!(separatedVertically || separatedHorizontally)) {
            return NO;
        }
    }
    return YES;
}

- (void)resetBoardAnimated:(BOOL)animated
{
    for (HRDPieceModel *piece in self.pieces) {
        piece.row = piece.originalRow;
        piece.col = piece.originalCol;
    }
    [self rebuildGrid];
    self.hasShownVictory = NO;
    [self layoutPiecesAnimated:animated];
}

- (void)checkVictoryCondition
{
    if (self.hasShownVictory) {
        return;
    }
    for (HRDPieceModel *piece in self.pieces) {
        if ([piece.identifier isEqualToString:@"cao"]) {
            if (piece.row == 3 && piece.col == 1) {
                [self presentVictory];
            }
            break;
        }
    }
}

- (void)presentVictory
{
    if (self.hasShownVictory) {
        return;
    }
    self.hasShownVictory = YES;
    __weak typeof(self) weakSelf = self;
    [CelebrationOverlayView presentInView:self.view
                                  message:@"曹操突围成功！"
                                   detail:@"华容道已被你破解，继续挑战更优的步数吧。"
                                  confirm:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf resetBoardAnimated:YES];
        }
    }];
}

@end
