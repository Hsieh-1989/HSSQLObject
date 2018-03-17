//
//  HSSQLValueProtocol.h
//  HSSQLObject
//
//  Created by Hsieh on 2018/3/17.
//  Copyright © 2018年 Hsieh. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Protocol
@protocol HSSQLValueProtocol <NSObject>

- (nonnull NSString *)SQLValueString;

@end

#pragma mark - DefaultSQLValue
@interface NSNumber (HSSQLValue) <HSSQLValueProtocol>

@end

@interface NSString (HSSQLValue) <HSSQLValueProtocol>

@end

@interface NSNull (HSSQLValue) <HSSQLValueProtocol>

@end
