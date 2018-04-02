//
//  HSCustomSQLValue.m
//  HSSQLObject
//
//  Created by Hsieh on 2018/4/2.
//  Copyright © 2018年 Hsieh. All rights reserved.
//

#import "HSCustomSQLValue.h"

@interface HSCustomSQLValue ()

@property (nonatomic, copy) NSString *value;

@end

@implementation HSCustomSQLValue

+ (instancetype)valueOfSQLString:(NSString *)SQLString {
    return [[self alloc] initWithSQLString:SQLString];
}

- (instancetype)initWithSQLString:(NSString *)SQLString {
    self = [super init];
    if (self) {
        _value = SQLString;
    }
    return self;
}

- (nonnull NSString *)SQLValueString {
    return [NSString stringWithFormat:@"(%@)", _value];
}

@end
