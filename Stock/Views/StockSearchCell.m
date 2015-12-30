//
//  StockSearchCell.m
//  Stock
//
//  Created by chairman on 15/12/26.
//  Copyright © 2015年 LaiYong. All rights reserved.
//

#import "StockSearchCell.h"
#import "Stock.h"

@interface StockSearchCell()
@property (weak, nonatomic) IBOutlet UILabel *stockNameSLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentPriceSLabel;
@property (weak, nonatomic) IBOutlet UILabel *amplitudeSLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceSLabel;

@end

@implementation StockSearchCell

- (void)setStock:(Stock *)stock {
    if (_stock!=stock) {
        _stock = stock;
        self.stockNameSLabel.text = _stock.stockName;
        self.currentPriceSLabel.text = [NSString stringWithFormat:@"%@",_stock.currentPrice];
        self.amplitudeSLabel.text = [NSString stringWithFormat:@"%.2f%%",_stock.amplitude.floatValue];
        self.priceSLabel.text = [NSString stringWithFormat:@"%.2f",_stock.price.floatValue];
        if (_stock.amplitude.floatValue<0) {
            self.amplitudeSLabel.textColor = [UIColor greenColor];
            self.priceSLabel.textColor = [UIColor greenColor];
        } else {
            self.amplitudeSLabel.textColor = [UIColor redColor];
            self.priceSLabel.textColor = [UIColor redColor];
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
