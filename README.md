ELRefresh
=========

Pull-to-refresh
<b>How to use</b>
pod 'ELRefresh', '~> 0.0.1'
In your viewController's viewWillAppear function:
(onceToken should be a property of you viewController);
	dispatch_once(&_onceToken, ^{
        self.refreshView = [[ELRefreshView alloc] initWithScrollView:self.tableView refreshDirection:ELRefreshUpper];
        __weak ELViewController *weakSelf = self;
        self.refreshView.refreshBlock = ^{
          	[weakSelf doString];
        };
    });
    
</b>TO DO</b>
Now just support RefreshView in the top.
