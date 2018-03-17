//
//  HSSQLColumnWithOperatorProtocol.m
//  HSSQLObject
//
//  Created by Hsieh on 2018/3/17.
//  Copyright © 2018年 Hsieh. All rights reserved.
//

#import "HSSQLColumnWithOperatorProtocol.h"
#import "NSString+SQLHelper.h"

#pragma mark - Default SQLColumnWithOperator
@implementation NSString (HSSQLColumnWithOperator)

- (nonnull NSString *)generateKey {
    return [[self escapingSingleQuote] trimWhiteSpace];
}

- (nonnull NSString *)column {
    NSString *trimString = [self generateKey];
    if (![trimString containsString:@" "]) {
        return trimString;
    }
    NSUInteger index = [trimString rangeOfString:@" "].location;
    return [trimString substringToIndex:index];
}


- (nonnull NSString *)operatorAcoordingValue:(nullable NSObject<HSSQLValueProtocol> *)sqlValue defaultOperator:(nullable NSString *)defaultOperator {
    NSString *trimString = [self generateKey];
    if (![trimString containsString:@" "]) {
        if ([sqlValue isKindOfClass:[NSNull class]] && [defaultOperator isEqualToString:@"="]) {
            return @"IS";
        }
        return defaultOperator;
    }
    NSUInteger index = [trimString rangeOfString:@" "].location;
    return [trimString substringFromIndex:index + 1];
}

@end
