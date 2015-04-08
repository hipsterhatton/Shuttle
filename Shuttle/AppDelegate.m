//
//  AppDelegate.m
//  Shuttle
//
//  Created by Stephen Hatton on 08/04/2015.
//  Copyright (c) 2015 Stephen Hatton. All rights reserved.
//

#import "AppDelegate.h"
#import "Shuttle/Shuttle.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self test];
}

- (void)test
{
    Shuttle *rocket = [[Shuttle alloc] initWithDefaults:@{
                                                          @"Things Go Here..." : @"Values Go Here..."
                                                          }];
    
    NSString *test = @"Some Sample HTTP";
    
    RXPromise *promise = [RXPromise new];
    
    promise = [rocket launch:GET :JSON :test :@{}]
    
    .then(^id (NSDictionary *rawJSON) {
        NSLog(@"All Done :D");
        return nil;
    }, nil);
}

@end
