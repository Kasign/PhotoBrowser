//
//  FlyPhotosBrowserView.m
//  
//
//  Created by walg on 2017/3/1.
//  Copyright © 2017年 walg. All rights reserved.
//

#import "FlyPhotosBrowserView.h"
#import "FlyPhotoEnlargeToolView.h"

#define FLY_SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define FLY_SCREEN_HEIGHT  [UIScreen mainScreen].bounds.size.height

@interface FlyPhotosBrowserView ()<UIScrollViewDelegate,NewShowImageDelegate>{
    UIImageView *imageview;
    CGSize bigSize;
    CGSize smallSize;
    CGRect zframe;
    CGRect wframe;
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

-(void)resetAllData{
    _bottomScrollView = nil;
    _bottomLabel = nil;
    imageview = nil;
    zframe = CGRectZero;
    wframe = CGRectZero;
    bigSize = CGSizeZero;
    smallSize = CGSizeZero;
    _index = 0;
    _pop_type = 0;
    _countEveryLine = 0;
    _imageArray = nil;
    self.backgroundColor = [UIColor blackColor];
    self.frame = [UIScreen mainScreen].bounds;
}

-(void)viewDidAppear{
    
    NSString* string = [NSString stringWithFormat:@"%ld/%ld",_index+1,_imageArray.count];
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc]initWithString:string];
    [attriString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 1)];
    _bottomLabel.attributedText = attriString;
    
    if (_pop_type == 1)
    {
        [self enlagerWithAnimationOne];
    }else{
        CGPoint point = CGPointMake(FLY_SCREEN_WIDTH/2.0, FLY_SCREEN_HEIGHT/2.0);
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            imageview.center = point;
        } completion:^(BOOL finished) {
            imageview.clipsToBounds = false;
            [self enlagerWithAnimationZero];
        }];
    }
}

-(void)initUIViews{
    
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
    
    for (int i =0 ; i<_imageArray.count; i++) {
        FlyPhotoEnlargeToolView *imgView = [[FlyPhotoEnlargeToolView alloc]initWithFrame:CGRectMake(FLY_SCREEN_WIDTH*i, 0, FLY_SCREEN_WIDTH, FLY_SCREEN_HEIGHT)];
        imgView.delegate = self;
        imgView.backgroundColor = [UIColor clearColor];
        UIImage * image = _imageArray[i];
        imgView.image = image;
        [_bottomScrollView addSubview:imgView];
    }
    
    _bottomScrollView.contentSize = CGSizeMake(_imageArray.count*(FLY_SCREEN_WIDTH), FLY_SCREEN_HEIGHT);
    
    [self addSubview:_bottomScrollView];
    [self addSubview:_bottomLabel];
    
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    
    NSInteger page = scrollView.contentOffset.x/FLY_SCREEN_WIDTH;
    NSString* string = [NSString stringWithFormat:@"%ld/%ld",page+1,_imageArray.count];
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc]initWithString:string];
    [attriString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 1)];
    _bottomLabel.attributedText = attriString;
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    NSInteger page = scrollView.contentOffset.x/FLY_SCREEN_WIDTH;
    NSString* string = [NSString stringWithFormat:@"%ld/%ld",page+1,_imageArray.count];
    NSMutableAttributedString *attriString = [[NSMutableAttributedString alloc]initWithString:string];
    [attriString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 1)];
    _bottomLabel.attributedText = attriString;
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    NSInteger page = scrollView.contentOffset.x/FLY_SCREEN_WIDTH;
    UIImage *image = _imageArray[page];
    [imageview setImage: image];
    if (_countEveryLine == 0) {
        return;
    }
    
    if (_countEveryLine == 1) {
        NSInteger cha = page - _index;
        CGFloat y = zframe.origin.y + (cha * (zframe.size.height + _distance));
        wframe = CGRectMake(zframe.origin.x, y, zframe.size.width, zframe.size.height);
    }else{
        NSInteger a1 = _index % _countEveryLine;
        NSInteger a = page % _countEveryLine;
        NSInteger chax = a - a1;
        NSInteger b1 = _index /_countEveryLine;
        NSInteger b = page / _countEveryLine;
        NSInteger chay = b - b1;
        CGFloat x = zframe.origin.x + (chax * (zframe.size.width + _distance));
        CGFloat y = zframe.origin.y + (chay * (zframe.size.height + _distance));
        wframe = CGRectMake(x, y, zframe.size.width, zframe.size.height);
    }
    
}


-(void)showPhotosWithOriginalFrame:(CGRect)originalFrame image:(UIImage *)image countEveryLine:(NSInteger)count distance:(CGFloat)distance currentIndex:(NSInteger)index imageArray:(NSArray*)imageArray pop_type:(NSInteger)pop_type toViewController:(UIViewController*)controller{
    
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
    zframe = originalFrame;
    imageview = [[UIImageView alloc] initWithFrame:originalFrame];
    imageview.image = image;
    imageview.clipsToBounds = YES;
    imageview.backgroundColor = [UIColor clearColor];
    imageview.contentMode = UIViewContentModeScaleAspectFill;
    
    [self addSubview:imageview];
    
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
        smallSize = CGSizeMake(w, h);
    }else{
        CGFloat w = originalFrame.size.width;
        CGFloat h = iheight / iwidth * w;
        smallSize = CGSizeMake(w, h);
    }
    if ((frame.size.height / frame.size.width) < (iheight / iwidth)) {
        CGFloat h = frame.size.height;
        CGFloat w = iwidth / iheight * h;
        bigSize = CGSizeMake(w, h);
    }else{
        CGFloat w = frame.size.width;
        CGFloat h = iheight / iwidth * w;
        bigSize = CGSizeMake(w, h);
    }
    
    [self viewDidAppear];
}

-(void)enlagerWithAnimationZero{
    
    imageview.bounds = CGRectMake(0, 0, bigSize.width, bigSize.height);
    
    CGFloat d = smallSize.height / bigSize.height;
    
    if (smallSize.width > smallSize.height) {
        d = smallSize.width / bigSize.width;
    }
    imageview.layer.transform = CATransform3DMakeScale(d, d, 1);
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:d initialSpringVelocity:d options:UIViewAnimationOptionCurveLinear animations:^{
        imageview.layer.transform = CATransform3DIdentity;
    } completion:^(BOOL finished) {
        [_bottomScrollView setHidden:NO];
        [_bottomScrollView setContentOffset:CGPointMake(_index*FLY_SCREEN_WIDTH,0)];
        [imageview setHidden:YES];
    }];
}

-(void)enlagerWithAnimationOne{
    
    imageview.clipsToBounds = YES;
    
    [UIView animateWithDuration:0.2 animations:^{
        imageview.layer.position =CGPointMake(FLY_SCREEN_WIDTH/2.0, FLY_SCREEN_HEIGHT/2.0);
    }];
    
    [UIView animateWithDuration:0.2 animations:^{
        imageview.layer.bounds =CGRectMake(0, 0, bigSize.width, bigSize.height);
    } completion:^(BOOL finished) {
        [_bottomScrollView setHidden:NO];
        [_bottomScrollView setContentOffset:CGPointMake(_index*FLY_SCREEN_WIDTH,0)];
        [imageview setHidden:YES];
    }];
}

//从放大回到原来位置
-(void)comeBackOnclick{
    if (_pop_type == 1) {
        [self recoverBackToOriginalPositionWithAnimationOne];
    }else{
        [self recoverBackToOriginalPositionWithAnimationZero];
    }
}

-(void)recoverBackToOriginalPositionWithAnimationZero{
    
    [imageview setHidden:NO];
    [_bottomScrollView setHidden:YES];
    CGFloat d = smallSize.height / bigSize.height;
    
    if (smallSize.width > smallSize.height) {
        d = smallSize.width / bigSize.width;
    }
    
    [self.bottomLabel removeFromSuperview];
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        imageview.layer.transform = CATransform3DMakeScale(d,d,1.0);
        imageview.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [self recoverBackToOriginalPosition];
    }];
}

-(void)recoverBackToOriginalPosition{
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (wframe.size.width != 0) {
            imageview.frame = wframe;
        }else{
            imageview.frame = zframe;
        }
        
    } completion:^(BOOL finished) {
        [self dissMiss];
    }];
}

//从放大回到原来位置
-(void)recoverBackToOriginalPositionWithAnimationOne{
    
    [_bottomScrollView setHidden:YES];
    [imageview setHidden:NO];
    imageview.clipsToBounds = YES;
    
    [self.bottomLabel removeFromSuperview];
    
    CGPoint point = CGPointMake(zframe.origin.x + zframe.size.width/2, zframe.origin.y + zframe.size.height/2);
    if (wframe.size.width != 0) {
        point = CGPointMake(wframe.origin.x + wframe.size.width/2, wframe.origin.y + wframe.size.height/2);
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.backgroundColor = [UIColor clearColor];
        imageview.layer.position =point;
    } completion:^(BOOL finished) {
        [self dissMiss];
    }];
    
    [UIView animateWithDuration:0.2 animations:^{
        if (wframe.size.width != 0) {
            imageview.layer.bounds =wframe;
        }else{
            imageview.layer.bounds =zframe;
        }
    }];
}

-(void)dissMiss{
    for (UIView *view in _bottomScrollView.subviews) {
        [view removeFromSuperview];
    }
    [imageview removeFromSuperview];
    [self.bottomScrollView removeFromSuperview];
    [self.bottomLabel removeFromSuperview];
    [self removeFromSuperview];
    [self resetAllData];
}

@end
