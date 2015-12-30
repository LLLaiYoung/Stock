//
//  DownLoadManager.h
//  CQTravelGuide
//
//  Created by chairman on 15/11/16.
//  Copyright © 2015年 LaiYong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Stock;
@interface DownLoadManager : NSObject
//给一个链接 返回data 异步
+ (void)downloadLink:(NSString *)link withData:(void (^)(NSData *data))dataHandler;
//给一个链接 返回网络请求到的Stock对象 异步
+ (void)downloadWithLink:(NSString *)link withStock:(void (^)(Stock *stock))stockHandler;
//给一个stock对象 返回网络请求到的Stock对象 同步
+ (void)downloadSynStock:(Stock *)stock withStock:(void (^)(Stock *stock))stockHandler;///<用于数据刷新
@end
