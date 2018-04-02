//
//  HSHSSQLObjectTests.m
//  HSHSSQLObjectTests
//
//  Created by Hsieh on 2018/3/17.
//  Copyright © 2018年 Hsieh. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HSSQLObject.h"
#import "HSSQLColumnWithTable.h"
#import "HSSQLColumnWithOperator.h"
#import "HSCustomSQLValue.h"
#import "NSString+SQLHelper.h"

NSString *const tableName = @"tableName";
NSString *const tableNameB = @"tableNameB";
NSString *const tableNameC = @"tableNameC";

NSString *const columnA = @"columnA";
NSString *const columnB = @"columnB";
NSString *const columnC = @"columnC";
NSString *const columnD = @"columnD";
NSString *const columnE = @"columnE";

@interface HSSQLObjectTests : XCTestCase

@end

@implementation HSSQLObjectTests

// FIXME: the test might fail because the order of dictionary may be different (but the SQL is the same)

- (void)testSelect {
    HSSQLObject *sqlobj = [[HSSQLObject alloc] initWith:SELECT tableName:tableName];
    [sqlobj select:@[columnA, columnB, columnC]];
    NSString *expectedA = @"SELECT columnA,columnB,columnC FROM tableName";
    NSString *generatedA = [sqlobj generateQuery];
    XCTAssertTrue([expectedA isEqualToString:generatedA]);
    
    [sqlobj select:@[columnD, columnE]];
    NSString *expectedB = @"SELECT columnA,columnB,columnC,columnD,columnE FROM tableName";
    NSString *generatedB = [sqlobj generateQuery];
    XCTAssertTrue([expectedB isEqualToString:generatedB]);
}


- (void)testInsert {
    HSSQLObject *sqlobj = [[HSSQLObject alloc] initWith:INSERT tableName:tableName];
    NSDictionary *insertValueOne = @{columnA: @(1), columnB: @(2), columnC: @"3"};
    [sqlobj insert:@[insertValueOne]];
    NSString *expected = @"INSERT INTO tableName (columnA,columnB,columnC) VALUES (1,2,'3')";
    NSString *generated = [sqlobj generateQuery];
    XCTAssertTrue([expected isEqualToString:generated]);
}

- (void)testInsertContainNULLValue {
    HSSQLObject *sqlobj = [[HSSQLObject alloc] initWith:INSERT tableName:tableName];
    NSDictionary *insertValueOne = @{columnA: @(1), columnB: [NSNull null], columnC: @"3"};
    [sqlobj insert:@[insertValueOne]];
    NSString *expected = @"INSERT INTO tableName (columnA,columnB,columnC) VALUES (1,NULL,'3')";
    NSString *generated = [sqlobj generateQuery];
    XCTAssertTrue([expected isEqualToString:generated]);
}

- (void)testUdpate {
    HSSQLObject *sqlobj = [[HSSQLObject alloc] initWith:UPDATE tableName:tableName];
    [sqlobj update:columnA value:@(1)];
    NSString *expectedA = @"UPDATE tableName SET columnA = 1";
    NSString *generatedA = [sqlobj generateQuery];
    XCTAssertTrue([expectedA isEqualToString:generatedA]);
    
    [sqlobj update:@{columnB: @(2), columnC: @"3"}];
    NSString *expectedB = @"UPDATE tableName SET columnA = 1 , columnB = 2 , columnC = '3'";
    NSString *generateB = [sqlobj generateQuery];
    NSLog(@"UPDATE: %@", generateB);
    XCTAssertTrue([expectedB isEqualToString:generateB]);
}

- (void)testUdpateContainNULLValue {
    HSSQLObject *sqlobj = [[HSSQLObject alloc] initWith:UPDATE tableName:tableName];
    [sqlobj update:columnA value:[NSNull null]];
    NSString *expectedA = @"UPDATE tableName SET columnA = NULL";
    NSString *generatedA = [sqlobj generateQuery];
    XCTAssertTrue([expectedA isEqualToString:generatedA]);
    
    [sqlobj update:@{columnB: [NSNull null], columnC: @"3"}];
    NSString *expectedB = @"UPDATE tableName SET columnA = NULL , columnB = NULL , columnC = '3'";
    NSString *generateB = [sqlobj generateQuery];
    NSLog(@"UPDATE: %@", generateB);
    XCTAssertTrue([expectedB isEqualToString:generateB]);
}

- (void)testDelete {
    HSSQLObject *sqlobj = [[HSSQLObject alloc] initWith:DELETE tableName:tableName];
    NSString *expected = @"DELETE FROM tableName";
    NSString *generated = [sqlobj generateQuery];
    XCTAssertTrue([expected isEqualToString:generated]);
}

- (void)testWhereClause {
    HSSQLObject *sqlobj = [[HSSQLObject alloc] initWith:SELECT tableName:tableName];
    [sqlobj select:@[columnA, columnB, columnC]];
    [sqlobj where:@{columnA: @(1), columnB: @"1"}];
    NSString *expectedA = @"SELECT columnA,columnB,columnC FROM tableName WHERE (columnA = 1 AND columnB = '1')";
    NSString *generatedA = [sqlobj generateQuery];
    XCTAssertTrue([expectedA isEqualToString:generatedA]);
    
    
    [sqlobj where:@{columnD: @(2), columnE: @"2"}];
    NSString *expectedB =
    @"SELECT columnA,columnB,columnC "
    @"FROM tableName "
    @"WHERE (columnA = 1 AND columnB = '1') "
    @"OR (columnD = 2 AND columnE = '2')";
    NSString *generatedB = [sqlobj generateQuery];
    XCTAssertTrue([expectedB isEqualToString:generatedB]);
    
    [sqlobj where:@{columnC: [NSNull null]}];
    NSString *expectedC =
    @"SELECT columnA,columnB,columnC "
    @"FROM tableName "
    @"WHERE (columnA = 1 AND columnB = '1') "
    @"OR (columnD = 2 AND columnE = '2') "
    @"OR (columnC IS NULL)";
    NSString *generatedC = [sqlobj generateQuery];
    XCTAssertTrue([expectedC isEqualToString:generatedC]);
}

- (void)testMultipleWhereConditionClause {
    HSSQLObject *sqlobj = [[HSSQLObject alloc] initWith:SELECT tableName:tableName];
    [sqlobj select:@[columnA, columnB, columnC]];
    [sqlobj where:@{columnA: @(1), columnD: @(2), columnB: @"1", columnE: @"2", columnC: [NSNull null]}];
    // where condition order is not always the same
    NSString *expected =
    @"SELECT columnA,columnB,columnC "
    @"FROM tableName "
    @"WHERE (columnA = 1 AND columnD = 2 AND columnB = '1' AND columnE = '2' AND columnC IS NULL)";
    NSString *generated = [sqlobj generateQuery];
    XCTAssertTrue([expected isEqualToString:generated]);
}

- (void)testJoin {
    // Join One State
    HSSQLObject *sqlobj = [[HSSQLObject alloc] initWith:SELECT tableName:tableName];
    [sqlobj select:@[columnA, columnB, columnC]];
    HSSQLColumnWithTable *columnWithtableA = [HSSQLColumnWithTable table:tableNameB column:columnA];
    HSSQLConditionDictionary *dic = @{@"tableName.columnA": columnWithtableA};
    [sqlobj join:tableNameB on:@[dic] type:LEFT];
    NSString *expectedA =
    @"SELECT columnA,columnB,columnC "
    @"FROM tableName "
    @"LEFT JOIN tableNameB "
    @"ON (tableName.columnA = tableNameB.columnA)";
    NSString *generatedA = [sqlobj generateQuery];
    XCTAssertTrue([expectedA isEqualToString:generatedA]);
}

- (void)testMultipleJoinState {
    HSSQLObject *sqlobj = [[HSSQLObject alloc] initWith:SELECT tableName:tableName];
    [sqlobj select:@[columnA, columnB, columnC]];
    HSSQLColumnWithTable *columnWithtableA = [HSSQLColumnWithTable table:tableNameB column:columnA];
    HSSQLColumnWithTable *columnWithtableB = [HSSQLColumnWithTable table:tableNameB column:columnB];
    HSSQLColumnWithTable *columnWithtableC = [HSSQLColumnWithTable table:tableNameB column:columnC];
    HSSQLConditionDictionary *dic = @{@"tableName.columnA": columnWithtableA};
    HSSQLConditionDictionary *dic2 = @{@"tableName.columnB": columnWithtableB, @"tableName.columnC": columnWithtableC};
    [sqlobj join:tableNameB on:@[dic, dic2] type:INNER];
    NSString *expected =
    @"SELECT columnA,columnB,columnC "
    @"FROM tableName "
    @"INNER JOIN tableNameB "
    @"ON (tableName.columnA = tableNameB.columnA) "
    @"OR (tableName.columnB = tableNameB.columnB AND tableName.columnC = tableNameB.columnC)";
    NSString *generated = [sqlobj generateQuery];
    XCTAssertTrue([expected isEqualToString:generated]);
}

- (void)testMultipleTableJoin {
    HSSQLObject *sqlobj = [[HSSQLObject alloc] initWith:SELECT tableName:tableName];
    [sqlobj select:@[columnA, columnB, columnC]];
    HSSQLColumnWithTable *columnWithtableA = [HSSQLColumnWithTable table:tableNameB column:columnA];
    
    HSSQLConditionDictionary *dic = @{@"tableName.columnA": columnWithtableA};
    [sqlobj join:tableNameB on:@[dic] type:LEFT];
    
    HSSQLColumnWithTable *columnWithtableC = [HSSQLColumnWithTable table:tableNameC column:columnC];
    HSSQLConditionDictionary *dic2 = @{@"tableName.columnC": columnWithtableC};
    [sqlobj join:tableNameC on:@[dic2] type:INNER];
    
    NSString *expected =
    @"SELECT columnA,columnB,columnC "
    @"FROM tableName "
    @"LEFT JOIN tableNameB ON (tableName.columnA = tableNameB.columnA) "
    @"INNER JOIN tableNameC ON (tableName.columnC = tableNameC.columnC)";
    NSString *generated = [sqlobj generateQuery];
    XCTAssertTrue([expected isEqualToString:generated]);
}

- (void)testOrder {
    HSSQLObject *sqlobj = [[HSSQLObject alloc] initWith:SELECT tableName:tableName];
    [sqlobj select:@[columnA, columnB, columnC]];
    [sqlobj orderBy:columnA ascending:YES];
    NSString *expectedA = @"SELECT columnA,columnB,columnC FROM tableName ORDER BY columnA ASC";
    NSString *generatedA = [sqlobj generateQuery];
    XCTAssertTrue([expectedA isEqualToString:generatedA]);
    
    [sqlobj orderBy:columnB ascending:NO];
    NSString *expectedB = @"SELECT columnA,columnB,columnC FROM tableName ORDER BY columnA ASC,columnB DESC";
    NSString *generatedB = [sqlobj generateQuery];
    XCTAssertTrue([expectedB isEqualToString:generatedB]);
}

- (void)testLimit {
    HSSQLObject *sqlobj = [[HSSQLObject alloc] initWith:SELECT tableName:tableName];
    [sqlobj select:@[columnA, columnB, columnC]];
    [sqlobj queryLimit:1];
    NSString *expected = @"SELECT columnA,columnB,columnC FROM tableName LIMIT 1";
    NSString *generated = [sqlobj generateQuery];
    XCTAssertTrue([expected isEqualToString:generated]);
}

- (void)testOperator {
    // NOT NULL
    HSSQLObject *sqlobj = [[HSSQLObject alloc] initWith:SELECT tableName:tableName];
    [sqlobj select:@[columnA, columnB, columnC]];
    [sqlobj where:@{@"columnA IS NOT": [NSNull null]}];
    NSString *expectedA = @"SELECT columnA,columnB,columnC FROM tableName WHERE (columnA IS NOT NULL)";
    NSString *generatedA = [sqlobj generateQuery];
    XCTAssertTrue([expectedA isEqualToString:generatedA]);
    
    // NOT EQUAL
    [sqlobj where:@{@"columnB !=": @(2)}];
    NSString *expectedB =
    @"SELECT columnA,columnB,columnC "
    @"FROM tableName "
    @"WHERE (columnA IS NOT NULL) "
    @"OR (columnB != 2)";
    NSString *generatedB = [sqlobj generateQuery];
    XCTAssertTrue([expectedB isEqualToString:generatedB]);
    
    // NOT LIKE
    [sqlobj where:@{@"columnC LIKE": @"%test%"}];
    NSString *expected =
    @"SELECT columnA,columnB,columnC "
    @"FROM tableName "
    @"WHERE (columnA IS NOT NULL) "
    @"OR (columnB != 2) "
    @"OR (columnC LIKE '%test%')";
    NSString *generated = [sqlobj generateQuery];
    XCTAssertTrue([expected isEqualToString:generated]);
}

- (void)testOperatorBySQLCoditionKey {
    // NOT NULL
    HSSQLObject *sqlobj = [[HSSQLObject alloc] initWith:SELECT tableName:tableName];
    [sqlobj select:@[columnA, columnB, columnC]];
    HSSQLColumnWithOperator *nullKey = [HSSQLColumnWithOperator column:columnA operator:HSConditionNotNull];
    [sqlobj where:@{nullKey: [NSNull null]}];
    NSString *expectedA = @"SELECT columnA,columnB,columnC FROM tableName WHERE (columnA IS NOT NULL)";
    NSString *generatedA = [sqlobj generateQuery];
    XCTAssertTrue([expectedA isEqualToString:generatedA]);
    
    // NOT EQUAL
    HSSQLColumnWithOperator *notEqualKey = [HSSQLColumnWithOperator column:columnB operator:HSConditionNotEqual];
    [sqlobj where:@{notEqualKey: @(2)}];
    NSString *expectedB =
    @"SELECT columnA,columnB,columnC "
    @"FROM tableName "
    @"WHERE (columnA IS NOT NULL) "
    @"OR (columnB != 2)";
    NSString *generatedB = [sqlobj generateQuery];
    XCTAssertTrue([expectedB isEqualToString:generatedB]);
    
    // NOT LIKE
    HSSQLColumnWithOperator *likeKey = [HSSQLColumnWithOperator column:columnC operator:HSConditionLike];
    [sqlobj where:@{likeKey: @"%test%"}];
    NSString *expected =
    @"SELECT columnA,columnB,columnC "
    @"FROM tableName "
    @"WHERE (columnA IS NOT NULL) "
    @"OR (columnB != 2) "
    @"OR (columnC LIKE '%test%')";
    NSString *generated = [sqlobj generateQuery];
    XCTAssertTrue([expected isEqualToString:generated]);
}

- (void)testComplictedSelect {
    // SELECT
    HSSQLObject *sqlobj = [[HSSQLObject alloc] initWith:SELECT tableName:tableName];
    NSArray<NSString *> *columnsA = [HSSQLColumnWithTable columns:@[columnA, columnB] prefixTable:tableName];
    NSArray<NSString *> *columnsB = [HSSQLColumnWithTable columns:@[columnC, columnD] prefixTable:tableNameB];
    NSArray<NSString *> *allSelectedColumns = [columnsA arrayByAddingObjectsFromArray:columnsB];
    [sqlobj select:allSelectedColumns];
    
    // JOIN
    HSSQLColumnWithTable *columnAWithtableA = [HSSQLColumnWithTable table:tableName column:columnA];
    HSSQLColumnWithTable *columnAWithtableB = [HSSQLColumnWithTable table:tableNameB column:columnA];
    HSSQLConditionDictionary *dic = @{columnAWithtableA.column: columnAWithtableB};
    [sqlobj join:tableNameB on:@[dic] type:INNER];
    
    // WHERE
    NSString *columnBWithtableA = [tableName tableNameBindColumnNamed:columnB];
    NSString *columnBWithtableB = [tableNameB tableNameBindColumnNamed:columnB];
    HSSQLColumnWithOperator *key = [HSSQLColumnWithOperator column:columnBWithtableA operator:HSConditionNotNull];
    [sqlobj where:@{key: [NSNull null],
                    columnBWithtableB: @(123.456) }];
    
    // ORDER
    HSSQLColumnWithTable *columnCWithtableA = [HSSQLColumnWithTable table:tableName column:columnC];
    [sqlobj orderBy:columnCWithtableA.column ascending:YES];
    
    // LIMIT
    [sqlobj queryLimit:5];
    
    NSString *expected =
    @"SELECT tableName.columnA,tableName.columnB,tableNameB.columnC,tableNameB.columnD "
    @"FROM tableName "
    @"INNER JOIN tableNameB ON (tableName.columnA = tableNameB.columnA) "
    @"WHERE (tableNameB.columnB = 123.456 AND tableName.columnB IS NOT NULL) "
    @"ORDER BY tableName.columnC "
    @"ASC LIMIT 5";
    NSString *generated = [sqlobj generateQuery];
    XCTAssertTrue([expected isEqualToString:generated]);
}

- (void)testCustomSQLValue {
    HSSQLObject *sqlobj = [[HSSQLObject alloc] initWith:SELECT tableName:tableName];
    [sqlobj select:@[columnA, columnB, columnC]];
    
    HSCustomSQLValue *customValue = [HSCustomSQLValue valueOfSQLString:@"SELECT id FROM tabeleB where columnZ = 1"];
    [sqlobj where:@{columnA : customValue}];
    NSString *expectedA = @"SELECT columnA,columnB,columnC FROM tableName WHERE (columnA = (SELECT id FROM tabeleB where columnZ = 1))";
    NSString *generatedA = [sqlobj generateQuery];
    XCTAssertTrue([expectedA isEqualToString:generatedA]);
}

@end
