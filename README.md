ELRefresh
=========

Pull-to-refresh
<b>How to use</b><br/>
pod 'ELRefresh', '~> 0.0.1'<br/>
In your viewController's viewWillAppear function:<br/>
(onceToken should be a property of you viewController);<br/>
	dispatch_once(&_onceToken, ^{<br/>
        self.refreshView = [[ELRefreshView alloc] initWithScrollView:self.tableView refreshDirection:ELRefreshUpper];<br/>
        __weak ELViewController *weakSelf = self;<br/>
        self.refreshView.refreshBlock = ^{<br/>
          	[weakSelf doString];<br/>
        };<br/>
    });<br/>
    
</b>TO DO</b><br/>
Now just support RefreshView in the top.<br/>
