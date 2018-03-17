//
//  HSSQLColumnWithOperator.m
//  HSSQLObject
//
//  Created by Hsieh on 2018/3/17.
//  Copyright © 2018年 Hsieh. All rights reserved.
//

#import "HSSQLColumnWithOperator.h"
#import "NSString+SQLHelper.h"

@interface HSSQLColumnWithOperator()

#pragma mark - Private Property
@property (nonatomic, strong) NSString *column;
@property (nonatomic, strong) HSSQLConditionOperator operator;

@end

@implementation HSSQLColumnWithOperator

#pragma mark - Initializer
+ (HSSQLColumnWithOperator *)column:(NSString *)column operator:(HSSQLConditionOperator)conditionOperator {
    return [[HSSQLColumnWithOperator alloc] initWithColumn:column operator:conditionOperator];
}

- (instancetype)initWithColumn:(NSString *)column operator:(HSSQLConditionOperator)conditionOperator {
    self = [super init];
    if (self) {
        _column = [[column escapingSingleQuote] trimWhiteSpace];
        _operator = conditionOperator;
    }
    return self;
}

#pragma mark - NSCopying
- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return [[[self class] allocWithZone:zone] initWithColumn:_column operator:_operator];
}

#pragma mark - SQLColumnWithOperatorProtocol
- (nonnull NSString *)column {
    return _column;
}

- (nonnull NSString *)generateKey {
    return [NSString stringWithFormat:@"%@ %@", _column, _operator];
}


- (nonnull NSString *)operatorAcoordingValue:(nullable NSObject<HSSQLValueProtocol> *)sqlValue defaultOperator:(nullable NSString *)defaultOperator {
    return _operator;
}

@end
