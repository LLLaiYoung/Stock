//
//  DropdownMenuController.m
//  Stock
//
//  Created by chairman on 15/12/26.
//  Copyright © 2015年 LaiYong. All rights reserved.
//

#import "DropdownMenuController.h"
#import "DropdownMenuView.h"
#import "UIView+Extension.h"
#import "K_LineGraphController.h"
@interface DropdownMenuController ()
<
UITableViewDelegate
>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation DropdownMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    DropdownMenuView *menu = [DropdownMenuView dropdown];
    NSLog(@"subviews %@", [menu subviews]);
    
    menu.array = self.titles;
    [self.view addSubview:menu];
    // 设置控制器view在popover中的尺寸
    self.preferredContentSize = menu.size;
    //查找menu 视图下的所有子视图
    NSInteger index = 0;
    while ([menu subviews].count) {
        if (index == [menu subviews].count) {
            return;
        } else {
           BOOL isY = [[menu subviews][index] isKindOfClass:[UITableView class]];
            if (isY) {
                self.tableView = [menu subviews][index];
                self.tableView.delegate = self;
                return;
            } else {
                index++;
            }
        }
    }
}
//UITableViewDataSource 在DropdownMenuView中实现
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    /**
     *  这个类只负责获取点击的index和通知 具体的present应该是prensent出本控制器的控制器
     */
    if ([self.delegate respondsToSelector:@selector(DropdownMenuController:withIndex:)]) {
        [self.delegate DropdownMenuController:self withIndex:indexPath.row];
        [self dismissViewControllerAnimated:NO completion:nil];//Animated 有延迟 所以不应该有动画效果
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
