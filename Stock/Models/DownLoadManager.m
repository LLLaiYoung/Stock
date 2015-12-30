//
//  DownLoadManager.m
//  CQTravelGuide
//
//  Created by chairman on 15/11/16.
//  Copyright © 2015年 LaiYong. All rights reserved.
//

#import "DownLoadManager.h"
#import "Stock.h"
#import "DataBaseManager.h"
@implementation DownLoadManager
/**
 *dataHandler 相当于一个函数名 返回值类型是void 这个函数的参数是NSData类型的参数  参数名是data
 */
+ (void)downloadLink:(NSString *)link withData:(void (^)(NSData *data))dataHandler {
    NSURL *url = [NSURL URLWithString:link];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (connectionError) {
            NSLog(@"链接错误:%@",connectionError);
        }
        NSInteger code = ((NSHTTPURLResponse *)response).statusCode;
        if (code!=200) {
            NSLog(@"响应错误代码:%li",(long)code);
        }
        dataHandler(data);//block里面的参数不是本身block的参数  而是需要传值的参数
    }];
}
#pragma mark - 同步
+ (void)downloadSynStock:(Stock *)stock withStock:(void (^)(Stock *stock))stockHandler {
    NSString *link = [NSString stringWithFormat:@"http://hq.sinajs.cn/list=%@%@",stock.stockHouse,stock.stockCode];
    NSURL *url = [NSURL URLWithString:link];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSHTTPURLResponse *response= nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];//请求数据
    if (error) {
        NSLog(@"Error is:%@",error);
        return;
    } if (response.statusCode!=200) {
        NSLog(@"链接错误,错误码是:%li",(long)response.statusCode);
        return;
    }
    /**
     在类方法中self不是对象 代表的是类
     要调用实力方法需要创建一个实例然后代用实例方法
     */
    DownLoadManager *download = [[DownLoadManager alloc]init];
    [download parsingStockWithData:data withStock:^(Stock *stock) {
        stockHandler(stock);
   }];
}
#pragma mark - 异步
+ (void)downloadWithLink:(NSString *)link withStock:(void (^)(Stock *stock))stockHandler{
    DownLoadManager *download = [[DownLoadManager alloc]init];
    [DownLoadManager downloadLink:link withData:^(NSData *data) {
        [download parsingStockWithData:data withStock:^(Stock *stock) {
            stockHandler(stock);
        }];
    }];
}

//解析Stock 返回一个Stock的Block
-(void)parsingStockWithData:(NSData *)data withStock:(void (^)(Stock *stock))stockHandler{
    Stock *stock = [Stock new];
    NSStringEncoding enc =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);//GB2312 转UTF-8
    NSString *str = [[NSString alloc]initWithData:data encoding:enc];
    
    NSArray *firstList = [str componentsSeparatedByString:@"\""];//带有"号的需要加\
    
    if (!firstList[1]) {
        NSLog(@"股票代码出错,请检查股票代码");
        return ;
    }
    NSString *stockStr = firstList[1];
    if (stockStr.length==0) {
        NSLog(@"没找到对应的股票,请检查股票代码");
        return ;
    } else {
        //交易所,股票代码
        NSString *stockHouseAndCode = firstList[0];
        if (stockHouseAndCode.length==0) {
            NSLog(@"没找到对应的股票,请检查股票代码");
            return ;
        } else {
            NSArray *stockHouseAndCodes = [stockHouseAndCode componentsSeparatedByString:@"_"];
            NSString *stockSubStr = stockHouseAndCodes[2];
            NSString *stockHouse = [stockSubStr substringToIndex:2];
            NSRange rang={2,6};
            NSString *stockCode = [stockSubStr substringWithRange:rang];
            NSLog(@"\nstockHouse %@\nstockCode %@",stockHouse,stockCode);
            stock.stockHouse = stockHouse;
            stock.stockCode = stockCode;
        }
        //股票名称.......
        NSLog(@"_______________我是分隔符号______________");
        NSArray *list = [stockStr componentsSeparatedByString:@","];
        stock.stockName = list[0];
        stock.currentPrice = list[3];
        stock.todayPrice = list[1];
        stock.todayLowestPrice = list[5];
        stock.todayHighestPrice = list[4];
        stock.yesterDayPrice = list[2];
        stock.amplitude = @(((stock.currentPrice.floatValue-stock.yesterDayPrice.floatValue)/stock.yesterDayPrice.floatValue)*100.0);
        stock.price = @(stock.currentPrice.floatValue - stock.yesterDayPrice.floatValue);
        stockHandler(stock);
    }
}
/**
 *     
Stock *stock = [[Stock alloc]init];
 NSStringEncoding enc =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);//GB2312 转UTF-8
 [DownLoadManager downloadLink:link withData:^(NSData *data) {
     NSString *str = [[NSString alloc]initWithData:data encoding:enc];

     NSArray *firstList = [str componentsSeparatedByString:@"\""];//带有"号的需要加\

     if (!firstList[1]) {
         NSLog(@"股票代码出错,请检查股票代码");
         return ;
     }
     NSString *stockStr = firstList[1];
     if (stockStr.length==0) {
         NSLog(@"没找到对应的股票,请检查股票代码");
         return ;
     } else {
         //交易所,股票代码
         NSString *stockHouseAndCode = firstList[0];
         if (stockHouseAndCode.length==0) {
             NSLog(@"没找到对应的股票,请检查股票代码");
             return ;
         } else {
             NSArray *stockHouseAndCodes = [stockHouseAndCode componentsSeparatedByString:@"_"];
             NSString *stockSubStr = stockHouseAndCodes[2];
             NSString *stockHouse = [stockSubStr substringToIndex:2];
             NSRange rang={2,6};
             NSString *stockCode = [stockSubStr substringWithRange:rang];
             NSLog(@"\nstockHouse %@\nstockCode %@",stockHouse,stockCode);
             stock.stockHouse = stockHouse;
             stock.stockCode = stockCode;
         }
         //股票名称.......
         NSLog(@"_______________我是分隔符号______________");
         NSArray *list = [stockStr componentsSeparatedByString:@","];
         stock.stockName = list[0];
         stock.currentPrice = list[3];
         stock.todayPrice = list[1];
         stock.todayLowestPrice = list[5];
         stock.todayHighestPrice = list[4];
         stock.yesterDayPrice = list[2];
         stock.amplitude = @(((stock.currentPrice.floatValue-stock.yesterDayPrice.floatValue)/stock.yesterDayPrice.floatValue)*100.0);
         stock.price = @(stock.currentPrice.floatValue - stock.yesterDayPrice.floatValue);
     }
     stockHandler(stock);
 }];
 */
@end
