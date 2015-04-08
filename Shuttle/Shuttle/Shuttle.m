//
//  Shuttle.m
//  Shuttle
//
//  Created by Stephen Hatton on 08/04/2015.
//  Copyright (c) 2015 Stephen Hatton. All rights reserved.
//

#import "Shuttle.h"
#import "Reachability.h"

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
    RXPromise *HTTPOperation = [RXPromise new];
    
    if (![self isConnected]) {
        NSLog(@" SHUTTLE: [ - NO CONNETION FOUND - ] [%@]", HTTP);
        [HTTPOperation rejectWithReason:nil];
        return HTTPOperation;
    }
    
    if (recievingAs == JSON) {
         [_manager setResponseSerializer:[AFJSONResponseSerializer new]];
    } else {
        [_manager setResponseSerializer:[AFHTTPResponseSerializer new]];
    }
   
    
    if (launchMode == DELETE) {
        
        [_manager DELETE:HTTP parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if (kPRINT_HTTP)
                NSLog(@"SHUTTLE: [DELETE] [%@]", HTTP);
            
            if (kPRINT_RESP)
                NSLog(@"SHUTTLE: [DELETE] [%@]", responseObject);
            
            [HTTPOperation fulfillWithValue:responseObject];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"SHUTTLE: [DELETE FAILED] [%@]", HTTP);
            NSLog(@"Shuttle Error: %@", [error localizedDescription]);
            
            [HTTPOperation rejectWithReason:nil];
            
        }];
        
    } else if (launchMode == GET) {
        
        [_manager GET:HTTP parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if (kPRINT_HTTP)
                NSLog(@"SHUTTLE: [GET] [%@]", HTTP);
            
            if (kPRINT_RESP)
                NSLog(@"SHUTTLE: [GET] [%@]", responseObject);
            
            [HTTPOperation fulfillWithValue:responseObject];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"SHUTTLE: [GET FAILED] [%@]", HTTP);
            NSLog(@"Shuttle Error: %@", [error localizedDescription]);
            
            [HTTPOperation rejectWithReason:nil];
            
        }];
        
    } else if (launchMode == POST) {
        
        [_manager POST:HTTP parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if (kPRINT_HTTP)
                NSLog(@"SHUTTLE: [POST] [%@]", HTTP);
            
            if (kPRINT_RESP)
                NSLog(@"SHUTTLE: [POST] [%@]", responseObject);
            
            [HTTPOperation fulfillWithValue:responseObject];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"SHUTTLE: [POST FAILED] [%@]", HTTP);
            NSLog(@"Shuttle Error: %@", [error localizedDescription]);
            
            [HTTPOperation rejectWithReason:nil];
            
        }];
        
    } else if (launchMode == PUT) {
        
        [_manager PUT:HTTP parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if (kPRINT_HTTP)
                NSLog(@"SHUTTLE: [PUT] [%@]", HTTP);
            
            if (kPRINT_RESP)
                NSLog(@"SHUTTLE: [PUT] [%@]", responseObject);
            
            [HTTPOperation fulfillWithValue:responseObject];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"SHUTTLE: [PUT FAILED] [%@]", HTTP);
            NSLog(@"Shuttle Error: %@", [error localizedDescription]);
            
            [HTTPOperation rejectWithReason:nil];
            
        }];

    }
    
    return HTTPOperation;
}



#pragma mark - Set Operation Defaults Method

- (void)updateDefaults:(NSDictionary *)defaults
{
    for (NSString *key in defaults) {
        [[_manager responseSerializer] setValue:[defaults valueForKey:key]  forKey:key];
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
