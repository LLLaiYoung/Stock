//
//  StockCell.m
//  Stock
//
//  Created by chairman on 15/12/23.
//  Copyright © 2015年 LaiYong. All rights reserved.
//

#import "StockCell.h"
#import "Stock.h"
@interface StockCell()

@property (weak, nonatomic) IBOutlet UILabel *stockNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *amplitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation StockCell

////创建自定义可重用的自定义cell对象
//+ (instancetype)stockCellWithTableView:(UITableView *)tableView {
//    static NSString *reuseId = @"stockCell";
//    StockCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
//    if (!cell) {
//        cell = [[[NSBundle mainBundle]loadNibNamed:@"StockCell" owner:nil options:nil] lastObject];
//    }
//    return cell;
//}

- (void)setStock:(Stock *)stock {
    if (_stock!=stock) {
        _stock = stock;
        self.stockNameLabel.text = _stock.stockName;
        self.currentPriceLabel.text = [NSString stringWithFormat:@"%.2f",_stock.currentPrice.floatValue];
        self.amplitudeLabel.text = [NSString stringWithFormat:@"%.2f%%",_stock.amplitude.floatValue];
        self.priceLabel.text = [NSString stringWithFormat:@"%.2f",_stock.price.floatValue];
        if (_stock.amplitude.floatValue<0) {
            self.amplitudeLabel.textColor = [UIColor greenColor];
            self.priceLabel.textColor = [UIColor greenColor];
        } else {
            self.amplitudeLabel.textColor = [UIColor redColor];
            self.priceLabel.textColor = [UIColor redColor];
        }
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
