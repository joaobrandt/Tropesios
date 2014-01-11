//
//  TvTropes.m
//  tropesios
//
//  Created by João Paulo Gonçalves on 07/01/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import "TvTropes.h"

@interface TvTropes()<NSURLConnectionDataDelegate> {
    NSMutableData *responseData;
    NSURLSession *urlSession;
}

@end

@implementation TvTropes

- (id)init
{
    self = [super init];

    if (self) {
        urlSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    }
    
    return self;
}

- (void)loadPageNamed:(NSString *)name
{
    NSURL *url = [NSURL URLWithString:@"http://google.com.br"];
    
    NSURLSessionDataTask *task = [urlSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    
    }];
    [task resume];
}

@end
