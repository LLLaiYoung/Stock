//
//  AddOrQueryStockController.m
//  Stock
//
//  Created by chairman on 15/12/24.
//  Copyright © 2015年 LaiYong. All rights reserved.
//
/**
 *  ****功能****
 *  网络查询数据
 */
#import "AddOrQueryStockController.h"
#import "DownLoadManager.h"
#import "StockSearchCell.h"
#import "Stock.h"
#import <MBProgressHUD/MBProgressHUD.h>
@interface AddOrQueryStockController ()
<
UISearchBarDelegate,
UISearchResultsUpdating
>
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *queryList;
@property (nonatomic, strong) MBProgressHUD *mbProgressHUD;
@property (nonatomic, strong) UISearchBar *searchBar;
@end

@implementation AddOrQueryStockController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.queryList = [NSMutableArray array];
    self.navigationItem.title = @"新增自选股";
    self.tableView.tableFooterView = [UIView new];
    [self search];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.tableView.contentInset = UIEdgeInsetsZero;
        self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    }
}
- (void)search {
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];//初始化搜索控制器WithSearchResultsController:表示搜索的结果使用什么控制器展示出来  nil就表示用自带的，用其他的就需要push出来一个
    self.searchController.searchBar.keyboardType = UIKeyboardTypeNumberPad;
    self.searchController.searchResultsUpdater = self;//相当于设置searchController控制器的代理
    self.searchController.searchBar.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;//设置点击搜索控制器的Bar后是否为透明 默认为YES
    self.searchController.hidesNavigationBarDuringPresentation = YES;//设置是否隐藏搜索控制器的Bar 默认为YES
    self.searchController.searchBar.scopeButtonTitles = @[@"上海",@"深圳"];//必须要写此行 设置搜索控制器下方显示搜索类型  @[]表示没有 写参数就相当于一个segment可供搜索的多种样式选择
    self.searchController.searchBar.placeholder = @"请输入股票代码";
//    [self.searchControllerView addSubview:self.searchController.searchBar];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.searchBar = self.searchController.searchBar;
    self.definesPresentationContext = YES; //不加，则在没有点击取消的情况下直接返回会黑屏
}
#pragma mark - 生命周期

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSLog(@"searchControllerFrame = %@",NSStringFromCGRect(searchController.searchBar.frame));
    CGRect frame = CGRectZero;
    if (searchController.isActive) {
        frame = searchController.searchBar.frame;
    } else {
        frame.size.height = 56.0f;
    }
    self.tableView.tableHeaderView.frame = frame;
    
    if (searchController.searchBar.text.length==6) {
        [self.queryList removeAllObjects];
        NSLog(@"%@",searchController.searchBar.text);
        NSString *link;
        if(searchController.searchBar.selectedScopeButtonIndex==0) {
            link = [NSString stringWithFormat:@"http://hq.sinajs.cn/list=sh%@",searchController.searchBar.text];
            
            [DownLoadManager downloadWithLink:link withStock:^(Stock *stock) {
                [self.queryList addObject:stock];
                [self.tableView reloadData];
            }];
        } else {
            link =[NSString stringWithFormat:@"http://hq.sinajs.cn/list=sz%@",searchController.searchBar.text];
            [DownLoadManager downloadWithLink:link withStock:^(Stock *stock) {
                [self alert];
                [self.queryList addObject:stock];
                [self.tableView reloadData];
            }];
        }
    }
    if (!searchController.isActive) {
        [self.queryList removeAllObjects];
    }
    [self.tableView reloadData];
}
- (void)alert{
    if (self.searchController.searchBar.text.length>=6) {
        self.mbProgressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.mbProgressHUD.labelText = @"请检查股票代码";
        [self.mbProgressHUD hide:YES afterDelay:2.0];
    }
}
#pragma mark - UIsearchBar delegate
//selectedScopeButtonIndexDidChange 意思是刷新筛选条件的Btn 使筛选出来的条件立即显示出来
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    NSLog(@"UIsearchBar delegate");
    [self updateSearchResultsForSearchController:self.searchController];//上面的UISearchController delegate已经做了选择searchBar的selectedScopeButtonIndex 所以直接调用就可以了
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.queryList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StockSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell" forIndexPath:indexPath];
    cell.stock = self.queryList[indexPath.row];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    if ([segue.identifier isEqualToString:@"search2detail"]) {
        [segue.destinationViewController setValue:self.queryList[indexPath.row] forKey:@"stock"];
    }
}

@end
