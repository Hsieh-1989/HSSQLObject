//
//  HSSQLConstant.h
//  HSSQLObject
//
//  Created by Hsieh on 2018/3/17.
//  Copyright © 2018年 Hsieh. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Operator Enum
typedef NSString * HSSQLConditionOperator NS_TYPED_ENUM;
extern HSSQLConditionOperator const HSConditionEqual;
extern HSSQLConditionOperator const HSConditionNotEqual;
extern HSSQLConditionOperator const HSConditionNULL;
extern HSSQLConditionOperator const HSConditionNotNull;
extern HSSQLConditionOperator const HSConditionLike;

#pragma mark - QueryOrder Enum
typedef NSString * HSQueryOrder NS_TYPED_ENUM;
extern HSQueryOrder const HSQueryOrderASC;
extern HSQueryOrder const HSQueryOrderDESC;
