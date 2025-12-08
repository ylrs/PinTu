//
//  PuzzleViewController.m
//  PinTu
//
//  Created by Codex on 2024/10/05.
//

#import "PuzzleViewController.h"
#import "PinTu/PinTuView.h"
#import <QuartzCore/QuartzCore.h>

@interface PuzzleViewController ()
@property (nonatomic, strong) UIImage *sourceImage;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) UIView *puzzleContainer;
@property (nonatomic, strong) PinTuView *puzzleView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIImageView *referenceImageView;
@end

@implementation PuzzleViewController

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _sourceImage = image;
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
    [self.view addSubview:referenceView];
    self.referenceImageView = referenceView;
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
        [puzzle configureWithImage:self.sourceImage];
        [self.puzzleContainer addSubview:puzzle];
        self.puzzleView = puzzle;
    } else if (!CGRectEqualToRect(self.puzzleView.frame, self.puzzleContainer.bounds)) {
        [self.puzzleView removeFromSuperview];
        PinTuView *puzzle = [[PinTuView alloc] initWithFrame:self.puzzleContainer.bounds];
        puzzle.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [puzzle configureWithImage:self.sourceImage];
        [self.puzzleContainer addSubview:puzzle];
        self.puzzleView = puzzle;
    }
    
    [self.view bringSubviewToFront:self.backButton];
    [self.view bringSubviewToFront:self.referenceImageView];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
