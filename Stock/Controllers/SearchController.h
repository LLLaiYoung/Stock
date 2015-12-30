//
//  SearchController.h
//  Stock
//
//  Created by chairman on 15/12/23.
//  Copyright © 2015年 LaiYong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchController : UISearchController
//- (instancetype)initWithSearchResultsController:(UIViewController *)searchResultsController;
//- (instancetype)initWithSearchResultsController:(UIViewController *)searchResultsController
//              withDimsBackgroundOrHiddenNaviBar:(NSArray<NSNumber *> *)bools
//                                     withTitles:(NSArray<NSString *>*)array
//                                   withDelegate:(NSArray<id<UISearchBarDelegate, UISearchResultsUpdating>>*)delegates
//                                withDisplayView:(UIView *)view;
//+ (void)searchResultsController:(UIViewController *)searchResultsController
//      withDimsBackgroundOrHiddenNaviBar:(NSArray<NSNumber *> *)bools
//                             withTitles:(NSArray<NSString *>*)array
//                           withDelegate:(NSArray<id<UISearchBarDelegate, UISearchResultsUpdating>>*)delegates
//                        withDisplayView:(UIView *)view;
//withData:(void (^)(NSData *data))dataHandler;
//+ (void)searchResultsController:(UIViewController *)searchResultsController
//withDimsBackgroundOrHiddenNaviBar:(NSArray<NSNumber *> *)bools
//                     withTitles:(NSArray<NSString *>*)array
//                   withDelegate:(NSArray<id<UISearchBarDelegate, UISearchResultsUpdating>>*)delegates
//                withDisplayView:(void (^)(SearchController *searchController))handler;


- (instancetype)searchResultsController:(UIViewController *)searchResultsController
withDimsBackgroundOrHiddenNaviBar:(NSArray<NSNumber *> *)bools
                     withTitles:(NSArray<NSString *>*)array
                   withDelegate:(NSArray<id<UISearchBarDelegate, UISearchResultsUpdating>>*)delegates
                withDisplayView:(void (^)(SearchController *searchController))handler;
@end
