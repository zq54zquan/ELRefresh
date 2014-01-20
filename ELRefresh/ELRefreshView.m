//
//  ELRefreshView.m
//  ELRefresh
//
//  Created by ZhouQuan on 14-1-20.
//  Copyright (c) 2014年 iOSTeam. All rights reserved.
//

#import "ELRefreshView.h"
#define ELREFRESHLASTDATE     @"ELREFRESHLASTDATE"
#define ELDRAWHEIGHT          60
@interface ELRefreshView()
@property (nonatomic,weak) UIScrollView *scrollView;
@property (nonatomic,strong) NSDate *lastFreshDate;
@end



@implementation ELRefreshView

-(instancetype)initWithScrollView:(UIScrollView *)scrollView refreshDirection:(ELRefreshDirection)direction
{
    if (self = [super initWithFrame:CGRectMake(0, -scrollView.bounds.size.height, scrollView.bounds.size.width, scrollView.bounds.size.height)]) {
        _scrollView = scrollView;
        if ([[NSUserDefaults standardUserDefaults] valueForKey:ELREFRESHLASTDATE]) {
            self.lastFreshDate = [[NSUserDefaults standardUserDefaults] valueForKey:ELREFRESHLASTDATE];
        }
        [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:Nil];
        [_scrollView addObserver:self forKeyPath:@"pan.state" options:NSKeyValueObservingOptionNew context:Nil];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{

    if (object == self.scrollView&&[keyPath isEqualToString:@"pan.state"]) {
        if ([[change valueForKey:@"new"] intValue] == UIGestureRecognizerStateEnded) {
            NSLog(@"release");
        }
    }else if(object == self.scrollView&&[keyPath isEqualToString:@"contentOffset"]){
        [self setNeedsDisplay];
    }
    
    
}


-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    UIFont *font = [UIFont boldSystemFontOfSize:10];
    float y = self.scrollView.contentOffset.y+64;
    float fac = 1-MAX(0,MIN(1,(y+ELDRAWHEIGHT)/ELDRAWHEIGHT));
    CGRect avaibleRect= CGRectMake(0, self.frame.size.height-ELDRAWHEIGHT, self.frame.size.width, ELDRAWHEIGHT);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
    CGContextAddArc(context, CGRectGetWidth(avaibleRect)*0.5, self.frame.size.height-ELDRAWHEIGHT+ELDRAWHEIGHT*0.25, ELDRAWHEIGHT*0.25, 0, 2*M_PI*fac, 0);
    NSLog(@"y:%f,ANGLE:%f",y,fac*360);
    CGContextStrokePath(context);
    NSString *hintString;
    if (fac==1) {
        hintString = @"释放立即刷新";
    }else{
        hintString = @"下拉刷新";
    }
    [hintString drawAtPoint:CGPointMake(CGRectGetWidth(avaibleRect)*0.5+0.25*ELDRAWHEIGHT, self.frame.size.height-ELDRAWHEIGHT+0.5*(ELDRAWHEIGHT*0.5-font.lineHeight)) withAttributes:@{NSFontAttributeName:font}];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
