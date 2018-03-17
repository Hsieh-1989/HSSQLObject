//
//  HSSQLColumnWithOperator.h
//  HSSQLObject
//
//  Created by Hsieh on 2018/3/17.
//  Copyright © 2018年 Hsieh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HSSQLColumnWithOperatorProtocol.h"
#import "HSSQLConstant.h"

@interface HSSQLColumnWithOperator : NSObject <NSCopying, HSSQLColumnWithOperatorProtocol>

NS_ASSUME_NONNULL_BEGIN

- (instancetype)initWithColumn:(NSString *)column operator:(HSSQLConditionOperator)conditionOperator;
+ (HSSQLColumnWithOperator *)column:(NSString *)column operator:(HSSQLConditionOperator)conditionOperator;

NS_ASSUME_NONNULL_END

@end
