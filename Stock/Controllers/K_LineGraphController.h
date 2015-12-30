//
//  K_LineGraphController.h
//  Stock
//
//  Created by chairman on 15/12/24.
//  Copyright © 2015年 LaiYong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Stock;
@interface K_LineGraphController : UIViewController
@property (nonatomic, strong) Stock *stock;
@property (nonatomic, assign) NSInteger index;
@end
