//
//  NSString+SQLHelper.h
//  HSSQLObject
//
//  Created by Hsieh on 2018/3/17.
//  Copyright © 2018年 Hsieh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HSSQLConstant.h"

@interface NSString (SQLHelper)

- (NSString *)escapingSingleQuote;
- (NSString *)trimWhiteSpace;
- (NSString *)tableNameBindColumnNamed:(NSString *)column;
- (NSString *)bindOperator:(HSSQLConditionOperator)sqlOperator;

@end
