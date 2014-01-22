//
//  ELRefreshView.h
//  ELRefresh
//
//  Created by ZhouQuan on 14-1-20.
//  Copyright (c) 2014年 iOSTeam. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    ELRefreshTop,
    ELRefreshBottom
} ELRefreshDirection;

typedef void (^RefeshBlock)();



@interface ELRefreshView : UIView
/**
 *  initilization
 *
 *  @param scrollView scrollView to observer
 *  @param direction  refresh direction ----- not implement
 *
 *  @return Refresh view
 */
-(instancetype)initWithScrollView:(UIScrollView *)scrollView refreshDirection:(ELRefreshDirection)direction;
@property (nonatomic, copy) RefeshBlock refreshBlock;
@property (nonatomic, assign) BOOL loading;
@end
