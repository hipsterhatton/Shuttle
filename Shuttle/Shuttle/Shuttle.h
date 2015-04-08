//
//  Shuttle.h
//  Shuttle
//
//  Created by Stephen Hatton on 08/04/2015.
//  Copyright (c) 2015 Stephen Hatton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import <RXPromise/RXPromise.h>

@interface Shuttle : NSObject

typedef enum {
    DELETE,
    GET,
    POST,
    PUT
} ShuttleHTTPModes;

typedef enum {
    HTTP,
    JSON
} ShuttleHTTPResponses;

@property (nonatomic, retain) AFHTTPRequestOperationManager *manager;

- (id)initWithDefaults:(NSDictionary *)defaults;

- (RXPromise *)launch:(ShuttleHTTPModes)launchMode :(ShuttleHTTPResponses)recievingAs :(NSString *)HTTP :(NSDictionary *)params;

- (void)updateDefaults:(NSDictionary *)defaults;

@end
