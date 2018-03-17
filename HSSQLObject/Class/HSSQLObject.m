//
//  HSSQLObject.m
//  HSSQLObject
//
//  Created by Hsieh on 2018/3/17.
//  Copyright © 2018年 Hsieh. All rights reserved.
//

#import "HSSQLObject.h"
#import "NSString+SQLHelper.h"

#pragma mark - Private Type Definition
typedef NSString * (^SQLConvert)(NSObject<HSSQLColumnWithOperatorProtocol> *key, NSObject<HSSQLValueProtocol> *obj);
typedef NSDictionary<NSString *, HSQueryOrder> HSOrderInfo;
typedef NSObject<HSSQLColumnWithOperatorProtocol> HSSQLConditionKey;
typedef NSMutableDictionary<NSString *, NSObject<HSSQLValueProtocol> *> HSMutableSQLSetValueDictionary;


#pragma mark - Convinent Helper
static inline BOOL isEmpty(id obj) {
    return obj == nil
    || ([obj respondsToSelector:@selector(length)] && [obj length] == 0)
    || ([obj respondsToSelector:@selector(count)] && [obj count] == 0);
}

#pragma mark - Private Helper - Catergory
@interface NSString (JoinType)
+ (NSString *)joinTypeString:(HSJoinType)type;
@end

#pragma mark - Private - Property
@interface HSSQLObject()

@property (nonatomic, assign) HSQueryType type;
@property (nonatomic, strong) NSString *table;
@property (nonatomic, strong) NSMutableArray<NSString *> *columns;
@property (nonatomic, strong) NSMutableArray<HSSQLSetValueDictionary *> *insertValues;
@property (nonatomic, strong) HSMutableSQLSetValueDictionary *updateConfig;
@property (nonatomic, strong) NSMutableArray<HSSQLConditionDictionary *> *whereConstraint;
@property (nonatomic, strong) NSMutableDictionary<HSSQLConditionKey *, HSSQLConditionArray *> *joinConfig;
@property (nonatomic, strong) NSMutableArray<HSOrderInfo *> *order;
@property (nonatomic, strong) NSNumber *limit;

@end

@implementation HSSQLObject
#pragma mark - Initializer
- (instancetype)initWith:(HSQueryType)type
               tableName:(nonnull NSString *)table {
    self = [super init];
    if (self) {
        self.type = type;
        self.table = [table escapingSingleQuote];
    }
    return self;
}

#pragma mark - Main Implementation
- (NSString *)generateQuery {
    NSString *result;
    switch (self.type) {
        case SELECT:
            result = [self selectQuery];
            break;
        case INSERT:
            result = [self insertQuery];
            break;
        case UPDATE:
            result = [self updateQuery];
            break;
        case DELETE:
            result = [self deleteQuery];
            break;
    }
    return [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

#pragma mark - Query Setting
- (void)select:(NSArray<NSString *> *)columns {
    if (self.columns == nil) {
        self.columns = [NSMutableArray arrayWithArray:columns];
    } else {
        [self.columns addObjectsFromArray:[columns valueForKeyPath:@"escapingSingleQuote"]];
    }
}

- (void)insert:(nonnull NSArray<HSSQLSetValueDictionary *> *)values {
    if (self.insertValues == nil) {
        self.insertValues = [NSMutableArray arrayWithArray:values];
    } else {
        [self.insertValues addObjectsFromArray:values];
    }
}

- (void)update:(nonnull NSString *)column value:(nonnull NSObject<HSSQLValueProtocol> *)value {
    if (self.updateConfig == nil) {
        self.updateConfig = [NSMutableDictionary dictionary];
    }
    self.updateConfig[column] = value;
}

- (void)update:(HSSQLSetValueDictionary *)updateDictionary {
    if (self.updateConfig == nil) {
        self.updateConfig = [NSMutableDictionary dictionary];
    }
    [self.updateConfig addEntriesFromDictionary:updateDictionary];
}

- (void)where:(HSSQLConditionDictionary *)condition {
    if (self.whereConstraint == nil) {
        self.whereConstraint = [NSMutableArray array];
    }
    [self.whereConstraint addObject:condition];
}

- (void)join:(nonnull NSString *)table on:(nonnull HSSQLConditionArray *)conditions type:(HSJoinType)type {
    if (self.joinConfig == nil) {
        self.joinConfig = [NSMutableDictionary dictionary];
    }
    NSString *joinTypeString = [NSString joinTypeString:type];
    NSString *key = [NSString stringWithFormat:@"%@ %@", table, joinTypeString];
    self.joinConfig[key] = conditions;
}

- (void)orderBy:(NSString *)column ascending:(BOOL)ascending {
    HSQueryOrder order = ascending ? HSQueryOrderASC : HSQueryOrderDESC;
    HSOrderInfo *info = @{column: order};
    if (self.order == nil) {
        self.order = [NSMutableArray arrayWithObject:info];
    } else {
        [self.order addObject:info];
    }
}

- (void)queryLimit:(NSUInteger)limit {
    self.limit = @(limit);
}

#pragma mark - Private - Main CRUD function
- (NSString *)selectQuery {
    NSMutableArray<NSString *> *queryArray = [NSMutableArray array];
    // SELECT
    NSString *parametersString = [self.columns componentsJoinedByString:@","];;
    [queryArray addObject:[NSString stringWithFormat:@"SELECT %@", parametersString]];
    
    // FROM
    [queryArray addObject:[NSString stringWithFormat:@"FROM %@", self.table]];
    
    // JOIN
    if (!isEmpty(self.joinConfig)) {
        NSString *joinClause = [self convertJoinClauseFrom:self.joinConfig];
        [queryArray addObject:joinClause];
    }
    
    // WHERE
    if (!isEmpty(self.whereConstraint)) {
        NSString *whereClause = [self convertWhereClauseFrom:self.whereConstraint];
        [queryArray addObject:whereClause];
    }
    
    // ORDER
    if (!isEmpty(self.order)) {
        NSString *orderClause = [self convertOrderClauseFrom:self.order];
        [queryArray addObject:orderClause];
    }
    
    // Limit
    if (self.limit != nil && [self.limit integerValue] > 0) {
        [queryArray addObject:[NSString stringWithFormat:@"LIMIT %@", self.limit]];
    }
    
    return [queryArray componentsJoinedByString:@" "];
}

- (NSString *)insertQuery {
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO %@", self.table];
    NSString *vaulesSql = [self convertValuesClauseFrom:self.insertValues];
    return [NSString stringWithFormat:@"%@ %@", insertSql, vaulesSql];
}

- (NSString *)updateQuery {
    NSString *updateSql = [NSString stringWithFormat:@"UPDATE %@", self.table];
    NSString *setClause = [NSString stringWithFormat:@"SET %@", [self convertSetClauseFrom:self.updateConfig]];
    NSString *whereClause = isEmpty(self.whereConstraint) ? @"" : [self convertWhereClauseFrom:self.whereConstraint];
    return [NSString stringWithFormat:@"%@ %@ %@", updateSql, setClause, whereClause];
}

- (NSString *)deleteQuery {
    NSString *whereClause = self.whereConstraint == nil ? @"" : [self convertWhereClauseFrom:self.whereConstraint];
    return [NSString stringWithFormat:@"DELETE FROM %@ %@", self.table, whereClause];
}

#pragma mark - Private - SQL String Convert Functions
- (NSString *)convertValuesClauseFrom:(NSArray<HSSQLSetValueDictionary * > *)dicArray {
    if (isEmpty(dicArray)) {
        return @"";
    }
    
    NSMutableArray<NSString *> *clause = [NSMutableArray array];
    NSArray<NSString *> *columns = [dicArray[0] allKeys];
    for (HSSQLSetValueDictionary *setCondition in dicArray) {
        NSMutableArray<NSString *> *currentValue = [NSMutableArray array];
        for (NSInteger i = 0; i < columns.count; i++) {
            NSString *column = columns[i];
            NSObject<HSSQLValueProtocol> *value = setCondition[column];
            [currentValue addObject:[value SQLValueString]];
        }
        [clause addObject:[currentValue componentsJoinedByString:@","]];
    }
    NSString *columnString = [NSString stringWithFormat:@"(%@)", [columns componentsJoinedByString:@","]];
    NSString *values = [NSString stringWithFormat:@"(%@)", [clause componentsJoinedByString:@"),("]];
    return [NSString stringWithFormat:@"%@ VALUES %@",columnString, values];
}

- (NSString *)convertSetClauseFrom:(HSSQLSetValueDictionary *)parametersDic {
    return [self convertParameters:parametersDic seperator:@"," convert:^NSString *(NSObject<HSSQLColumnWithOperatorProtocol> *key, NSObject<HSSQLValueProtocol> *obj) {
        NSString *operator = [key operatorAcoordingValue:obj defaultOperator:@"="];
        NSLog(@"%@ %@ %@", key.column, operator, obj.SQLValueString);
        return [NSString stringWithFormat:@"%@ %@ %@", key.column, operator, obj.SQLValueString];
    }];
}
- (NSString *)convertJoinClauseFrom:(NSMutableDictionary<HSSQLConditionKey *,HSSQLConditionArray *> *)joinConfig {
    NSMutableArray<NSString *> *clause = [NSMutableArray array];
    NSString *seperator = @"AND";
    [joinConfig enumerateKeysAndObjectsUsingBlock:^(HSSQLConditionKey * _Nonnull tableWithJoinType, HSSQLConditionArray * _Nonnull conditionArray, BOOL * _Nonnull stop) {
        NSMutableArray<NSString *> *currentJoinClause = [NSMutableArray array];
        for (NSInteger i = 0; i < [conditionArray count]; i++) {
            NSString *currentClause = [self convertParameters:conditionArray[i] seperator:seperator convert:^NSString *(NSObject<HSSQLColumnWithOperatorProtocol> *key, NSObject<HSSQLValueProtocol> *obj) {
                NSString *operator = [key operatorAcoordingValue:obj defaultOperator:@"="];
                return [NSString stringWithFormat:@"%@ %@ %@", key.column, operator, obj.SQLValueString];
            }];
            NSString *format = i == 0 ? @"ON (%@)" : @"OR (%@)";
            [currentJoinClause addObject:[NSString stringWithFormat:format, currentClause]];
        }
        NSString *joinType = [tableWithJoinType operatorAcoordingValue:nil defaultOperator:nil];
        NSString *joinCondition = [currentJoinClause componentsJoinedByString:@" "];
        NSString *currentJoinString = [NSString stringWithFormat:@"%@ JOIN %@ %@", joinType, tableWithJoinType.column, joinCondition];
        [clause addObject:currentJoinString];
    }];
    return [clause componentsJoinedByString:@" "];
}

- (NSString *)convertWhereClauseFrom:(NSArray<HSSQLConditionDictionary *> *)dicArray {
    NSMutableArray<NSString *> *clause = [NSMutableArray array];
    NSString *seperator = @"AND";
    for (NSInteger i = 0; i < [dicArray count]; i++) {
        NSString *currentClause = [self convertParameters:dicArray[i] seperator:seperator convert:^NSString *(NSObject<HSSQLColumnWithOperatorProtocol> *key, NSObject<HSSQLValueProtocol> *obj) {
            NSString *operator = [key operatorAcoordingValue:obj defaultOperator:@"="];
            return [NSString stringWithFormat:@"%@ %@ %@", key.column, operator, obj.SQLValueString];
        }];
        NSString *format = i == 0 ? @"WHERE (%@)" : @"OR (%@)";
        [clause addObject:[NSString stringWithFormat:format, currentClause]];
    }
    return [clause componentsJoinedByString:@" "];
}

- (NSString *)convertOrderClauseFrom:(NSArray<HSOrderInfo *> *)orderInfos {
    NSMutableArray<NSString *> *clause = [NSMutableArray array];
    NSString *seperator = @",";
    for (NSInteger i = 0; i < [orderInfos count]; i++) {
        NSString *currentClause = [self convertParameters:orderInfos[i] seperator:seperator convert:^NSString *(NSObject<HSSQLColumnWithOperatorProtocol> *key, NSObject<HSSQLValueProtocol> *obj) {
            return [NSString stringWithFormat:@"%@ %@", key, obj];
        }];
        [clause addObject:currentClause];
    }
    
    return [NSString stringWithFormat:@"ORDER BY %@", [clause componentsJoinedByString:@","]];
}

#pragma mark - Private - Helper
- (NSString *)convertParameters:(HSSQLConditionDictionary *)parametersDic
                      seperator:(NSString *)seperator
                        convert:(SQLConvert)convert {
    NSMutableArray<NSString *> *clause = [NSMutableArray array];
    [parametersDic enumerateKeysAndObjectsUsingBlock:^(NSObject<HSSQLColumnWithOperatorProtocol> * _Nonnull key, NSObject<HSSQLValueProtocol> * _Nonnull obj, BOOL * _Nonnull stop) {
        [clause addObject:convert(key, obj)];
    }];
    return [clause componentsJoinedByString:[NSString stringWithFormat:@" %@ ", seperator]];
}

- (NSArray<NSString *> *)excapingSingleQuoteFromArray:(NSArray<NSString *> *)origionalArray {
    // = [origionalArray valueForKeyPath:@"escapingSingleQuote"];
    NSMutableArray *result = [NSMutableArray array];
    [origionalArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *escsped = [obj escapingSingleQuote];
        [result addObject:escsped];
    }];
    return [result copy];
}

@end


#pragma mark - Private Helper - Catergory
@implementation NSString (JoinType)

+ (NSString *)joinTypeString:(HSJoinType)type {
    switch (type) {
        case LEFT:
            return @"LEFT";
        case INNER:
            return @"INNER";
    }
}

@end
