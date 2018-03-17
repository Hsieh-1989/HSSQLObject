//
//  HSSQLColumnWithTable.m
//  HSSQLObject
//
//  Created by Hsieh on 2018/3/17.
//  Copyright © 2018年 Hsieh. All rights reserved.
//

#import "HSSQLColumnWithTable.h"
#import "NSString+SQLHelper.h"

@interface HSSQLColumnWithTable()

#pragma mark - Private Property
@property (nonatomic, strong) NSString *value;

@end

@implementation HSSQLColumnWithTable

#pragma mark - Initializer
- (instancetype)initWithTable:(NSString *)tableName column:(NSString *)column {
    self = [super init];
    if (self) {
        _value = [tableName tableNameBindColumnNamed:column];
    }
    return self;
}

#pragma mark - Public Method
+ (HSSQLColumnWithTable *)table:(NSString *)tableName column:(NSString *)column {
    return [[HSSQLColumnWithTable alloc] initWithTable:tableName column:column];
}

+ (NSArray<NSString *> *)columns:(NSArray<NSString *> *)columns prefixTable:(NSString *)tableName {
    NSMutableArray<NSString *> *result = [NSMutableArray array];
    [columns enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [result addObject:[tableName tableNameBindColumnNamed:obj]];
    }];
    return [result copy];
}

#pragma mark - SQLValue
- (NSString *)SQLValueString {
    return _value;
}

#pragma mark - SQLColumnWithOperator
- (nonnull NSString *)column {
    return [_value column];
}

- (nonnull NSString *)generateKey {
    return [_value generateKey];
}

- (nonnull NSString *)operatorAcoordingValue:(nullable NSObject<HSSQLValueProtocol> *)sqlValue
                             defaultOperator:(nullable NSString *)defaultOperator {
    return [_value operatorAcoordingValue:sqlValue defaultOperator:defaultOperator];
}

@end

