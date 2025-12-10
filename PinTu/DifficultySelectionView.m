//
//  DifficultySelectionView.m
//  PinTu
//
//  Created by Codex on 2025/12/09.
//

#import "DifficultySelectionView.h"

static const CGFloat kContentCornerRadius = 18.0f;
static const CGFloat kButtonCornerRadius = 12.0f;
static const CGFloat kButtonHeight = 64.0f;
static const CGFloat kButtonHorizontalPadding = 16.0f;
static const CGFloat kButtonVerticalPadding = 14.0f;

static inline UIColor *DifficultyAccentColor(void)
{
    return [UIColor colorWithRed:0.23f green:0.47f blue:0.96f alpha:1.0f];
}

@interface DifficultySelectionView ()

@property (nonatomic, copy) DifficultySelectionHandler selectionHandler;
@property (nonatomic, copy) dispatch_block_t cancelHandler;
@property (nonatomic, assign) PinTuShuffleDifficulty selectedDifficulty;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) NSArray<UIButton *> *difficultyButtons;

@end

@implementation DifficultySelectionView

+ (void)presentInView:(UIView *)view
   defaultDifficulty:(PinTuShuffleDifficulty)defaultDifficulty
           selection:(DifficultySelectionHandler)selectionHandler
              cancel:(dispatch_block_t)cancelHandler
{
    if (!view) {
        return;
    }
    DifficultySelectionView *selectionView = [[DifficultySelectionView alloc] initWithDefaultDifficulty:defaultDifficulty
                                                                                              selection:selectionHandler
                                                                                                cancel:cancelHandler];
    selectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:selectionView];
    
    [NSLayoutConstraint activateConstraints:@[
        [selectionView.leadingAnchor constraintEqualToAnchor:view.leadingAnchor],
        [selectionView.trailingAnchor constraintEqualToAnchor:view.trailingAnchor],
        [selectionView.topAnchor constraintEqualToAnchor:view.topAnchor],
        [selectionView.bottomAnchor constraintEqualToAnchor:view.bottomAnchor]
    ]];
    
    selectionView.alpha = 0.0f;
    selectionView.contentView.transform = CGAffineTransformMakeScale(0.94f, 0.94f);
    [UIView animateWithDuration:0.24
                          delay:0
         usingSpringWithDamping:0.88
          initialSpringVelocity:0.65
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        selectionView.alpha = 1.0f;
        selectionView.contentView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (instancetype)initWithDefaultDifficulty:(PinTuShuffleDifficulty)defaultDifficulty
                                selection:(DifficultySelectionHandler)selectionHandler
                                  cancel:(dispatch_block_t)cancelHandler
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _selectedDifficulty = defaultDifficulty;
        _selectionHandler = [selectionHandler copy];
        _cancelHandler = [cancelHandler copy];
        [self buildInterface];
    }
    return self;
}

- (void)buildInterface
{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.45f];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    tap.cancelsTouchesInView = NO;
    [self addGestureRecognizer:tap];
    
    UIView *content = [[UIView alloc] init];
    content.translatesAutoresizingMaskIntoConstraints = NO;
    content.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.95f];
    content.layer.cornerRadius = kContentCornerRadius;
    content.layer.masksToBounds = NO;
    content.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.35f].CGColor;
    content.layer.shadowOpacity = 0.4f;
    content.layer.shadowRadius = 18.0f;
    content.layer.shadowOffset = CGSizeMake(0, 12.0f);
    [self addSubview:content];
    self.contentView = content;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.text = @"选择难度";
    titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    titleLabel.textColor = [UIColor colorWithWhite:0.1f alpha:1.0f];
    
    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    subtitleLabel.text = @"不同复杂度会影响打乱步数和挑战难度";
    subtitleLabel.font = [UIFont systemFontOfSize:14.0f weight:UIFontWeightRegular];
    subtitleLabel.textColor = [UIColor colorWithWhite:0.28f alpha:1.0f];
    subtitleLabel.numberOfLines = 0;
    
    UIStackView *buttonStack = [[UIStackView alloc] init];
    buttonStack.translatesAutoresizingMaskIntoConstraints = NO;
    buttonStack.axis = UILayoutConstraintAxisVertical;
    buttonStack.spacing = 12.0f;
    buttonStack.alignment = UIStackViewAlignmentFill;
    buttonStack.distribution = UIStackViewDistributionFillEqually;
    
    NSArray<NSNumber *> *difficulties = @[
        @(PinTuShuffleDifficultySimple),
        @(PinTuShuffleDifficultyHard),
        @(PinTuShuffleDifficultyHell)
    ];
    
    NSMutableArray<UIButton *> *createdButtons = [NSMutableArray arrayWithCapacity:difficulties.count];
    for (NSNumber *value in difficulties) {
        PinTuShuffleDifficulty difficulty = (PinTuShuffleDifficulty)value.integerValue;
        UIButton *button = [self buildButtonForDifficulty:difficulty];
        [buttonStack addArrangedSubview:button];
        [createdButtons addObject:button];
    }
    self.difficultyButtons = createdButtons;
    [self refreshButtonStates];
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
    confirmButton.translatesAutoresizingMaskIntoConstraints = NO;
    confirmButton.backgroundColor = DifficultyAccentColor();
    confirmButton.layer.cornerRadius = kButtonCornerRadius;
    confirmButton.layer.masksToBounds = YES;
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:17.0f weight:UIFontWeightSemibold];
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(confirmButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    UIStackView *rootStack = [[UIStackView alloc] initWithArrangedSubviews:@[titleLabel, subtitleLabel, buttonStack, confirmButton]];
    rootStack.translatesAutoresizingMaskIntoConstraints = NO;
    rootStack.axis = UILayoutConstraintAxisVertical;
    rootStack.spacing = 18.0f;
    rootStack.alignment = UIStackViewAlignmentFill;
    
    [content addSubview:rootStack];
    
    CGFloat contentWidth = MIN([UIScreen mainScreen].bounds.size.width - 48.0f, 320.0f);
    
    [NSLayoutConstraint activateConstraints:@[
        [content.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
        [content.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
        [content.widthAnchor constraintEqualToConstant:contentWidth],
        
        [rootStack.topAnchor constraintEqualToAnchor:content.topAnchor constant:24.0f],
        [rootStack.leadingAnchor constraintEqualToAnchor:content.leadingAnchor constant:24.0f],
        [rootStack.trailingAnchor constraintEqualToAnchor:content.trailingAnchor constant:-24.0f],
        [rootStack.bottomAnchor constraintEqualToAnchor:content.bottomAnchor constant:-24.0f],
        
        [subtitleLabel.widthAnchor constraintLessThanOrEqualToAnchor:rootStack.widthAnchor],
        [confirmButton.heightAnchor constraintEqualToConstant:52.0f]
    ]];
    
    for (UIButton *button in self.difficultyButtons) {
        [button.heightAnchor constraintEqualToConstant:kButtonHeight].active = YES;
    }
}

- (UIButton *)buildButtonForDifficulty:(PinTuShuffleDifficulty)difficulty
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.layer.cornerRadius = kButtonCornerRadius;
    button.layer.masksToBounds = YES;
    button.tag = difficulty;
    button.titleLabel.hidden = YES;
    button.titleLabel.font = [UIFont systemFontOfSize:17.0f weight:UIFontWeightSemibold];
    
    UILabel *detailLabel = [[UILabel alloc] init];
    detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    detailLabel.font = [UIFont systemFontOfSize:12.0f weight:UIFontWeightMedium];
    detailLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.45f];
    detailLabel.text = [self detailTextForDifficulty:difficulty];
    detailLabel.tag = 1001;
    
    UIView *content = [[UIView alloc] init];
    content.translatesAutoresizingMaskIntoConstraints = NO;
    content.userInteractionEnabled = NO;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.text = [PinTuView displayNameForDifficulty:difficulty];
    titleLabel.font = [UIFont systemFontOfSize:17.0f weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor colorWithWhite:0.15f alpha:1.0f];
    titleLabel.tag = 1000;
    
    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[titleLabel, detailLabel]];
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 4.0f;
    stack.alignment = UIStackViewAlignmentLeading;
    
    [content addSubview:stack];
    [button addSubview:content];
    
    [NSLayoutConstraint activateConstraints:@[
        [content.leadingAnchor constraintEqualToAnchor:button.leadingAnchor constant:kButtonHorizontalPadding],
        [content.trailingAnchor constraintEqualToAnchor:button.trailingAnchor constant:-kButtonHorizontalPadding],
        [content.topAnchor constraintEqualToAnchor:button.topAnchor constant:kButtonVerticalPadding],
        [content.bottomAnchor constraintEqualToAnchor:button.bottomAnchor constant:-kButtonVerticalPadding],
        
        [stack.leadingAnchor constraintEqualToAnchor:content.leadingAnchor],
        [stack.trailingAnchor constraintEqualToAnchor:content.trailingAnchor],
        [stack.topAnchor constraintEqualToAnchor:content.topAnchor],
        [stack.bottomAnchor constraintEqualToAnchor:content.bottomAnchor]
    ]];
    
    [button addTarget:self action:@selector(difficultyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (NSString *)detailTextForDifficulty:(PinTuShuffleDifficulty)difficulty
{
    switch (difficulty) {
        case PinTuShuffleDifficultySimple:
            return @"较少步数，适合轻松体验";
        case PinTuShuffleDifficultyHard:
            return @"标准挑战，平衡难度";
        case PinTuShuffleDifficultyHell:
            return @"大量步数，极限难度";
    }
    return @"";
}

- (void)refreshButtonStates
{
    for (UIButton *button in self.difficultyButtons) {
        BOOL isSelected = (button.tag == self.selectedDifficulty);
        button.backgroundColor = isSelected ? [UIColor colorWithWhite:1.0f alpha:0.98f] : [UIColor colorWithWhite:0.96f alpha:1.0f];
        button.layer.borderWidth = isSelected ? 2.0f : 0.0f;
        button.layer.borderColor = isSelected ? DifficultyAccentColor().CGColor : [UIColor clearColor].CGColor;
        UILabel *titleLabel = [button viewWithTag:1000];
        UILabel *detailLabel = [button viewWithTag:1001];
        if ([titleLabel isKindOfClass:[UILabel class]]) {
            titleLabel.textColor = isSelected ? DifficultyAccentColor() : [UIColor colorWithWhite:0.15f alpha:1.0f];
        }
        if ([detailLabel isKindOfClass:[UILabel class]]) {
            detailLabel.textColor = isSelected ? [DifficultyAccentColor() colorWithAlphaComponent:0.8f] : [[UIColor blackColor] colorWithAlphaComponent:0.45f];
        }
    }
}

- (void)dismissWithCompletion:(void (^ _Nullable)(void))completion
{
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        self.alpha = 0.0f;
        self.contentView.transform = CGAffineTransformMakeScale(0.88f, 0.88f);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (completion) {
            completion();
        }
    }];
}

#pragma mark - Actions

- (void)difficultyButtonTapped:(UIButton *)sender
{
    PinTuShuffleDifficulty chosenDifficulty = (PinTuShuffleDifficulty)sender.tag;
    self.selectedDifficulty = chosenDifficulty;
    [self refreshButtonStates];
}

- (void)confirmButtonTapped
{
    PinTuShuffleDifficulty chosenDifficulty = self.selectedDifficulty;
    __weak typeof(self) weakSelf = self;
    [self dismissWithCompletion:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        if (strongSelf.selectionHandler) {
            strongSelf.selectionHandler(chosenDifficulty);
        }
    }];
}

- (void)cancelButtonTapped
{
    __weak typeof(self) weakSelf = self;
    [self dismissWithCompletion:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        if (strongSelf.cancelHandler) {
            strongSelf.cancelHandler();
        }
    }];
}

- (void)backgroundTapped:(UITapGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self];
    if (CGRectContainsPoint(self.contentView.frame, location)) {
        return;
    }
    [self cancelButtonTapped];
}

@end
