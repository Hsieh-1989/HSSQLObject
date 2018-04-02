//
//  HSCustomSQLValue.h
//  HSSQLObject
//
//  Created by Hsieh on 2018/4/2.
//  Copyright © 2018年 Hsieh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HSSQLValueProtocol.h"

@interface HSCustomSQLValue : NSObject <HSSQLValueProtocol>

+ (instancetype)valueOfSQLString:(NSString *)SQLString;
- (instancetype)initWithSQLString:(NSString *)SQLString;

@end
