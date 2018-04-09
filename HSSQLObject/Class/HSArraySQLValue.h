//
//  HSArraySQLValue.h
//  HSSQLObject
//
//  Created by Hsieh on 2018/4/9.
//  Copyright © 2018年 Hsieh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HSSQLValueProtocol.h"

typedef NSArray<NSObject<HSSQLValueProtocol> *> * ArrayOfSQLValue;

@interface HSArraySQLValue : NSObject <HSSQLValueProtocol>

+ (instancetype)sqlValueOfArray:(ArrayOfSQLValue)array;
- (instancetype)initWithSQLValueArray:(ArrayOfSQLValue)array;

@end
