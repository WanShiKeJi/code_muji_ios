//
//  TXNavgationController.m
//  TXBoxNew
//
//  Created by Naron on 15/5/13.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "TXNavgationController.h"

@interface TXNavgationController ()
{
    CGPoint startTouch;//拖动时的开始坐标
    BOOL isMoving;//是否在拖动中
    UIView *blackMask;//那层黑面罩
    
    UIImageView *lastScreenShotView;//截图
    
}

@property (nonatomic,retain) UIView *backgroundView;//背景
@property (nonatomic,retain) NSMutableArray *screenShotsList;//存截图

@end

@implementation TXNavgationController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 至少2个 头一个肯定是顶级的界面
    self.screenShotsList = [[NSMutableArray alloc]initWithCapacity:2];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //拖动手势
    UIPanGestureRecognizer *panGesture=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGesture:)];
    //添加手势
    [self.view addGestureRecognizer:panGesture];
    
    //是否开始拖动
    isMoving = NO;

}

//拖动手势
-(void)handlePanGesture:(UIGestureRecognizer*)sender{
    
    //如果是顶级viewcontroller，结束
    if (self.viewControllers.count <= 1) return;
    
    //得到触摸中在window上拖动的过程中的xy坐标
    CGPoint translation=[sender locationInView:WINDOW];
    //状态结束，保存数据
    if(sender.state == UIGestureRecognizerStateEnded){
        VCLog(@"结束%f,%f",translation.x,translation.y);
        isMoving = NO;
        
        self.backgroundView.hidden = NO;
        //如果结束坐标大于开始坐标50像素就动画效果移动
        if (translation.x - startTouch.x > 50) {
            [UIView animateWithDuration:0.3 animations:^{
                //动画效果，移动
                [self moveViewWithX:320];
            } completion:^(BOOL finished) {
                //返回上一层
                [self popViewControllerAnimated:NO];
                //并且还原坐标
                CGRect frame = self.view.frame;
                frame.origin.x = 0;
                self.view.frame = frame;
            }];
            
        }else{
            //不大于50时就移动原位
            [UIView animateWithDuration:0.3 animations:^{
                //动画效果
                [self moveViewWithX:0];
            } completion:^(BOOL finished) {
                //背景隐藏
                self.backgroundView.hidden = YES;
            }];
        }
        return;
        
    }else if(sender.state == UIGestureRecognizerStateBegan){
        NSLog(@"开始%f,%f",translation.x,translation.y);
        //开始坐标
        startTouch = translation;
        //是否开始移动
        isMoving = YES;
        if (!self.backgroundView)
        {
            //添加背景
            CGRect frame = self.view.frame;
            self.backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
            //把backgroundView插入到Window视图上，并below低于self.view层
            [WINDOW insertSubview:self.backgroundView belowSubview:self.view];
            
            //在backgroundView添加黑色的面罩
            blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
            blackMask.backgroundColor = [UIColor blackColor];
            [self.backgroundView addSubview:blackMask];
        }
        self.backgroundView.hidden = NO;
        
        if (lastScreenShotView) [lastScreenShotView removeFromSuperview];
        
        //数组中最后截图
        UIImage *lastScreenShot = [self.screenShotsList lastObject];
        //并把截图插入到backgroundView上，并黑色的背景下面
        lastScreenShotView = [[UIImageView alloc]initWithImage:lastScreenShot];
        [self.backgroundView insertSubview:lastScreenShotView belowSubview:blackMask];
        
    }
    
    if (isMoving) {
        [self moveViewWithX:translation.x - startTouch.x];
        
    }
}

- (void)moveViewWithX:(float)x
{
    
    VCLog(@"Move to:%f",x);
    x = x>320?320:x;
    x = x<0?0:x;
    
    CGRect frame = self.view.frame;
    frame.origin.x = x;
    self.view.frame = frame;
    
    //float scale = (x/6400)+0.95;//缩放大小
    float alpha = 0.4 - (x/800);//透明值
    
    //缩放scale
    //lastScreenShotView.transform = CGAffineTransformMakeScale(scale, scale);
    //背景颜色透明值
    blackMask.alpha = alpha;
    
}

//把UIView转化成UIImage，实现截屏
- (UIImage *)ViewRenderImage
{
    //创建基于位图的图形上下文 Creates a bitmap-based graphics context with the specified options.:UIGraphicsBeginImageContextWithOptions(CGSize size, BOOL opaque, CGFloat scale),size大小，opaque是否透明，不透明（YES），scale比例缩放
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    
    //当前层渲染到上下文
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    //上下文形成图片
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    //结束并删除当前基于位图的图形上下文。
    UIGraphicsEndImageContext();
    //反回图片
    return img;
}

#pragma mark -- Navagation 覆盖方法
-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //图像数组中存放一个当前的界面图像，然后再push
    [self.screenShotsList addObject:[self ViewRenderImage]];
    
    [super pushViewController:viewController animated:animated];
}

-(UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    //移除最后一个
    [self.screenShotsList removeLastObject];
    return [super popViewControllerAnimated:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
