//
//  XLMultiSegmentedControl.h
//  XLMultiSegmentedControl
//
//  Created by lei xue on 15/12/6.
//  Copyright © 2015年 userstar. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Usage: initWithFrame, set normalColor, selectionColor and titles, then MUST makeUI to generate appropriate subviews.
 */
@interface XLMultiSegmentedControl : UIView
@property(copy, nonatomic) void(^valueChangedBlock)(NSUInteger valueIndex, BOOL isSelected);
@property(strong, nonatomic) UIColor *normalColor;
@property(strong, nonatomic) UIColor *selectionColor;
@property(strong, nonatomic) NSArray *titles;
@property(strong, nonatomic, setter=setSelectedIndexSet:) NSMutableIndexSet *selectedIndexSet;

- (void)selectAllSegments:(BOOL)select; // pass NO to deselect all
-(void)makeUI;
@end
