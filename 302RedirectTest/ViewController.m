//
//  ViewController.m
//  302RedirectTest
//
//  Created by Christian Netthöfel on 07.09.14.
//  Copyright (c) 2014 codenarko.se. All rights reserved.
//

#import "ViewController.h"
#import <OHHTTPStubs/OHHTTPStubs.h>


@interface ViewController ()<NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURLConnection *connection;

@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupHTTPStubs];
    [self performRequestToRedirect];
}

/**
 stubs a 302 redirect response for all requests where the url contains "redirect"
 */
- (void)setupHTTPStubs
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        if ([request.URL.absoluteString containsString:@"redirect"]) {
             return YES;
        }
        
        return NO;
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(@"stubResponseContent.txt", [NSBundle mainBundle]) statusCode:302 headers:@{ @"Location" : @"http://google.com" , @"Content-Type" : @"text/xml"}];
    }];
}

- (void)performRequestToRedirect
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.example.com/redirect"]];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

#pragma mark - NSURLConnectionDelegate

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"connection did fail with error: %@", error);
}

#pragma mark - NSURLConnectionDataDelegate

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"connection did receive data");
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    NSLog(@"connection will send request; redirection response: %@", response);
    if (response) {
        return nil;
    }
    
    return request;
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"connection did receive response");
}

@end
