//
//  GGWaypoint.m
//  BringgTracking
//
//  Created by Matan on 8/9/15.
//  Copyright (c) 2015 Matan Poreh. All rights reserved.
//

#import "GGWaypoint.h"
#import "GGBringgUtils.h"

@implementation GGWaypoint

@synthesize orderid,waypointId,customerId,merchantId,position,done,ASAP,allowFindMe,address, latitude, longitude, ETA, startTime, checkinTime, doneTime;

static NSDateFormatter *dateFormat;

-(id)initWaypointWithData:(NSDictionary*)data{
    
    if (self = [super init]) {
        
        
        dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        
        if (data){
            orderid = [GGBringgUtils integerFromJSON:data[PARAM_ORDER_ID] defaultTo:0];
            waypointId = [GGBringgUtils integerFromJSON:data[PARAM_ID] defaultTo:0];
            customerId = [GGBringgUtils integerFromJSON:data[PARAM_CUSTOMER_ID] defaultTo:0];
            merchantId = [GGBringgUtils integerFromJSON:data[PARAM_MERCHANT_ID] defaultTo:0];

            done =[GGBringgUtils boolFromJSON:data[@"done"] defaultTo:NO];
            ASAP = [GGBringgUtils boolFromJSON:data[@"asap"] defaultTo:NO];
            allowFindMe = [GGBringgUtils boolFromJSON:data[@"find_me"] defaultTo:NO];

            address =  [GGBringgUtils stringFromJSON:data[PARAM_ADDRESS] defaultTo:nil];
            
            latitude =  [GGBringgUtils doubleFromJSON:data[@"lat"] defaultTo:0];
            longitude =  [GGBringgUtils doubleFromJSON:data[@"lng"] defaultTo:0];
            
            ETA = [GGBringgUtils stringFromJSON:data[PARAM_ETA] defaultTo:nil];
            
            // get start/checkin/checkout dates
            NSString *startString   = [GGBringgUtils stringFromJSON:data[@"start_time"] defaultTo:nil];
            NSString *checkinString = [GGBringgUtils stringFromJSON:data[@"checkin_time"] defaultTo:nil];
            NSString *doneString    = [GGBringgUtils stringFromJSON:data[@"checkout_time"] defaultTo:nil];
            
            self.startTime    = startString ? [dateFormat dateFromString:startString] : nil;
            self.checkinTime  = checkinString ? [dateFormat dateFromString:checkinString] : nil;
            self.doneTime     = doneString ? [dateFormat dateFromString:doneString] : nil;
        }
        
    }
    
    return self;
    
}

#pragma mark - NSCODING

- (id) initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super init]){
        
        self.orderid = [aDecoder decodeIntegerForKey:GGWaypointStoreKeyOrderID];
        self.customerId = [aDecoder decodeIntegerForKey:GGWaypointStoreKeyID];
        self.orderid = [aDecoder decodeIntegerForKey:GGWaypointStoreKeyCustomerID];
        self.merchantId = [aDecoder decodeIntegerForKey:GGWaypointStoreKeyMerchantID];
        
        self.done = [aDecoder decodeBoolForKey:GGWaypointStoreKeyDone];
        self.ASAP = [aDecoder decodeBoolForKey:GGWaypointStoreKeyASAP];
        
        self.address = [[aDecoder decodeObjectForKey:GGWaypointStoreKeyAddress] stringValue];
        self.startTime = [aDecoder decodeObjectForKey:GGWaypointStoreKeyStartTime];
        self.checkinTime = [aDecoder decodeObjectForKey:GGWaypointStoreKeyArriveTime];
        self.doneTime = [aDecoder decodeObjectForKey:GGWaypointStoreKeyDoneTime];
    }
    
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeInteger:orderid forKey:GGWaypointStoreKeyOrderID];
    [aCoder encodeInteger:waypointId forKey:GGWaypointStoreKeyID];
    [aCoder encodeInteger:customerId forKey:GGWaypointStoreKeyCustomerID];
    [aCoder encodeInteger:merchantId forKey:GGWaypointStoreKeyMerchantID];
    
    [aCoder encodeBool:done forKey:GGWaypointStoreKeyDone];
    [aCoder encodeBool:ASAP forKey:GGWaypointStoreKeyASAP];
    
    [aCoder encodeObject:address forKey:GGWaypointStoreKeyAddress];
    [aCoder encodeObject:startTime forKey:GGWaypointStoreKeyStartTime];
    [aCoder encodeObject:checkinTime forKey:GGWaypointStoreKeyArriveTime];
    [aCoder encodeObject:doneTime forKey:GGWaypointStoreKeyDoneTime];
    
}

@end
