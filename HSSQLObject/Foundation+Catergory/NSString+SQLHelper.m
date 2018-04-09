//
//  NSString+SQLHelper.m
//  HSSQLObject
//
//  Created by Hsieh on 2018/3/17.
//  Copyright © 2018年 Hsieh. All rights reserved.
//

#import "NSString+SQLHelper.h"

@implementation NSString (SQLHelper)

- (NSString *)escapingSingleQuote {
    return [self stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
}

- (NSString *)trimWhiteSpace {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)tableNameBindColumnNamed:(NSString *)column {
    return [[NSString stringWithFormat:@"%@.%@", self, column] escapingSingleQuote];
}

- (NSString *)bindOperator:(HSSQLConditionOperator)sqlOperator {
    return [NSString stringWithFormat:@"%@ %@", self, sqlOperator];
}

@end
