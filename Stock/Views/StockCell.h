//
//  StockCell.h
//  Stock
//
//  Created by chairman on 15/12/23.
//  Copyright © 2015年 LaiYong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Stock;
@interface StockCell : UITableViewCell
@property (nonatomic, strong) Stock *stock;
//+ (instancetype)stockCellWithTableView:(UITableView *)tableView;
@end
