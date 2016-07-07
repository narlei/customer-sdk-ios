//
//  GGNetworkUtils.m
//  BringgTracking
//
//  Created by Matan on 07/07/2016.
//  Copyright © 2016 Matan Poreh. All rights reserved.
//

#import "GGNetworkUtils.h"
#import "BringgGlobals.h"

@implementation GGNetworkUtils



+ (void)parseStatusOfJSONResponse:(nonnull NSDictionary *)responseObject
                        toSuccess:(BOOL  * _Nonnull )successResult
                         andError:(NSError *__autoreleasing __nonnull* __nonnull)error{
 
    
    *successResult = NO;
    
    // there are two params that represent success
    id success = [responseObject objectForKey:BCSuccessKey];
    
    // if it's "success" then then check for valid data (should be bool)
    if (success && [success isKindOfClass:[NSNumber class]]) {
        
        *successResult = [success boolValue];
        
    }
    
    // check if there is another success params to indicate response status
    if (!success) {
        
        // "status" could also represent a succesfull call - status here will be a string
        id status = [responseObject objectForKey:BCSuccessAlternateKey];
        
        // check if status field is valid and if success
        if ([status isKindOfClass:[NSString class]] &&
            [status isEqualToString:@"ok"]) {
            
            *successResult = YES;
            
        } else {
            
            // for sure we have a failed response - both success params tests failed
            
            id message = [responseObject objectForKey:BCMessageKey];
            
            
            // some times the success key is part of a legitimate response object - so no message will exits
            // but other data will be present so we should conisder it
            
            if ([message isKindOfClass:[NSString class]]) {
                *error = [NSError errorWithDomain:@"BringgHTTPClient" code:0
                                        userInfo:@{NSLocalizedDescriptionKey: message,
                                                   NSLocalizedRecoverySuggestionErrorKey: message}];
                
            } else {
                
                // check if there is other data
                if (!message && [[responseObject allKeys] count] > 1) {
                    
                    // the response is legit
                    *successResult = YES;
                }else{
                    *error = [NSError errorWithDomain:@"BringgHTTPClient" code:0
                                            userInfo:@{NSLocalizedDescriptionKey: @"Undefined Error",
                                                       NSLocalizedRecoverySuggestionErrorKey: @"Undefined Error"}];
                }
                
            }
        }
    }

}

+ (NSMutableURLRequest * _Nullable)jsonRequestForServer:(nonnull NSString *)server
                                                 method:(NSString * _Nonnull)method
                                                   path:(NSString *_Nonnull)path
                                                headers:(NSDictionary * _Nonnull)headers
                                                 params:(NSDictionary * _Nullable)params
                                                  error:(NSError *__autoreleasing __nonnull*)error{
    
    
    
    NSURL *CTSURL = [NSURL URLWithString:server];
    
    // build mutable request with url
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:CTSURL
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:30.0];
    
    
    // add content headers
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [request addValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"text/plain" forHTTPHeaderField:@"Accept"];
    
    // set method
    [request setHTTPMethod:method];
    
    
    // set the authentication headers of the request
    [headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [request setValue:obj forHTTPHeaderField:key];
        
    }];
    
    
    // build the params as json serialized
    NSError *jsonParamsError;
    
    NSData *paramsData = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&jsonParamsError];
    
    if (jsonParamsError) {
        
        *error = jsonParamsError;
        return nil;
    }
    
    // add params data to body
    [request setHTTPBody:paramsData];

    return request;
}


+ (void)handleDataSuccessResponseWithData:(nullable NSData*)data
                        completionHandler:(nullable GGNetworkResponseHandler)completionHandler{
    
    if (data) {
        NSError *jsonError = nil;
        
        
        NSError *responseError = nil;
        BOOL responseSuccess = NO;
        
        id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
        
        
        if (jsonError) {
            responseError = jsonError;
        }else{
            // check that response is json is of calid structure
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                
                // parse json response
                [self parseStatusOfJSONResponse:responseObject toSuccess:&responseSuccess andError:&responseError];
                
                
            }
            
        }
        
        // execute completion handler
        if (completionHandler){
            
            completionHandler(responseSuccess, [responseObject isKindOfClass:[NSDictionary class]] ? responseObject : nil, responseError);
        }
        
        
    }
}

+ (void)handleDataFailureResponse:(nullable NSURLResponse *)response
                            error:(nonnull NSError*)error
                completionHandler:(nullable GGNetworkResponseHandler)completionHandler{
    
    
    NSString *path = response.URL.relativePath;
    
#if DEBUG
    NSLog(@"GOT HTTP ERROR (%@) For Path %@:", error, path);
#endif
    
    if (completionHandler) {
    
        // check if error code implies server unavailable
        if (error && error.code >= 500 && error.code < 600) {
            
            NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:error.userInfo];
            [info setObject:@"server temporarily unavailable, please try again later." forKey:NSLocalizedDescriptionKey];
            
            // create new error object and send it
            NSError *newError = [NSError errorWithDomain:error.domain code:error.code userInfo:info];
            completionHandler(NO, nil, newError);
            
        }else{
            // execute failure completion
            completionHandler(NO, nil, error);
        }
        
        
    }
    
}


+ (NSURLSessionDataTask * _Nullable) httpRequestWithSession:(NSURLSession *)session
                                                     server:(nonnull NSString *)server
                                                     method:(NSString * _Nonnull)method
                                                       path:(NSString *_Nonnull)path
                                                    headers:(NSDictionary * _Nonnull)headers
                                                     params:(NSDictionary * _Nullable)params
                                          completionHandler:(nullable GGNetworkResponseHandler)completionHandler{
    
    NSError *jsonRequestError;
    
    // build mutable request with url
    NSMutableURLRequest *request = [ self jsonRequestForServer:server method:method path:path headers:headers params:params error:&jsonRequestError];
    
    if (jsonRequestError) {
        NSLog(@" error creating json params for request request in %s : %@", __PRETTY_FUNCTION__, jsonRequestError);
        
        if (completionHandler) {
            completionHandler(NO, nil, jsonRequestError);
        }
        
        return nil;
    }

    
    // create data task for session
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        

        // handle competion for data task
        if (error) {
            // handle error
            [self handleDataFailureResponse:response error:error completionHandler:completionHandler];
        }else{
            
            // handle success response
            [self handleDataSuccessResponseWithData:data completionHandler:completionHandler];
        }
 
    }];
    
    return dataTask;
    
    
    
    
}

@end
