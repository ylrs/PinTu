//
//  CollectionViewCell.m
//  PinTu
//
//  Created by YLRS on 6/18/15.
//  Copyright (c) 2015 YLRS. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.mb_imageView = [[UIImageView alloc] init];
        self.mb_imageView.frame = self.bounds;
        self.mb_imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.mb_imageView.clipsToBounds = YES;
        self.mb_imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.mb_imageView];
        
        self.mb_label = [[UILabel alloc] initWithFrame:self.bounds];
        self.mb_label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.mb_label.textAlignment = NSTextAlignmentCenter;
        self.mb_label.font = [UIFont boldSystemFontOfSize:48.0f];
        self.mb_label.textColor = [UIColor darkGrayColor];
        self.mb_label.hidden = YES;
        [self.contentView addSubview:self.mb_label];
        
        self.contentView.clipsToBounds = YES;
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.mb_imageView.image = nil;
    self.mb_imageView.backgroundColor = [UIColor clearColor];
    self.mb_label.hidden = YES;
    self.mb_label.text = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
