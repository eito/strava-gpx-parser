//
//  NavController.m
//  strava-gpx-parser
//
//  Created by Eric Ito on 11/8/13.
//  Copyright (c) 2013 Eric Ito. All rights reserved.
//

#import "NavController.h"

@interface NavController ()

@end

@implementation NavController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *navColor = [UIColor blueColor];
    
    [[UINavigationBar appearance] setBarTintColor:navColor];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    [self setNeedsStatusBarAppearanceUpdate];    
}

@end
