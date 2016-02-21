//
//  RCRootViewController.m
//  RCStarActivityIndicatorView
//
//  Created by Randy Cutshaw on 02/21/2016.
//  Copyright (c) 2016 Randy Cutshaw. All rights reserved.
//

#import "RCRootViewController.h"
#import "RCStarActivityIndicatorView.h"

@interface RCRootViewController ()
@property (nonatomic, strong) IBOutlet RCStarActivityIndicatorView *activityIndicatorView;
@end

@implementation RCRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Defaults
    //[self.activityIndicatorView setNumberOfStars:5];
    //[self.activityIndicatorView setAnimationDuration:1.5f];
    //[self.activityIndicatorView setStarSize:CGSizeMake(20.0f, 20.0f)];
    
    [self.activityIndicatorView startAnimating];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)onTap:(UIGestureRecognizer *)tapGestureRecognizer
{
    if([self.activityIndicatorView isAnimating]) {
        [self.activityIndicatorView stopAnimating];
    } else {
        [self.activityIndicatorView startAnimating];
    }
}

@end
