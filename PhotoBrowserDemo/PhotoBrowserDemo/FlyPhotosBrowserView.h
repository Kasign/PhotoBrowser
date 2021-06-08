//
//  FlyPhotosBrowserView.h
//  
//
//  Created by walg on 2017/3/1.
//  Copyright © 2017年 walg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlyPhotosBrowserView : UIView
+(instancetype)sharedInstance;

/**
 @param originalFrame 点击的图片的frame
 @param image 点击的图片的image
 @param count 每行图片数
 @param distance 相邻图片横向距离
 @param index 点击图片的位置（从0开始）
 @param imageArray 图片数组
 @param pop_type 动画类型（0，1），1为与微信同样动画模式
 @param controller 当前的viewController,不传默认为window
 */
- (void)showPhotosWithOriginalFrame:(CGRect)originalFrame
                             image:(UIImage *)image
                    countEveryLine:(NSInteger)count
                          distance:(CGFloat)distance
                      currentIndex:(NSInteger)index
                        imageArray:(NSArray*)imageArray
                          pop_type:(NSInteger)pop_type
                  toViewController:(UIViewController*)controller;
@end
