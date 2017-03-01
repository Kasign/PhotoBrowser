# PhotoBrowser
仿微信朋友圈浏览图片 一行代码全部搞定
将四个文件放入工程中，在需要的地方导入FlyPhotosBrowserView.h

/*
这里的pop_type为动画类型，1为与朋友圈形同的动画
这里的frmae为点击当前的图片相对于window的frame
18就是上面的x,相邻图片间的距离
image为当前点击的image
*/
[[FlyPhotosBrowserView sharedInstance] showPhotosWithOriginalFrame:imageView.frame  image:imageView.image countEveryLine:3 distance:18 currentIndex:imageView.tag imageArray:_array pop_type:1 toViewController:self];
