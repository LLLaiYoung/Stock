//
//  DataBaseManager.h
//  Stock
//
//  Created by chairman on 15/12/23.
//  Copyright © 2015年 LaiYong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Stock;
@interface DataBaseManager : NSObject

+(instancetype)defaultManager;///<单例
- (NSUInteger)numberOfStock;///<返回对象总数
- (BOOL)insertIntoStock:(Stock *)stock;///<插入数据
- (Stock *)queryStockAtIndex:(NSUInteger)index;///<查询数据 tableView接口
- (NSArray *)queryStockAtStock:(Stock *)stock;///<查询数据 searchController接口
- (NSArray *)backAllStock;///<返回所有数据库的对象 刷新数据接口
//filed 字段 format 格式
- (NSArray *)sortWithSortFormat:(NSString *)ascOrDesc withSortDBField:(NSString *)DBFiled;//排序接口
- (BOOL)deleteAtStock:(Stock *)stock;///<删除对象
- (BOOL)updateStock:(Stock *)stock;///<更新数据
@end
