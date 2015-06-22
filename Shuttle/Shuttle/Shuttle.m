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
BOOL const kPRINT_HTTP  = YES;
BOOL const kPRINT_RESP  = NO;

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
    [self _monitorConnection];
    
    return self;
}

- (void)_monitorConnection
{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    [[_manager reachabilityManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
                
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@" ---[No Internet Connection]: %s", __PRETTY_FUNCTION__);
                [[NSNotificationCenter defaultCenter]
                 postNotificationName: @"ErrorRaised" object:nil userInfo:@{
                                                                            @"ErrorMessage" : @"No Internet Connection",
                                                                            @"ErrorOrigin"  : @"Networking Reachability"
                                                                            }];
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@" ---[Connection via WiFi]: %s", __PRETTY_FUNCTION__);
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@" ---[Connection via WAN]: %s", __PRETTY_FUNCTION__);
                break;
                
            default:
                NSLog(@" ---[Connection - Unknown Status]: %s", __PRETTY_FUNCTION__);
                [[NSNotificationCenter defaultCenter]
                 postNotificationName: @"ErrorRaised" object:nil userInfo:@{
                                                                            @"ErrorMessage" : @"Connection Unknown...",
                                                                            @"ErrorOrigin"  : @"Networking Reachability"
                                                                            }];
                break;
        }
    }];
    
    [[_manager reachabilityManager] startMonitoring];
}



#pragma mark - Process HTTP Method

- (RXPromise *)launch:(ShuttleHTTPModes)launchMode :(ShuttleHTTPResponses)recievingAs :(NSString *)HTTP :(NSDictionary *)params
{
    RXPromise *HTTPPromise = [RXPromise new];
    
    if (![self isConnected]) {
        NSLog(@" SHUTTLE: [ - NO CONNETION FOUND - ] [%@]", HTTP);
        [HTTPPromise rejectWithReason:@"No Connection Found"];
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
    
    if (kPRINT_HTTP) {
        NSLog(@" ");
        NSLog(@"SHUTTLE: [LAUNCH] [%@]", HTTP);
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
    
    //    NSMutableDictionary *errorDict = [[error userInfo] mutableCopy];
    
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey:              ([error localizedDescription] != NULL ? [error localizedDescription] : @""),
                               NSLocalizedFailureReasonErrorKey:       ([error localizedFailureReason] != NULL ? [error localizedFailureReason] : @""),
                               NSLocalizedRecoverySuggestionErrorKey:  ([error localizedRecoverySuggestion] != NULL ? [error localizedRecoverySuggestion] : @""),
                               @"ErrorMessage":                        ([error localizedDescription] != NULL ? [error localizedDescription] : @"(Server Error Was Blank)"),
                               //        @"ErrorMessage":                        ([errorJSON objectForKey:@"errors"] ? [errorJSON objectForKey:@"errors"] : @"-- blank --"),
                               @"ErrorOrigin":                         [[NSMutableArray alloc] initWithObjects:@"Shuttle HTTP", nil]
                               };
    
    error = [NSError errorWithDomain:[error domain]
                                code:[error code]
                            userInfo:userInfo];
    
    NSLog(@" ");
    NSLog(@"SHUTTLE: [%@ FAILED] [%@]", op, http);
    NSLog(@"SHUTTLE ERROR: %@ || %@", [error localizedDescription], [[error userInfo] valueForKey:@"ErrorMessage"]);
    NSLog(@" ");
    
    [promise rejectWithReason:error];
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
