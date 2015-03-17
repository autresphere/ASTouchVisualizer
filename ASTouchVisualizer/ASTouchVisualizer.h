//
//  ASTouchVisualizer.h
//  ASTouchVisualizer
//
//  Created by Philippe Converset on 15/11/12.
//  Copyright (c) 2012 AutreSphere. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ASTouchVisualizer : NSObject

+ (BOOL)isInstalled;

+ (void)install;

+ (void)uninstall;

@end
