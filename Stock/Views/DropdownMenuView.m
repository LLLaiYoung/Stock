//
//  DropdownMenuView.m
//  Stock
//
//  Created by chairman on 15/12/26.
//  Copyright © 2015年 LaiYong. All rights reserved.
//

#import "DropdownMenuView.h"

@interface DropdownMenuView()
<
UITableViewDataSource
>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DropdownMenuView

+ (instancetype)dropdown
{
    return [[[NSBundle mainBundle] loadNibNamed:@"DropdownMenuView" owner:nil options:nil] firstObject];
}
- (void)awakeFromNib {
    self.tableView.tableFooterView = [UIView new];
    //不需要跟随父控件的尺寸变化而伸缩
//    self.autoresizingMask = UIViewAutoresizingNone;
}
#pragma mark - UITableViewDataSource
//行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.array.count;
}
//数据显示
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *Cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MenuCell"];
    Cell.textAlignment = NSTextAlignmentCenter;
    Cell.textLabel.text = self.array[indexPath.row];
    return Cell;
}
/**
 * UITableViewDelegate 在DropdownMenuController实现 因为UIView不能执行控制器之间的跳转
 */
@end
