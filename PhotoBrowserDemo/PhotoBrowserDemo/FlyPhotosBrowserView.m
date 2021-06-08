//
//  FlyPhotosBrowserView.m
//  
//
//  Created by walg on 2017/3/1.
//  Copyright © 2017年 walg. All rights reserved.
//

#import "FlyPhotosBrowserView.h"
#import "FlyZoomView.h"

#define FLY_SCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
#define FLY_SCREEN_HEIGHT  [UIScreen mainScreen].bounds.size.height
#define FLY_DURATION 0.25

@interface FlyPhotosBrowserView ()<UIScrollViewDelegate, FlyZoomDelegate> {
    UIImageView *_imageview;
    CGSize _bigSize;
    CGSize _smallSize;
    CGRect _zframe;
    CGRect _wframe;
}

@property (nonatomic, strong) NSArray *imageArray;
//类型
@property (nonatomic, assign) NSInteger countEveryLine;
//动画类型
@property (nonatomic, assign) NSInteger pop_type;
//页标
@property (nonatomic, assign) NSInteger index;

@property (nonatomic, assign) CGFloat distance;

@property (nonatomic, strong) UIScrollView *bottomScrollView;
@property (nonatomic, strong) UILabel *bottomLabel;

@end

@implementation FlyPhotosBrowserView
+(instancetype)sharedInstance{
    static FlyPhotosBrowserView *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FlyPhotosBrowserView alloc]init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self resetAllData];
    }
    return self;
}

- (void)resetAllData {
    _bottomScrollView = nil;
    _bottomLabel = nil;
    _imageview = nil;
    _zframe = CGRectZero;
    _wframe = CGRectZero;
    _bigSize = CGSizeZero;
    _smallSize = CGSizeZero;
    _index = 0;
    _pop_type = 0;
    _countEveryLine = 0;
    _imageArray = nil;
    self.backgroundColor = [UIColor blackColor];
    self.frame = [UIScreen mainScreen].bounds;
}

- (void)viewDidAppear {
    
    NSString* string = [NSString stringWithFormat:@"%ld/%ld",_index+1,_imageArray.count];
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc]initWithString:string];
    [attriString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 1)];
    _bottomLabel.attributedText = attriString;
    
    if (_pop_type == 1) {
        [self enlagerWithAnimationOne];
    } else {
        CGPoint point = CGPointMake(FLY_SCREEN_WIDTH/2.0, FLY_SCREEN_HEIGHT/2.0);
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            _imageview.center = point;
        } completion:^(BOOL finished) {
            _imageview.clipsToBounds = false;
            [self enlagerWithAnimationZero];
        }];
    }
}

- (void)initUIViews {
    
    _bottomLabel = [[UILabel alloc]init];
    _bottomLabel.bounds = CGRectMake(0, 0, FLY_SCREEN_WIDTH, 40);
    _bottomLabel.center = CGPointMake(FLY_SCREEN_WIDTH/2.0, FLY_SCREEN_HEIGHT-60);
    _bottomLabel.backgroundColor = [UIColor clearColor];
    _bottomLabel.font = [UIFont systemFontOfSize:12];
    _bottomLabel.textColor = [UIColor whiteColor];
    _bottomLabel.textAlignment = NSTextAlignmentCenter;
    
    _bottomScrollView = [[UIScrollView alloc] init];
    _bottomScrollView.frame = CGRectMake(0, 0, FLY_SCREEN_WIDTH, FLY_SCREEN_HEIGHT);
    _bottomScrollView.backgroundColor = [UIColor clearColor];
    _bottomScrollView.pagingEnabled = YES;
    _bottomScrollView.showsVerticalScrollIndicator = NO;
    _bottomScrollView.showsHorizontalScrollIndicator = NO;
    _bottomScrollView.delegate = self;
    
    for (int i = 0; i<_imageArray.count; i++) {
        FlyZoomView *imgView = [[FlyZoomView alloc]initWithFrame:CGRectMake(FLY_SCREEN_WIDTH*i, 0, FLY_SCREEN_WIDTH, FLY_SCREEN_HEIGHT)];
        imgView.delegate = self;
        imgView.backgroundColor = [UIColor clearColor];
        UIImage * image = _imageArray[i];
        [imgView updateImage:image];
        [_bottomScrollView addSubview:imgView];
    }
    
    _bottomScrollView.contentSize = CGSizeMake(_imageArray.count*(FLY_SCREEN_WIDTH), FLY_SCREEN_HEIGHT);
    
    [self addSubview:_bottomScrollView];
    [self addSubview:_bottomLabel];
}

#pragma mark - ScrollView Delegate
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    
    NSInteger page = scrollView.contentOffset.x/FLY_SCREEN_WIDTH;
    NSString* string = [NSString stringWithFormat:@"%ld/%ld",page+1,_imageArray.count];
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc]initWithString:string];
    [attriString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 1)];
    _bottomLabel.attributedText = attriString;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSInteger page = scrollView.contentOffset.x/FLY_SCREEN_WIDTH;
    NSString* string = [NSString stringWithFormat:@"%ld/%ld",page+1,_imageArray.count];
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc]initWithString:string];
    [attriString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 1)];
    _bottomLabel.attributedText = attriString;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    NSInteger page = scrollView.contentOffset.x/FLY_SCREEN_WIDTH;
    UIImage *image = _imageArray[page];
    [_imageview setImage: image];
    if (_countEveryLine == 0) {
        return;
    }
    
    if (_countEveryLine == 1) {
        NSInteger cha = page - _index;
        CGFloat y = _zframe.origin.y + (cha * (_zframe.size.height + _distance));
        _wframe = CGRectMake(_zframe.origin.x, y, _zframe.size.width, _zframe.size.height);
    } else {
        NSInteger a1 = _index % _countEveryLine;
        NSInteger a = page % _countEveryLine;
        NSInteger chax = a - a1;
        NSInteger b1 = _index /_countEveryLine;
        NSInteger b = page / _countEveryLine;
        NSInteger chay = b - b1;
        CGFloat x = _zframe.origin.x + (chax * (_zframe.size.width + _distance));
        CGFloat y = _zframe.origin.y + (chay * (_zframe.size.height + _distance));
        _wframe = CGRectMake(x, y, _zframe.size.width, _zframe.size.height);
    }
}

#pragma mark - ZoomView Delegate
- (BOOL)zoomView:(FlyZoomView *)zoomView shouldRespondsSingleTap:(UITapGestureRecognizer *)gesture {
    
    if (zoomView.zoomScrollView.zoomScale == zoomView.minScale) {
        [self comeBackOnclick];
        return NO;
    }
    return YES;
}

#pragma mark - Public
- (void)showPhotosWithOriginalFrame:(CGRect)originalFrame
                             image:(UIImage *)image
                    countEveryLine:(NSInteger)count
                          distance:(CGFloat)distance
                      currentIndex:(NSInteger)index
                        imageArray:(NSArray*)imageArray
                          pop_type:(NSInteger)pop_type
                  toViewController:(UIViewController*)controller {
    
    [self resetAllData];
    
    _index = index;
    _countEveryLine = count;
    _pop_type = pop_type;
    _distance = distance;
    _imageArray = imageArray;
    
    if (!_imageArray || _imageArray.count == 0) {
        _imageArray = [NSArray arrayWithObject:image];
    }
    
    UIView *view = controller.view;
    
    if (!controller) {
        view = [[UIApplication sharedApplication].delegate window];
    }
    [view addSubview:self];
    
    [self initUIViews];
    
    CGRect frame = [UIScreen mainScreen].bounds;
    _zframe = originalFrame;
    _imageview = [[UIImageView alloc] initWithFrame:originalFrame];
    _imageview.image = image;
    _imageview.clipsToBounds = YES;
    _imageview.backgroundColor = [UIColor clearColor];
    _imageview.contentMode = UIViewContentModeScaleAspectFill;
    
    [self addSubview:_imageview];
    
    [_bottomScrollView setHidden:YES];
    
    CGFloat w = image.size.width;
    CGFloat h = image.size.height;
    w = w==0?1000:w;
    h = h==0?1000:h;
    CGFloat iwidth = w;
    CGFloat iheight = h;
    if (iwidth > iheight) {
        CGFloat h = originalFrame.size.height;
        CGFloat w = iwidth / iheight * h;
        _smallSize = CGSizeMake(w, h);
    } else {
        CGFloat w = originalFrame.size.width;
        CGFloat h = iheight / iwidth * w;
        _smallSize = CGSizeMake(w, h);
    }
    if ((frame.size.height / frame.size.width) < (iheight / iwidth)) {
        CGFloat h = frame.size.height;
        CGFloat w = iwidth / iheight * h;
        _bigSize = CGSizeMake(w, h);
    } else {
        CGFloat w = frame.size.width;
        CGFloat h = iheight / iwidth * w;
        _bigSize = CGSizeMake(w, h);
    }
    
    [self viewDidAppear];
}

#pragma mark - Animation
- (void)enlagerWithAnimationZero {
    
    _imageview.bounds = CGRectMake(0, 0, _bigSize.width, _bigSize.height);
    
    CGFloat d = _smallSize.height / _bigSize.height;
    
    if (_smallSize.width > _smallSize.height) {
        d = _smallSize.width / _bigSize.width;
    }
    _imageview.layer.transform = CATransform3DMakeScale(d, d, 1);
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:d initialSpringVelocity:d options:UIViewAnimationOptionCurveLinear animations:^{
        _imageview.layer.transform = CATransform3DIdentity;
    } completion:^(BOOL finished) {
        [_bottomScrollView setHidden:NO];
        [_bottomScrollView setContentOffset:CGPointMake(_index*FLY_SCREEN_WIDTH,0)];
        [_imageview setHidden:YES];
    }];
}

- (void)enlagerWithAnimationOne {
    
    _imageview.clipsToBounds = YES;
    
    [UIView animateWithDuration:FLY_DURATION animations:^{
        _imageview.layer.position = CGPointMake(FLY_SCREEN_WIDTH/2.0, FLY_SCREEN_HEIGHT/2.0);
    }];
    
    [UIView animateWithDuration:FLY_DURATION animations:^{
        _imageview.layer.bounds = CGRectMake(0, 0, _bigSize.width, _bigSize.height);
    } completion:^(BOOL finished) {
        [_bottomScrollView setHidden:NO];
        [_bottomScrollView setContentOffset:CGPointMake(_index*FLY_SCREEN_WIDTH,0)];
        [_imageview setHidden:YES];
    }];
}

//从放大回到原来位置
- (void)comeBackOnclick {
    
    if (_pop_type == 1) {
        [self recoverBackToOriginalPositionWithAnimationOne];
    }else{
        [self recoverBackToOriginalPositionWithAnimationZero];
    }
}

- (void)recoverBackToOriginalPositionWithAnimationZero {
    
    [_imageview setHidden:NO];
    [_bottomScrollView setHidden:YES];
    CGFloat d = _smallSize.height / _bigSize.height;
    
    if (_smallSize.width > _smallSize.height) {
        d = _smallSize.width / _bigSize.width;
    }
    
    [self.bottomLabel removeFromSuperview];
    
    [UIView animateWithDuration:FLY_DURATION delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _imageview.layer.transform = CATransform3DMakeScale(d,d,1.0);
        _imageview.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [self recoverBackToOriginalPosition];
    }];
}

- (void)recoverBackToOriginalPosition {
    
    [UIView animateWithDuration:FLY_DURATION delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (_wframe.size.width != 0) {
            _imageview.frame = _wframe;
        } else {
            _imageview.frame = _zframe;
        }
    } completion:^(BOOL finished) {
        [self dissMiss];
    }];
}

//从放大回到原来位置
- (void)recoverBackToOriginalPositionWithAnimationOne {
    
    [_bottomScrollView setHidden:YES];
    [_imageview setHidden:NO];
    _imageview.clipsToBounds = YES;
    
    [self.bottomLabel removeFromSuperview];
    
    CGPoint point = CGPointMake(_zframe.origin.x + _zframe.size.width/2, _zframe.origin.y + _zframe.size.height/2);
    if (_wframe.size.width != 0) {
        point = CGPointMake(_wframe.origin.x + _wframe.size.width/2, _wframe.origin.y + _wframe.size.height/2);
    }
    
    [UIView animateWithDuration:FLY_DURATION animations:^{
        self.backgroundColor = [UIColor clearColor];
        _imageview.layer.position = point;
    } completion:^(BOOL finished) {
        [self dissMiss];
    }];
    
    [UIView animateWithDuration:FLY_DURATION animations:^{
        if (_wframe.size.width != 0) {
            _imageview.layer.bounds =_wframe;
        } else {
            _imageview.layer.bounds =_zframe;
        }
    }];
}

- (void)dissMiss {
    
    for (UIView *view in _bottomScrollView.subviews) {
        [view removeFromSuperview];
    }
    [_imageview removeFromSuperview];
    [self.bottomScrollView removeFromSuperview];
    [self.bottomLabel removeFromSuperview];
    [self removeFromSuperview];
    [self resetAllData];
}

@end
