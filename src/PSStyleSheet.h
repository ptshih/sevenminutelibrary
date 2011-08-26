//
//  PSStyleSheet.h
//  MealTime
//
//  Created by Peter Shih on 8/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSStyleSheet : NSObject

+ (void)setStyleSheet:(NSString *)styleSheet;
+ (UIFont *)fontForStyle:(NSString *)style;
+ (UIColor *)textColorForStyle:(NSString *)style;
+ (UIColor *)shadowColorForStyle:(NSString *)style;
+ (CGSize)shadowOffsetForStyle:(NSString *)style;

@end
