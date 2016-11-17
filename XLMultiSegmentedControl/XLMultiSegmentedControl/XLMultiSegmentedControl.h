//
//  XLMultiSegmentedControl.h
//  XLMultiSegmentedControl
//
//  Created by lei xue on 15/12/6.
//  Copyright © 2015年 userstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XLMultiSegmentedControl : UIView
@property(copy, nonatomic) void(^valueChangedBlock)(NSUInteger valueIndex, BOOL isSelected);
@property(strong, nonatomic) NSArray *titles;
@property(strong, nonatomic, setter=setSelectedIndexSet:) NSMutableIndexSet *selectedIndexSet;

-(id)initWithTitles:(NSArray *)ts normalColor:(UIColor *)nColor selectionColor:(UIColor *)sColor;
- (void)selectAllSegments:(BOOL)select; // pass NO to deselect all
@end
