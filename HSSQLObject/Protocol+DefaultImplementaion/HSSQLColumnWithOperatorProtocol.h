//
//  HSSQLColumnWithOperatorProtocol.h
//  HSSQLObject
//
//  Created by Hsieh on 2018/3/17.
//  Copyright © 2018年 Hsieh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HSSQLValueProtocol.h"

@protocol HSSQLColumnWithOperatorProtocol <NSObject>

- (nonnull NSString *)generateKey;
- (nonnull NSString *)column;
- (nonnull NSString *)operatorAcoordingValue:(nullable NSObject<HSSQLValueProtocol> *)sqlValue
                             defaultOperator:(nullable NSString *)defaultOperator;

@end

@interface NSString (HSSQLColumnWithOperator) <HSSQLColumnWithOperatorProtocol>

@end
