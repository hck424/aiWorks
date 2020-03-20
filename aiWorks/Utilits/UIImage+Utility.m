//
//  UIImage+Utility.m
//  aiWorks
//
//  Created by 김학철 on 2020/03/17.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "UIImage+Utility.h"

@implementation UIImage (Utility)
- (UIImage *)resizedImageWithBounds:(CGSize)bounds {
    
    //uses the “aspect fit” approach to keep the aspect ratio intact
    CGFloat horizontalRatio = bounds.width / self.size.width;
    CGFloat verticalRatio = bounds.height / self.size.height;
    CGFloat ratio = MIN(horizontalRatio, verticalRatio);
    
    CGSize newSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio);
    
    //creates a new image context and draws the image into that
    UIGraphicsBeginImageContextWithOptions(newSize, YES, 0);
    
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
