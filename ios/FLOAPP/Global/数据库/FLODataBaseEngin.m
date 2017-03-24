//
//  FLODataBaseEngin.m
//  XMPPChat
//
//  Created by admin on 15/12/14.
//  Copyright © 2015年 Flolangka. All rights reserved.
//

#import "FLODataBaseEngin.h"
#import <FMDB.h>
#import "FLOBookMarkModel.h"
#import "FLOCollectionItem.h"
#import "FLOWeiboStatusModel.h"

static FLODataBaseEngin *dataBaseEngin;
static NSString *dataBasePath;

@implementation FLODataBaseEngin

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"沙河>>%@", NSHomeDirectory());
        
        dataBaseEngin = [[FLODataBaseEngin alloc] init];
        dataBasePath = [dataBaseEngin databasePath];
        [dataBaseEngin createEditableCopyOfDatabaseIfNeeded];
    });
    return dataBaseEngin;
}

- (void)createEditableCopyOfDatabaseIfNeeded
{
    // 判断 documents 文件夹里面有没有数据库文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL dataBaseExist = [fileManager fileExistsAtPath:dataBasePath];
    if (dataBaseExist) {
        return;
    } else {
        NSLog(@"数据库不存在,需要复制");
    }
    
    NSError *error;
    NSString *defaultDBPath = [[NSBundle mainBundle] pathForResource:@"floapp" ofType:@"db"];
    
    BOOL copySuccess = [fileManager copyItemAtPath:defaultDBPath toPath:dataBasePath error:&error];
    if (!copySuccess) {
        NSLog(@"复制数据库失败 >> '%@'.", [error localizedDescription]);
    }
    
    return;
}

- (NSString *)databasePath
{
    NSString *documentsDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"floapp.db"];
    return writableDBPath;
}

/**
 *  获取表字段
 *
 *  @param table 表名
 *
 *  @return 表字段集合
 */
- (NSArray *)columnOfTable:(NSString *)table
{
    NSMutableArray *columnArray = [NSMutableArray array];
    
    FMDatabase *db = [FMDatabase databaseWithPath:dataBasePath];
    [db open];
    
    // 将表名转换为小写
    NSString *tableName = [table lowercaseString];
    
    // 查询表中所有字段名称
    FMResultSet *result = [db getTableSchema:tableName];
    while ([result next]) {
        [columnArray addObject:[result stringForColumn:@"name"]];
    }
    
    [db close];
    return columnArray;
}

/**
 *  组合插入的SQL语句
 *
 *  @param table    操作的表名
 *  @param valueDic 插入数据键值对
 *
 *  @return sql语句
 */
- (NSString *)createInsertSql4Table:(NSString *)table valueDict:(NSDictionary *)valueDic
{
    NSArray *allKeys = [valueDic allKeys];
    
    // 构造 column
    NSString *columnString = [allKeys componentsJoinedByString:@", "];
    // 构造key
    NSString *keyString = [allKeys componentsJoinedByString:@", :"];
    keyString = [@":" stringByAppendingString:keyString];
    
    NSString *sql = [NSString stringWithFormat:@"insert into %@(%@) values(%@)", table, columnString, keyString];
    
    return sql;
}

/**
 *  查询数据
 *
 *  @param sql         查询语句
 *  @param parseResult 对查询结果进行处理的block块，将每个查询结果封装成对象
 *
 *  @return 对象的集合
 */
- (NSArray *)selectDataWithSQLString:(NSString *)sql parseResult:(NSObject *(^)(FMResultSet *))parseResult
{
    FMDatabase *db = [FMDatabase databaseWithPath:dataBasePath];
    [db open];
    
    FMResultSet *result = [db executeQuery:sql];
    NSMutableArray *mutableArr = [NSMutableArray array];
    while ([result next]) {
        
        [mutableArr addObject:parseResult(result)];
    }
    
    [db close];
    return mutableArr;
}

/**
 *  查询数据组合成字典
 *
 *  @param sql         查询语句
 *  @param parseResult 对每一条数据进行处理
 *
 *  @return 字典
 */
- (NSDictionary *)selectInfoWithSQLString:(NSString *)sql parseResult:(NSDictionary *(^)(FMResultSet *))parseResult
{
    FMDatabase *db = [FMDatabase databaseWithPath:dataBasePath];
    [db open];
    
    FMResultSet *result = [db executeQuery:sql];
    NSMutableDictionary *muDic = [NSMutableDictionary dictionary];
    
    while ([result next]) {
        [muDic setValuesForKeysWithDictionary:parseResult(result)];
    }
    
    [db close];
    return muDic;
}

/**
 *  插入数据
 *
 *  @param table  表名
 *  @param values 需要插入的数据集合，每一个都是一个完整的字典
 */
- (void)insert2Table:(NSString *)table values:(NSArray *)values
{
    NSArray *tableColumn = [self columnOfTable:table];
    
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:dataBasePath];
    [queue inDatabase:^(FMDatabase *db) {
        BOOL success = YES;
        for (NSDictionary *dic in values) {
            
            //过滤字典中无用字段
            NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:dic];
            NSArray *allkey = [dic allKeys];
            for (NSString *key in allkey) {
                if (![tableColumn containsObject:key]) {
                    [muDic removeObjectForKey:key];
                }
            }
            
            NSString *sql = [self createInsertSql4Table:table valueDict:muDic];
            BOOL insertSuccess = [db executeUpdate:sql withParameterDictionary:muDic];
            if (!insertSuccess) {
                success = NO;
                NSLog(@"%@\n插入失败,参数:%@", sql, muDic);
            }
        }
        if (success) {
            NSLog(@"保存数据库成功");
        }
    }];
}

/**
 *  删除数据
 *
 *  @param table 表名
 *  @param datas 待删除数据集合
 */
- (void)deleteFromTable:(NSString *)table datas:(NSArray *)datas
{
    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:dataBasePath];
    [queue inDatabase:^(FMDatabase *db) {
        if ([table isEqualToString:@"CollectionItems"]) {
            //collectionItem
            for (FLOCollectionItem *collectionItem in datas) {
                NSString *sql = [NSString stringWithFormat:@"delete from %@ where ItemName = '%@' and ItemIconURL = '%@' and ItemAddress = '%@'", table, collectionItem.itemName, collectionItem.itemIconURLStr, collectionItem.itemAddress];
                
                BOOL deleteSuccess = [db executeUpdate:sql];
                if (deleteSuccess) {
                    NSLog(@"从数据库删除成功");
                } else {
                    NSLog(@"%@\n删除失败", sql);
                }
            }
            
        } else if ([table isEqualToString:@"BookMarks"]) {
            //书签
            for (FLOBookMarkModel *bookMark in datas) {
                NSString *sql = [NSString stringWithFormat:@"delete from %@ where BookMarkName = '%@' and BookMarkURL = '%@'", table, bookMark.bookMarkName, bookMark.bookMarkURLStr];
                
                BOOL deleteSuccess = [db executeUpdate:sql];
                if (deleteSuccess) {
                    NSLog(@"从数据库删除成功");
                } else {
                    NSLog(@"%@\n删除失败", sql);
                }
            }
        }
    }];
}

//执行sql语句
- (void)executeUpdateSQLStr:(NSString *)sqlStr
{
    FMDatabase *db = [FMDatabase databaseWithPath:dataBasePath];
    [db open];
    
    [db executeUpdate:sqlStr];
    
    [db close];
}


//清除用户的数据(将应用中的数据库替换document中的数据库)
- (void)resetDatabase
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:dataBasePath error:nil];
    
    NSError *error;
    NSString *defaultDBPath = [[NSBundle mainBundle] pathForResource:@"floapp" ofType:@"db"];
    BOOL copySuccess = [fileManager copyItemAtPath:defaultDBPath toPath:dataBasePath error:&error];
    if (!copySuccess) {
        NSLog(@"重置数据库失败 >> '%@'.", [error localizedDescription]);
    }
}

#pragma mark - CollectionItems
//CREATE TABLE CollectionItems(ID integer PRIMARY KEY, ItemName text, ItemIconURL text, ItemAddress text);
- (NSArray *)selectAllCollectionItem
{
    NSString *sql = @"select * from CollectionItems";
    return [self selectDataWithSQLString:sql parseResult:^NSObject *(FMResultSet *rs) {
        FLOCollectionItem *collectionItem = [[FLOCollectionItem alloc] initWithDictionary:[rs resultDictionary]];
        return collectionItem;
    }];
}
- (void)insertCollectionItem:(FLOCollectionItem *)collectionItem
{
    NSArray *insertArr = @[[collectionItem infoDictionary]];
    [self insert2Table:@"CollectionItems" values:insertArr];
}
- (void)deleteCollectionItem:(FLOCollectionItem *)collectionItem
{
    [self deleteFromTable:@"CollectionItems" datas:@[collectionItem]];
}

#pragma mark - 书签
//CREATE TABLE BookMarks(ID integer PRIMARY KEY, BookMarkName text, BookMarkURL text);
- (NSArray *)selectAllBookMark
{
    NSString *sql = @"select * from BookMarks";
    return [self selectDataWithSQLString:sql parseResult:^NSObject *(FMResultSet *rs) {
        FLOBookMarkModel *bookMark = [[FLOBookMarkModel alloc] initWithBookMarkName:[rs stringForColumn:@"BookMarkName"] urlString:[rs stringForColumn:@"BookMarkURL"]];
        return bookMark;        
    }];
}
- (void)insertBookMark:(FLOBookMarkModel *)bookMark
{
    NSMutableDictionary *muDic = [NSMutableDictionary dictionary];
    [muDic setObject:bookMark.bookMarkName forKey:@"BookMarkName"];
    [muDic setObject:bookMark.bookMarkURLStr forKey:@"BookMarkURL"];
    
    NSArray *insertArr = @[muDic];
    [self insert2Table:@"BookMarks" values:insertArr];
}
- (void)deleteBookMark:(FLOBookMarkModel *)bookMark
{
    [self deleteFromTable:@"BookMarks" datas:@[bookMark]];
}

#pragma mark - 微博
//CREATE TABLE WeiboStatus(created_at text,id integer primary key ,mid integer ,idstr text,text text,source text,favorited integer,truncated integer,in_reply_to_status_id text,in_reply_to_user_id text,in_reply_to_screen_name text,thumbnail_pic text,bmiddle_pic text,original_pic text,geo blob,user blob,retweeted_status blob,reposts_count integer,comments_count integer,abttitudes_count integer,mlevel integer,visible string,pic_urls blob);
- (void)clearWeiboData
{
    [self executeUpdateSQLStr:@"delete from WeiboStatus"];
}

- (void)resetWeiboDataWithStatus:(NSArray *)status
{
    [self clearWeiboData];
    
    NSMutableArray *muArr = [NSMutableArray array];
    for (FLOWeiboStatusModel *weibo in status) {
        NSDictionary *dic = [weibo infoDictionary];
        [muArr addObject:dic];
    }
    
    [self insert2Table:@"WeiboStatus" values:muArr];
}

- (NSArray *)selectWeiboStatus
{
    NSString *sql = @"select * from WeiboStatus order by id desc limit 20";
    return [self selectDataWithSQLString:sql parseResult:^NSObject *(FMResultSet *rs) {
        return [self weiboStatusWithResultSet:rs];
    }];
}

- (FLOWeiboStatusModel *)weiboStatusWithResultSet:(FMResultSet *)result
{
    // 将查询结果转为字典并转化为微博对象
    NSDictionary *statusInfo = [result resultDictionary];
    NSMutableDictionary *muStatusInfo = [NSMutableDictionary dictionaryWithDictionary:statusInfo];
    
    // 将data数据转化为对象
    NSArray *allValues = [muStatusInfo allValues];
    for (id object in allValues) {
        if ([object isKindOfClass:[NSData class]]) {
            NSData *data = (NSData *)object;
            NSString *key = [[muStatusInfo allKeysForObject:object] firstObject];
            
            if ([key isEqualToString:@"pic_urls"]) {
                NSArray *picURLs = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                // 给键重新赋值
                [muStatusInfo setObject:picURLs forKey:key];
            } else if ([key isEqualToString:@"user"]){
                NSDictionary *userInfo = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                [muStatusInfo setObject:userInfo forKey:key];
                
            } else if ([key isEqualToString:@"retweeted_status"]){
                NSDictionary *retweetStatus = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                [muStatusInfo setObject:retweetStatus forKey:key];
            }
        }
    }
    
    return [[FLOWeiboStatusModel alloc] initWithDictionary:muStatusInfo];
}

@end
