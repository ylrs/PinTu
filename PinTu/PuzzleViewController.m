//
//  PuzzleViewController.m
//  PinTu
//
//  Created by Codex on 2024/10/05.
//

#import "PuzzleViewController.h"
#import "PinTu/PinTuView.h"
#import <QuartzCore/QuartzCore.h>
#import "BackdoorViewController.h"
#import "CelebrationOverlayView.h"

@interface PuzzleViewController ()<BackdoorViewControllerDelegate, PinTuViewDelegate>
@property (nonatomic, strong) UIImage *sourceImage;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) UIView *puzzleContainer;
@property (nonatomic, strong) PinTuView *puzzleView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIImageView *referenceImageView;
@property (nonatomic, assign) BOOL hasRevealedIndices;
@property (nonatomic, strong) UIImage *activePuzzleImage;
@property (nonatomic, strong) NSDate *puzzleStartDate;
@property (nonatomic, assign) BOOL hasShownCompletionAlert;
@property (nonatomic, strong) UILabel *timerLabel;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL autoSolving;
@property (nonatomic, assign) PinTuShuffleDifficulty currentDifficulty;
@property (nonatomic, strong) UIView *autoSolveHUD;
@property (nonatomic, strong) UIActivityIndicatorView *autoSolveIndicator;
@property (nonatomic, strong) UILabel *autoSolveLabel;
@end

@implementation PuzzleViewController

- (instancetype)initWithImage:(UIImage *)image
{
    return [self initWithImage:image difficulty:PinTuShuffleDifficultyHard];
}

- (instancetype)initWithImage:(UIImage *)image difficulty:(PinTuShuffleDifficulty)difficulty
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _sourceImage = image;
        _activePuzzleImage = image;
        _puzzleStartDate = nil;
        _hasShownCompletionAlert = NO;
        _currentDifficulty = difficulty;
        _hasRevealedIndices = [[NSUserDefaults standardUserDefaults] boolForKey:BackdoorShowTileIndicesPreferenceKey];
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:self.sourceImage];
    backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundView.clipsToBounds = YES;
    backgroundView.frame = self.view.bounds;
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:backgroundView];
    self.backgroundImageView = backgroundView;
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.frame = self.view.bounds;
    blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:blurView];
    self.blurView = blurView;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImage *backImage = nil;
    if (@available(iOS 13.0, *)) {
        backImage = [UIImage systemImageNamed:@"chevron.left"];
    }
    if (backImage) {
        [backButton setImage:backImage forState:UIControlStateNormal];
        backButton.tintColor = [UIColor whiteColor];
    } else {
        [backButton setTitle:@"←" forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    backButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.35f];
    backButton.layer.cornerRadius = 22.0f;
    backButton.layer.masksToBounds = YES;
    backButton.contentEdgeInsets = UIEdgeInsetsMake(8.0f, 12.0f, 8.0f, 12.0f);
    [backButton addTarget:self action:@selector(closePressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    self.backButton = backButton;
    
    UILabel *timerLabel = [[UILabel alloc] init];
    timerLabel.textAlignment = NSTextAlignmentCenter;
    timerLabel.font = [UIFont monospacedDigitSystemFontOfSize:26 weight:UIFontWeightBold];
    timerLabel.textColor = [UIColor whiteColor];
    timerLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35f];
    timerLabel.layer.cornerRadius = 18.0f;
    timerLabel.layer.masksToBounds = YES;
    timerLabel.text = @"00:00";
    [self.view addSubview:timerLabel];
    self.timerLabel = timerLabel;
    
    UIImageView *referenceView = [[UIImageView alloc] initWithImage:self.sourceImage];
    referenceView.contentMode = UIViewContentModeScaleAspectFill;
    referenceView.layer.cornerRadius = 8.0f;
    referenceView.layer.masksToBounds = YES;
    referenceView.layer.borderWidth = 1.0f;
    referenceView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.6f].CGColor;
    referenceView.layer.shadowColor = [UIColor blackColor].CGColor;
    referenceView.layer.shadowOpacity = 0.25f;
    referenceView.layer.shadowRadius = 6.0f;
    referenceView.layer.shadowOffset = CGSizeZero;
    referenceView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(referenceTapped)];
    [referenceView addGestureRecognizer:tap];
    [self.view addSubview:referenceView];
    self.referenceImageView = referenceView;
}

- (void)ensureAutoSolveHUD
{
    if (self.autoSolveHUD) {
        return;
    }
    UIView *hud = [[UIView alloc] init];
    hud.translatesAutoresizingMaskIntoConstraints = NO;
    hud.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.55f];
    hud.layer.cornerRadius = 18.0f;
    hud.layer.masksToBounds = YES;
    hud.hidden = YES;
    hud.alpha = 0.0f;
    
    UIActivityIndicatorView *indicator = nil;
    if (@available(iOS 13.0, *)) {
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    } else {
        indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    indicator.translatesAutoresizingMaskIntoConstraints = NO;
    indicator.color = [UIColor whiteColor];
    indicator.hidesWhenStopped = YES;
    
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.text = @"正在计算最佳路径…";
    label.font = [UIFont systemFontOfSize:15.0f weight:UIFontWeightSemibold];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    
    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[indicator, label]];
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    stack.axis = UILayoutConstraintAxisVertical;
    stack.alignment = UIStackViewAlignmentCenter;
    stack.spacing = 12.0f;
    
    [hud addSubview:stack];
    [NSLayoutConstraint activateConstraints:@[
        [stack.centerXAnchor constraintEqualToAnchor:hud.centerXAnchor],
        [stack.centerYAnchor constraintEqualToAnchor:hud.centerYAnchor],
        [stack.leadingAnchor constraintEqualToAnchor:hud.leadingAnchor constant:20.0f],
        [stack.trailingAnchor constraintEqualToAnchor:hud.trailingAnchor constant:-20.0f]
    ]];
    
    [self.view addSubview:hud];
    [NSLayoutConstraint activateConstraints:@[
        [hud.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [hud.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [hud.widthAnchor constraintGreaterThanOrEqualToConstant:200.0f]
    ]];
    
    self.autoSolveHUD = hud;
    self.autoSolveIndicator = indicator;
    self.autoSolveLabel = label;
}

- (void)showAutoSolveLoading
{
    [self ensureAutoSolveHUD];
    if (!self.autoSolveHUD || !self.autoSolveIndicator) {
        return;
    }
    self.autoSolveLabel.text = @"正在计算最佳路径…";
    self.autoSolveHUD.hidden = NO;
    [self.view bringSubviewToFront:self.autoSolveHUD];
    [self.autoSolveIndicator startAnimating];
    [UIView animateWithDuration:0.2 animations:^{
        self.autoSolveHUD.alpha = 1.0f;
    }];
}

- (void)hideAutoSolveLoading
{
    if (!self.autoSolveHUD || self.autoSolveHUD.hidden) {
        return;
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.autoSolveHUD.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.autoSolveHUD.hidden = YES;
        [self.autoSolveIndicator stopAnimating];
    }];
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.backgroundImageView.frame = self.view.bounds;
    self.blurView.frame = self.view.bounds;
    
    UIEdgeInsets safeInsets;
    if (@available(iOS 11.0, *)) {
        safeInsets = self.view.safeAreaInsets;
    } else {
        safeInsets = UIEdgeInsetsZero;
    }
    
    [self.backButton sizeToFit];
    CGFloat buttonWidth = MAX(self.backButton.bounds.size.width, 44.0f);
    CGFloat buttonHeight = MAX(self.backButton.bounds.size.height, 44.0f);
    self.backButton.frame = CGRectMake(safeInsets.left + 16.0f,
                                       safeInsets.top + 16.0f,
                                       buttonWidth,
                                       buttonHeight);
    self.backButton.layer.cornerRadius = buttonHeight / 2.0f;
    
    CGFloat referenceSide = 120.0f;
    CGRect referenceFrame = CGRectMake(self.view.bounds.size.width - safeInsets.right - referenceSide - 16.0f,
                                       safeInsets.top + 16.0f,
                                       referenceSide,
                                       referenceSide);
    self.referenceImageView.frame = referenceFrame;
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.referenceImageView.bounds];
    self.referenceImageView.layer.shadowPath = shadowPath.CGPath;
    
    CGSize boundsSize = self.view.bounds.size;
    CGFloat horizontalMargin = 24.0f;
    CGFloat sideLength = MIN(boundsSize.width, boundsSize.height) - horizontalMargin * 2.0f;
    if (sideLength < 220.0f) {
        sideLength = 220.0f;
    }
    CGRect puzzleFrame = CGRectMake((boundsSize.width - sideLength) / 2.0f,
                                    (boundsSize.height - sideLength) / 2.0f,
                                    sideLength,
                                    sideLength);
    
    CGFloat glowCornerRadius = 0.0f;
    if (!self.puzzleContainer) {
        UIView *container = [[UIView alloc] initWithFrame:puzzleFrame];
        container.backgroundColor = [UIColor colorWithWhite:1 alpha:0.05f];
        container.layer.cornerRadius = glowCornerRadius;
        container.layer.borderWidth = 2.0f;
        container.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.45f].CGColor;
        container.layer.shadowColor = [UIColor colorWithRed:0.6f green:0.78f blue:1.0f alpha:1.0f].CGColor;
        container.layer.shadowOpacity = 0.85f;
        container.layer.shadowRadius = 24.0f;
        container.layer.shadowOffset = CGSizeZero;
        container.layer.masksToBounds = NO;
        [self.view addSubview:container];
        self.puzzleContainer = container;
        [self applyGlowAnimationToLayer:container.layer];
    } else if (![self.puzzleContainer.layer animationForKey:@"glowPulse"]) {
        [self applyGlowAnimationToLayer:self.puzzleContainer.layer];
    }
    self.puzzleContainer.frame = puzzleFrame;
    self.puzzleContainer.layer.cornerRadius = glowCornerRadius;
    self.puzzleContainer.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.puzzleContainer.bounds].CGPath;
    
    if (!self.puzzleView) {
        PinTuView *puzzle = [[PinTuView alloc] initWithFrame:self.puzzleContainer.bounds];
        puzzle.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        puzzle.completionDelegate = self;
        [puzzle configureWithImage:self.sourceImage];
        [puzzle showIndexOverlay:self.hasRevealedIndices];
        [self.puzzleContainer addSubview:puzzle];
        self.puzzleView = puzzle;
        self.activePuzzleImage = self.sourceImage;
        self.hasShownCompletionAlert = NO;
        [self applyDifficulty:self.currentDifficulty];
    } else if (!CGRectEqualToRect(self.puzzleView.frame, self.puzzleContainer.bounds)) {
        [self.puzzleView removeFromSuperview];
        PinTuView *puzzle = [[PinTuView alloc] initWithFrame:self.puzzleContainer.bounds];
        puzzle.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        puzzle.completionDelegate = self;
        [puzzle configureWithImage:self.sourceImage];
        [puzzle showIndexOverlay:self.hasRevealedIndices];
        [self.puzzleContainer addSubview:puzzle];
        self.puzzleView = puzzle;
        self.activePuzzleImage = self.sourceImage;
        self.hasShownCompletionAlert = NO;
        [self applyDifficulty:self.currentDifficulty];
    }
    self.puzzleView.completionDelegate = self;
    [self.puzzleView showIndexOverlay:self.hasRevealedIndices];
    
    [self.view bringSubviewToFront:self.backButton];
    [self.view bringSubviewToFront:self.referenceImageView];
    CGSize timerSize = CGSizeMake(140.0f, 44.0f);
    self.timerLabel.frame = CGRectMake((self.view.bounds.size.width - timerSize.width) / 2.0f,
                                       safeInsets.top + 70.0f,
                                       timerSize.width,
                                       timerSize.height);
    [self.view bringSubviewToFront:self.timerLabel];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.puzzleView showIndexOverlay:self.hasRevealedIndices];
    [self startPuzzleTimerIfNeeded];
}

- (void)referenceTapped
{
    BackdoorViewController *controller = [[BackdoorViewController alloc] init];
    controller.delegate = self;
    controller.showTileIndices = self.hasRevealedIndices;
    controller.selectedDifficulty = self.currentDifficulty;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)applyGlowAnimationToLayer:(CALayer *)layer
{
    if (!layer) {
        return;
    }
    if ([layer animationForKey:@"glowPulse"]) {
        return;
    }
    CABasicAnimation *opacityPulse = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    opacityPulse.fromValue = @(0.35f);
    opacityPulse.toValue = @(0.95f);
    opacityPulse.duration = 1.2f;
    opacityPulse.autoreverses = YES;
    opacityPulse.repeatCount = HUGE_VALF;
    opacityPulse.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [layer addAnimation:opacityPulse forKey:@"glowPulse"];
}

- (void)closePressed
{
    [self stopPuzzleTimer];
    self.autoSolving = NO;
    self.puzzleView.userInteractionEnabled = YES;
    [self hideAutoSolveLoading];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - BackdoorViewControllerDelegate
- (void)backdoorViewController:(BackdoorViewController *)controller didSelectAction:(BackdoorAction)action
{
    __weak typeof(self) weakSelf = self;
    BOOL shouldShow = controller.showTileIndices;
    PinTuShuffleDifficulty chosenDifficulty = controller.selectedDifficulty;
    [controller dismissViewControllerAnimated:YES completion:^{
        if (!weakSelf) {
            return;
        }
        if (action == BackdoorActionShowTileIndices) {
            [weakSelf toggleTileIndices:shouldShow];
        } else if (action == BackdoorActionAutoSolve) {
            [weakSelf startAutoSolveSequence];
        } else if (action == BackdoorActionChangeDifficulty) {
            [weakSelf applyDifficulty:chosenDifficulty];
        }
    }];
}

- (void)applyDifficulty:(PinTuShuffleDifficulty)difficulty
{
    self.currentDifficulty = difficulty;
    if (!self.puzzleView) {
        return;
    }
    self.autoSolving = NO;
    self.puzzleView.userInteractionEnabled = YES;
    [self.puzzleView resetAutoSolveProgress];
    [self stopPuzzleTimer];
    self.puzzleStartDate = [NSDate date];
    self.hasShownCompletionAlert = NO;
    self.timerLabel.text = @"00:00";
    [self.puzzleView applyShuffleWithDifficulty:difficulty];
    [self.puzzleView showIndexOverlay:self.hasRevealedIndices];
    [self startPuzzleTimerIfNeeded];
    [self hideAutoSolveLoading];
}

- (void)toggleTileIndices:(BOOL)show
{
    self.hasRevealedIndices = show;
    [self.puzzleView showIndexOverlay:show];
    [[NSUserDefaults standardUserDefaults] setBool:self.hasRevealedIndices
                                            forKey:BackdoorShowTileIndicesPreferenceKey];
}

- (void)startAutoSolveSequence
{
    if (self.autoSolving || !self.puzzleView) {
        return;
    }
    self.autoSolving = YES;
    self.hasShownCompletionAlert = NO;
    self.puzzleView.userInteractionEnabled = NO;
    [self stopPuzzleTimer];
    self.timerLabel.text = @"自动中";
    self.puzzleStartDate = [NSDate date];
    [self.puzzleView resetAutoSolveProgress];
    [self showAutoSolveLoading];
    [self performAutoSolveStepAndSchedule];
}

- (void)performAutoSolveStepAndSchedule
{
    if (!self.puzzleView) {
        self.autoSolving = NO;
        self.puzzleView.userInteractionEnabled = YES;
        [self hideAutoSolveLoading];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self.puzzleView performAutoSolveStepWithCompletion:^(BOOL hasMore) {
        if (!weakSelf) {
            return;
        }
        [weakSelf hideAutoSolveLoading];
        if (!weakSelf.autoSolving || !hasMore) {
            weakSelf.autoSolving = NO;
            weakSelf.puzzleView.userInteractionEnabled = YES;
            return;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!weakSelf.autoSolving) {
                return;
            }
            [weakSelf performAutoSolveStepAndSchedule];
        });
    }];
}

- (void)startPuzzleTimerIfNeeded
{
    if (!self.puzzleStartDate) {
        self.puzzleStartDate = [NSDate date];
    }
    [self updateTimerLabel];
    if (self.timer) {
        [self.timer invalidate];
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(updateTimerLabel)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)stopPuzzleTimer
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    [self hideAutoSolveLoading];
}

- (void)updateTimerLabel
{
    if (!self.puzzleStartDate) {
        self.timerLabel.text = @"00:00";
        return;
    }
    NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:self.puzzleStartDate];
    NSInteger totalSeconds = (NSInteger)elapsed;
    NSInteger minutes = totalSeconds / 60;
    NSInteger seconds = totalSeconds % 60;
    self.timerLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
}

- (void)dealloc
{
    [self.timer invalidate];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopPuzzleTimer];
    self.autoSolving = NO;
    self.puzzleView.userInteractionEnabled = YES;
    [self hideAutoSolveLoading];
}

#pragma mark - PinTuViewDelegate
- (void)pinTuViewDidComplete:(PinTuView *)puzzleView
{
    if (self.hasShownCompletionAlert) {
        return;
    }
    self.hasShownCompletionAlert = YES;
    self.autoSolving = NO;
    self.puzzleView.userInteractionEnabled = YES;
    [self stopPuzzleTimer];
    NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:self.puzzleStartDate ?: [NSDate date]];
    NSInteger totalSeconds = (NSInteger)round(elapsed);
    NSInteger minutes = totalSeconds / 60;
    NSInteger seconds = totalSeconds % 60;
    NSString *title = @"馨馨小宝贝\n你太棒了！";
    NSString *detail = [NSString stringWithFormat:@"用时 %02ld:%02ld 完成拼图，点亮完美徽章 ✨", (long)minutes, (long)seconds];
    self.timerLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    
    __weak typeof(self) weakSelf = self;
    [CelebrationOverlayView presentInView:self.view
                                  message:title
                                   detail:detail
                                  confirm:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [strongSelf dismissViewControllerAnimated:YES completion:nil];
        });
    }];
}

@end
