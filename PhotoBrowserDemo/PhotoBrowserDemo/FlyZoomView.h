//
//  FlyPhotoEnlargeToolView.h
//
//
//  Created by walg on 2017/2/28.
//  Copyright © 2017年 walg. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlyZoomView;
@protocol FlyZoomDelegate <NSObject>

@optional
- (BOOL)zoomView:(FlyZoomView *)zoomView shouldRespondsSingleTap:(UITapGestureRecognizer *)gesture;
- (BOOL)zoomView:(FlyZoomView *)zoomView shouldRespondsDoubleTap:(UITapGestureRecognizer *)gesture;
- (BOOL)zoomView:(FlyZoomView *)zoomView shouldRespondsLongPress:(UILongPressGestureRecognizer *)gesture;
- (void)zoomView:(FlyZoomView *)zoomView didEndZoomingAtScale:(CGFloat)scale;
- (void)zoomViewDidZoom:(FlyZoomView *)zoomView;
- (void)zoomViewDidScroll:(FlyZoomView *)zoomView;

@end

@interface FlyZoomView : UIView

@property (weak, nonatomic) id<FlyZoomDelegate> delegate;

@property (nonatomic, strong, readonly) UIScrollView *zoomScrollView;
@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, assign) CGFloat minScale;
@property (nonatomic, assign) CGFloat maxScale;

- (void)updateImage:(UIImage *)image;

@end
