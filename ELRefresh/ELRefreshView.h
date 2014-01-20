//
//  ELRefreshView.h
//  ELRefresh
//
//  Created by ZhouQuan on 14-1-20.
//  Copyright (c) 2014年 iOSTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    ELRefreshUpper,
    ELRefreshBottom
} ELRefreshDirection;

typedef void (^RefeshBlock)();



@interface ELRefreshView : UIView
-(instancetype)initWithScrollView:(UIScrollView *)scrollView refreshDirection:(ELRefreshDirection)direction;
@property (nonatomic, copy) RefeshBlock refreshBlock;
@end
