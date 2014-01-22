//
//  ELRefreshView.m
//  ELRefresh
//
//  Created by ZhouQuan on 14-1-20.
//  Copyright (c) 2014年 iOSTeam. All rights reserved.
//

#import "ELRefreshView.h"

#define ELDRAWHEIGHT          64


@interface ELRefreshView()
@property (nonatomic,weak) UIScrollView *scrollView;
@property (nonatomic,strong) NSDate *lastFreshDate;
@property (nonatomic, copy) NSString *lastUpdateText;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, assign) float rotation;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, assign) ELRefreshDirection direction;
@end


@implementation ELRefreshView

-(instancetype)initWithScrollView:(UIScrollView *)scrollView refreshDirection:(ELRefreshDirection)direction
{
    float addedHeight = 0;
    if ( ELRefreshTop == direction) {
        addedHeight = scrollView.contentInset.top;
    }else{
        addedHeight = -scrollView.contentInset.bottom+scrollView.frame.size.height-ELDRAWHEIGHT;
    }
    if (self = [super initWithFrame:CGRectMake(scrollView.frame.origin.x, scrollView.frame.origin.y+addedHeight, scrollView.frame.size.width, ELDRAWHEIGHT)]) {
        _scrollView = scrollView;
        [_scrollView addObserver:self forKeyPath:@"pan.state" options:NSKeyValueObservingOptionNew context:Nil];
        [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:Nil];
        [_scrollView.superview insertSubview:self belowSubview:_scrollView];
        _scrollView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        if (ELRefreshTop==direction) {
            self.formatter = [[NSDateFormatter alloc] init];
            [self.formatter setAMSymbol:@"AM"];
            [self.formatter setPMSymbol:@"PM"];
            [self.formatter setDateFormat:@"MM/dd/yyyy hh:mm:ss"];
        }
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        self.direction = direction;
        dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, 0), 0.05*NSEC_PER_SEC, 0);
        dispatch_source_set_event_handler(_timer, ^{
            self.rotation = fmodf((self.rotation+M_PI*0.05),(M_PI*2));
            [self setNeedsDisplay];
        });
    }
    return self;
}



-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (object == self.scrollView&&[keyPath isEqualToString:@"pan.state"]) {
        if (!self.loading&&[[change valueForKey:@"new"] intValue] == UIGestureRecognizerStateEnded) {
            if (ELRefreshTop==self.direction&&self.scrollView.contentOffset.y<-ELDRAWHEIGHT-self.frame.origin.y) {
                [self setLoading:YES];
                self.lastFreshDate = [NSDate date];
                if (self.refreshBlock) {
                    self.refreshBlock();
                }
            }else if(ELRefreshBottom == self.direction && self.scrollView.contentOffset.y+self.scrollView.frame.size.height>self.scrollView.contentSize.height+ELDRAWHEIGHT){
                [self setLoading:YES];
                if (self.refreshBlock) {
                    self.refreshBlock();
                }
            }
            
        }
    }else if(object == self.scrollView&&[keyPath isEqualToString:@"contentOffset"]){
        [self setNeedsDisplay];
    }
}




-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    UIFont *font = [UIFont boldSystemFontOfSize:10];
    UIFont *dateFont = [UIFont systemFontOfSize:10];
    float fac;
    if (ELRefreshTop == self.direction) {
        float y = self.scrollView.contentOffset.y+self.frame.origin.y;
        fac = 1-MAX(0,MIN(1,(y+ELDRAWHEIGHT)/(ELDRAWHEIGHT)));
    }else{
        fac = (self.scrollView.contentOffset.y+self.scrollView.frame.size.height-self.scrollView.contentSize.height)/ELDRAWHEIGHT;
        fac = MAX(0, MIN(1, fac));
    }
    if (self.loading) {
        fac = 1;
    }

    float width = rect.size.width;
    NSString *hintString;
    if (!self.loading) {
        if (fac==1) {
            hintString = @"释放立即刷新";
        }else{
            hintString = (ELRefreshTop == self.direction?@"下拉刷新":@"上拉刷新");
        }
    }else{
        hintString = @"正在刷新";
    }
    
    float textWidth = [hintString boundingRectWithSize:CGSizeMake(width, font.lineHeight) options:(NSStringDrawingTruncatesLastVisibleLine) attributes:@{NSFontAttributeName:font} context:nil].size.width;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
    
    if (!self.loading) {
        CGContextAddArc(context, 0.5*(width-(ELDRAWHEIGHT*0.55+textWidth)), ELDRAWHEIGHT*0.3, ELDRAWHEIGHT*0.25, 0, 2*M_PI*fac-M_PI*0.1, 0);
    }else{
        CGContextAddArc(context, 0.5*(width-(ELDRAWHEIGHT*0.55+textWidth)), ELDRAWHEIGHT*0.3, ELDRAWHEIGHT*0.25, self.rotation, self.rotation+2*M_PI*fac-M_PI*0.1, 0);
    }
    
    CGContextStrokePath(context);
    [hintString drawAtPoint:CGPointMake(0.5*(width-(ELDRAWHEIGHT*0.55+textWidth))+0.55*ELDRAWHEIGHT, 0.05*ELDRAWHEIGHT+0.5*(ELDRAWHEIGHT*0.5-font.lineHeight)) withAttributes:@{NSFontAttributeName:font}];
    if (ELRefreshTop == self.direction) {
        [self lastStringFromDate:self.lastFreshDate];
        CGSize dateSize = [self.lastUpdateText boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:(NSStringDrawingTruncatesLastVisibleLine) attributes:@{NSFontAttributeName:dateFont} context:nil].size;
        //    float dateHeight = dateSize.height;
        float dateWidth = dateSize.width;
        [self.lastUpdateText drawAtPoint:CGPointMake(0.5*(width-dateWidth), ELDRAWHEIGHT*0.6) withAttributes:@{NSFontAttributeName:dateFont}];
    }
    
}

-(void)lastStringFromDate:(NSDate *)lastDate{
    if (!lastDate) {
        self.lastUpdateText = @"从未刷新!";
    }else{
        self.lastUpdateText = [NSString stringWithFormat:@"上次刷新时间: %@", [self.formatter stringFromDate:lastDate]];
    }
    
}

-(void)setLoading:(BOOL)loading{
    _loading = loading;
    [UIView animateWithDuration:0.25 animations:^{
        if (!_loading) {
            if (ELRefreshTop==self.direction) {
                self.scrollView.contentInset = UIEdgeInsetsMake(self.frame.origin.y-self.scrollView.frame.origin.y, 0, self.scrollView.contentInset.bottom, 0);
            }else{
                self.scrollView.contentInset = UIEdgeInsetsMake(self.scrollView.contentInset.top, 0, 0, 0);
            }
            dispatch_suspend(self.timer);
        }else{
            if (ELRefreshTop == self.direction) {
                self.scrollView.contentInset = UIEdgeInsetsMake(self.frame.origin.y-self.scrollView.frame.origin.y+ELDRAWHEIGHT, 0, 0, 0);
            }else{
                self.scrollView.contentInset = UIEdgeInsetsMake(self.scrollView.contentInset.top, 0, ELDRAWHEIGHT, 0);
            }
            self.rotation = 0;
            dispatch_resume(self.timer);
        }
    }];
}


-(void)dealloc{
    self.formatter = nil;
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
