//
//  Stock.h
//  Stock
//
//  Created by chairman on 15/12/23.
//  Copyright © 2015年 LaiYong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Stock : NSObject
/**
 *  NSString 类型 转换成 NSNumber 开头是0的会直接被省略掉
 */
@property (nonatomic, copy) NSString *stockName;///<股票名称    0
@property (nonatomic, copy) NSString *stockHouse;///<股票交易所 sub1
@property (nonatomic, strong) NSString *stockCode;///<股票代码  sub2
@property (nonatomic, strong) NSNumber *todayPrice;///<今日开盘价格   1
@property (nonatomic, strong) NSNumber *yesterDayPrice;///<昨日收盘价格   2
@property (nonatomic, strong) NSNumber *currentPrice;///<当前价格   3
@property (nonatomic, strong) NSNumber *todayHighestPrice;///<今日最高价 4
@property (nonatomic, strong) NSNumber *todayLowestPrice;///<今日最低价  5
@property (nonatomic, strong) NSNumber *amplitude;///<涨跌幅 涨幅=(现价-上一个交易日收盘价）/上一个交易日收盘价*100%
@property (nonatomic, strong) NSNumber *price;///<涨跌价格  涨跌=今收盘-昨收盘
@property (nonatomic, strong) NSNumber *like;///<是否收藏
@property (nonatomic, assign) NSUInteger length;

@end
