//
//  K_LineGraphController.m
//  Stock
//
//  Created by chairman on 15/12/24.
//  Copyright © 2015年 LaiYong. All rights reserved.
//
/**
 *  ****功能****
 *  日K线,周K线,月K线
 */
#import "K_LineGraphController.h"
#import "DownLoadManager.h"
#import "Stock.h"
#import "TimeLineController.h"
#import <MBProgressHUD/MBProgressHUD.h>
@interface K_LineGraphController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) MBProgressHUD *mbProgressHUD;
//@property (nonatomic, strong) NSTimer *timer;

@end

@implementation K_LineGraphController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%li",self.index);
    switch (self.index) {
        case 0:
            [self dayKlineBtn:nil];
            break;
        case 1:
            [self weekKlineBtn:nil];
            break;
        default:
            [self monthKlineBtn:nil];
            break;
    }
}
#pragma mark - 生命周期
//视图将要显示时候
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //转屏
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationLandscapeRight;//横屏
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}
////视图将要消失的暂停
//-(void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    NSDate *date = [NSDate distantFuture];
//    [self.timer setFireDate:date];
//}

#pragma mark - UIBarButtonItem funcation
//- (void)backItem {
//    //http://www.cnblogs.com/aukle/p/3217683.html
//    UIWindow *window=[[UIApplication sharedApplication]keyWindow];//主窗口
//    UINavigationController *nav0=(UINavigationController *)window.rootViewController;//根视图
//    UIViewController *timeLine=[nav0.viewControllers objectAtIndex:2];//根据索引查找视图控制器
//    [self.navigationController pushViewController:timeLine animated:YES];
//}
#pragma mark - UIBtton funcation
- (IBAction)switchKlineBtn:(UIButton *)sender {
    switch (sender.tag) {
        case 1: {
            self.navigationItem.title = [NSString stringWithFormat:@"%@ 日K线图",self.stock.stockName];
            NSString *link = [NSString stringWithFormat:@"http://image.sinajs.cn/newchart/daily/n/%@%@.gif",self.stock.stockHouse,self.stock.stockCode];
            [self downloadImageWithLink:link];
        }
            break;
        case 2: {
            self.navigationItem.title = [NSString stringWithFormat:@"%@ 周K线图",self.stock.stockName];
            NSString *link = [NSString stringWithFormat:@"http://image.sinajs.cn/newchart/weekly/n/%@%@.gif",self.stock.stockHouse,self.stock.stockCode];
            [self downloadImageWithLink:link];
        }
            break;
        default: {
            self.navigationItem.title = [NSString stringWithFormat:@"%@ 月K线图",self.stock.stockName];
            NSString *link = [NSString stringWithFormat:@"http://image.sinajs.cn/newchart/monthly/n/%@%@.gif",self.stock.stockHouse,self.stock.stockCode];
            [self downloadImageWithLink:link];
        }
            break;
    }
}
- (void)downloadImageWithLink:(NSString *)link{
    [DownLoadManager downloadLink:link withData:^(NSData *data) {
        UIImage *imageData = [UIImage imageWithData:data];
        self.imageView.image = imageData;
        [self.mbProgressHUD hide:YES];
    }];

}
- (IBAction)dayKlineBtn:(UIButton *)sender {
    self.imageView.image = nil;
    self.mbProgressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.navigationItem.title = [NSString stringWithFormat:@"%@ 日K线图",self.stock.stockName];
    NSString *link = [NSString stringWithFormat:@"http://image.sinajs.cn/newchart/daily/n/%@%@.gif",self.stock.stockHouse,self.stock.stockCode];
    [self downloadImageWithLink:link];
}
- (IBAction)weekKlineBtn:(UIButton *)sender {
    self.imageView.image = nil;
    self.mbProgressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.navigationItem.title = [NSString stringWithFormat:@"%@ 周K线图",self.stock.stockName];
    NSString *link = [NSString stringWithFormat:@"http://image.sinajs.cn/newchart/weekly/n/%@%@.gif",self.stock.stockHouse,self.stock.stockCode];
    [self downloadImageWithLink:link];
}
- (IBAction)monthKlineBtn:(UIButton *)sender {
    self.imageView.image = nil;
    self.mbProgressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.navigationItem.title = [NSString stringWithFormat:@"%@ 月K线图",self.stock.stockName];
    NSString *link = [NSString stringWithFormat:@"http://image.sinajs.cn/newchart/monthly/n/%@%@.gif",self.stock.stockHouse,self.stock.stockCode];
    [self downloadImageWithLink:link];
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
