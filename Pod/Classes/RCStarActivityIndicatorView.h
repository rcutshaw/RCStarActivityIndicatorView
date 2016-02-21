//
//  RCStarActivityIndicatorView.h
//  Pods
//
//  Created by David Cutshaw on 2/21/16.
//
//

#import <UIKit/UIKit.h>

@interface RCStarActivityIndicatorView : UIView

@property (nonatomic, assign) NSUInteger numberOfStars;

@property (nonatomic, strong) UIColor *starColor;

@property (nonatomic, assign) CGSize starSize;

@property (nonatomic, assign) NSTimeInterval animationDuration;

- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;

@end
