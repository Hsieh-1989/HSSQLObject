//
//  HSArraySQLValue.m
//  HSSQLObject
//
//  Created by Hsieh on 2018/4/9.
//  Copyright © 2018年 Hsieh. All rights reserved.
//

#import "HSArraySQLValue.h"

@interface HSArraySQLValue ()

@property (nonatomic, strong) ArrayOfSQLValue value;

@end

@implementation HSArraySQLValue

+ (instancetype)sqlValueOfArray:(ArrayOfSQLValue)array {
    return [[self alloc] initWithSQLValueArray:array];
}

- (instancetype)initWithSQLValueArray:(ArrayOfSQLValue)array {
    self = [super init];
    if (self) {
        _value = array;
    }
    return self;
}

- (NSString *)SQLValueString {
    NSArray<NSString *> *valueStrings = [_value valueForKeyPath:@"SQLValueString"];
    return [NSString stringWithFormat:@"(%@)", [valueStrings componentsJoinedByString:@","]];
}

@end
