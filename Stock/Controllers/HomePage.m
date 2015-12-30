//
//  HomePage.m
//  Stock
//
//  Created by chairman on 15/12/22.
//  Copyright © 2015年 LaiYong. All rights reserved.
//
/**
 *  ****功能****
 *  显示数据(从数据库读取)->自定义cell
 *  数据的删除
 *  数据的查询
 *  数据自动刷新 (10s) 注意在删除数据的时候需要停止cell的数据加载
 *  数据排序(按字段)
 */
#import "HomePage.h"
#import "DownLoadManager.h"
#import "Stock.h"
#import "SearchController.h"
#import "DataBaseManager.h"
#import "StockCell.h"
#import "DetailStockController.h"

@interface HomePage ()
<
UISearchBarDelegate,
UISearchResultsUpdating,
UITableViewDataSource,
UITableViewDelegate
>
@property (weak, nonatomic) IBOutlet UIView *searchControllerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UISearchController *searchController;
@property (weak, nonatomic) IBOutlet UIButton *currentPriceBtn;
@property (weak, nonatomic) IBOutlet UIButton *amplitudeBtn;
@property (weak, nonatomic) IBOutlet UIButton *priceBtn;

@property (nonatomic, strong) NSMutableArray *queryList;///<查询结果数组
@property (nonatomic, strong) NSMutableArray *sortList;///<排序结果数组
@property (nonatomic, assign, getter=isSort) BOOL sort;///<是否排序
@property (nonatomic, assign,getter=isAsc) BOOL asc;///<是否为升序
@property (nonatomic, strong) NSMutableArray *updataArray;///<获取数据库的所有对象用于更新数据 因在视图将要显示的时候获取数据库的数据
@property (nonatomic, strong) NSTimer *timer;///<定时器
@end

@implementation HomePage

- (void)viewDidLoad {
    [super viewDidLoad];
    [self search];
    self.navigationItem.title = @"我的自选股";
    self.queryList = [NSMutableArray array];
    self.sortList = [NSMutableArray array];
    self.tableView.tableFooterView = [UIView new];
//    self.tableView.allowsSelection = NO;//不能响应点击事件
    //http://blog.csdn.net/justinjing0612/article/details/7306836
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"everLaunched"]) {
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"everLaunched"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
        NSLog(@"first launch第一次程序启动");
        
    }else {
        
        NSLog(@"second launch再次程序启动");
    }
    
    [self updata];
}
#pragma mark - Updata
//http://blog.csdn.net/totogo2010/article/details/8016129  iOS多线程编程之Grand Central Dispatch(GCD)介绍和使用
static NSInteger count=0;
- (void)updata {//同步下载和定时器不会互相冲突？未拿到数据,再次发送请求
    __weak typeof(self) weakSelf = self; //在GCD中__weak
    //http://blog.lessfun.com/blog/2014/11/22/when-should-use-weakself-and-strongself-in-objc-block/
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (Stock *stock in self.updataArray) {
            [DownLoadManager downloadSynStock:stock withStock:^(Stock *stock) {//这里是一个同步下载
                [[DataBaseManager defaultManager]updateStock:stock];
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
                NSLog(@"\nHomePage\n第%li次访问",count);
            });
        }
    });
    count ++;
}

#pragma mark - funcation
- (void)search {
    self.searchController = [[UISearchController alloc]initWithSearchResultsController:nil];//初始化搜索控制器WithSearchResultsController:表示搜索的结果使用什么控制器展示出来  nil就表示用自带的，用其他的就需要push出来一个
    self.searchController.searchResultsUpdater = self;//相当于设置searchController控制器的代理
    self.searchController.searchBar.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;//设置点击搜索控制器的Bar后是否为透明 默认为YES
    self.searchController.hidesNavigationBarDuringPresentation = NO;//设置是否隐藏搜索控制器的Bar 默认为YES
    self.searchController.searchBar.scopeButtonTitles = @[];//@[@"上海",@"深圳"];//必须要写此行 设置搜索控制器下方显示搜索类型  @[]表示没有 写参数就相当于一个segment可供搜索的多种样式选择
    self.searchController.searchBar.placeholder = @"请输入股票名称";
    [self.searchControllerView addSubview:self.searchController.searchBar];//view 使用addSubView添加

    self.definesPresentationContext = YES; //不加，则在没有点击取消的情况下直接返回会黑屏
}

#pragma mark - 生命周期函数
//视图将被从屏幕上移除之前执行
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];//设置返回按钮的文字
    [self.searchController.searchBar resignFirstResponder];//隐藏键盘
    //暂停定时器
    NSDate *date = [NSDate distantFuture];
    [self.timer setFireDate:date];
}
//视图将显示时候
//转屏应该在生命周期里执行
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //获取数据库的所有对象
    self.updataArray = [[[DataBaseManager defaultManager]backAllStock] mutableCopy];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(updata) userInfo:nil repeats:YES];
    /**
     *  关于iOS 强制转横屏的博客
     *  http://www.cocoachina.com/bbs/read.php?tid=39663
     *  http://stackoverflow.com/questions/7968451/different-ways-of-getting-current-interface-orientation#
     *  http://stackoverflow.com/questions/634745/how-to-programmatically-determine-iphone-interface-orientation/3897243#3897243
     *  http://zhenby.com/blog/2013/08/20/talk-ios-orientation/
     */
    //setOrientation: 3.0~成为私有API 据说运用此方法很难通过AppStore的审核,具体解决的办法在上面几篇博客中有提到
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        //http://mobile.51cto.com/hot-431728.htm SEL
        //http://blog.csdn.net/huifeidexin_1/article/details/8608074  NSSelectorFromString
        //http://blog.jobbole.com/45963/  Objective-C的动态提示和技巧
        //NSSelectorFromString 动态加载实例方法
        SEL selector = NSSelectorFromString(@"setOrientation:");//==SEL selector = @selector(setOrientation:);
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
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];//==NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:@selector(setOrientation:)]];
        [invocation setSelector:selector];//==[invocation setSelector:@selector(setOrientation:)];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationPortrait;//竖屏
        /**
         *  第一个参数：需要给指定方法传递的值
         *  第一个参数需要接收一个指针，也就是传递值的时候需要传递地址
         *  第二个参数：需要给指定方法的第几个参数传值
         *  注意：设置参数的索引时不能从0开始，因为0已经被self(target)占用，1已经被_cmd(selector)占用 在NSInvocation的官方文档中已经说明
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
#warning searchBar frame 应该获取当前设备的width   横屏回来searchBar会显示不正常
    [self.searchController.searchBar removeFromSuperview];
//    CGRect frame=self.searchController.searchBar.frame;
//    CGSize size=frame.size;
//    size.width=375;
//    frame.size=size;
//    self.searchController.searchBar.frame=frame;
    [self.searchControllerView addSubview:self.searchController.searchBar];
//    NSLog(@"%f",self.searchControllerView.frame.size.width);
    [self.tableView reloadData];
}
#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSLog(@"_______________UISearchResultsUpdating______________");
    NSLog(@"%@",searchController.searchBar.text);

    [self.queryList removeAllObjects];
    Stock *stock = [Stock new];
    stock.stockName = searchController.searchBar.text;
    stock.length = searchController.searchBar.text.length;
    self.queryList = [[[DataBaseManager defaultManager]queryStockAtStock:stock] mutableCopy];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchController.active) {
        return self.queryList.count;
    }
    else if (self.isSort) {
        return self.sortList.count;
    }
    else {
        return [[DataBaseManager defaultManager]numberOfStock];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StockCell *cell= [tableView dequeueReusableCellWithIdentifier:@"stockCell" forIndexPath:indexPath];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;//cell选中之后的样式
    if (self.searchController.active) {
        cell.stock = self.queryList[indexPath.row];
    }
     else if (self.isSort) {
        cell.stock = self.sortList[indexPath.row];
    }
    else {
        cell.stock = [[DataBaseManager defaultManager]queryStockAtIndex:indexPath.row];
    }
    return cell;
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //        要先从数据源删除 一定要保证数据同步
        if (self.searchController.active) {
            [self.queryList removeObjectAtIndex:indexPath.row];
        } else {
            [[DataBaseManager defaultManager]deleteAtStock:[[DataBaseManager defaultManager] queryStockAtIndex:indexPath.row]];
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    [self.tableView reloadData];
}
//设置searchController激活的时候不能删除
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.searchController.active) {
        return NO;
    }
    return YES;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"取消收藏";
}
#pragma mark - SortAction
- (IBAction)sortBtns:(UIButton *)sender {
    [self.sortList removeAllObjects];
    switch (sender.tag) {
        case 1://当前价 currentPrice
        {
            if (self.isAsc) {
                self.sortList = [[self sortWithDBField:@"currentPrice" WithSortFormat:@"asc"] mutableCopy];
                [self.currentPriceBtn setTitle:@"当前价⬆️" forState:UIControlStateNormal];
            } else {
                self.sortList = [[self sortWithDBField:@"currentPrice" WithSortFormat:@"desc"] mutableCopy];
                [self.currentPriceBtn setTitle:@"当前价⬇️" forState:UIControlStateNormal];
            }
                self.sort = YES;
            [self setBtnTitle:@"涨跌幅%" WithSender:self.amplitudeBtn];
            [self setBtnTitle:@"涨跌¥" WithSender:self.priceBtn];
            [self.tableView reloadData];
        }
        break;
        case 2://涨跌幅% amplitude
        {
            if (self.isAsc) {
                self.sortList = [[self sortWithDBField:@"amplitude" WithSortFormat:@"asc"] mutableCopy];
                [self.amplitudeBtn setTitle:@"涨跌幅%⬆️" forState:UIControlStateNormal];
            } else {
                self.sortList = [[self sortWithDBField:@"amplitude" WithSortFormat:@"desc"] mutableCopy];
                [self.amplitudeBtn setTitle:@"涨跌幅%⬇️" forState:UIControlStateNormal];
            }
            self.sort = YES;
            [self setBtnTitle:@"当前价" WithSender:self.currentPriceBtn];
            [self setBtnTitle:@"涨跌¥" WithSender:self.priceBtn];
            [self.tableView reloadData];
        }
        break;
        default://涨跌¥ price
        {
            if (self.isAsc) {
                self.sortList = [[self sortWithDBField:@"price" WithSortFormat:@"asc"] mutableCopy];
                [self.priceBtn setTitle:@"涨跌⬆️" forState:UIControlStateNormal];
            } else {
                self.sortList = [[self sortWithDBField:@"price" WithSortFormat:@"desc"] mutableCopy];
                [self.priceBtn setTitle:@"涨跌⬇️" forState:UIControlStateNormal];
            }
            self.sort = YES;
            [self setBtnTitle:@"当前价" WithSender:self.currentPriceBtn];
            [self setBtnTitle:@"涨跌幅%" WithSender:self.amplitudeBtn];
            [self.tableView reloadData];
        }
            break;
    }
}

- (NSArray *)sortWithDBField:(NSString *)DBField WithSortFormat:(NSString *)ascOrDesc {
    NSArray *tempArray = [NSArray new];
    tempArray = [[DataBaseManager defaultManager]sortWithSortFormat:ascOrDesc withSortDBField:DBField];
    self.asc=!self.asc;
    [self.tableView reloadData];
    return tempArray;
}
- (void)setBtnTitle:(NSString *)title WithSender:(UIButton *)sender {
    [sender setTitle:title forState:UIControlStateNormal];
}

//谨记MVC模式,view不持有数据  不要在view去读取数据 
#pragma mark - 触摸/触控
//UISearchController 的searchBar 用此方法不行 //  看 iOS响应者链
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self.view endEditing:YES];
//    self.sort = NO;//点击除了需要排序的几个btn之外点击其他地方 把sort设置为no
        [self setBtnTitle:@"涨跌幅%" WithSender:self.amplitudeBtn];
        [self setBtnTitle:@"涨跌¥" WithSender:self.priceBtn];
        [self setBtnTitle:@"当前价" WithSender:self.currentPriceBtn];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    if ([segue.identifier isEqualToString:@"home2detail"]) {
        if (self.searchController.active) {
            [segue.destinationViewController setValue:self.queryList[indexPath.row] forKey:@"stock"];
            }
            else if (self.isSort) {
                [segue.destinationViewController setValue:self.sortList[indexPath.row] forKey:@"stock"];
            }
            else {
                [segue.destinationViewController setValue:[[DataBaseManager defaultManager]queryStockAtIndex:indexPath.row] forKey:@"stock"];
            }
        
    }
}

@end
