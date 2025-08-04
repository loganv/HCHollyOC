# HCHollyOC
### iOS Holly SDK
注：ios_sdk最低支持 ios 10,目前只支持pod集成
0.9.2版本：新增权限桥接，sdk初始化之后不会在直接获取用户权限，webview内客服页面按钮在点击使用的时候，调用sdk桥接，获取用户权限
sdk 使用步骤
注意⚠️：在info.plist中添加允许，定位、麦克风，相册，相机的权限请求；

### pod集成（不区分真机与模拟器）
    1.Podfile 配置文件添加
        pod 'HCHollyOC', '~> 0.9.2'
    2.导入头文件
        #import <HCHollyWebView.h>
    4.在 didFinishLaunchingWithOptions 中添加
        [HCHollyWebView initializtionWithAccount:@"N000000011595" chatId:@"348b3452-2881-4fcd-9ad8-93bdcc0c65e9" param:@{@"a":@"1",@"b":@"2"} cb:^(BOOL iss, NSString * _Nonnull mess) {
            NSLog(@"%@", mess);
        }];
    这个方法 (国际域名初始化使用：initializtionWithImxgAccount)
    5.在需要用到的ViewController中添加

``` Objective-C
    self.holly = [[HCHollyWebView alloc] init];

    //***注：这里实现webview推送事件给webview的监听交互，（仅 0.9.1版本以上支持）
    //详细请登录呼叫中心，菜单：对接平台-在线对接-访客端自定义事件对接
    _holly.onMessageFromWeb = ^(id mess){
      // mess 就是网页的内容
    };
    // 监听 网页端的下载请求事件
    _holly.onElseMsg = ^(id mess){
      // mess 就是网页的内容(WKScriptMessage.body)
    };


    WKWebView *v = [_holly getC6WebViewWithFrame:self.view.bounds];
    [self.view addSubview: v];
```

    6.在退出ViewController，或要销毁holly的时候调用
        [_holly removeHandler];
            
### 以下是：手动导入静态库的操作

#### swift嵌入
    0.分为模拟器、真机两种 HCHollySDK.framework，；
    1.将对应的 HCHollySDK.framework（在demo中下载 AliyunOSSiOS.framework 一并） 拖入到项目；
    2.确保Embedded Binaries, Linked Frameworks and Libraries中有 HCHollySDK.framework；
    4.在 didFinishLaunchingWithOptions 中添加
        HCHollyWebView.initializtion(account: "", chatId: "", param: ["a":1,"b":"bb"]) { (iss, mess) in
        }
    这个方法
    5.在需要用到的ViewController中添加
        let holly = HCHollyWebView()
        webview = holly.getC6WebView(frame: self.view.bounds)
        self.view.addSubview(webview)
    6.在退出ViewController，或要销毁holly的时候调用
        holly.removeHandler()
            
#### object-c 嵌入
    0.分为模拟器、真机两种 HCHollySDK.framework，；
    1.将对应的 HCHollySDK.framework 拖入到项目；
    2.确保Embedded Binaries, Linked Frameworks and Libraries中有 HCHollySDK.framework；
    4.在 didFinishLaunchingWithOptions 中添加
        [HCHollyWebView initializtionWithAccount:@"N000000011595" chatId:@"348b3452-2881-4fcd-9ad8-93bdcc0c65e9" param:@{@"a":@"1",@"b":@"2"} cb:^(BOOL iss, NSString * _Nonnull mess) {
            NSLog(@"%@", mess);
        }];
    这个方法
    5.在需要用到的ViewController中添加
        self.holly = [[HCHollyWebView alloc] init];

        WKWebView *v = [_holly getC6WebViewWithFrame:self.view.bounds];
        [self.view addSubview: v];

    6.在退出ViewController，或要销毁holly的时候调用
        [_holly removeHandler];
            
### sdk 中 wkwebview 的页面成功失败代理
    1.在 webview = holly.getC6WebView(frame: self.view.bounds)代码之后
    加上一行webview 的 WKNavigationDelegate代理
    webview.navigationDelegate = self

    2.在上述的self中实现 WKNavigationDelegate 代理方法，更多详情可以参考 WKNavigationDelegate这个代理
    -(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
        NSLog(@"didFailNavigation -> %@",error);
    }
    -(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
        NSLog(@"didFailProvisionalNavigation -> %@",error);
    }
    -(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
        NSLog(@"didFinishNavigation %@", webView);
    }
            
### sdk 常见问题
    如果找不到iamge，检查 Build Settings的设置
    Always Embed Swift Standard Libraries = Yes（编译需要）
    如果是oc项目，需要在 Build Settings->Build Options 中设置
    Embedded Content Contains Swift Code = Yes
    如果是c++需要调用sdk，需要在 .m文件里面初始化及使用（不能在 .mm文件里面初始化）;


### 内部实现
``` js
// 保存图片到相册
window.webkit.messageHandlers["savePicture"].postMessage("")
// 回调js的方法
hollyCallback(mess, isSuccess)

```
``` Objective-C

```

