//
//  DropdownMenuController.h
//  Stock
//
//  Created by chairman on 15/12/26.
//  Copyright © 2015年 LaiYong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Stock;
@class DropdownMenuController;
@protocol DropdownMenuControllerDelegate <NSObject>
@required
- (void)DropdownMenuController:(DropdownMenuController *)dropdownMenu withIndex:(NSUInteger)index;
@optional

@end

@interface DropdownMenuController : UIViewController
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) Stock *stock;
@property (nonatomic, weak) id<DropdownMenuControllerDelegate> delegate;
@end
