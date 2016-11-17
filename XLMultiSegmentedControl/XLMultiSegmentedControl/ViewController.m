//
//  ViewController.m
//  XLMultiSegmentedControl
//
//  Created by lei xue on 15/12/7.
//  Copyright © 2015年 userstar. All rights reserved.
//

#import "ViewController.h"
#import "XLMultiSegmentedControl.h"
#import "Masonry.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    XLMultiSegmentedControl *control = [[XLMultiSegmentedControl alloc] initWithTitles:@[@"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat", @"Sun"] normalColor:[UIColor whiteColor] selectionColor:[UIColor redColor]];
    control.titles = @[@"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat", @"Sun"];
    control.valueChangedBlock = ^(NSUInteger valueIndex, BOOL isSelected){
        if (control.selectedIndexSet.count == 0) {
            //must select at least one.
            control.selectedIndexSet = [NSMutableIndexSet indexSetWithIndex:valueIndex];
        }
    };
    control.selectedIndexSet = [[NSMutableIndexSet alloc] initWithIndexesInRange:NSMakeRange(1, 3)];
    [self.view addSubview:control];
    [control mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.right.equalTo(@-10);
        make.centerY.equalTo(self.view);
        make.height.equalTo(@30);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
