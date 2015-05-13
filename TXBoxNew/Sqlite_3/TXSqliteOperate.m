//
//  TXSqliteOperate.m
//  TXBox
//
//  Created by Naron on 15/3/30.
//  Copyright (c) 2015年 com. All rights reserved.
//

#import "TXSqliteOperate.h"

@implementation TXSqliteOperate




#pragma mark --打开数据库
-(BOOL)openDatabase
{
    //文件的路径
    NSString *path=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",DB_NAME]];
    
    VCLog(@"sqlite3_path:%@",path);
    //若数据库存在就打开，不存在就创建，
    //[path UTF8String]把字符串转成char。。。SQLITE_OK常量0
    if (sqlite3_open([path UTF8String], &dataBase)==SQLITE_OK) {
        //NSLog(@"is open");
        return YES;
    }
    
    return NO;
}
#pragma mark --建表
-(void)createTable:(NSString *)tableName
{
    if ([self openDatabase]) {
        //sql语句AUTOINCREMENT
        NSString *sql = [NSString stringWithFormat:@"create table if not exists %@(tel_id integer primary key AUTOINCREMENT,hisName text,hisNumber text,callDirection text,callLength text,callBeginTime text,hisHome text,hisOperator text)",tableName];
        
        //执行sql语句
        if (sqlite3_exec(dataBase, [sql UTF8String], NULL, NULL, &msg)==SQLITE_OK) {
            VCLog(@"create table success !");
        }else{
            VCLog(@"create table error:%s",msg);
            //清空错误信息
            sqlite3_free(msg);
        }

    }else {
        VCLog(@"sqlite ...");
    }
    
    //关闭数据库
    sqlite3_close(dataBase);
    
}

#pragma mark --插入(添加)数据
-(void)addInfo:(TXData *)data into:(NSString *)table
{
    if ([self openDatabase]) {
        
        //NSString *insertSql = [NSString stringWithFormat:@"insert into tels(tel_number) values(?)"];
        NSString *insertSql = [NSString stringWithFormat:@"insert into %@(hisName ,hisNumber ,callDirection ,callLength,callBeginTime ,hisHome ,hisOperator ) values(?,?,?,?,?,?,?)",table];
        
        if (sqlite3_prepare_v2(dataBase, [insertSql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
            VCLog(@"insert prepare ok");
        }else{
            VCLog(@"insert prepare error:%s",msg);
            //清空错误信息
            sqlite3_free(msg);
        }
        //sqlite3_bind_int(stmt,1, data.tel_id);
        sqlite3_bind_text(stmt, 1, [data.hisName UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [data.hisNumber UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 3, [data.callDirection UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 4, [data.callLength UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 5, [data.callBeginTime UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 6, [data.hisHome UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 7, [data.hisOperator UTF8String], -1, NULL);
        
        if (sqlite3_step(stmt) == SQLITE_DONE) {
            //清空错误信息
            sqlite3_free(msg);
            VCLog(@"insert success");
            
        }else
        {
            VCLog(@"insert msg:%s",msg);
        }
        
        sqlite3_reset(stmt);
        //关闭
        sqlite3_close(dataBase);
    }else{
        VCLog(@"sqlite ...");
    }
    
    
    
}

#pragma mark --查询所有

-(NSMutableArray *)searchInfoFrom:(NSString *)table
{
    mutArray=[[NSMutableArray alloc] init];
    
    if ([self openDatabase]) {
        
        NSString *selectSql = [NSString stringWithFormat:@"select *from %@",table];
        
        if (sqlite3_prepare_v2(dataBase, [selectSql UTF8String], -1, &stmt, nil)==SQLITE_OK) {
            VCLog(@"select prepare ok!");
        }
        //循环遍历，sqlite3_step处理一行结果
        while (sqlite3_step(stmt)==SQLITE_ROW) {
            
            int tid=sqlite3_column_int(stmt, 0);
            
            NSString *name = [NSString stringWithCString:(char *)sqlite3_column_text(stmt, 1) encoding:NSUTF8StringEncoding];
            NSString *number=[NSString stringWithCString:(char *)sqlite3_column_text(stmt, 2) encoding:NSUTF8StringEncoding];
            NSString *direction=[NSString stringWithCString:(char *)sqlite3_column_text(stmt, 3) encoding:NSUTF8StringEncoding];
            NSString *length=[NSString stringWithCString:(char *)sqlite3_column_text(stmt, 4) encoding:NSUTF8StringEncoding];
            NSString *beginTime=[NSString stringWithCString:(char *)sqlite3_column_text(stmt, 5) encoding:NSUTF8StringEncoding];
            NSString *home=[NSString stringWithCString:(char *)sqlite3_column_text(stmt, 6) encoding:NSUTF8StringEncoding];
            NSString *operator=[NSString stringWithCString:(char *)sqlite3_column_text(stmt, 7) encoding:NSUTF8StringEncoding];
            
            //VCLog(@"id = %d,date = %@",tid,date);
            
            TXData *data=[[TXData alloc] init];
            data.tel_id = tid;
            data.hisName=name;
            data.hisNumber=number;
            data.callDirection=direction;
            data.callLength = length;
            data.callBeginTime=beginTime;
            data.hisHome = home;
            data.hisOperator = operator;
            
            /*
            [mutArray addObject:[NSString stringWithFormat:@"%d",tid]];
            [mutArray addObject:number];
            [mutArray addObject:date];
            [mutArray addObject:operators];
            [mutArray addObject:address];
            [mutArray addObject:name];
            */
            
            [mutArray addObject:data];//
            
            
        }
        //删除预备语句
        sqlite3_finalize(stmt);
        //关闭
        sqlite3_close(dataBase);
        
        VCLog(@" mutArr=%@",mutArray);
        return mutArray;
    }
    
    
    return nil;
}

#pragma mark -- 查询，某一条记录
-(NSMutableArray *)searchARecordWithName:(NSString *)hisName fromTable:(NSString *)table
{
    array = [[NSMutableArray alloc] init];
    
    if ([self openDatabase]) {
        
        
        NSString *selectSql = [NSString stringWithFormat:@"select from %@ where hisName=%@",table,hisName];
        
        if (sqlite3_prepare_v2(dataBase, [selectSql UTF8String], -1, &stmt, nil)==SQLITE_OK) {
            VCLog(@"select prepare ok!");
        }
        
        //未完
        
        
        
        
        
        
    }

    return array;
}


#pragma mark --删除-->根据联系人号码
-(void)deleteContacterWithNumber:(NSString *)hisNumber formTable:(NSString *)table
{
    if ([self openDatabase]) {
    
        NSString *deleteSql=[NSString stringWithFormat:@"delete from %@ where hisNumber=%@",table,hisNumber];
        if (sqlite3_exec(dataBase, [deleteSql UTF8String], nil, nil, &msg)==SQLITE_OK) {
            VCLog(@"delete number = %@ ok",hisNumber);
        }else{
            VCLog(@"error:%s",msg);
            sqlite3_free(msg);
        }
        
        sqlite3_close(dataBase);
    }else{
        VCLog(@"sqlite  。。。");
    }
    
}

#pragma mark -- 删除表


@end
