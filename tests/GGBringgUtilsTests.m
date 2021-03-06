//
//  GGBringgUtilsTests.m
//  BringgTracking
//
//  Created by Matan on 23/06/2016.
//  Copyright © 2016 Matan Poreh. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GGBringgUtils.h"
#import "BringgGlobals.h"

@interface GGBringgUtilsTests : XCTestCase

@end

@implementation GGBringgUtilsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testParseCompoundUUID{
    // test no compound key, invalid compound key, valid compound key
    
    NSString *compoundUUID;
    
    NSString *orderUUID;
    NSString *shareUUID;
    
    NSError *error;
    
    
    [GGBringgUtils parseOrderCompoundUUID:compoundUUID toOrderUUID:&orderUUID andSharedUUID:&shareUUID error:&error];
    
    // since compound uuid is empty we should have an error
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, GGErrorTypeUUIDNotFound);
    
    
    compoundUUID = @"asldfhasl fhaksldjhf asldkfj asdlfjkasdf";
    error = nil;
    
    [GGBringgUtils parseOrderCompoundUUID:compoundUUID toOrderUUID:&orderUUID andSharedUUID:&shareUUID error:&error];
    
    // since compound uuid is of unfamiliar structure we should have an error
    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, GGErrorTypeInvalidUUID);
    
    compoundUUID = @"SOME_ORDER_UUID$$SOME_SHARED_UUID";
    error = nil;
     [GGBringgUtils parseOrderCompoundUUID:compoundUUID toOrderUUID:&orderUUID andSharedUUID:&shareUUID error:&error];
    
    XCTAssertNil(error);
    XCTAssertNotNil(orderUUID);
    XCTAssertNotNil(shareUUID);
    XCTAssertTrue([orderUUID isEqualToString: @"SOME_ORDER_UUID"]);
    XCTAssertTrue([shareUUID isEqualToString: @"SOME_SHARED_UUID"]);

    
}


- (void)testURLStringValidation{
    
    NSString *testURL = @"http://www.google.com";
    BOOL result = [GGBringgUtils isValidUrlString:testURL];
    NSURL *nsurl = [NSURL URLWithString:testURL];
    XCTAssertNotNil(nsurl);
    XCTAssertTrue([nsurl.absoluteString isEqualToString:testURL] && result);
    
    testURL = @"https://www.google.com";
    result = [GGBringgUtils isValidUrlString:testURL];
    nsurl = [NSURL URLWithString:testURL];
    XCTAssertNotNil(nsurl);
    XCTAssertTrue([nsurl.absoluteString isEqualToString:testURL] && result);
    
    testURL = @"www.google.com";
    result = [GGBringgUtils isValidUrlString:testURL];
    nsurl = [NSURL URLWithString:testURL];
    XCTAssertNotNil(nsurl);
    XCTAssertTrue([nsurl.absoluteString isEqualToString:testURL] && result);
    
    testURL = @"www.google";
    result = [GGBringgUtils isValidUrlString:testURL];
    nsurl = [NSURL URLWithString:testURL];
    XCTAssertNotNil(nsurl);
    XCTAssertTrue([nsurl.absoluteString isEqualToString:testURL] && result);
    
    testURL = @"http://www.google";
    result = [GGBringgUtils isValidUrlString:testURL];
    nsurl = [NSURL URLWithString:testURL];
    XCTAssertNotNil(nsurl);
    XCTAssertTrue([nsurl.absoluteString isEqualToString:testURL] && result);
    
    
    testURL = @"http://google/";
    result = [GGBringgUtils isValidUrlString:testURL];
    nsurl = [NSURL URLWithString:testURL];
    XCTAssertNotNil(nsurl);
    XCTAssertTrue([nsurl.absoluteString isEqualToString:testURL] && result);

    // should fail due to illegal characters
    testURL = @"http://mw1.google.com/mw-earth-vectordb/kml-samples/gp/seattle/gigapxl/$[level]/r$[y]_c$[x].jpg";
    result = [GGBringgUtils isValidUrlString:testURL];
    nsurl = [NSURL URLWithString:testURL];
    XCTAssertNotNil(nsurl);
    XCTAssertFalse(result);
    
    
    testURL = @"http://10.0.1.148:3030/api/public_alert/f7bc05e0-4835-11e6-bb5e-91d8c6caeffa";
    result = [GGBringgUtils isValidUrlString:testURL];
    nsurl = [NSURL URLWithString:testURL];
    XCTAssertNotNil(nsurl);
    XCTAssertTrue(result);
    
    
}

@end
