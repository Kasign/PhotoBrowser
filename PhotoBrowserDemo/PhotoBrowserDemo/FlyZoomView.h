//
//  FlyPhotoEnlargeToolView.h
//
//
//  Created by walg on 2017/2/28.
//  Copyright © 2017年 walg. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, FlyZoomGestureType) {
    FlyZoomGestureType_SINGLE = 1 << 0,
    FlyZoomGestureType_DOUBLE = 1 << 1,
    FlyZoomGestureType_LONG   = 1 << 2,
    FlyZoomGestureType_ALL    = 0xF,
};

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

@property (nonatomic, strong, readonly) UIScrollView *zoomScrollView;
@property (nonatomic, strong, readonly) UIView *contentView;
@property (weak, nonatomic) id<FlyZoomDelegate> delegate;
@property (nonatomic, assign) CGFloat minScale; //Default 1.0
@property (nonatomic, assign) CGFloat maxScale; //Default 4.0
@property (nonatomic, assign) FlyZoomGestureType gestureType; // Default FlyZoomGestureType_ALL

/// 重置contentView的size到合适的位置，如果需要
- (void)resetContentViewFrame:(UIView *)contentView;

/// 添加需要缩放的view
- (void)updateContentView:(UIView *)contentView;

@end
