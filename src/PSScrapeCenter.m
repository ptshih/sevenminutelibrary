//
//  PSScrapeCenter.m
//  Spotlight
//
//  Created by Peter Shih on 8/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PSScrapeCenter.h"
#import "TFHpple.h"

@implementation PSScrapeCenter

+ (id)defaultCenter {
  static id defaultCenter = nil;
  if (!defaultCenter) {
    defaultCenter = [[self alloc] init];
  }
  return defaultCenter;
}

- (id)init {
  self = [super init];
  if (self) {
  }
  return self;
}

- (void)dealloc {
  [super dealloc];
}

#pragma mark - Public Methods
- (NSString *)scrapeNumberOfPhotosWithHTMLString:(NSString *)htmlString {
  // HTML Scraping
  NSString *strippedString = [htmlString stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
  NSData *strippedData = [strippedString dataUsingEncoding:NSUTF8StringEncoding];
  
  TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:strippedData];
  NSArray *numPhotosArray = [xpathParser searchWithXPathQuery:@"//div[@id=\"mainContent\"]//td[@class=\"pager_current\"]"];
  NSLog(@"asdf: %@", numPhotosArray);
  if ([numPhotosArray count] > 0) {
    NSString *numPhotosRaw = [[numPhotosArray objectAtIndex:0] content];
    NSRange ofRange = [numPhotosRaw rangeOfString:@" of "];
    NSString *numPhotos = [numPhotosRaw substringFromIndex:(ofRange.location + ofRange.length)];
    return numPhotos;
  } else {
    return @"0";
  }
}

- (NSArray *)scrapePhotosWithHTMLString:(NSString *)htmlString {
  // HTML Scraping
  NSString *strippedString = [htmlString stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
  NSData *strippedData = [strippedString dataUsingEncoding:NSUTF8StringEncoding];
  
  TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:strippedData];
  NSArray *elements  = [xpathParser searchWithXPathQuery:@"//div[@id=\"mainContent\"]//img"];
  
  NSMutableArray *photoArray = [NSMutableArray array];
  for (TFHppleElement *element in elements) {
    // Get the photo src url
    NSString *src = [[element objectForKey:@"src"] stringByReplacingOccurrencesOfString:@"ms.jpg" withString:@"l.jpg"];
    
    // Get the photo caption
    NSString *alt = [element objectForKey:@"alt"];
    
    NSDictionary *photoDict = [NSDictionary dictionaryWithObjectsAndKeys:src, @"src", alt, @"alt", nil];
    [photoArray addObject:photoDict];
  }
  
  VLog(@"Photos: %@", photoArray);
  
  [xpathParser release];
  
  return photoArray;
}

- (NSArray *)scrapePlacesWithHTMLString:(NSString *)htmlString {
  // HTML Scraping
  NSString *strippedString = [htmlString stringByReplacingOccurrencesOfString:@"<br>" withString:@""];
  NSData *strippedData = [strippedString dataUsingEncoding:NSUTF8StringEncoding];
  
  TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:strippedData];
  NSArray *elements  = [xpathParser searchWithXPathQuery:@"//span[@class=\"address\"]"];
  
  NSMutableArray *placeArray = [NSMutableArray array];
  int i = 0;
  for (TFHppleElement *element in elements) {
    // Add an internal autoincrementing index
    NSNumber *index = [NSNumber numberWithInt:i];
    
    // Get the business id string that is used to identify this place
    NSString *biz = [[[[[element firstChild] firstChild] attributes] objectForKey:@"href"] stringByReplacingOccurrencesOfString:@"/biz/" withString:@""];
    
    // Get the business name
    NSString *name = [[[element firstChild] firstChild] content];
    
    // Find Distance in Miles
    NSRange milesRange = [[element content] rangeOfString:@"miles"];
    NSString *distance = nil;
    if (NSEqualRanges(NSMakeRange(NSNotFound, 0), milesRange)) {
      distance = @"0.00";
    } else {
      distance = [[element content] substringToIndex:(milesRange.location-1)];
    }
    
    // Find Price in $
    NSRange priceRange = [[element content] rangeOfString:@"Price: "];
    NSString *price = nil;
    if (NSEqualRanges(NSMakeRange(NSNotFound, 0), priceRange)) {
      price = @"";
    } else {
      price = [[element content] substringFromIndex:(priceRange.location + priceRange.length)];
    }
    
    // Find Phone Number
    NSString *phone = [[[element children] lastObject] content];
    
    // Create payload, add to array
    NSMutableDictionary *placeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:index, @"index", biz, @"biz", name, @"name", distance, @"distance", price, @"price", phone, @"phone", nil];
    [placeArray addObject:placeDict];
    
    i++;
  }
  
  VLog(@"Places: %@", placeArray);
  
  [xpathParser release];
  
  return placeArray;
}

@end
