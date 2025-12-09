//
//  CelebrationOverlayView.m
//  PinTu
//
//  Created by Codex on 2025/12/09.
//

#import "CelebrationOverlayView.h"

static const CGFloat kCardCornerRadius = 24.0f;
static const CGFloat kButtonCornerRadius = 18.0f;

@interface CelebrationOverlayView ()

@property (nonatomic, copy) dispatch_block_t confirmHandler;
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) CAEmitterLayer *confettiLayer;

@end

@implementation CelebrationOverlayView

+ (void)presentInView:(UIView *)view
              message:(NSString *)message
               detail:(NSString *)detail
              confirm:(dispatch_block_t)confirmHandler
{
    if (!view) {
        return;
    }
    CelebrationOverlayView *overlay = [[CelebrationOverlayView alloc] initWithMessage:message
                                                                               detail:detail
                                                                              confirm:confirmHandler];
    overlay.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:overlay];
    [NSLayoutConstraint activateConstraints:@[
        [overlay.leadingAnchor constraintEqualToAnchor:view.leadingAnchor],
        [overlay.trailingAnchor constraintEqualToAnchor:view.trailingAnchor],
        [overlay.topAnchor constraintEqualToAnchor:view.topAnchor],
        [overlay.bottomAnchor constraintEqualToAnchor:view.bottomAnchor]
    ]];
    [overlay showAnimated];
}

- (instancetype)initWithMessage:(NSString *)message
                         detail:(NSString *)detail
                        confirm:(dispatch_block_t)confirmHandler
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _confirmHandler = [confirmHandler copy];
        [self configureInterfaceWithMessage:message detail:detail];
    }
    return self;
}

- (void)configureInterfaceWithMessage:(NSString *)message detail:(NSString *)detail
{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.55f];
    self.userInteractionEnabled = YES;
    
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    blurView.translatesAutoresizingMaskIntoConstraints = NO;
    blurView.alpha = 0.45f;
    [self addSubview:blurView];
    [NSLayoutConstraint activateConstraints:@[
        [blurView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [blurView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [blurView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [blurView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
    ]];
    
    UIView *card = [[UIView alloc] init];
    card.translatesAutoresizingMaskIntoConstraints = NO;
    card.layer.cornerRadius = kCardCornerRadius;
    card.layer.masksToBounds = YES;
    card.layer.shadowColor = [UIColor colorWithRed:0.1f green:0.15f blue:0.35f alpha:0.35f].CGColor;
    card.layer.shadowOpacity = 0.5f;
    card.layer.shadowRadius = 20.0f;
    card.layer.shadowOffset = CGSizeMake(0, 20.0f);
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.colors = @[(__bridge id)[UIColor colorWithRed:0.18f green:0.28f blue:0.96f alpha:1.0f].CGColor,
                        (__bridge id)[UIColor colorWithRed:0.80f green:0.18f blue:1.0f alpha:1.0f].CGColor];
    gradient.startPoint = CGPointMake(0.0f, 0.0f);
    gradient.endPoint = CGPointMake(1.0f, 1.0f);
    gradient.frame = CGRectMake(0, 0, 320.0f, 260.0f);
    gradient.cornerRadius = kCardCornerRadius;
    [card.layer insertSublayer:gradient atIndex:0];
    [self addSubview:card];
    self.cardView = card;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.text = message.length > 0 ? message : @"太棒了！";
    titleLabel.font = [UIFont systemFontOfSize:28.0f weight:UIFontWeightHeavy];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 0;
    
    UILabel *detailLabel = [[UILabel alloc] init];
    detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    detailLabel.text = detail;
    detailLabel.font = [UIFont systemFontOfSize:16.0f weight:UIFontWeightMedium];
    detailLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9f];
    detailLabel.textAlignment = NSTextAlignmentCenter;
    detailLabel.numberOfLines = 0;
    
    UIView *glowBadge = [[UIView alloc] init];
    glowBadge.translatesAutoresizingMaskIntoConstraints = NO;
    glowBadge.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.18f];
    glowBadge.layer.cornerRadius = 18.0f;
    glowBadge.layer.masksToBounds = YES;
    
    UILabel *badgeLabel = [[UILabel alloc] init];
    badgeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    badgeLabel.text = @"⭐️ 完美拼图";
    badgeLabel.font = [UIFont systemFontOfSize:14.0f weight:UIFontWeightSemibold];
    badgeLabel.textColor = [UIColor whiteColor];
    [glowBadge addSubview:badgeLabel];
    [NSLayoutConstraint activateConstraints:@[
        [badgeLabel.centerXAnchor constraintEqualToAnchor:glowBadge.centerXAnchor],
        [badgeLabel.centerYAnchor constraintEqualToAnchor:glowBadge.centerYAnchor],
        [badgeLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:glowBadge.leadingAnchor constant:12.0f],
        [badgeLabel.trailingAnchor constraintLessThanOrEqualToAnchor:glowBadge.trailingAnchor constant:-12.0f]
    ]];
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
    confirmButton.translatesAutoresizingMaskIntoConstraints = NO;
    confirmButton.layer.cornerRadius = kButtonCornerRadius;
    confirmButton.layer.masksToBounds = YES;
    confirmButton.backgroundColor = [UIColor whiteColor];
    [confirmButton setTitleColor:[UIColor colorWithRed:0.18f green:0.24f blue:0.56f alpha:1.0f] forState:UIControlStateNormal];
    [confirmButton setTitle:@"继续闯关" forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:17.0f weight:UIFontWeightSemibold];
    [confirmButton addTarget:self action:@selector(confirmButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[glowBadge, titleLabel, detailLabel, confirmButton]];
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 18.0f;
    stack.alignment = UIStackViewAlignmentCenter;
    
    [card addSubview:stack];
    
    CGFloat cardWidth = MIN([UIScreen mainScreen].bounds.size.width - 40.0f, 320.0f);
    [NSLayoutConstraint activateConstraints:@[
        [card.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [card.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [card.widthAnchor constraintEqualToConstant:cardWidth],
        
        [stack.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:28.0f],
        [stack.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-28.0f],
        [stack.topAnchor constraintEqualToAnchor:card.topAnchor constant:32.0f],
        [stack.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-32.0f],
        
        [glowBadge.heightAnchor constraintEqualToConstant:36.0f],
        [glowBadge.widthAnchor constraintGreaterThanOrEqualToConstant:140.0f],
        [confirmButton.heightAnchor constraintEqualToConstant:48.0f],
        [confirmButton.widthAnchor constraintEqualToAnchor:stack.widthAnchor]
    ]];
    
    [self addConfettiLayer];
    [self addPulseAnimationToView:glowBadge];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    for (CALayer *layer in self.cardView.layer.sublayers) {
        if ([layer isKindOfClass:[CAGradientLayer class]]) {
            layer.frame = self.cardView.bounds;
            layer.cornerRadius = kCardCornerRadius;
        }
    }
    self.confettiLayer.emitterPosition = CGPointMake(CGRectGetMidX(self.bounds), -10.0f);
    self.confettiLayer.emitterSize = CGSizeMake(self.bounds.size.width * 1.2f, 1.0f);
}

- (void)addConfettiLayer
{
    CAEmitterLayer *emitter = [CAEmitterLayer layer];
    emitter.emitterShape = kCAEmitterLayerLine;
    emitter.emitterMode = kCAEmitterLayerOutline;
    emitter.birthRate = 1;
    
    NSArray<UIColor *> *colors = @[
        [UIColor colorWithRed:0.99f green:0.52f blue:0.47f alpha:1.0f],
        [UIColor colorWithRed:0.45f green:0.78f blue:0.99f alpha:1.0f],
        [UIColor colorWithRed:0.60f green:0.96f blue:0.60f alpha:1.0f],
        [UIColor colorWithRed:1.00f green:0.89f blue:0.53f alpha:1.0f]
    ];
    
    NSMutableArray<CAEmitterCell *> *cells = [NSMutableArray array];
    for (UIColor *color in colors) {
        CAEmitterCell *cell = [CAEmitterCell emitterCell];
        cell.birthRate = 80;
        cell.lifetime = 4.5f;
        cell.lifetimeRange = 1.0f;
        cell.velocity = 150.0f;
        cell.velocityRange = 60.0f;
        cell.emissionRange = (CGFloat)M_PI;
        cell.spin = 3.5f;
        cell.spinRange = 4.0f;
        cell.scale = 0.5f;
        cell.scaleRange = 0.25f;
        cell.contents = (id)[self imageForConfettiWithColor:color].CGImage;
        [cells addObject:cell];
    }
    emitter.emitterCells = cells;
    [self.layer addSublayer:emitter];
    self.confettiLayer = emitter;
}

- (UIImage *)imageForConfettiWithColor:(UIColor *)color
{
    CGSize size = CGSizeMake(12.0f, 16.0f);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width, size.height)
                                                    cornerRadius:3.0f];
    [color setFill];
    [path fill];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image ?: [UIImage new];
}

- (void)addPulseAnimationToView:(UIView *)view
{
    CABasicAnimation *pulse = [CABasicAnimation animationWithKeyPath:@"opacity"];
    pulse.fromValue = @(0.5f);
    pulse.toValue = @(0.95f);
    pulse.duration = 1.5f;
    pulse.autoreverses = YES;
    pulse.repeatCount = HUGE_VALF;
    [view.layer addAnimation:pulse forKey:@"pulseOpacity"];
}

- (void)showAnimated
{
    self.alpha = 0.0f;
    self.cardView.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
    [UIView animateWithDuration:0.28f
                          delay:0
         usingSpringWithDamping:0.82f
          initialSpringVelocity:0.8f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.alpha = 1.0f;
        self.cardView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)dismissAnimated
{
    [UIView animateWithDuration:0.22f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
        self.alpha = 0.0f;
        self.cardView.transform = CGAffineTransformMakeScale(0.75f, 0.75f);
    } completion:^(BOOL finished) {
        [self.confettiLayer removeFromSuperlayer];
        [self removeFromSuperview];
    }];
}

- (void)confirmButtonTapped
{
    dispatch_block_t handler = self.confirmHandler;
    [self dismissAnimated];
    if (handler) {
        handler();
    }
}

@end
