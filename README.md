ELRefresh
=========
![image](ELRefresh.gif)
<br/>Pull-to-refresh<br/>
<b>How to use</b><br/>
pod 'ELRefresh', '~> 0.0.1'<br/>
In your viewController's viewWillAppear function:<br/>
(onceToken should be a property of you viewController);<br/>
<pre><code>
	dispatch_once(&_onceToken, ^{
        self.refreshView = [[ELRefreshView alloc] initWithScrollView:self.tableView refreshDirection:ELRefreshUpper];<br/>
        __weak ELViewController *weakSelf = self;
        self.refreshView.refreshBlock = ^{
          	[weakSelf doString];
        };
    });
</code></pre>
</b>TO DO</b><br/>
Now just support RefreshView in the top.<br/>
