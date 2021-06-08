//
//  FlyPhotoEnlargeToolView.m
//  
//
//  Created by walg on 2017/2/28.
//  Copyright © 2017年 walg. All rights reserved.
//

#import "FlyZoomView.h"

@interface FlyZoomView ()<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong, readwrite) UIScrollView *zoomScrollView;
@property (nonatomic, strong, readwrite) UIImageView *imageView;
@property (nonatomic, assign) CGFloat defaultScale;

@end

@implementation FlyZoomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _minScale = 1.0;
        _maxScale = 4.0;
        _defaultScale = 1.0;
        [self addSubview:self.zoomScrollView];
        [self.zoomScrollView addSubview:self.imageView];
    }
    return self;
}

- (void)setMaxScale:(CGFloat)maxScale {
    
    if (_maxScale != maxScale) {
        _maxScale = maxScale;
        self.zoomScrollView.maximumZoomScale = maxScale;
    }
}

- (void)setMinScale:(CGFloat)minScale {
    
    if (_minScale != minScale) {
        _minScale = minScale;
        _defaultScale = minScale;
        self.zoomScrollView.minimumZoomScale = minScale;
    }
}

- (UIScrollView *)zoomScrollView {
    
    if (!_zoomScrollView) {
        _zoomScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _zoomScrollView.backgroundColor = [UIColor clearColor];
        _zoomScrollView.showsVerticalScrollIndicator = NO;
        _zoomScrollView.showsHorizontalScrollIndicator = NO;
        _zoomScrollView.delegate = self;
        
        if (@available(iOS 11.0, *)) {
            _zoomScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            _zoomScrollView.scrollIndicatorInsets = _zoomScrollView.contentInset;
        }
        
        _zoomScrollView.bounces = NO;
        _zoomScrollView.minimumZoomScale = _minScale;
        _zoomScrollView.maximumZoomScale = _maxScale;
        _zoomScrollView.showsVerticalScrollIndicator = NO;
        _zoomScrollView.showsHorizontalScrollIndicator = NO;
        _zoomScrollView.zoomScale = _minScale;
        
        //单击
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        tapGR.numberOfTapsRequired = 1;
        tapGR.numberOfTouchesRequired = 1;
        tapGR.delegate = self;
        [_zoomScrollView addGestureRecognizer:tapGR];
        
        //双击
        UITapGestureRecognizer *doubleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTap:)];
        doubleTapGR.numberOfTapsRequired = 2;
        doubleTapGR.numberOfTouchesRequired = 1;
        [_zoomScrollView addGestureRecognizer:doubleTapGR];
        
        //长按
        UILongPressGestureRecognizer *pressLongGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onPressLong:)];
        [_zoomScrollView addGestureRecognizer:pressLongGesture];
        
        //单击依赖双击失败之后才响应
        [tapGR requireGestureRecognizerToFail:doubleTapGR];
    }
    return _zoomScrollView;
}

- (UIImageView *)imageView {
    
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.contentMode = UIViewContentModeScaleToFill;
    }
    return _imageView;
}

#pragma mark - Zoom Delegate

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    
    if ([self.delegate respondsToSelector:@selector(zoomView:didEndZoomingAtScale:)]) {
        [self.delegate zoomView:self didEndZoomingAtScale:scale];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?(scrollView.bounds.size.width - scrollView.contentSize.width)/2 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?(scrollView.bounds.size.height - scrollView.contentSize.height)/2 : 0.0;
    self.imageView.center = CGPointMake(scrollView.contentSize.width/2 + offsetX,scrollView.contentSize.height/2 + offsetY);
    
    if ([self.delegate respondsToSelector:@selector(zoomViewDidZoom:)]) {
        [self.delegate zoomViewDidZoom:self];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ([self.delegate respondsToSelector:@selector(zoomViewDidScroll:)]) {
        [self.delegate zoomViewDidScroll:self];
    }
}

#pragma mark - GestureRecognizer Delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (touch.view == self.imageView || touch.view == self.zoomScrollView) {
        return YES;
    }
    return NO;
}

- (void)onTap:(UITapGestureRecognizer *)gesture {
    
    BOOL shouldResponds = YES;
    if ([self.delegate respondsToSelector:@selector(zoomView:shouldRespondsSingleTap:)]) {
        shouldResponds = [self.delegate zoomView:self shouldRespondsSingleTap:gesture];
    }
    if (!shouldResponds) {
        return;
    }
    //单击恢复
    if (self.zoomScrollView.zoomScale != self.defaultScale) {
        [self.zoomScrollView setZoomScale:self.defaultScale animated:YES];
    }
}

- (void)onDoubleTap:(UITapGestureRecognizer *)gesture {
    
    CGPoint touchPoint = [gesture locationInView:self.imageView];
    if (touchPoint.x < 0 || touchPoint.y < 0) {
        return;
    }
    
    BOOL shouldResponds = YES;
    if ([self.delegate respondsToSelector:@selector(zoomView:shouldRespondsDoubleTap:)]) {
        shouldResponds = [self.delegate zoomView:self shouldRespondsDoubleTap:gesture];
    }
    if (!shouldResponds) {
        return;
    }
    
    if (self.zoomScrollView.zoomScale != self.defaultScale){
        [self.zoomScrollView setZoomScale:self.defaultScale animated:YES];
    } else {
        CGFloat currentScale = self.zoomScrollView.maximumZoomScale;
        CGSize zoomSize = self.zoomScrollView.bounds.size;
        zoomSize.width = zoomSize.width / currentScale;
        zoomSize.height = zoomSize.height / currentScale;
        CGFloat zoomX = touchPoint.x - zoomSize.width * 0.5 - self.imageView.frame.origin.x/currentScale;
        CGFloat zoomY = touchPoint.y - zoomSize.height * 0.5 - self.imageView.frame.origin.y/currentScale;
        CGRect zoomRect = CGRectMake(zoomX, zoomY, zoomSize.width, zoomSize.height);
        [self.zoomScrollView zoomToRect:zoomRect animated:YES];
    }
}

- (void)onPressLong:(UILongPressGestureRecognizer *)gesture {
    
    BOOL shouldResponds = YES;
    if ([self.delegate respondsToSelector:@selector(zoomView:shouldRespondsLongPress:)]) {
        shouldResponds = [self.delegate zoomView:self shouldRespondsLongPress:gesture];
    }
    if (!shouldResponds) {
        return;
    }
}

#pragma mark - Update Image
- (void)updateImage:(UIImage *)image {
    
    [self.imageView setImage:image];
    [self resetImageViewFrame];
    [self resetScrollView];
}

- (void)resetImageViewFrame {
    
    CGFloat contentW = self.zoomScrollView.bounds.size.width;
    CGFloat contentH = self.zoomScrollView.bounds.size.height;
    
    CGFloat imageW = self.imageView.image.size.width;
    CGFloat imageH = self.imageView.image.size.height;
    
    imageW = imageW == 0 ? contentW : imageW;
    imageH = imageH == 0 ? contentH : imageH;
    
    CGRect rect = CGRectZero;
    
    rect.size.width = contentW;
    rect.size.height = imageH * contentW/imageW;
    
    if (rect.size.width < contentW) {
        rect.origin.x = 0.5 * (contentW - rect.size.width);
    }
    if (rect.size.height < contentH) {
        rect.origin.y = 0.5 * (contentH - rect.size.height);
    }
    [self.imageView setFrame:rect];
}

- (void)resetScrollView {
    
    CGSize contentSize = self.imageView.bounds.size;
    [self.zoomScrollView setContentSize:contentSize];
    [self.zoomScrollView setContentOffset:CGPointZero];
}

@end
