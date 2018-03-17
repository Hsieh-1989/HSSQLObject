//
//  HSSQLConstant.m
//  HSSQLObject
//
//  Created by Hsieh on 2018/3/17.
//  Copyright © 2018年 Hsieh. All rights reserved.
//

#import "HSSQLConstant.h"

#pragma mark - Constant - Operator Enum
HSSQLConditionOperator const HSConditionEqual = @"=";
HSSQLConditionOperator const HSConditionNotEqual = @"!=";
HSSQLConditionOperator const HSConditionNULL = @"IS";
HSSQLConditionOperator const HSConditionNotNull = @"IS NOT";
HSSQLConditionOperator const HSConditionLike = @"LIKE";

#pragma mark - QueryOrder Enum
HSQueryOrder const HSQueryOrderASC = @"ASC";
HSQueryOrder const HSQueryOrderDESC = @"DESC";
