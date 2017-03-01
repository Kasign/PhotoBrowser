//
//  FlyPhotoEnlargeToolView.m
//  
//
//  Created by walg on 2017/2/28.
//  Copyright © 2017年 walg. All rights reserved.
//

#import "FlyPhotoEnlargeToolView.h"
#define FLY_SCREEN_BOUNDS [[UIScreen mainScreen] bounds].size

@interface FlyPhotoEnlargeToolView()<UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollview;
@property (strong ,nonatomic) UIImageView *imageView;

@end

@implementation FlyPhotoEnlargeToolView{
    CGFloat currentScale;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _scrollview = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollview.backgroundColor = [UIColor clearColor];
        _scrollview.showsVerticalScrollIndicator = NO;
        _scrollview.showsHorizontalScrollIndicator = NO;
        _scrollview.delegate = self;
        [self addSubview:_scrollview];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [self addView];
}

-(void)addView{
    CGFloat width,height;
    width = _image.size.width;
    height = _image.size.height;
    width = width==0?1000:width;
    height = height==0?1000:height;
    CGRect rect;
    _imageView = [[UIImageView alloc] init];
    [_imageView setBackgroundColor:[UIColor clearColor]];
    rect.size.width = width;
    rect.size.height = height;
    if (width < FLY_SCREEN_BOUNDS.width) {
        rect.size.width = FLY_SCREEN_BOUNDS.width * 2;
        CGFloat p = width/height;
        rect.size.height = (FLY_SCREEN_BOUNDS.width/p)*2;
    }
    [_imageView setFrame:rect];
    [_scrollview setContentSize:[_imageView frame].size];
    [_scrollview setMinimumZoomScale:[_scrollview frame].size.width / [_imageView frame].size.width];
    [_scrollview setZoomScale:0.0];
    [_imageView setImage:_image];
    [_scrollview addSubview:_imageView];
    
    UITapGestureRecognizer *tapImgView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImgViewHandle)];
    tapImgView.numberOfTapsRequired = 1;
    tapImgView.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tapImgView];
    
    UITapGestureRecognizer *tapImgViewTwice = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImgViewHandleTwice:)];
    tapImgViewTwice.numberOfTapsRequired = 2;
    tapImgViewTwice.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tapImgViewTwice];
    [tapImgView requireGestureRecognizerToFail:tapImgViewTwice];
}

-(void)changeView{
    [_imageView removeFromSuperview];
    [self addView];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    currentScale = scale;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

#pragma mark - tap
-(void)tapImgViewHandle{
    if (currentScale > 0.6) {
        currentScale = 0.0;
        [self.scrollview setZoomScale:0.0 animated:YES];
    }else{
        if ([_delegate respondsToSelector:@selector(comeBackOnclick)]) {
                [_delegate comeBackOnclick];
        }
    }
}

-(void)tapImgViewHandleTwice:(UIGestureRecognizer *)sender{
    
    CGPoint touchPoint = [sender locationInView:self.scrollview];
    if(currentScale > 0.6){
        currentScale = 0.0;
        [self.scrollview setZoomScale:0.0 animated:YES];
    }else{
        currentScale = 2.0;
        [self.scrollview zoomToRect:CGRectMake(touchPoint.x*4, touchPoint.y*4, 1, 1) animated:YES];
    }
    
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?(scrollView.bounds.size.width - scrollView.contentSize.width)/2 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?(scrollView.bounds.size.height - scrollView.contentSize.height)/2 : 0.0;
    _imageView.center = CGPointMake(scrollView.contentSize.width/2 + offsetX,scrollView.contentSize.height/2 + offsetY);
}


@end
