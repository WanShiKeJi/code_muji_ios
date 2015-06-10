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
    NSFileManager *fileManager; //文件管理器
    sqlite3 *dataBase;
    sqlite3_stmt *stmt;
    char *msg;
}

//============共用===============
/**
 *  @method     打开数据库
 *  @return     BOOL 1成功，0失败
 */
-(BOOL)openDatabase;

/**
 *  @method 创建表
 *  @pragma table       表名
 *  @pragma sql         sql执行语句
 */
-(void)createTable:(NSString *)tableName withSql:(NSString *)sqlSring;


/**
 *  @method 向某table中添加数据
 *  @pragma table       表名
 *  @pragma Sql  数据库执行语句
 *  @discuss  根据表名
 */
-(void)addInfo:(TXData *)tel inTable:(NSString *)table withSql:(NSString *)sqlSring; ;//添加


/**
 *  @method 查询某一张表的所有记录
 *  @pragma table       表名
 *  @discuss  根据表名不同查找的结果不同
 *  @return 返回一个NSMutableArray
 */
-(NSMutableArray *)searchInfoFromTable:(NSString *)table ;//查找记录


/**
 *  @method  实现删除，一条通话记录，或单条短信记录或整个短信会话
 *  @pragma Number 对方号码
 *  @pragma table  数据库里的表
 *  @pragma peopleId ID
 *  @pragma Sql  数据库执行语句
 *  @discuss   根据sql语句进行不同的操作
 */
-(void)deleteContacterWithNumber:(NSString *)hisNumber formTable:(NSString *)table peopleId:(NSString *)pId withSql:(NSString *)sqlSring;


/**
 *  @method  实现删除一张数据表
 *  @pragma Name 表名
 */
-(void)deleteTableWithName:(NSString *)table;//删除整张表


/**
 *  @method 查询某一次整个会话
 *  @pragma hisNumber   对方号码
 *  @pragma table       表名
 *  @pragma sql         sql语句
 *  @return NSMutableArray  元素类型TXData
 */
-(NSMutableArray *)searchARecordWithNumber:(NSString *)hisNumber fromTable:(NSString *)table withSql:(NSString *)sqlString;


/**
 *  @method 查询某一次会话的最后一条
 *  @pragma hisNumber   对方号码
 *  @pragma table       表名
 *  @pragma sql         sql语句
 *  @return 返回一条TXData记录
 */
-(TXData *)searchConversationFromtable:(NSString *)table hisNumber:(NSString *)number wihtSqlString:(NSString *)sqlString;


/**
 *  @method 查询所有与输入匹配的短信内容
 *  @pragma InputText   输入的内容
 *  @pragma table       表名
 *  @pragma sql         sql语句
 *  @return NSMutableArray  元素类型TXData
 */
-(NSMutableArray *)searchContentWithInputText:(NSString *)text fromTable:(NSString *)table withSql:(NSString *)sqlString;


//=====================================//
//          号码归属地查询               //
//=====================================//

/**
 *  @method     打开号码归属地db
 *  @return     1 为打开成功， 0 打开失败
 */
-(BOOL)openPhoneArearDatabase;


/**
 *  @method 查询号码归属地
 *  @pragma hisNumber   对方号码前7位
 *  @return 返回一条NSString的归属地
 */
-(NSString *)searchAreaWithHisNumber:(NSString *)hisNumber;


@end
