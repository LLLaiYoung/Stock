//
//  SearchController.m
//  Stock
//
//  Created by chairman on 15/12/23.
//  Copyright © 2015年 LaiYong. All rights reserved.
//

#import "SearchController.h"
#import <FMDB/FMDB.h>
@interface SearchController ()
//@property (nonatomic, strong) UISearchController *searchController;
@end

@implementation SearchController
//- (instancetype)initWithSearchResultsController:(UIViewController *)searchResultsController {
//    if (self = [super initWithSearchResultsController:searchResultsController]) {
//        self.searchController = [[UISearchController alloc]initWithSearchResultsController:nil];//初始化搜索控制器WithSearchResultsController:表示搜索的结果使用什么控制器展示出来  nil就表示用自带的，用其他的就需要push出来一个
//        self.searchController.searchResultsUpdater = searchResultsController;//相当于设置searchController控制器的代理
//        self.searchController.searchBar.delegate = searchResultsController;
//        self.searchController.dimsBackgroundDuringPresentation = NO;//设置点击搜索控制器的Bar后是否为透明 默认为YES
//        self.searchController.hidesNavigationBarDuringPresentation = NO;//设置是否隐藏搜索控制器的Bar 默认为YES
//        self.searchController.searchBar.scopeButtonTitles = @[];//必须要写此行 设置搜索控制器下方显示搜索类型  @[]表示没有 写参数就相当于一个segment可供搜索的多种样式选择
////            self.tableView.tableHeaderView = self.searchController.searchBar;//把searchController的searchBar放在tableView的HeadView上面
//        
//        self.definesPresentationContext = YES; //不加，则在没有点击取消的情况下直接返回会黑屏
//    }
//    return self;
//}

//- (instancetype)initWithSearchResultsController:(UIViewController *)searchResultsController
//              withDimsBackgroundOrHiddenNaviBar:(NSArray<NSNumber *> *)bools
//                                     withTitles:(NSArray<NSString *>*)array
//                                   withDelegate:(NSArray<id<UISearchBarDelegate, UISearchResultsUpdating>>*)delegates
//                                withDisplayView:(UIView *)view {
//        if (self = [super initWithSearchResultsController:searchResultsController]) {
//       SearchController *searchController = [[SearchController alloc]initWithSearchResultsController:searchResultsController];//初始化搜索控制器WithSearchResultsController:表示搜索的结果使用什么控制器展示出来  nil就表示用自带的，用其他的就需要push出来一个
//        searchController.searchResultsUpdater = delegates[0];//相当于设置searchController控制器的代理
//        searchController.searchBar.delegate = delegates[1];
//        searchController.dimsBackgroundDuringPresentation = bools[0];//设置点击搜索控制器的Bar后是否为透明 默认为YES
//        searchController.hidesNavigationBarDuringPresentation = bools[1];//设置是否隐藏搜索控制器的Bar 默认为YES
//        searchController.searchBar.scopeButtonTitles = array;//必须要写此行 设置搜索控制器下方显示搜索类型  @[]表示没有 写参数就相当于一个segment可供搜索的多种样式选择
//            view = searchController.searchBar;//把searchController的searchBar放在tableView的HeadView上面
//    
//        self.definesPresentationContext = YES; //不加，则在没有点击取消的情况下直接返回会黑屏
//    }
//    return self;
//}
//+ (void)searchResultsController:(UIViewController *)searchResultsController
//      withDimsBackgroundOrHiddenNaviBar:(NSArray<NSNumber *> *)bools
//                             withTitles:(NSArray<NSString *>*)array
//                           withDelegate:(NSArray<id<UISearchBarDelegate, UISearchResultsUpdating>>*)delegates
//                        withDisplayView:(UIView *)view {
//    SearchController *searchController = [[SearchController alloc]initWithSearchResultsController:searchResultsController];//初始化搜索控制器WithSearchResultsController:表示搜索的结果使用什么控制器展示出来  nil就表示用自带的，用其他的就需要push出来一个
//    searchController.searchResultsUpdater = delegates[0];//相当于设置searchController控制器的代理
//    searchController.searchBar.delegate = delegates[1];
//    searchController.dimsBackgroundDuringPresentation = bools[0];//设置点击搜索控制器的Bar后是否为透明 默认为YES
//    searchController.hidesNavigationBarDuringPresentation = bools[1];//设置是否隐藏搜索控制器的Bar 默认为YES
//    searchController.searchBar.scopeButtonTitles = array;//必须要写此行 设置搜索控制器下方显示搜索类型  @[]表示没有 写参数就相当于一个segment可供搜索的多种样式选择
//    view = searchController.searchBar;//把searchController的searchBar放在tableView的HeadView上面
//    
//    searchController.definesPresentationContext = YES; //不加，则在没有点击取消的情况下直接返回会黑屏
////    return searchController;
//}
//+ (void)searchResultsController:(UIViewController *)searchResultsController
//withDimsBackgroundOrHiddenNaviBar:(NSArray<NSNumber *> *)bools
//                     withTitles:(NSArray<NSString *>*)array
//                   withDelegate:(NSArray<id<UISearchBarDelegate, UISearchResultsUpdating>>*)delegates
//                withDisplayView:(void (^)(SearchController *searchController))handler {
//    SearchController *searchController = [[SearchController alloc]initWithSearchResultsController:searchResultsController];//初始化搜索控制器WithSearchResultsController:表示搜索的结果使用什么控制器展示出来  nil就表示用自带的，用其他的就需要push出来一个
//    searchController.searchResultsUpdater = delegates[0];//相当于设置searchController控制器的代理
//    searchController.searchBar.delegate = delegates[1];
//    searchController.dimsBackgroundDuringPresentation = bools[0];//设置点击搜索控制器的Bar后是否为透明 默认为YES
//    searchController.hidesNavigationBarDuringPresentation = bools[1];//设置是否隐藏搜索控制器的Bar 默认为YES
//    searchController.searchBar.scopeButtonTitles = array;//必须要写此行 设置搜索控制器下方显示搜索类型  @[]表示没有 写参数就相当于一个segment可供搜索的多种样式选择
//    searchController.definesPresentationContext = YES; //不加，则在没有点击取消的情况下直接返回会黑屏
//
//    handler(searchController);
//    
//}


- (instancetype)searchResultsController:(UIViewController *)searchResultsController
withDimsBackgroundOrHiddenNaviBar:(NSArray<NSNumber *> *)bools
                     withTitles:(NSArray<NSString *>*)array
                   withDelegate:(NSArray<id<UISearchBarDelegate, UISearchResultsUpdating>>*)delegates
                withDisplayView:(void (^)(SearchController *searchController))handler {
    SearchController *searchController = [[SearchController alloc]initWithSearchResultsController:searchResultsController];//初始化搜索控制器WithSearchResultsController:表示搜索的结果使用什么控制器展示出来  nil就表示用自带的，用其他的就需要push出来一个
    searchController.searchResultsUpdater = delegates[0];//相当于设置searchController控制器的代理
    searchController.searchBar.delegate = delegates[1];
    searchController.dimsBackgroundDuringPresentation = bools[0].boolValue;//设置点击搜索控制器的Bar后是否为透明 默认为YES
    searchController.hidesNavigationBarDuringPresentation = bools[1].boolValue;//设置是否隐藏搜索控制器的Bar 默认为YES
//    searchController.searchBar.scopeButtonTitles = array;//必须要写此行 设置搜索控制器下方显示搜索类型  @[]表示没有 写参数就相当于一个segment可供搜索的多种样式选择
    searchController.definesPresentationContext = YES; //不加，则在没有点击取消的情况下直接返回会黑屏
    searchController.searchBar.placeholder = @"1111";
    
    
    handler(searchController);
    return searchController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
