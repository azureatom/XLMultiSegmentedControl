//
//  XLMultiSegmentedControl.m
//  XLMultiSegmentedControl
//
//  Created by lei xue on 15/12/6.
//  Copyright © 2015年 userstar. All rights reserved.
//

#import "XLMultiSegmentedControl.h"

@interface XLMultiSegmentedControl()
@property(strong, nonatomic) NSMutableArray *labels;//array of UILabel. labels.count = titles.count
@property(strong, nonatomic) UIView *viewAfterFirstLabel;//覆盖在第一个label后半部分的UIView
@property(strong, nonatomic) UIView *viewBeforeLastLabel;//覆盖在最后一个label前半部分的UIView
@property(strong, nonatomic) NSMutableArray *dividers;//array of UIImageView. dividers.count = labels.count - 1
@property(strong, nonatomic) UIImage *dividerImage;
@property(strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@end

@implementation XLMultiSegmentedControl
@synthesize valueChangedBlock;
@synthesize normalColor;
@synthesize selectionColor;
@synthesize titles;
@synthesize selectedIndexSet = _selectedIndexSet;
@synthesize labels;
@synthesize viewAfterFirstLabel;
@synthesize viewBeforeLastLabel;
@synthesize dividers;
@synthesize dividerImage;
@synthesize tapGestureRecognizer;

-(void)setSelectedIndexSet:(NSMutableIndexSet *)selectedIndexSet{
    _selectedIndexSet = selectedIndexSet;
    [self updateUI];
}

- (void)selectAllSegments:(BOOL)select{
    self.selectedIndexSet = select ? [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.titles.count)] : [NSMutableIndexSet indexSet];
}

-(void)makeUI{
    const int shorterWidth = floorf(self.frame.size.width / titles.count);//如果shorterWidth为CGFloat，则某些位置的label和divider贴合不紧密。
    int numberOfLongerLabel = self.frame.size.width - shorterWidth * titles.count;//前numberOfLongerLabel个labe的长度比后面几个大1.
    const int longerWidth = numberOfLongerLabel > 0 ? shorterWidth + 1 : shorterWidth;
    const CGFloat eachHeight = self.frame.size.height;
    const CGFloat dividerWidth = 1;
    const CGFloat edgeCornerRadius = 3;
    
    self.layer.borderColor = self.selectionColor.CGColor;
    self.layer.borderWidth = 1;
    self.layer.cornerRadius = edgeCornerRadius;
    
    _selectedIndexSet = [NSMutableIndexSet new];
    labels = [NSMutableArray new];
    dividers = [NSMutableArray new];
    dividerImage = [self lineImageWithBodyColor:self.normalColor bodyHeight:eachHeight - 2 endsColor:self.selectionColor endsHeight:1];
    
    //第一个和最后一个label的cornerRadius同self.layer.cornerRadius，并且覆盖宽度为cornerRadius的UIView在第一个label后半部分和最后一个label前半部分。
    //bug:如果文字占满label，则label前或后面的文字可能被上面的UIView遮挡部分。需要改成drawRect方式处理cornerRadius。
    
    CGFloat x = 0;
    //第一个lable和divider
    UILabel *firstLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, (numberOfLongerLabel > 0 ? longerWidth : shorterWidth) - dividerWidth, eachHeight)];
    firstLabel.text = [titles firstObject];
    firstLabel.textAlignment = NSTextAlignmentCenter;
    firstLabel.font = [UIFont systemFontOfSize:14];
    firstLabel.layer.cornerRadius = edgeCornerRadius;
    firstLabel.clipsToBounds = YES;//防止backgroundColor显示到cornerRadius外面去
    [self addSubview:firstLabel];
    [labels addObject:firstLabel];
    viewAfterFirstLabel = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(firstLabel.frame) - edgeCornerRadius, 0, edgeCornerRadius, eachHeight)];
    [self addSubview:viewAfterFirstLabel];
    
    UIImageView *divider = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(firstLabel.frame), 0, dividerWidth, eachHeight)];
    [self addSubview:divider];
    [dividers addObject:divider];
    x += (numberOfLongerLabel-- > 0 ? longerWidth : shorterWidth);
    
    //中间的label和divider
    for(int i = 1; i < titles.count - 1; ++i){
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, (numberOfLongerLabel > 0 ? longerWidth : shorterWidth) - dividerWidth, eachHeight)];
        label.text = titles[i];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        [self addSubview:label];
        [labels addObject:label];
        
        UIImageView *divider = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label.frame), 0, dividerWidth, eachHeight)];
        [self addSubview:divider];
        [dividers addObject:divider];
        x += (numberOfLongerLabel-- > 0 ? longerWidth : shorterWidth);
    }
    
    //最后一个lable和divider
    UILabel *lastLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, self.frame.size.width - x, eachHeight)];
    lastLabel.text = [titles lastObject];
    lastLabel.textAlignment = NSTextAlignmentCenter;
    lastLabel.font = [UIFont systemFontOfSize:14];
    lastLabel.layer.cornerRadius = edgeCornerRadius;
    lastLabel.clipsToBounds = YES;
    [self addSubview:lastLabel];
    [labels addObject:lastLabel];
    viewBeforeLastLabel = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(lastLabel.frame), 0, edgeCornerRadius, eachHeight)];
    [self addSubview:viewBeforeLastLabel];
    
    if (tapGestureRecognizer == nil) {
        tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [self addGestureRecognizer:tapGestureRecognizer];
    }
    
    [self updateUI];
}

-(void)tapped:(UITapGestureRecognizer *)gesture{
    CGFloat x = [gesture locationInView:self].x;
    NSUInteger tappedIndex = MIN(x / (self.frame.size.width / titles.count), titles.count - 1);
    
    BOOL selectedBefore = [self.selectedIndexSet containsIndex:tappedIndex];
    if (selectedBefore) {
        [self.selectedIndexSet removeIndex:tappedIndex];
    }
    else{
        [self.selectedIndexSet addIndex:tappedIndex];
    }
    
    [self updateUI];
    if (valueChangedBlock) {
        valueChangedBlock(tappedIndex, !selectedBefore);
    }
}

-(void)updateUI{
    for (int i = 0; i < labels.count; ++i) {
        UILabel *label = labels[i];
        UIImageView *divider = i < labels.count - 1 ? dividers[i] : nil;
        
        if ([self.selectedIndexSet containsIndex:i]) {
            label.textColor = self.normalColor;
            label.backgroundColor = self.selectionColor;
            if (i == 0) {
                viewAfterFirstLabel.backgroundColor = self.selectionColor;
            }
            if (i == titles.count - 1) {
                viewBeforeLastLabel.backgroundColor = self.selectionColor;
            }
            
            if (divider) {
                //左右两边都为选中状态的divider，显示clearColor
                if ([self.selectedIndexSet containsIndex:i + 1]) {
                    divider.image = self.dividerImage;
                }
                else{
                    divider.image = nil;
                    divider.backgroundColor = self.selectionColor;
                }
            }
        }
        else{
            label.textColor = selectionColor;
            label.backgroundColor = [UIColor clearColor];
            if (i == 0) {
                viewAfterFirstLabel.backgroundColor = [UIColor clearColor];
            }
            if (i == titles.count - 1) {
                viewBeforeLastLabel.backgroundColor = [UIColor clearColor];
            }
            
            if (divider) {
                divider.image = nil;
                divider.backgroundColor = self.selectionColor;
            }
        }
    }
}

//generate image for vertical separator，whose ends color is endsColor and body color is bodyColor.
-(UIImage *)lineImageWithBodyColor:(UIColor *)bodyColor bodyHeight:(CGFloat)bodyHeight endsColor:(UIColor *)endsColor endsHeight:(CGFloat)endsHeight{
    const CGFloat width = 1;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, bodyHeight + 2 * endsHeight), NO, [UIScreen mainScreen].scale);
    [endsColor set];
    UIRectFill(CGRectMake(0, 0, width, endsHeight));
    UIRectFill(CGRectMake(0, endsHeight + bodyHeight, width, endsHeight));
    [bodyColor set];
    UIRectFill(CGRectMake(0, endsHeight, width, bodyHeight));
    UIImage *lineImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return lineImage;
}
@end
