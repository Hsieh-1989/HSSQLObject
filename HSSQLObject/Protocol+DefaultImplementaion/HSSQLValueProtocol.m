//
//  HSSQLValueProtocol.m
//  HSSQLObject
//
//  Created by Hsieh on 2018/3/17.
//  Copyright © 2018年 Hsieh. All rights reserved.
//

#import "HSSQLValueProtocol.h"
#import "NSString+SQLHelper.h"

#pragma mark - Default SQLValue

@implementation NSNumber (HSSQLValue)

- (NSString *)SQLValueString {
    return self.stringValue;
}

@end

@implementation NSString (HSSQLValue)

- (NSString *)SQLValueString {
    return [NSString stringWithFormat:@"'%@'", [self escapingSingleQuote]];
}

@end

@implementation NSNull (HSSQLValue)

- (NSString *)SQLValueString {
    return @"NULL";
}

@end
