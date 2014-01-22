//
//  ELViewController.m
//  ELRefresh
//
//  Created by ZhouQuan on 14-1-20.
//  Copyright (c) 2014年 iOSTeam. All rights reserved.
//

#import "ELViewController.h"
#import "ELRefreshView.h"


@interface ELViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) ELRefreshView *refreshView;
@property (nonatomic, assign) dispatch_once_t onceToken;
@property (nonatomic, strong) ELRefreshView *refreshView1;
@end

@implementation ELViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"identifier"];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    dispatch_once(&_onceToken, ^{
        self.refreshView = [[ELRefreshView alloc] initWithScrollView:self.tableView refreshDirection:ELRefreshTop];
        __weak ELViewController *weakSelf = self;
        self.refreshView.refreshBlock = ^{
            double delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [weakSelf.refreshView setLoading:NO];
            });
        };
        
        self.refreshView1 = [[ELRefreshView alloc] initWithScrollView:self.tableView refreshDirection:ELRefreshBottom];
        self.refreshView1.refreshBlock =  ^{
            double delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [weakSelf.refreshView1 setLoading:NO];
            });
        };
    });
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TableView DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 20;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"identifier" forIndexPath:indexPath];
    cell.textLabel.text = @"Text";
    return cell;
}


#pragma mark TableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"toDetail" sender:self];
}
@end
