//
//  XLMultiSegmentedControl.m
//  XLMultiSegmentedControl
//
//  Created by lei xue on 15/12/6.
//  Copyright © 2015年 userstar. All rights reserved.
//

#import "XLMultiSegmentedControl.h"
#import "Masonry.h"

@interface XLMultiSegmentedControl()
@property(strong, nonatomic) UIColor *normalColor;
@property(strong, nonatomic) UIColor *selectionColor;
@property(strong, nonatomic) NSMutableArray *labels;//array of UILabel. labels.count = titles.count
@property(strong, nonatomic) UIView *viewAfterFirstLabel;//覆盖在第一个label后半部分的UIView
@property(strong, nonatomic) UIView *viewBeforeLastLabel;//覆盖在最后一个label前半部分的UIView
@property(strong, nonatomic) NSMutableArray *dividers;//array of UIView. dividers.count = labels.count - 1
@property(strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@end

@implementation XLMultiSegmentedControl
@synthesize valueChangedBlock;
@synthesize titles;
@synthesize normalColor;
@synthesize selectionColor;
@synthesize selectedIndexSet = _selectedIndexSet;
@synthesize labels;
@synthesize viewAfterFirstLabel;
@synthesize viewBeforeLastLabel;
@synthesize dividers;
@synthesize tapGestureRecognizer;

-(id)initWithTitles:(NSArray *)ts normalColor:(UIColor *)nColor selectionColor:(UIColor *)sColor{
    self = [super init];
    if (self) {
        titles = ts;
        normalColor = nColor;
        selectionColor = sColor;
        
        [self createUI];
    }
    return self;
}

-(void)setSelectedIndexSet:(NSMutableIndexSet *)selectedIndexSet{
    _selectedIndexSet = selectedIndexSet;
    [self updateUI];
}

- (void)selectAllSegments:(BOOL)select{
    self.selectedIndexSet = select ? [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.titles.count)] : [NSMutableIndexSet indexSet];
}

-(void)createUI{
    const CGFloat kDividerWidth = 1;
    const CGFloat kEdgeCornerRadius = 3;
    
    self.layer.borderColor = self.selectionColor.CGColor;
    self.layer.borderWidth = 1;
    self.layer.cornerRadius = kEdgeCornerRadius;
    
    _selectedIndexSet = [NSMutableIndexSet new];
    labels = [NSMutableArray new];
    dividers = [NSMutableArray new];
    
    //第一个和最后一个label的cornerRadius同self.layer.cornerRadius，并且覆盖宽度为cornerRadius的UIView在第一个label后半部分和最后一个label前半部分。
    //bug:如果文字占满label，则label前或后面的文字可能被上面的UIView遮挡部分。需要改成drawRect方式处理cornerRadius。
    
    //第一个lable和divider
    UILabel *firstLabel = [[UILabel alloc] init];
    firstLabel.text = [titles firstObject];
    firstLabel.textAlignment = NSTextAlignmentCenter;
    firstLabel.font = [UIFont systemFontOfSize:14];
    firstLabel.layer.cornerRadius = kEdgeCornerRadius;
    firstLabel.clipsToBounds = YES;//防止backgroundColor显示到cornerRadius外面去
    [self addSubview:firstLabel];
    [firstLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.top.equalTo(@0);
        make.height.equalTo(self);
    }];
    [labels addObject:firstLabel];
    
    viewAfterFirstLabel = [[UIView alloc] init];
    [self addSubview:viewAfterFirstLabel];
    [viewAfterFirstLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(firstLabel.mas_right).offset(-kEdgeCornerRadius);
        make.top.equalTo(@0);
        make.width.equalTo(@(kEdgeCornerRadius));
        make.height.equalTo(self);
    }];
    
    UIView *divider = [[UIView alloc] init];
    [self addSubview:divider];
    [divider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(firstLabel.mas_right);
        make.top.equalTo(@0);
        make.width.equalTo(@(kDividerWidth));
        make.height.equalTo(self);
    }];
    [dividers addObject:divider];
    
    //中间的label和divider
    for(int i = 1; i < titles.count - 1; ++i){
        UILabel *label = [[UILabel alloc] init];
        label.text = titles[i];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:14];
        [self addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(((UIView *)dividers[i - 1]).mas_right);
            make.top.equalTo(@0);
            make.width.equalTo(firstLabel);
            make.height.equalTo(self);
        }];
        [labels addObject:label];
        
        UIView *divider = [[UIView alloc] init];
        [self addSubview:divider];
        [divider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(label.mas_right);
            make.top.equalTo(@0);
            make.width.equalTo(@(kDividerWidth));
            make.height.equalTo(self);
        }];
        [dividers addObject:divider];
    }
    
    //最后一个lable
    UILabel *lastLabel = [[UILabel alloc] init];
    lastLabel.text = [titles lastObject];
    lastLabel.textAlignment = NSTextAlignmentCenter;
    lastLabel.font = [UIFont systemFontOfSize:14];
    lastLabel.layer.cornerRadius = kEdgeCornerRadius;
    lastLabel.clipsToBounds = YES;
    [self addSubview:lastLabel];
    [lastLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(((UIView *)dividers.lastObject).mas_right);
        make.right.equalTo(@0);
        make.top.equalTo(@0);
        make.width.equalTo(firstLabel);
        make.height.equalTo(self);
    }];
    [labels addObject:lastLabel];
    
    viewBeforeLastLabel = [[UIView alloc] init];
    [self addSubview:viewBeforeLastLabel];
    [viewBeforeLastLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(lastLabel.mas_left);
        make.top.equalTo(@0);
        make.width.equalTo(@(kEdgeCornerRadius));
        make.height.equalTo(self);
    }];
    
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
        UIView *divider = i < labels.count - 1 ? dividers[i] : nil;
        
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
                    divider.backgroundColor = self.normalColor;
                }
                else{
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
