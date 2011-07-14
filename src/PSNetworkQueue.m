//
//  PSNetworkQueue.m
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 1/27/11.
//  Copyright 2011 Peter Shih. All rights reserved.
//

#import "PSNetworkQueue.h"

@interface PSNetworkQueue (Private)

- (void)queueDidFinish:(ASINetworkQueue *)queue;

@end

@implementation PSNetworkQueue

- (id)init {
  self = [super init];
  if (self) {
    [self setDelegate:self];
    [self setQueueDidFinishSelector:@selector(queueDidFinish:)];
//    [self setRequestDidStartSelector:@selector(requestDidStart:)];
//    [self setRequestDidFinishSelector:@selector(requestDidFinish:)];
//    [self setRequestDidFailSelector:@selector(requestDidFail:)];
    [self setSuspended:NO]; // Always enable queue
    
    _pendingRequests = [[NSMutableDictionary alloc] initWithCapacity:1];
  }
	return self;
}

- (void)dealloc {
  RELEASE_SAFELY(_pendingRequests);
  [super dealloc];
}

+ (PSNetworkQueue *)sharedQueue {
  static PSNetworkQueue *sharedQueue = nil;
  @synchronized(self) {
    if (sharedQueue == nil) {
      sharedQueue = [[self alloc] init];
    }
    return sharedQueue;
  }
}

#pragma mark - Request Preparation
//- (void)addOperation:(NSOperation *)op {
//  // Override this to check for duplicate requests
//  if (![op isKindOfClass:[ASIHTTPRequest class]]) {
//		[NSException raise:@"AttemptToAddInvalidRequest" format:@"Attempted to add an object that was not an ASIHTTPRequest to an ASINetworkQueue"];
//  }
//  
//  ASIHTTPRequest *newOp = (ASIHTTPRequest *)op;
//  
//  NSString *newUrlPath = [[newOp originalURL] absoluteString];
//  if ([_pendingRequests objectForKey:newUrlPath]) {
//    // request already pending, don't add another one
//  } else {
//    // Pass to ASINetworkQueue 
//    [super addOperation:op];
//  }
//}

#pragma mark - Delegate
- (void)requestDidStart:(ASIHTTPRequest *)request {
  NSString *urlPath = [[request originalURL] absoluteString];
  [_pendingRequests setObject:request forKey:urlPath];
}

- (void)requestDidFinish:(ASIHTTPRequest *)request {
  NSString *urlPath = [[request originalURL] absoluteString];
  [_pendingRequests removeObjectForKey:urlPath];
}

- (void)requestDidFail:(ASIHTTPRequest *)request {
  NSString *urlPath = [[request originalURL] absoluteString];
  [_pendingRequests removeObjectForKey:urlPath];
}

- (void)queueDidFinish:(ASINetworkQueue *)queue {
  VLog(@"queueDidFinish: %@", queue);
}

@end
