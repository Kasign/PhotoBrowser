//
//  ViewController.m
//  PhotoBrowserDemo
//
//  Created by walg on 2017/3/1.
//  Copyright © 2017年 walg. All rights reserved.
//
#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT  [UIScreen mainScreen].bounds.size.height

#import "ViewController.h"
#import "FlyPhotosBrowserView.h"

@interface ViewController ()
@property (nonatomic, strong) NSArray *array;
@property (nonatomic, strong) NSMutableArray *mutableArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _array = [NSArray arrayWithObjects:[UIImage imageNamed:@"0.jpg"],[UIImage imageNamed:@"1.jpg"],[UIImage imageNamed:@"2.jpg"],[UIImage imageNamed:@"3.jpg"],[UIImage imageNamed:@"4.jpg"],[UIImage imageNamed:@"5.png"], nil];
    
    _mutableArray = [NSMutableArray array];
    
    NSInteger width = 100;
    NSInteger x = (SCREEN_WIDTH-width*3)/4.0;
    
    for (int i=0; i<_array.count; i++) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(i%3*(width+x)+x, i/3*(width+10)+194, width, width)];
        imageView.image = _array[i];
        imageView.tag = i;
        imageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(lookImage:)];
        
        [imageView addGestureRecognizer:tap];
        
        [self.view addSubview:imageView];
        [_mutableArray addObject:imageView];
    }
}

-(void)lookImage:(UITapGestureRecognizer*)tap{
    
    UIImageView *imageView = (UIImageView*)tap.view;
    /*
     这里的pop_type为动画类型，1为与朋友圈形同的动画
     这里的frmae为点击当前的图片相对于window的frame
     18就是上面的x,相邻图片间的距离
     image为当前点击的image
     */
    [[FlyPhotosBrowserView sharedInstance] showPhotosWithOriginalFrame:imageView.frame  image:imageView.image countEveryLine:3 distance:18 currentIndex:imageView.tag imageArray:_array pop_type:1 toViewController:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
