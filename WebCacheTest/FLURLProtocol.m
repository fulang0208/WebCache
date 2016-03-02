//
//  CustomURLProtocol.m
//  WebCacheTest
//
//  Created by 傅浪 on 16/2/25.
//  Copyright © 2016年 傅浪. All rights reserved.
//

#import "FLURLProtocol.h"
#import "Reachability.h"

@interface FLURLProtocol ()
@property (nonatomic, strong) NSURLConnection *connection;
@end

static NSString *FLURLHeader = @"X-FLCache";

static NSObject *FLCachingSupportedSchemesMonitor;
static NSSet *FLCachingSupportedSchemes;

@implementation FLURLProtocol

+ (void)initialize
{
    if (self == [FLURLProtocol class])
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            FLCachingSupportedSchemesMonitor = [NSObject new];
        });
        
        [self setSupportedSchemes:[NSSet setWithObject:@"http"]];
    }
}
//get schemes which need cache offline
+ (NSSet *)supportedSchemes {
    NSSet *supportedSchemes;
    @synchronized(FLCachingSupportedSchemesMonitor)
    {
        supportedSchemes = FLCachingSupportedSchemes;
    }
    return supportedSchemes;
}
//set schemes which need cache offline
+ (void)setSupportedSchemes:(NSSet *)supportedSchemes
{
    @synchronized(FLCachingSupportedSchemesMonitor)
    {
        FLCachingSupportedSchemes = supportedSchemes;
    }
}
#pragma mark - NSURLProtocol methods

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if ([[self supportedSchemes] containsObject:request.URL.scheme] &&
        [request valueForHTTPHeaderField:FLURLHeader] == nil) {
        return YES;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading {
    NSCachedURLResponse *response = [[NSURLCache sharedURLCache] cachedResponseForRequest:self.request];
    NSMutableURLRequest *connectionRequest = [self.request mutableCopy];
    [connectionRequest setValue:@"" forHTTPHeaderField:FLURLHeader];
    if ([self networkReachable]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response.response;
        if (httpResponse) {
            [connectionRequest setValue:httpResponse.allHeaderFields[@"Last-Modified"] forHTTPHeaderField:@"Last-Modified"];
            [connectionRequest setValue:httpResponse.allHeaderFields[@"Etag"] forHTTPHeaderField:@"Etag"];
        }
        self.connection = [NSURLConnection connectionWithRequest:connectionRequest delegate:self];
    }else if (response) {
        [self.client URLProtocol:self didReceiveResponse:response.response cacheStoragePolicy:NSURLCacheStorageAllowed];
        [self.client URLProtocol:self didLoadData:response.data];
        [self.client URLProtocolDidFinishLoading:self];
    }else {
        [self.client URLProtocol:self didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCannotConnectToHost userInfo:nil]];
    }
}

- (void)stopLoading {
    [self.connection cancel];
}

#pragma mark - NSURLConnectionDataDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (httpResponse && httpResponse.statusCode == 304) {
        NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:self.request];
        if (cachedResponse) {
            [self.client URLProtocol:self didReceiveResponse:cachedResponse.response cacheStoragePolicy:NSURLCacheStorageAllowed];
            [self.client URLProtocol:self didLoadData:cachedResponse.data];
            [self.client URLProtocolDidFinishLoading:self];
        }
    }else {
        [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
    self.connection = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
    self.connection = nil;
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    
    return cachedResponse;
}

- (BOOL)networkReachable {
    return [[Reachability reachabilityWithHostName:self.request.URL.host] currentReachabilityStatus] != NotReachable;
}
@end
