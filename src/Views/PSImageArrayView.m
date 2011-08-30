//
//  PSImageArrayView.m
//  SevenMinuteLibrary
//
//  Created by Peter Shih on 5/17/11.
//  Copyright 2011 Seven Minute Labs. All rights reserved.
//

#import "PSImageArrayView.h"
#import "PSImageCache.h"
#import "UIImage+SML.h"

@implementation PSImageArrayView

@synthesize urlPathArray = _urlPathArray;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _animateIndex = 0;
    _shouldScale = NO;
    _images = [[NSMutableArray alloc] init];

    self.backgroundColor = [UIColor blackColor];
  }
  return self;
}

- (void)dealloc {
  [self.layer removeAllAnimations];
  RELEASE_SAFELY(_urlPathArray);
  RELEASE_SAFELY(_images);
  INVALIDATE_TIMER(_animateTimer);
  
  [super dealloc];
}

#pragma mark Array of Images
- (void)loadImageArray {
  // Download all images
  for (NSString *urlPath in _urlPathArray) {
    UIImage *image = [[PSImageCache sharedCache] imageForURLPath:urlPath shouldDownload:YES withDelegate:nil];
    if (image) {
      [_images addObject:image];
      [self prepareImageArray];
    }
  }
}

- (void)unloadImageArray {
  INVALIDATE_TIMER(_animateTimer);
  _animateIndex = 0;
  [_images removeAllObjects];
  [self.layer removeAllAnimations];
  self.image = nil;
}

- (void)prepareImageArray {
  if ([_images count] == 1) {
    [self setImage:[_images objectAtIndex:0] animated:YES];
  } else if ([_images count] > 1 && !_animateTimer) {
    _animateTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:3.0] interval:9.0 target:self selector:@selector(animateImages) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_animateTimer forMode:NSDefaultRunLoopMode];
  }
}

- (void)animateImages {
  if (![_animateTimer isValid]) return;  
  CABasicAnimation *crossFade = [CABasicAnimation animationWithKeyPath:@"contents"];
  crossFade.duration = 4.0;
  crossFade.fromValue = (id)[[_images objectAtIndex:_animateIndex] CGImage];
  
  _animateIndex++;
  if (_animateIndex == [_images count]) {
    _animateIndex = 0;
  }
  
  crossFade.toValue = (id)[[_images objectAtIndex:(_animateIndex)] CGImage];
  [self.layer addAnimation:crossFade forKey:@"animateContents"];
  
  [self setImage:[_images objectAtIndex:_animateIndex] animated:NO];
}

- (void)resumeAnimations {
  [self prepareImageArray];
}

- (void)pauseAnimations {
  [self.layer removeAllAnimations];
  INVALIDATE_TIMER(_animateTimer);
}

#pragma mark - PSImageCacheNotification
- (void)imageCacheDidLoad:(NSNotification *)notification {
  NSDictionary *userInfo = [notification userInfo];
  NSString *urlPath = [userInfo objectForKey:@"urlPath"];
  NSData *imageData = [userInfo objectForKey:@"imageData"];
  
  if (imageData && [_urlPathArray containsObject:urlPath]) {
    UIImage *image = [UIImage imageWithData:imageData];
    [_images addObject:image];
    [self prepareImageArray];
  }
}

#pragma mark - PSImageCacheDelegate
//- (void)imageCacheDidLoad:(NSData *)imageData forURLPath:(NSString *)urlPath {
//  if (imageData && [_urlPathArray containsObject:urlPath]) {
//    UIImage *image = [UIImage imageWithData:imageData];
//    [_images addObject:image];
//    [self prepareImageArray];
//  }
//}


@end
