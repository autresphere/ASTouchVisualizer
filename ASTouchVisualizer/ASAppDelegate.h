//
//  ASAppDelegate.h
//  ASTouchVisualizer
//
//  Created by Philippe Converset on 15/11/12.
//  Copyright (c) 2012 AutreSphere. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ASViewController;

@interface ASAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ASViewController *viewController;

@end
