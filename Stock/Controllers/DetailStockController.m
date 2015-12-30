//
//  DetailStockController.m
//  Stock
//
//  Created by chairman on 15/12/25.
//  Copyright © 2015年 LaiYong. All rights reserved.
//
/**
 *  ****功能****
 *  显示数据(从网络请求)
 *  数据的删除(取消收藏)
 *  数据的新增(新增)
 *  数据自动刷新 (10s)
 *  分时线,日K线,周K线,月K线
 */
#import "DetailStockController.h"
#import "Stock.h"
#import "DownLoadManager.h"
#import "DataBaseManager.h"
#import "TimeLineController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "Reachability.h"
@interface DetailStockController ()
@property (weak, nonatomic) IBOutlet UILabel *stockHouseLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentController;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *currentPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *todayPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *yesterdayPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *todayHighestPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *todayLowestPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *amplitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (nonatomic, strong) Stock *stock;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *klineMenuItemBtn;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) Stock *newsStock;///<更新之后的值,new是系统关键值 textLabel 也是系统关键字
@property (nonatomic, strong) MBProgressHUD *mbProgressHUD;
@property (nonatomic, strong) Reachability *reach;

@end

@implementation DetailStockController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = [NSString stringWithFormat:@"%@(%@)",self.stock.stockName,self.stock.stockCode];
    [self downloadData];
    [self timeline];
    self.mbProgressHUD = [MBProgressHUD showHUDAddedTo:self.imageView animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    self.reach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    [self.reach startNotifier];
}
#pragma mark - 网络判断
-(BOOL)isConnectionAvailable{
    BOOL isExistenceNetwork = YES;
    switch ([self.reach currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork = NO;
            break;
        case ReachableViaWiFi:
            isExistenceNetwork = YES;
            break;
        case ReachableViaWWAN:
            isExistenceNetwork = YES;
            break;
    }
    return isExistenceNetwork;
}
#pragma mark - 网络检查
- (void)reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}
- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    if (reachability == self.reach) {
        [self changeState];
    }
}
- (void)changeState{
    if (![self isConnectionAvailable]) {
        //暂停定时器
        NSDate *date = [NSDate distantFuture];
        [self.timer setFireDate:date];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"当前网络不可用，请检查网络连接";  //提示的内容
        [hud hide:YES afterDelay:3];
    } else {
        //开始定时器
        NSDate *date = [NSDate distantPast];
        [self.timer setFireDate:date];
    }
}
#pragma mark - 生命周期
//视图将显示时候
//转屏应该在生命周期里执行
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationPortrait;//竖屏
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
    self.stock.length = self.stock.stockCode.length;
    if ([[DataBaseManager defaultManager]queryStockAtStock:self.stock].count>0) {
        self.likeBtn.selected = YES;
    } else {
        self.likeBtn.selected = NO;
    }
    
    /**
     *  离开界面控制器不暂停定时器 小心一会儿一套房子就没了
     */
    if ([self isConnectionAvailable]) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(downloadData) userInfo:nil repeats:YES];
    } else {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"当前网络不可用，请检查网络连接";  //提示的内容
        [hud hide:YES afterDelay:3];
    }
}
//开始
//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    NSDate *date = [NSDate distantPast];
//    [self.timer setFireDate:date];
//}
//暂停
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSDate *date = [NSDate distantFuture];
    [self.timer setFireDate:date];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    /**
     *  如果更新的某个值为nil 或者数据类型不对 会卡在  obj = va_arg(args, id); FMDB 只能存对象
     */
    if (self.stock.like.boolValue) {//如果收藏了就更新值
        self.newsStock.like = @1;//不设置为1则修改数据失败,请求的数据没有like
        [[DataBaseManager defaultManager]updateStock:self.newsStock];
    }
}
#pragma mark - download
static  NSInteger count=1;
- (void)downloadData {
    /**
     *  NSString 类型的数字 转换成 NSNumber 开头数字是0的会直接被省略掉
     */
    NSString *link = [NSString stringWithFormat:@"http://hq.sinajs.cn/list=%@%@",self.stock.stockHouse,self.stock.stockCode];
    [DownLoadManager downloadWithLink:link withStock:^(Stock *stock) {
        self.currentPriceLabel.text = [NSString stringWithFormat:@"%.2f",stock.currentPrice.floatValue];
        self.todayHighestPriceLabel.text = [NSString stringWithFormat:@"%.2f",stock.todayHighestPrice.floatValue];
        self.todayLowestPriceLabel.text = [NSString stringWithFormat:@"%.2f",stock.todayLowestPrice.floatValue];
        self.yesterdayPriceLabel.text = [NSString stringWithFormat:@"%.2f",stock.yesterDayPrice.floatValue];
        self.todayPriceLabel.text = [NSString stringWithFormat:@"%.2f",stock.todayPrice.floatValue];
        self.amplitudeLabel.text = [NSString stringWithFormat:@"%.2f%%",stock.amplitude.floatValue];
        self.priceLabel.text = [NSString stringWithFormat:@"%.2f(¥)",stock.price.floatValue];
        if (stock.amplitude.floatValue<0) {
            self.amplitudeLabel.textColor = [UIColor greenColor];
            self.priceLabel.textColor = [UIColor greenColor];
        } else {
            self.amplitudeLabel.textColor = [UIColor redColor];
            self.priceLabel.textColor = [UIColor redColor];
        }

        if ([self.stock.stockHouse isEqualToString:@"sh"]) {
            self.stockHouseLabel.text = @"上海";
        } else {
            self.stockHouseLabel.text = @"深圳";
        }
        self.newsStock = stock;

    }];
//    NSStringEncoding enc =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);//GB2312 转UTF-8

    NSLog(@"\n第%li次访问\n",count);
    count++;
}


- (IBAction)segmentController:(UISegmentedControl *)sender {
    self.imageView.image = nil;
    if (self.segmentController.selectedSegmentIndex==0) {
        [self timeline];
        self.mbProgressHUD = [MBProgressHUD showHUDAddedTo:self.imageView animated:YES];
    } else if (self.segmentController.selectedSegmentIndex==1) {
        NSString *link = [NSString stringWithFormat:@"http://image.sinajs.cn/newchart/daily/n/%@%@.gif",self.stock.stockHouse,self.stock.stockCode];
        [self downloadImageWithLink:link];
        self.mbProgressHUD = [MBProgressHUD showHUDAddedTo:self.imageView animated:YES];
    } else if (self.segmentController.selectedSegmentIndex == 2) {
        NSString *link = [NSString stringWithFormat:@"http://image.sinajs.cn/newchart/weekly/n/%@%@.gif",self.stock.stockHouse,self.stock.stockCode];
        [self downloadImageWithLink:link];
        self.mbProgressHUD = [MBProgressHUD showHUDAddedTo:self.imageView animated:YES];
    } else {
        NSString *link = [NSString stringWithFormat:@"http://image.sinajs.cn/newchart/monthly/n/%@%@.gif",self.stock.stockHouse,self.stock.stockCode];
        [self downloadImageWithLink:link];
        self.mbProgressHUD = [MBProgressHUD showHUDAddedTo:self.imageView animated:YES];
    }
}
- (void)timeline{
    NSString *link = [NSString stringWithFormat:@"http://image.sinajs.cn/newchart/min/n/%@%@.gif",self.stock.stockHouse,self.stock.stockCode];
    [self downloadImageWithLink:link];
}
- (void)downloadImageWithLink:(NSString *)link{
    [DownLoadManager downloadLink:link withData:^(NSData *data) {
        UIImage *imageData = [UIImage imageWithData:data];
        [self.mbProgressHUD hide:YES];
        self.imageView.image = imageData;
    }];
}
//如果把image设置成button的bgImage 则会在选中的时候出现一个多余的小点
- (IBAction)likeBtn:(UIButton *)sender {
    NSLog(@"\n点击了likeBtn\n");
    if (self.stock.like.boolValue) {
        self.stock.like = @0;
       BOOL isY = [[DataBaseManager defaultManager]deleteAtStock:self.stock];
        if (isY) {
            self.likeBtn.selected = NO;
            [self showHUDText:@"取消收藏"];
        } else {
            [self showHUDText:@"操作失败"];
        }
    } else {
        self.stock.like = @1;
        self.newsStock.like = @1;
       BOOL isY = [[DataBaseManager defaultManager]insertIntoStock:self.newsStock];
        if (isY) {
            self.likeBtn.selected = YES;
            [self showHUDText:@"收藏成功"];
        } else {
            [self showHUDText:@"操作失败"];
        }
    }
}
- (void)showHUDText:(NSString *)text {
    self.mbProgressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.mbProgressHUD.mode = MBProgressHUDModeText;//设置显示的样式，默认带有菊花
    self.mbProgressHUD.labelText = text;
    [self.mbProgressHUD hide:YES afterDelay:0.5];
}
#pragma mark - Menu
//Menu
- (IBAction)klineMenuItemBtn:(UIBarButtonItem *)sender {
    NSString * storyboardName = @"Main";
    NSString * viewControllerID = @"timeLine";
    /**
     *  Name则是自己起的，在.storyboard前面的名字，如果不动，则默认是Main，而且不需要添加文件的扩展名，如果加了，就会报错；
     *  bundle：这个参数包含storyboard的文件以及和它相关的资源，如果为空，则会调用当前程序的main bundle
     */
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    TimeLineController *timeLineVC = (TimeLineController *)[storyboard instantiateViewControllerWithIdentifier:viewControllerID];
    timeLineVC.stock = self.stock;
    [self.navigationController pushViewController:timeLineVC animated:YES];
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
