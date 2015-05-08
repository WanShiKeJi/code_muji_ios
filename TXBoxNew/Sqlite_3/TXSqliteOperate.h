//
//  TXSqliteOperate.h
//  TXBox
//
//  Created by Naron on 15/3/30.
//  Copyright (c) 2015年 com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXData.h"
#import <sqlite3.h>
#import "Common.h"
//#import "/usr/include/sqlite3.h"

@interface TXSqliteOperate : NSObject

{
    NSFileManager *fileManager;
    sqlite3 *dataBase;
    sqlite3_stmt *stmt;
    char *msg;
    NSMutableArray *mutArray;//所有信息
    NSMutableArray *array;  //单条记录信息
}
-(BOOL)openDatabase;    //打开数据库
-(void)createTable:(NSString *)tableName;     //创建表
-(void)addInfo:(TXData *)tel into:(NSString *)table;//添加
-(NSMutableArray *)searchInfoFrom:(NSString *)table;//查找所有记录
-(NSMutableArray *)searchARecordWithName:(NSString *)name fromTable:(NSString *)table;//查找其中一条记录
-(void)deleteContacterWithNumber:(NSString *)hisNumber formTable:(NSString *)table;//删除
@end
