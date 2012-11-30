//
//  NMFontArtist.m
//  NMFontArtist
//
//  Created by Salazar, Alexandros on 7/12/12.
//  Copyright (c) 2012 nomothetis. All rights reserved.
//

#import "NMFontArtist.h"

/*
 This class creates an imprinted look for fonts. It is heavily (in fact, almost exclusively)
 based on the code found in the answer to this Stack Overflow question:
 
 http://stackoverflow.com/questions/8467141/ios-how-to-achieve-emboss-effect-for-the-text-on-uilabel
 
 Credit to Rob Mayoff for ceating it and distributing it. I have merely added the comments,
 mostly to clarify for myself what's going on. As I am not an expert, they reflect my best current
 understanding, and may need to be revised. Use for learning at your own peril.
 */

@implementation NMFontArtist

/* This mask is created for two purposes:
 
 1. To use to draw the full string.
 2. To draw the inner shadow of the string.
 
 The UIImage is simply a convenient vessel for the CGImage memory-wise.
 
 */
+ (UIImage *)maskWithString:(NSString *)string font:(UIFont *)font size:(CGSize)size {
    CGRect imageRect = { CGPointZero, size };
    
    /* In order to account for retina displays. */
    CGFloat scale = [UIScreen mainScreen].scale;
    
    /* The color space is grey because the shadow will no be in color. */
    CGColorSpaceRef greySpace = CGColorSpaceCreateDeviceGray();
    
    CGContextRef context = CGBitmapContextCreate(NULL, // Don't need to draw anywhere specific.
                                                 size.width * scale,
                                                 size.height * scale,
                                                 8,
                                                 size.width * scale, // Since we're using 8 bits/pixel
                                                 greySpace,
                                                 kCGImageAlphaOnly); // No RGB, since the mask only draws a shadow.
    /*
     Scaling the graphics context to account for retina; otherwise the size may be too small
     on retina-capable devices.
     */
    CGContextScaleCTM(context, scale, scale);
    
    CGColorSpaceRelease(greySpace); /* The context retains it as needed.  */
    
    /*
     Actually draw the string in the context; we'll get the image from that.
     It will take the white color (which is irrelevant since this is an alpha channel
     mask only---only the fact that there is something there matters).
     */
    UIGraphicsPushContext(context); {
        [[UIColor whiteColor] setFill];
        
        /*
         Draw the string shape in the context.
         */
        [string drawInRect:imageRect withFont:font];
    } UIGraphicsPopContext();
    
    /*
     Create the image to be used as the mask.
     */
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    
    UIImage *image = [UIImage imageWithCGImage:cgImage scale:scale orientation:UIImageOrientationUpMirrored];
    CGImageRelease(cgImage);
    
    return image;
    
}

/* We use the inverted mask to draw the outer shadow. */
+ (UIImage *)maskByInvertingMask:(UIImage *)mask {
    CGRect invertedMaskRect = { CGPointZero, mask.size };
    
    UIImage *invertedMask;
    UIGraphicsBeginImageContextWithOptions(mask.size, NO, mask.scale); {
        [[UIColor blackColor] setFill];
        UIRectFill(invertedMaskRect);
        
        /*
         Clipping to mask ensures that all further drawing will happen in the clipped space,
         i.e., the passed image.
         */
        CGContextClipToMask(UIGraphicsGetCurrentContext(), invertedMaskRect, mask.CGImage);
        
        /*
         Therefore, drawing the clear rectangle clears *only the passed image*, leaving the
         outside drawn in black; this is our inverted image.
         */
        CGContextClearRect(UIGraphicsGetCurrentContext(), invertedMaskRect);
        
        invertedMask = UIGraphicsGetImageFromCurrentImageContext();
    } UIGraphicsEndImageContext();
    
    return invertedMask;
    
}

/* We use this method to add an inside shadow. */
+ (UIImage *)imageByAddingUpwardShadowToImage:(UIImage *)image {
    UIImage *shadedImage;
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale); {
        /* Create the shadow. */
        CGContextSetShadowWithColor(UIGraphicsGetCurrentContext(),
                                    CGSizeMake(0, -1),
                                    1,
                                    [UIColor colorWithWhite:0 alpha:0.05].CGColor);
        
        /* The shadow is added around the non-transparent image; in our case, around the string. */
        [image drawAtPoint:CGPointZero];
        shadedImage = UIGraphicsGetImageFromCurrentImageContext();
    } UIGraphicsEndImageContext();
    
    return shadedImage;
}

+ (UIImage *)engravedImageOfString:(NSString *)string
                          withFont:(UIFont *)font
                             color:(UIColor *)color
                              size:(CGSize)size {
    CGRect imageSizeRect = { CGPointZero, size };
    UIImage *mask = [[self class] maskWithString:string font:font size:size];
    UIImage *invertedMask = [[self class] maskByInvertingMask:mask];
    
    UIImage *unshadedImage;
    UIGraphicsBeginImageContextWithOptions(imageSizeRect.size, NO, [UIScreen mainScreen].scale); {
        CGContextRef gc = UIGraphicsGetCurrentContext();
        
        /* Ensure any drawing happens inside the string shape. */
        CGContextClipToMask(gc, imageSizeRect, mask.CGImage);
        
        /* For aesthetic reasons, we apply the mask twice; the edges will be too rough otherwise. */
        CGContextClipToMask(gc, imageSizeRect, mask.CGImage);
        
        /*
         Draw the text in the desired color. Remember that since we set the clipping mask,
         only thigns inside the mask will be drawn.
         */
        [color setFill];
        CGContextFillRect(gc, imageSizeRect);
        
        
        /* Define the shadow. */
        CGContextSetShadowWithColor(gc, CGSizeZero, 1.6, [UIColor colorWithWhite:0.3 alpha:1].CGColor);
        
        /*
         Now draw it; this is what we use the inverted mask for: shadows are drawn
         *outside* of the defined image. Since the mask masks the inside of the string,
         the same inside is outside the mask, and the shadow will be applied there.
         
         Note also that the actual outside is not drawn, because it is clipped away by the clipping
         a few lines up. So the *only* thing that gets drawn is the shadow. Neat, eh?
         */
        [invertedMask drawAtPoint:CGPointZero];
        
        unshadedImage = UIGraphicsGetImageFromCurrentImageContext();
    } UIGraphicsEndImageContext();
    
    return [[self class] imageByAddingUpwardShadowToImage:unshadedImage];
    
}



@end
