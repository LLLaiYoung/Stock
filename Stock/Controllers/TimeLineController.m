//
//  TimeLineController.m
//  Stock
//
//  Created by chairman on 15/12/24.
//  Copyright © 2015年 LaiYong. All rights reserved.
//
/**
 *  ****功能****
 *  显示分时线
 *  10s自动刷新数据
 *  下拉菜单
 */
#import "TimeLineController.h"
#import "Stock.h"
#import "DownLoadManager.h"
#import "K_LineGraphController.h"
#import "DropdownMenuController.h"
#import <MBProgressHUD/MBProgressHUD.h>
@interface TimeLineController ()
<
UIPopoverPresentationControllerDelegate,
DropdownMenuControllerDelegate
>
@property (weak, nonatomic) IBOutlet UIImageView *KLineImageView;
@property (nonatomic, strong) DropdownMenuController *popoVerMenu;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) MBProgressHUD *mbProgressHUD;
@end

@implementation TimeLineController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = [NSString stringWithFormat:@"%@ 分时线",self.stock.stockName];
    
    [self downloadImage];
    
    UIBarButtonItem *kLine = [[UIBarButtonItem alloc]initWithTitle:@"K线图" style:UIBarButtonItemStylePlain target:self action:@selector(gotoKlineVC)];
    self.navigationItem.rightBarButtonItem = kLine;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(downloadImage) userInfo:nil repeats:YES];
    self.mbProgressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}
#pragma mark - 生命周期
//视图将要显示时候
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //转屏
//    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
//        SEL selector = NSSelectorFromString(@"setOrientation:");
//        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
//        [invocation setSelector:selector];
//        [invocation setTarget:[UIDevice currentDevice]];
//        int val = UIInterfaceOrientationLandscapeRight;//横屏
//        [invocation setArgument:&val atIndex:2];
//        [invocation invoke];
//    }
    /**
     *  关于iOS 强制转横屏的博客
     *  http://www.cocoachina.com/bbs/read.php?tid=39663
     *  http://stackoverflow.com/questions/7968451/different-ways-of-getting-current-interface-orientation#
     *  http://stackoverflow.com/questions/634745/how-to-programmatically-determine-iphone-interface-orientation/3897243#3897243
     *  http://zhenby.com/blog/2013/08/20/talk-ios-orientation/
     */
    //KVC//setOrientation: 3.0~成为私有API //orientation 取向
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        //http://mobile.51cto.com/hot-431728.htm SEL
        //http://blog.csdn.net/huifeidexin_1/article/details/8608074  NSSelectorFromString
        //http://blog.jobbole.com/45963/  Objective-C的动态提示和技巧
        //NSSelectorFromString 动态加载实例方法
//        SEL selector = NSSelectorFromString(@"setOrientation:");//==SEL selector = @selector(setOrientation:);
        /**
         *  iOS中可以直接调用某个对象的消息方式有两种
         *  1.performSelector:withObject;
         *  2.NSInvocation
         */
        //https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSInvocation_Class/#//apple_ref/occ/instm/NSInvocation/setArgument:atIndex: NSInvocation官方文档
        /**
         *  NSInvocation;用来包装方法和对应的对象，它可以存储方法的名称，对应的对象，对应的参数
         *  NSInvocation对象只能使用其类方法来初始化，不可使用alloc/init方法。
         *  以上内容在官方文档中都有提到
         */
        //调用签名方法
        //创建签名对象的时候不是使用NSMethodSignature这个类创建，而是方法属于谁就用谁来创建
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:@selector(setOrientation:)]];
        [invocation setSelector:@selector(setOrientation:)];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationLandscapeRight;//横屏
        /**
         *  第一个参数：需要给指定方法传递的值
         *  第一个参数需要接收一个指针，也就是传递值的时候需要传递地址
         *  第二个参数：需要给指定方法的第几个参数传值
         *  注意：设置参数的索引时不能从0开始，因为0已经被self(target)占用，1已经被_cmd(selector)占用 在NSMethodSignature类中已经说明 https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSMethodSignature_Class/
         *  (_cmd在Objective-C的方法中表示当前方法的selector，正如同self表示当前方法调用的对象实例。)
         */
        [invocation setArgument:&val atIndex:2];
        /**
         *  调用NSInvocation对象的invoke方法
         *  只要调用invocation的invoke方法，就代表需要执行NSInvocation对象中制定对象的指定方法，并且传递指定的参数
         */
        [invocation invoke];
        
        /**
         *  关于NSInvocation的博客
         *  http://blog.csdn.net/onlyou930/article/details/7449102
         *  http://www.jianshu.com/p/da96980648b6
         *  http://my.oschina.net/u/2340880/blog/398552?fromerr=sAJ1ndvB
         */
    }

}
//视图将要消失的时候暂停
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSDate *date = [NSDate distantFuture];
    [self.timer setFireDate:date];
}
#pragma mark - download
static NSInteger count=1;
- (void)downloadImage {
    NSString *link = [NSString stringWithFormat:@"http://image.sinajs.cn/newchart/min/n/%@%@.gif",self.stock.stockHouse,self.stock.stockCode];
    [DownLoadManager downloadLink:link withData:^(NSData *data) {
        UIImage *imagaData = [UIImage imageWithData:data];
        self.KLineImageView.image = imagaData;
        [self.mbProgressHUD hide:YES];
    }];
    NSLog(@"\nTimelineVC第%li次访问\n",count);
    count++;
}
#pragma mark - UIBarButtonItemAction
- (void)gotoKlineVC {    
    self.popoVerMenu = [[DropdownMenuController alloc]init];
    self.popoVerMenu.delegate = self;
    self.popoVerMenu.modalPresentationStyle = UIModalPresentationPopover;
    self.popoVerMenu.popoverPresentationController.barButtonItem = self.navigationItem.rightBarButtonItem;//箭头方向指向
    self.popoVerMenu.titles = @[@"日K线",@"周K线",@"月K线"];
    self.popoVerMenu.stock = self.stock;
    self.popoVerMenu.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionUnknown;//箭头方向,如果是baritem不设置方向，会默认up，up的效果也是最理想的
    self.popoVerMenu.popoverPresentationController.delegate = self;
    [self presentViewController:self.popoVerMenu animated:YES completion:nil];
}
//popover样式
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller{
    return UIModalPresentationNone;
}
#pragma mark - DropdownMenuControllerDelegate
- (void)DropdownMenuController:(DropdownMenuController *)dropdownMenu withIndex:(NSUInteger)index {
    NSString * storyboardName = @"Main";
    NSString * viewControllerID = @"kLineVC";
    /**
     *  Name则是自己起的，在.storyboard前面的名字，如果不动，则默认是Main，而且不需要添加文件的扩展名，如果加了，就会报错；
     *  bundle：这个参数包含storyboard的文件以及和它相关的资源，如果为空，则会调用当前程序的main bundle
     */
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    K_LineGraphController *klineVC = (K_LineGraphController *)[storyboard instantiateViewControllerWithIdentifier:viewControllerID];
    klineVC.stock = self.stock;
    klineVC.index = index;
    [self.navigationController pushViewController:klineVC animated:YES];
}
- (BOOL)popoverPresentationControllerShouldDismissPopover:(UIPopoverPresentationController *)popoverPresentationController{
    return YES;   //点击蒙版popover不消失， 默认yes
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
