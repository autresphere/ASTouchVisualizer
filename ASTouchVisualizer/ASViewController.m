//
//  ASViewController.m
//  ASTouchVisualizer
//
//  Created by Philippe Converset on 15/11/12.
//  Copyright (c) 2012 AutreSphere. All rights reserved.
//

#import "ASViewController.h"


/*
 Tentative pour capturer les evenements touch sans les bloquer.
 Une vue transparente est placée par dessus.
 */
@interface ASViewController ()

@end

@implementation ASViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleTapGesture:(UITapGestureRecognizer *)sender
{
    NSLog(@"TAP");
}
@end
