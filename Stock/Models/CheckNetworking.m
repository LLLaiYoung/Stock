//
//  CheckNetworking.m
//  Stock
//
//  Created by chairman on 15/12/30.
//  Copyright © 2015年 LaiYong. All rights reserved.
//

#import "CheckNetworking.h"

@implementation CheckNetworking
//#pragma mark - 网络判断
//-(BOOL)isConnectionAvailable{
//    BOOL isExistenceNetwork = YES;
//    switch ([self.reach currentReachabilityStatus]) {
//        case NotReachable:
//            isExistenceNetwork = NO;
//            break;
//        case ReachableViaWiFi:
//            isExistenceNetwork = YES;
//            break;
//        case ReachableViaWWAN:
//            isExistenceNetwork = YES;
//            break;
//    }
//    return isExistenceNetwork;
//}
//#pragma mark - 网络检查
//- (void)reachabilityChanged:(NSNotification *)note
//{
//    Reachability* curReach = [note object];
//    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
//    [self updateInterfaceWithReachability:curReach];
//}
//- (void)updateInterfaceWithReachability:(Reachability *)reachability
//{
//    if (reachability == self.reach) {
//        [self changeState];
//    }
//}
//- (void)changeState{
//    if (![self isConnectionAvailable]) {
//        //暂停定时器
//        NSDate *date = [NSDate distantFuture];
//        [self.timer setFireDate:date];
//        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        hud.mode = MBProgressHUDModeText;
//        hud.labelText = @"当前网络不可用，请检查网络连接";  //提示的内容
//        [hud hide:YES afterDelay:3];
//    } else {
//        NSDate *date = [NSDate distantPast];
//        [self.timer setFireDate:date];
//    }
//}

@end
