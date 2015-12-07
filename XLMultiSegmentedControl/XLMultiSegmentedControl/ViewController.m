//
//  ViewController.m
//  XLMultiSegmentedControl
//
//  Created by lei xue on 15/12/7.
//  Copyright © 2015年 userstar. All rights reserved.
//

#import "ViewController.h"
#import "XLMultiSegmentedControl.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    XLMultiSegmentedControl *control = [[XLMultiSegmentedControl alloc] initWithFrame:CGRectMake(28, 60, 264, 29)];
    control.titles = @[@"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat", @"Sun"];
    
    control.normalColor = [UIColor whiteColor];
    control.selectionColor = [UIColor redColor];
    [control makeUI];
    control.valueChangedBlock = ^(NSUInteger valueIndex, BOOL isSelected){
        if (control.selectedIndexSet.count == 0) {
            //must select at least one.
            control.selectedIndexSet = [NSMutableIndexSet indexSetWithIndex:valueIndex];
        }
    };
    [self.view addSubview:control];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
