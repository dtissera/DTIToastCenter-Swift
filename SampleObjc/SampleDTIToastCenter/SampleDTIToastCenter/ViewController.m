//
//  ViewController.m
//  SampleDTIToastCenter
//
//  Created by dtissera on 29/08/2014.
//  Copyright (c) 2014 o--O--o. All rights reserved.
//

#import "ViewController.h"
#import "SampleDTIToastCenter-Swift.h"

@interface ViewController () {
    UITextField *textField;
}

- (void)displayKeyboard;
- (void)hideKeyboard;
- (IBAction)actionToastMe:(id)sender;

@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)actionToastMe:(id)sender {
    [[DTIToastCenter defaultCenter] makeImage:[UIImage imageNamed:@"swift"]];
}

- (void)viewDidAppear:(BOOL)animated {
    [[DTIToastCenter defaultCenter] makeText:@"Hey! This is the toast system."];
    [[DTIToastCenter defaultCenter] makeText:@"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda. Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."];
    [self performSelector:@selector(displayKeyboard) withObject:nil afterDelay:3.0];
    [[DTIToastCenter defaultCenter] makeText:@"Toast with image !" image:[UIImage imageNamed:@"swift"]];
}

- (void)displayKeyboard {
    textField = [[UITextField alloc] initWithFrame:CGRectZero];
    [self.view addSubview:textField];
    
    [textField becomeFirstResponder];
    
    [self performSelector:@selector(hideKeyboard) withObject:nil afterDelay:4.0];
}

- (void)hideKeyboard {
    [textField resignFirstResponder];
}

@end
