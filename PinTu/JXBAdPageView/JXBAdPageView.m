//
//  JXBAdPageView.m
//  XBAdPageView
//
//  Created by Peter Jin mail:i@Jxb.name on 15/5/13.
//  Github ---- https://github.com/JxbSir
//  Copyright (c) 2015年 Peter. All rights reserved.
//

#import "JXBAdPageView.h"

@interface JXBAdPageView()<UIScrollViewDelegate>
@property (nonatomic,assign)int                 indexShow;
@property (nonatomic,copy)NSArray               *arrImage;
@property (nonatomic,strong)NSArray<UIImage *>  *arrPreparedImages;
@property (nonatomic,assign)BOOL                 usePreparedImages;
@property (nonatomic,strong)UIScrollView        *scView;
@property (nonatomic,strong)UIImageView         *imgPrev;
@property (nonatomic,strong)UIImageView         *imgCurrent;
@property (nonatomic,strong)UIImageView         *imgNext;
@property (nonatomic,strong)NSTimer             *myTimer;
@property (nonatomic,copy)JXBAdPageCallback     myBlock;
@end

@implementation JXBAdPageView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsLayout];
}

- (void)initUI {
    if (_scView) {
        return;
    }
    _scView = [[UIScrollView alloc] initWithFrame:self.frame];
    _scView.delegate = self;
    _scView.pagingEnabled = YES;
    _scView.bounces = NO;
    _scView.contentSize = CGSizeMake(self.frame.size.width * 3, self.frame.size.height);
    _scView.showsHorizontalScrollIndicator = NO;
    _scView.showsVerticalScrollIndicator = NO;
    [_scView setTranslatesAutoresizingMaskIntoConstraints:YES];
    [self addSubview:_scView];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAds)];
    [_scView addGestureRecognizer:tap];
    
    
    _imgPrev = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _imgCurrent = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
    _imgNext = [[UIImageView alloc] initWithFrame:CGRectMake(2*self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
    
    [_scView addSubview:_imgPrev];
    [_scView addSubview:_imgCurrent];
    [_scView addSubview:_imgNext];
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectZero];
    _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    _pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    [self addSubview:_pageControl];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize boundsSize = self.bounds.size;
    _scView.frame = self.bounds;
    _scView.contentSize = CGSizeMake(boundsSize.width * 3, boundsSize.height);
    _imgPrev.frame = CGRectMake(0, 0, boundsSize.width, boundsSize.height);
    _imgCurrent.frame = CGRectMake(boundsSize.width, 0, boundsSize.width, boundsSize.height);
    _imgNext.frame = CGRectMake(boundsSize.width * 2.0f, 0, boundsSize.width, boundsSize.height);
    CGFloat pageControlHeight = 20.0f;
    _pageControl.frame = CGRectMake(0,
                                    MAX(0.0f, boundsSize.height - pageControlHeight - 8.0f),
                                    boundsSize.width,
                                    pageControlHeight);
    [_scView scrollRectToVisible:CGRectMake(boundsSize.width, 0, boundsSize.width, boundsSize.height) animated:NO];
}

/**
 *  启动函数
 *
 *  @param imageArray 图片数组
 *  @param block      click回调
 */
- (void)startAdsWithBlock:(NSArray*)imageArray block:(JXBAdPageCallback)block {
    _usePreparedImages = NO;
    _arrPreparedImages = nil;
    if(imageArray.count <= 1)
        _scView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    _pageControl.numberOfPages = imageArray.count;
    _arrImage = imageArray;
    _myBlock = [block copy];
    _indexShow = 0;
    [self reloadImages];
}

/**
 *  点击广告
 */
- (void)tapAds
{
    if (_myBlock != NULL) {
        _myBlock(_indexShow);
    }
}

- (void)startAdsWithImages:(NSArray<UIImage *> *)images block:(JXBAdPageCallback)block
{
    if (images.count <= 1) {
        _scView.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    }
    _usePreparedImages = YES;
    _arrPreparedImages = [images copy];
    _arrImage = nil;
    _pageControl.numberOfPages = images.count;
    _myBlock = [block copy];
    _indexShow = 0;
    [self reloadImages];
}

/**
 *  加载图片顺序
 */
- (void)reloadImages {
    NSInteger totalCount = _usePreparedImages ? _arrPreparedImages.count : _arrImage.count;
    if (totalCount == 0) {
        _imgPrev.image = nil;
        _imgCurrent.image = nil;
        _imgNext.image = nil;
        return;
    }
    if (_indexShow >= (int)totalCount)
        _indexShow = 0;
    if (_indexShow < 0)
        _indexShow = (int)totalCount - 1;
    int prev = _indexShow - 1;
    if (prev < 0)
        prev = (int)totalCount - 1;
    int next = _indexShow + 1;
    if (next > totalCount - 1)
        next = 0;
    _pageControl.currentPage = _indexShow;
    if (_usePreparedImages) {
        _imgPrev.image = _arrPreparedImages[prev];
        _imgCurrent.image = _arrPreparedImages[_indexShow];
        _imgNext.image = _arrPreparedImages[next];
    }
    else if(_bWebImage)
    {
        NSString* prevImage = [_arrImage objectAtIndex:prev];
        NSString* curImage = [_arrImage objectAtIndex:_indexShow];
        NSString* nextImage = [_arrImage objectAtIndex:next];
        if(_delegate && [_delegate respondsToSelector:@selector(setWebImage:imgUrl:)])
        {
            [_delegate setWebImage:_imgPrev imgUrl:prevImage];
            [_delegate setWebImage:_imgCurrent imgUrl:curImage];
            [_delegate setWebImage:_imgNext imgUrl:nextImage];
        }
        else
        {
            _imgPrev.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:prevImage]]];
            _imgCurrent.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:curImage]]];
            _imgNext.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:nextImage]]];
        }
    }
    else
    {
        NSString* prevImage = [_arrImage objectAtIndex:prev];
        NSString* curImage = [_arrImage objectAtIndex:_indexShow];
        NSString* nextImage = [_arrImage objectAtIndex:next];
        _imgPrev.image = [UIImage imageNamed:prevImage];
        _imgCurrent.image = [UIImage imageNamed:curImage];
        _imgNext.image = [UIImage imageNamed:nextImage];
    }
    [_scView scrollRectToVisible:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height) animated:NO];
    
    if (_iDisplayTime > 0)
        [self startTimerPlay];
}

/**
 *  切换图片完毕事件
 *
 *  @param scrollView
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_myTimer)
        [_myTimer invalidate];
    if (scrollView.contentOffset.x >=self.frame.size.width*2)
        _indexShow++;
    else if (scrollView.contentOffset.x < self.frame.size.width)
        _indexShow--;
    [self reloadImages];
}

- (void)startTimerPlay {
    _myTimer = [NSTimer scheduledTimerWithTimeInterval:_iDisplayTime target:self selector:@selector(doImageGoDisplay) userInfo:nil repeats:NO];
}

/**
 *  轮播图片
 */
- (void)doImageGoDisplay {
    [_scView scrollRectToVisible:CGRectMake(self.frame.size.width * 2, 0, self.frame.size.width, self.frame.size.height) animated:YES];
    _indexShow++;
    [self performSelector:@selector(reloadImages) withObject:nil afterDelay:0.3];
}

@end
