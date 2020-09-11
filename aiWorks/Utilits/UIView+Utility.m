//
//  UIView+Utility.m
//  aiWorks
//
//  Created by 김학철 on 2020/02/29.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "UIView+Utility.h"
#define  TAG_LOADING_IMG 111000

@implementation UIView (Utility)

- (void)startAnimationWithRaduis:(CGFloat)raduis {
    NSString *imageName = @"loading";
    
    UIImageView *indicator = [self viewWithTag:TAG_LOADING_IMG];
    if (indicator) {
        [indicator removeFromSuperview];
    }
    
    self.hidden = NO;
    [[self superview] bringSubviewToFront:self];
    
    UIImageView *ivIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 2*raduis, 2*raduis)];
    //    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    ivIndicator.tag = TAG_LOADING_IMG;
    ivIndicator.contentMode = UIViewContentModeScaleAspectFit;
    ivIndicator.image = [UIImage imageNamed:imageName];
    [self addSubview:ivIndicator];
    indicator.layer.borderWidth = 1.0f;
    indicator.layer.borderColor = [UIColor redColor].CGColor;
    //    CGPoint point = self.center;
    //    ivIndicator.center = CGPointMake(point.x, point.y - raduis);
    ivIndicator.frame = CGRectMake((self.frame.size.width - ivIndicator.frame.size.width) / 2,
                                   (self.frame.size.height - ivIndicator.frame.size.height)/2,
                                   ivIndicator.frame.size.width, ivIndicator.frame.size.height);
    
    CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotation.fromValue = [NSNumber numberWithFloat:0.0f];
    rotation.toValue = [NSNumber numberWithFloat:-2*M_PI];
    rotation.duration = 1;
    rotation.repeatCount = INFINITY;
    
    [ivIndicator.layer addAnimation:rotation forKey:@"loading"];
    
}

- (void)startAnimation{
    UIImageView *ivIndicator = (UIImageView *)[self viewWithTag:TAG_LOADING_IMG];

    NSArray *values = [NSArray arrayWithObjects:
                       [NSNumber numberWithFloat: -0.0],
                       [NSNumber numberWithFloat: -M_PI_4],
                       [NSNumber numberWithFloat: -2*M_PI_2],
                       [NSNumber numberWithFloat: -2*M_PI],
                       nil];

    NSArray *timing = [NSArray arrayWithObjects:
                       [NSNumber numberWithFloat:0.0],
                       [NSNumber numberWithFloat:0.25],
                       [NSNumber numberWithFloat:0.5],
                       [NSNumber numberWithFloat:0.75],
                       nil];

    float duration = 1.5f;
    CAKeyframeAnimation *rotation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    rotation.values = values;
    rotation.keyTimes = timing;
    rotation.duration = duration;
    rotation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    rotation.repeatCount = INT_MAX;

//    CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
//    rotation.fromValue = [NSNumber numberWithFloat:0.0f];
//    rotation.toValue = [NSNumber numberWithFloat:-2*M_PI];
//    rotation.duration = 1;
//    rotation.repeatCount = INFINITY;

    [ivIndicator.layer addAnimation:rotation forKey:@"loading"];
    self.hidden = NO;
    [[self superview] bringSubviewToFront:self];

}

- (void)stopAnimation {
    self.hidden = YES;
    UIImageView *indicator = (UIImageView *)[self viewWithTag:TAG_LOADING_IMG];
    if (indicator){
        [indicator.layer removeAnimationForKey:@"loading"];
//        [indicator removeFromSuperview];
    }
}

@end

