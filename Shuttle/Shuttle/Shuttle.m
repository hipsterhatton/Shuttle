//
//  Shuttle.m
//  Shuttle
//
//  Created by Stephen Hatton on 08/04/2015.
//  Copyright (c) 2015 Stephen Hatton. All rights reserved.
//

#import "Shuttle.h"
#import "Reachability.h"

// Can only print HTTP Resposne when the "print HTTP" is set to true
BOOL const kPRINT_HTTP  = true;
BOOL const kPRINT_RESP  = false;

@implementation Shuttle



#pragma mark - Init Method

- (id)initWithDefaults:(NSDictionary *)defaults
{
    self = [[Shuttle alloc] init];
    
    _manager = [AFHTTPRequestOperationManager manager];
    
    for (NSString *key in defaults) {
        [_manager.requestSerializer setValue:[defaults valueForKey:key] forHTTPHeaderField:key];
    }
    
    [_manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    
    return self;
}



#pragma mark - Process HTTP Method

- (RXPromise *)launch:(ShuttleHTTPModes)launchMode :(ShuttleHTTPResponses)recievingAs :(NSString *)HTTP :(NSDictionary *)params
{
    RXPromise *HTTPPromise = [RXPromise new];
    
    
    if (![self isConnected]) {
        NSLog(@" SHUTTLE: [ - NO CONNETION FOUND - ] [%@]", HTTP);
        [HTTPPromise rejectWithReason:nil];
        return HTTPPromise;
    }
    
    
    if ([HTTP isEqualToString:@""]) {
        NSLog(@" SHUTTLE: [ - HTTP STRING NOT VALID - ] [%@]", HTTP);
        [HTTPPromise rejectWithReason:@"HTTP string was blank"];
        return HTTPPromise;
    }
    
    
    if (recievingAs == JSON) {
         [_manager setResponseSerializer:[AFJSONResponseSerializer new]];
    } else {
        [_manager setResponseSerializer:[AFHTTPResponseSerializer new]];
    }
   
    
    if (launchMode == DELETE) {
        
        [_manager DELETE:HTTP parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self success:HTTPPromise :responseObject :HTTP :@"DELETE"];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self failure:HTTPPromise :error :HTTP :@"DELETE"];
        }];
        
    } else if (launchMode == GET) {
        
        [_manager GET:HTTP parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self success:HTTPPromise :responseObject :HTTP  :@"GET"];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self failure:HTTPPromise :error :HTTP :@"GET"];
        }];
        
    } else if (launchMode == POST) {
        
        [_manager POST:HTTP parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self success:HTTPPromise :responseObject :HTTP  :@"POST"];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self failure:HTTPPromise :error :HTTP :@"POST"];
        }];
        
    } else if (launchMode == PUT) {
        
        [_manager PUT:HTTP parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self success:HTTPPromise :responseObject :HTTP  :@"PUT"];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self failure:HTTPPromise :error :HTTP :@"PUT"];
        }];

    }
    
    
    return HTTPPromise;
}

- (void)success:(RXPromise *)promise :(NSObject *)data :(NSString *)http :(NSString *)op
{
    if (kPRINT_HTTP) {
        NSLog(@" ");
        NSLog(@"SHUTTLE: [%@] [%@]", op, http);
    }
    
    if (kPRINT_HTTP && kPRINT_RESP) {
        NSLog(@"SHUTTLE: [%@] [%@]", op, data);
        NSLog(@" ");
    }
    
    if (kPRINT_HTTP && !kPRINT_RESP) {
        NSLog(@" ");
    }
    
    [promise fulfillWithValue:data];
}

- (void)failure:(RXPromise *)promise :(NSError *)error :(NSString *)http :(NSString *)op
{
    NSLog(@" ");
    NSLog(@"SHUTTLE: [%@ FAILED] [%@]", op, http);
    NSLog(@"SHUTTLE ERROR: %@", [error localizedDescription]);
    NSLog(@" ");
    
    [promise rejectWithReason:nil];
}



#pragma mark - Set Operation Defaults Method

- (void)updateDefaults:(NSDictionary *)defaults
{
    for (NSString *key in defaults) {
        [[_manager requestSerializer] setValue:[defaults valueForKey:key]  forHTTPHeaderField:key];
    }
}



#pragma mark - Check Connection Method

- (BOOL)isConnected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    
    return networkStatus != NotReachable;
}


@end
