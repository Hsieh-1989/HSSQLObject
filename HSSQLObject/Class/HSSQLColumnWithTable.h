//
//  HSSQLColumnWithTable.h
//  HSSQLObject
//
//  Created by Hsieh on 2018/3/17.
//  Copyright © 2018年 Hsieh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HSSQLValueProtocol.h"
#import "HSSQLColumnWithOperatorProtocol.h"

@interface HSSQLColumnWithTable : NSObject <HSSQLValueProtocol, HSSQLColumnWithOperatorProtocol>

NS_ASSUME_NONNULL_BEGIN

- (instancetype)initWithTable:(NSString *)tableName column:(NSString *)column;
+ (HSSQLColumnWithTable *)table:(NSString *)tableName column:(NSString *)column;
+ (NSArray<NSString *> *)columns:(NSArray<NSString *> *)columns prefixTable:(NSString *)tableName;

NS_ASSUME_NONNULL_END

@end
