//
//  HSSQLObject.h
//  HSSQLObject
//
//  Created by Hsieh on 2018/3/17.
//  Copyright © 2018年 Hsieh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HSSQLValueProtocol.h"
#import "HSSQLColumnWithOperatorProtocol.h"
#import "HSSQLConstant.h"

#pragma mark - Type Definition
typedef NS_ENUM(NSUInteger, HSQueryType) {
    SELECT,
    INSERT,
    UPDATE,
    DELETE,
};

typedef NS_ENUM(NSUInteger, HSJoinType) {
    LEFT,
    INNER
};

typedef NSDictionary<NSString *, NSObject<HSSQLValueProtocol> *> HSSQLSetValueDictionary;
typedef NSDictionary<NSObject<HSSQLColumnWithOperatorProtocol> *, NSObject<HSSQLValueProtocol> *> HSSQLConditionDictionary;
typedef NSDictionary<NSString *, HSQueryOrder> HSSQLOrderDictionary;
typedef NSArray<HSSQLConditionDictionary *> HSSQLConditionArray;

@interface HSSQLObject : NSObject

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Initilizar
- (instancetype)initWith:(HSQueryType)type tableName:(NSString *)table;

#pragma mark - Query Setting
- (void)select:(NSArray<NSString *> *)columns;
- (void)insert:(NSArray<HSSQLSetValueDictionary *> *)values;
- (void)update:(NSString *)column value:(NSObject<HSSQLValueProtocol> *)value;
- (void)update:(HSSQLSetValueDictionary *)updateDictionary;
- (void)where:(HSSQLConditionDictionary *)condition;
- (void)join:(NSString *)table on:(NSArray<HSSQLConditionDictionary *> *)conditions type:(HSJoinType)type;
- (void)orderBy:(NSString *)column ascending:(BOOL)ascending;
- (void)queryLimit:(NSUInteger)limit;

#pragma mark - Generate SQL
- (nullable NSString *)generateQuery;

NS_ASSUME_NONNULL_END

@end
