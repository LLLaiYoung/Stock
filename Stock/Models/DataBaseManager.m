//
//  DataBaseManager.m
//  Stock
//
//  Created by chairman on 15/12/23.
//  Copyright © 2015年 LaiYong. All rights reserved.
//

#define kDataBasePath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"Stock.db"]
#define kStock @"Stock"

#import "DataBaseManager.h"
#import <FMDB/FMDB.h>
#import "Stock.h"
/**
 *  FMDB只能存对象
 */
@interface DataBaseManager()
@property (nonatomic, strong) FMDatabase *dataBase;
@end

@implementation DataBaseManager

- (instancetype)init {
    if (self = [super init]) {
        self.dataBase = [FMDatabase databaseWithPath:kDataBasePath];
        if (![self.dataBase open]) {
            NSLog(@"数据库打开失败");
            return nil;
        } else {
            NSLog(@"数据库打开成功,路径是%@",kDataBasePath);
        }
        //integer类型 0开头的数字会默认省略
        NSString *sqlStr = [NSString stringWithFormat: @"create table if not exists %@ (stockName text primary key,stockHouse text,stockCode text,todayPrice integer,yesterDayPrice integer,currentPrice integer,todayHighestPrice integer,todayLowestPrice integer,amplitude integer,price integer,collect boolearn)",kStock];
        if (![self.dataBase executeUpdate:sqlStr]) {
            NSLog(@"创建%@表失败,SQL语句是%@",kStock,sqlStr);
            return nil;
        }
    }
    return self;
}

#pragma mark - 单例
+(instancetype)defaultManager {
    static DataBaseManager *theManager = nil;
    @synchronized(self) {//防止同时发送两个请求。一个执行一个则在外面等待执行完毕再执行
        if (!theManager) {
            theManager = [[DataBaseManager alloc]init];
        }
    }
    return theManager;

}
#pragma mark - 数据库接口
- (NSUInteger)numberOfStock {
    NSString *sqlStr = [NSString stringWithFormat:@"select count(*) from %@",kStock];
    return [self.dataBase intForQuery:sqlStr];
}
- (BOOL)insertIntoStock:(Stock *)stock {
    if (!stock) {
        NSLog(@"插入数据为nil");
        return NO;
    } else {
        NSString *sqlStr = [NSString stringWithFormat:@"insert into %@(stockName,stockHouse,stockCode,todayPrice,yesterDayPrice,currentPrice,todayHighestPrice,todayLowestPrice,amplitude,price,collect) values(?,?,?,?,?,?,?,?,?,?,?)",kStock];
        BOOL isSuccess = [self.dataBase executeUpdate:sqlStr,stock.stockName,stock.stockHouse ,stock.stockCode,stock.todayPrice,stock.yesterDayPrice,stock.currentPrice,stock.todayHighestPrice,stock.todayLowestPrice,stock.amplitude,stock.price,stock.like];//数据库是boolearn,NSNumber直接存,不用转换
        if (!isSuccess) {
            NSLog(@"插入数据失败,插入语句是:%@",sqlStr);
            return NO;
        }
    }
    return YES;
}
- (Stock *)queryStockAtIndex:(NSUInteger)index {
    if (index>=[self numberOfStock]) {
        return nil;
    }
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@ limit ?,1",kStock];
    FMResultSet *result = [self.dataBase executeQuery:sqlStr,@(index)];

    if (!result) {
        NSLog(@"%@表查询失败,查询语句是:%@",kStock,sqlStr);
        return nil;
    } else{
        Stock *stock = [Stock new];
        while ([result next]) {
            [self resultQuery:result WithStock:stock];
        }
        return stock;
    }
    return nil;
}
- (NSArray *)queryStockAtStock:(Stock *)stock {
    if (!stock.length) {
        NSLog(@"查询数据出错,查询对象为nil");
        return nil;
    }
    //SELECT 列名称 FROM 表名称 WHERE 列 运算符 值
//    NSString *NSsql=[NSString stringWithFormat:@"SELECT id,name,age FROM t_person WHERE name like '%%%@%%' ORDER BY age ASC;",condition];
    //select stockName from Stock where stockName like '%中%'
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@ where stockName like '%%%@%%'",kStock,stock.stockName];
    FMResultSet *result = [self.dataBase executeQuery:sqlStr];

    if (!result) {
        NSLog(@"%@表查询失败,查询语句是:%@",kStock,sqlStr);
        return nil;
    }
        NSMutableArray *tempArray = [NSMutableArray array];
        while ([result next]) {
            Stock *stock1 = [Stock new];
            [tempArray addObject:[self resultQuery:result WithStock:stock1]];
        }
        return tempArray;
}
- (BOOL)deleteAtStock:(Stock *)stock {
    if (!stock) {
        NSLog(@"删除的对象错误");
        return NO;
    }
    NSString *sqlStr = [NSString stringWithFormat:@"delete from %@ where stockName=?",kStock];
    if (![self.dataBase executeUpdate:sqlStr,stock.stockName]) {
        NSLog(@"删除失败,删除语句是%@",sqlStr);
        return NO;
    }
    return YES;
}
- (NSArray *)backAllStock {
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@",kStock];
    FMResultSet *result = [self.dataBase executeQuery:sqlStr];
    NSMutableArray *tempArray = [NSMutableArray array];
    while ([result next]) {
        Stock *stock = [Stock new];
       [tempArray addObject: [self resultQuery:result WithStock:stock]];
    }
    return tempArray;
}
- (BOOL)updateStock:(Stock *)stock {
    if (!stock) {
        NSLog(@"更新的对象错误");
        return NO;
    } else {
        //update 表名 set 列名称=新值 where 列名称='某值'
        NSString *sqlStr = [NSString stringWithFormat:@"update Stock set stockHouse=?,stockCode=?,todayPrice=?,yesterDayPrice=?,currentPrice=?,todayHighestPrice=?,todayLowestPrice=?,amplitude=?,price=?,collect=? where stockName='%@'",stock.stockName];
        BOOL isSuccess = [self.dataBase executeUpdate:sqlStr,stock.stockHouse,stock.stockCode,stock.todayPrice,stock.yesterDayPrice,stock.currentPrice,stock.todayHighestPrice,stock.todayLowestPrice,stock.amplitude,stock.price,stock.like];
        if (!isSuccess) {
            NSLog(@"更新数据失败,更新语句是:%@",sqlStr);
            return NO;
        } else {
            NSLog(@"更新数据成功");
            return YES;
        }
    }
}

//filed 字段 format 格式
- (NSArray *)sortWithSortFormat:(NSString *)ascOrDesc withSortDBField:(NSString *)DBFiled {
    if (!DBFiled) {
        NSLog(@"排序出错了,排序字段为nil");
        return nil;
    }
    NSString *sqlStr = [NSString stringWithFormat:@"select * from %@ order by %@ %@",kStock,DBFiled,ascOrDesc];
    FMResultSet *result = [self.dataBase executeQuery:sqlStr];
    if (!result) {
        NSLog(@"%@字段排序出错,排序语句是:%@",DBFiled,sqlStr);
        return nil;
    } else {
        NSMutableArray  *tempArray = [NSMutableArray array];
        while ([result next]) {
            Stock *stock1 = [Stock new];
            [tempArray addObject:[self resultQuery:result WithStock:stock1]];
        }
        return tempArray;
    }
    return nil;
}

- (Stock *)resultQuery:(FMResultSet*)result WithStock:(Stock *)stock{
    stock.stockName = [result stringForColumn:@"stockName"];
    stock.stockHouse = [result stringForColumn:@"stockHouse"];
    stock.stockCode = [result stringForColumn:@"stockCode"];
    stock.todayPrice = @([result doubleForColumn:@"todayPrice"]);
    stock.todayHighestPrice = @([result doubleForColumn:@"todayHighestPrice"]);
    stock.todayLowestPrice = @([result doubleForColumn:@"todayLowestPrice"]);
    stock.yesterDayPrice = @([result doubleForColumn:@"yesterDayPrice"]);
    stock.currentPrice = @([result doubleForColumn:@"currentPrice"]);
    stock.amplitude = @([result doubleForColumn:@"amplitude"]);
    stock.price = @([result doubleForColumn:@"price"]);
    stock.like = @([result boolForColumn:@"collect"]);
    return stock;
}

@end
