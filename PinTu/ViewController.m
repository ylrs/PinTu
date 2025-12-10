//
//  ViewController.m
//  PinTu
//
//  Created by YLRS on 6/18/15.
//  Copyright (c) 2015 YLRS. All rights reserved.
//

#import "ViewController.h"
#import "CollectionViewCell.h"
#import "JXBAdPageView.h"
#import "PuzzleViewController.h"
#import "DifficultySelectionView.h"
#import "PinTu/PinTuView.h"
#import "HuaRongDaoViewController.h"
#import <CoreGraphics/CoreGraphics.h>

static NSString * const kUserAddedImageFilenamesKey = @"UserAddedImageFilenames";
static NSString * const kUserImagesDirectoryName = @"UserPuzzleImages";
@interface ViewController ()
@property (nonatomic, strong) NSArray<NSString *> *defaultAdImageNames;
@property (nonatomic, strong) NSArray<UIImage *> *predecodedAdImages;
@property (nonatomic, assign) BOOL adImagesConfigured;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *defaultImages = @[@"Main_0.jpeg",@"Main_1.jpeg",@"Main_2.jpeg",@"Main_3.jpeg",@"Main_4.jpeg",@"Main_5.jpeg",@"Main_6.jpeg",@"Main_7.jpeg",@"Main_8.jpeg"];
    mb_puzzleItems = [NSMutableArray arrayWithArray:defaultImages];
    [self loadPersistedUserImages];
    self.defaultAdImageNames = @[@"1.jpg",@"2.jpg",@"3.jpg",@"4.jpg",@"5.jpg",@"6.jpg",@"7.jpg",@"8.jpg"];
    
    float width = (self.view.bounds.size.width -10 -10 -10 -10)/3.0f - 1;
    
    UICollectionViewFlowLayout * flowLayout=[[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(width, width);
    flowLayout.headerReferenceSize = CGSizeMake(0, 0);
    flowLayout.footerReferenceSize = CGSizeMake(0, 0);
    flowLayout.minimumLineSpacing = 10.0f;
    flowLayout.minimumInteritemSpacing = 10.0f;
    flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    mb_adView = [[JXBAdPageView alloc] initWithFrame:CGRectZero];
    mb_adView.iDisplayTime = 2;
    mb_adView.bWebImage = NO;
    [self.view addSubview:mb_adView];
    [self preloadAdImages];
    
    mb_collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [mb_collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"CollectionViewCell"];
    mb_collectionView.backgroundColor = [UIColor whiteColor];
    mb_collectionView.delegate = self;
    mb_collectionView.dataSource = self;
    [self.view addSubview:mb_collectionView];
    
    [self layoutHomeViews];

	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return mb_puzzleItems.count + 2;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell" forIndexPath:indexPath];
    cell.mb_imageView.image = nil;
    cell.mb_imageView.backgroundColor = [UIColor clearColor];
    cell.mb_imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.mb_label.hidden = YES;
    cell.mb_label.text = nil;
    cell.mb_label.numberOfLines = 1;
    cell.mb_label.font = [UIFont boldSystemFontOfSize:48.0f];
    cell.mb_label.textColor = [UIColor darkGrayColor];
    cell.mb_label.backgroundColor = [UIColor clearColor];
    
    if (indexPath.row == 0) {
        UIImage *coverImage = [UIImage imageNamed:@"caocao"];
        cell.mb_imageView.image = coverImage;
        cell.mb_imageView.contentMode = UIViewContentModeScaleAspectFill;
        cell.mb_imageView.backgroundColor = coverImage ? [UIColor blackColor] : [UIColor colorWithRed:0.27f green:0.20f blue:0.65f alpha:1.0f];
        cell.mb_label.hidden = NO;
        cell.mb_label.text = @"三国\n华容道";
        cell.mb_label.numberOfLines = 2;
        cell.mb_label.font = [UIFont boldSystemFontOfSize:22.0f];
        cell.mb_label.textColor = [UIColor whiteColor];
        cell.mb_label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.45f];
    } else if (indexPath.row <= mb_puzzleItems.count) {
        NSInteger puzzleIndex = indexPath.row - 1;
        id item = mb_puzzleItems[puzzleIndex];
        UIImage *image = [self imageForPuzzleItem:item];
        cell.mb_imageView.image = image;
        cell.mb_imageView.contentMode = UIViewContentModeScaleAspectFill;
        cell.mb_imageView.backgroundColor = image ? [UIColor whiteColor] : [UIColor colorWithWhite:0.95f alpha:1.0f];
        cell.mb_label.hidden = YES;
        cell.mb_label.text = nil;
        cell.mb_label.backgroundColor = [UIColor clearColor];
    } else {
        cell.mb_imageView.image = nil;
        cell.mb_imageView.backgroundColor = [UIColor colorWithWhite:0.92f alpha:1.0f];
        cell.mb_imageView.contentMode = UIViewContentModeCenter;
        cell.mb_label.hidden = NO;
        cell.mb_label.text = @"+";
        cell.mb_label.font = [UIFont boldSystemFontOfSize:52.0f];
        cell.mb_label.textColor = [UIColor colorWithWhite:0 alpha:0.35f];
        cell.mb_label.backgroundColor = [UIColor clearColor];
    }
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self presentHuaRongDao];
        return;
    }
    if (indexPath.row == mb_puzzleItems.count + 1) {
        [self addPhotoTapped];
        return;
    }
    NSInteger puzzleIndex = indexPath.row - 1;
    [self showPuzzleForIndex:puzzleIndex];
}
-(BOOL)shouldAutorotate
{
    return NO;
}
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self layoutHomeViews];
    [self configureAdViewIfNeeded];
}
-(void)showPuzzleForIndex:(NSInteger)index
{
    UIImage *sourceImage = [self puzzleImageForIndex:index];
    if (!sourceImage) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    UIImage *selectedImage = sourceImage;
    [DifficultySelectionView presentInView:self.view
                         defaultDifficulty:PinTuShuffleDifficultyHard
                                 selection:^(PinTuShuffleDifficulty difficulty) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        [strongSelf presentPuzzleWithImage:selectedImage difficulty:difficulty];
    } cancel:nil];
}
-(UIImage *)puzzleImageForIndex:(NSInteger)index
{
    if (index < 0 || index >= mb_puzzleItems.count) {
        return nil;
    }
    id item = mb_puzzleItems[index];
    return [self imageForPuzzleItem:item];
}

- (void)presentPuzzleWithImage:(UIImage *)image difficulty:(PinTuShuffleDifficulty)difficulty
{
    if (!image) {
        return;
    }
    PuzzleViewController *controller = [[PuzzleViewController alloc] initWithImage:image difficulty:difficulty];
    controller.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:controller animated:YES completion:nil];
}
-(void)layoutHomeViews
{
    CGFloat adHeight = 200.0f;
    CGFloat safeTop = 0.0f;
    CGFloat safeBottom = 0.0f;
    if (@available(iOS 11.0, *)) {
        safeBottom = self.view.safeAreaInsets.bottom;
    }
    
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat cellWidth = (viewWidth -10 -10 -10 -10)/3.0f - 1;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)mb_collectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(cellWidth, cellWidth);
    
    CGFloat gridHeight = cellWidth * 3 + 40;
    
    CGRect adFrame = CGRectMake(0, safeTop, viewWidth, adHeight);
    mb_adView.frame = adFrame;
    
    CGFloat collectionY = CGRectGetMaxY(adFrame);
    CGFloat availableHeight = self.view.bounds.size.height - collectionY - safeBottom;
    CGFloat collectionHeight = availableHeight > 0 ? availableHeight : gridHeight;
    if (collectionHeight < gridHeight) {
        collectionHeight = gridHeight;
    }
    
    mb_collectionView.frame = CGRectMake(0, collectionY, viewWidth, collectionHeight);
}

#pragma mark - 广告图片加载

- (void)preloadAdImages
{
    NSArray<NSString *> *names = self.defaultAdImageNames;
    if (names.count == 0) {
        self.predecodedAdImages = @[];
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        NSMutableArray<UIImage *> *decodedImages = [NSMutableArray arrayWithCapacity:names.count];
        @autoreleasepool {
            for (NSString *name in names) {
                NSString *baseName = [name stringByDeletingPathExtension];
                NSString *extension = [name pathExtension];
                NSString *path = [[NSBundle mainBundle] pathForResource:baseName ofType:extension inDirectory:@"MainImage"];
                if (!path) {
                    continue;
                }
                UIImage *image = [UIImage imageWithContentsOfFile:path];
                if (!image) {
                    continue;
                }
                UIImage *decoded = [ViewController decodedImageFromImage:image];
                if (decoded) {
                    [decodedImages addObject:decoded];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return;
            }
            strongSelf.predecodedAdImages = [decodedImages copy];
            strongSelf.adImagesConfigured = NO;
            [strongSelf configureAdViewIfNeeded];
        });
    });
}

- (void)configureAdViewIfNeeded
{
    if (self.adImagesConfigured) {
        return;
    }
    if (CGRectGetWidth(mb_adView.bounds) < 1.0f || CGRectGetHeight(mb_adView.bounds) < 1.0f) {
        return;
    }
    if (self.predecodedAdImages == nil) {
        return;
    }
    NSArray<UIImage *> *images = self.predecodedAdImages;
    if (images.count > 0) {
        [mb_adView startAdsWithImages:images block:[self adTapCallback]];
    } else if (self.defaultAdImageNames.count > 0) {
        [mb_adView startAdsWithBlock:self.defaultAdImageNames block:[self adTapCallback]];
    }
    self.adImagesConfigured = YES;
}

- (JXBAdPageCallback)adTapCallback
{
    __weak typeof(self) weakSelf = self;
    return ^(NSInteger clickIndex) {
        [weakSelf showPuzzleForIndex:clickIndex];
    };
}

+ (UIImage *)decodedImageFromImage:(UIImage *)image
{
    if (!image) {
        return nil;
    }
    CGImageRef imageRef = image.CGImage;
    if (!imageRef) {
        return image;
    }
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst;
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 width,
                                                 height,
                                                 8,
                                                 0,
                                                 colorSpace,
                                                 bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    if (!context) {
        return image;
    }
    CGRect rect = CGRectMake(0, 0, (CGFloat)width, (CGFloat)height);
    CGContextDrawImage(context, rect, imageRef);
    CGImageRef decompressedImageRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    if (!decompressedImageRef) {
        return image;
    }
    UIImage *decompressedImage = [UIImage imageWithCGImage:decompressedImageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(decompressedImageRef);
    return decompressedImage;
}

-(void)addPhotoTapped
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"无法访问相册" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:picker animated:YES completion:nil];
}
#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *selectedImage = info[UIImagePickerControllerOriginalImage];
    if (!selectedImage) {
        selectedImage = info[UIImagePickerControllerEditedImage];
    }
    if (selectedImage) {
        [self saveAndAppendUserImage:selectedImage];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - User Image Persistence
-(void)loadPersistedUserImages
{
    NSArray *storedNames = [[NSUserDefaults standardUserDefaults] objectForKey:kUserAddedImageFilenamesKey];
    if (storedNames.count == 0) {
        return;
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *directory = [self userImagesDirectory];
    BOOL listChanged = NO;
    for (NSString *fileName in storedNames) {
        if (![fileName isKindOfClass:[NSString class]]) {
            listChanged = YES;
            continue;
        }
        NSString *fullPath = [directory stringByAppendingPathComponent:fileName];
        if ([fm fileExistsAtPath:fullPath]) {
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            info[@"path"] = fileName;
            [mb_puzzleItems addObject:info];
        } else {
            listChanged = YES;
        }
    }
    if (listChanged) {
        [self persistUserImageList];
    }
}
-(void)saveAndAppendUserImage:(UIImage *)image
{
    if (!image) {
        return;
    }
    NSString *directory = [self userImagesDirectory];
    NSString *identifier = [[NSUUID UUID] UUIDString];
    NSString *fileName = [NSString stringWithFormat:@"puzzle_%@.jpg", identifier];
    NSString *fullPath = [directory stringByAppendingPathComponent:fileName];
    NSData *data = UIImageJPEGRepresentation(image, 0.9f);
    if (data.length == 0) {
        [self showSimpleAlertWithTitle:@"提示" message:@"保存图片失败"];
        return;
    }
    NSError *error = nil;
    if (![data writeToFile:fullPath options:NSDataWritingAtomic error:&error]) {
        NSLog(@"Failed to save image: %@", error);
        [self showSimpleAlertWithTitle:@"提示" message:@"保存图片失败"];
        return;
    }
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[@"path"] = fileName;
    info[@"cachedImage"] = image;
    [mb_puzzleItems addObject:info];
    [self persistUserImageList];
    [mb_collectionView reloadData];
    NSInteger lastIndex = mb_puzzleItems.count - 1;
    if (lastIndex >= 0) {
        NSIndexPath *lastPath = [NSIndexPath indexPathForRow:lastIndex + 1 inSection:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            [mb_collectionView scrollToItemAtIndexPath:lastPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
        });
    }
}
-(void)persistUserImageList
{
    NSMutableArray *fileNames = [NSMutableArray array];
    for (id item in mb_puzzleItems) {
        if ([item isKindOfClass:[NSDictionary class]]) {
            NSString *path = item[@"path"];
            if (path.length > 0) {
                [fileNames addObject:path];
            }
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:fileNames forKey:kUserAddedImageFilenamesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(NSString *)userImagesDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = paths.firstObject;
    NSString *directory = [documents stringByAppendingPathComponent:kUserImagesDirectoryName];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:directory]) {
        NSError *error = nil;
        [fm createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"Failed to create image directory: %@", error);
        }
    }
    return directory;
}
-(UIImage *)imageForPuzzleItem:(id)item
{
    if ([item isKindOfClass:[NSString class]]) {
        return [UIImage imageNamed:item];
    }
    if ([item isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *info = (NSMutableDictionary *)item;
        UIImage *cached = info[@"cachedImage"];
        if (cached) {
            return cached;
        }
        NSString *fileName = info[@"path"];
        if (fileName.length == 0) {
            return nil;
        }
        NSString *fullPath = [[self userImagesDirectory] stringByAppendingPathComponent:fileName];
        UIImage *image = [UIImage imageWithContentsOfFile:fullPath];
        if (image) {
            info[@"cachedImage"] = image;
        }
        return image;
    }
    return nil;
}
-(void)presentHuaRongDao
{
    HuaRongDaoViewController *controller = [[HuaRongDaoViewController alloc] init];
    controller.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:controller animated:YES completion:nil];
}
-(void)showSimpleAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
