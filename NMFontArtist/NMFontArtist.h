//
//  NMFontArtist.h
//  NMFontArtist
//
//  Created by Salazar, Alexandros on 7/12/12.
//  Copyright (c) 2012 nomothetis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NMFontArtist : NSObject

/*
 Draws an embossed image of the strig; technically, shadow parameters could also be passed into this method to
 allow greater granularity, but for now, I'll let them be defined in here.
 */
+ (UIImage *)engravedImageOfString:(NSString *)string withFont:(UIFont *)font color:(UIColor *)color size:(CGSize)size;

@end
