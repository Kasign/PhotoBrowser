//
//  FlyPhotoEnlargeToolView.h
//
//
//  Created by walg on 2017/2/28.
//  Copyright © 2017年 walg. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NewShowImageDelegate <NSObject>

-(void)comeBackOnclick;

@end

@interface FlyPhotoEnlargeToolView : UIView

@property (strong, nonatomic) UIImage  *image;
@property (weak, nonatomic) id<NewShowImageDelegate> delegate;

-(void)changeView;

@end
