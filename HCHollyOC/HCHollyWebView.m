//
//  HCHollyWebView.m
//  HCHollyOC
//
//  Created by 林龙成 on 2019/6/20.
//  Copyright © 2019 loganv. All rights reserved.
//

#import "HCHollyWebView.h"
#import <UIKit/UIKit.h>
#import "HCHollyRecord.h"
#import "HCHollyLocation.h"
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
//#import "SDKManager.h"
//#import "HollyA6Sdk/SDKManager.h"

#ifdef COCOAPODS_HollyA6Sdk_IMPORT
#import "HollyA6Sdk/SDKManager.h"
#endif

@interface HCHollyWebView()<WKScriptMessageHandler, HCHollyRecordDelegate>

@property(nonatomic, strong) WKWebView *webview;
@property(nonatomic, strong) UIProgressView *progress;
@property(nonatomic, copy) void(^messageFromWeb)(id);

@end



@implementation HCHollyWebView

static BOOL showlog = false;
static NSString *sdk_ver = @"&sdk_version=0.9.4";
static NSString *c6Url = @"";

+(void)showlog:(BOOL)iss{
    showlog = iss;
    [HCHollyRecord showlog:iss];
}

void printlog(NSString* a, ...) {
    if(showlog) {
        va_list args;
        va_start(args, a);
        NSString *formattedString = [[NSString alloc] initWithFormat:a arguments:args];
        va_end(args);
        NSLog(@"%@", formattedString);
    }
}
/**
 htype:
 0 a6 (默认)
 1 a5
 2 account, serviceNo, fromCID
 3 国外接口
 */

+(void)initializtionWithAccount:(NSString*)account chatId:(NSString*)chatId param:(NSDictionary<NSString *, id>*)param cb:(void(^)(BOOL iss, NSString *mess))cb {
    
    NSString *urlPath = [NSString stringWithFormat:@"https://a6.7x24cc.com/commonInte?flag=414&md5=81f0e1f0-32df-11e3-a2e6-1d21429e5f46&accountId=%@", account];
    NSURL *url = [NSURL URLWithString:urlPath];
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"hollysdk 初始化失败，请检查网络，或重新初始化 %@",error);
            cb(false, @"");
            return;
        }
        else{
            /**
             {
                 code = 200;
                 data =     {
                     node = a6;
                     nodeUrl = "https://im.7x24cc.com";
                 };
                 hostname = "app-node-85df86d65d-r9cmv";
                 message = "200 ok!";
                 success = 1;
             }
             */
            NSString *dStr = [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];
            NSDictionary *dc = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingAllowFragments error:nil];
            if (dc != nil) {
                
                printlog(@"414: %@",dc);
                NSInteger succ = [dc[@"success"] integerValue];
                if (succ == 1) {
                    NSDictionary *data = dc[@"data"];
                    if (data != nil) {
                        NSString *node = data[@"node"];
                        NSString *nodeUrl = data[@"nodeUrl"];
                        
                        if ([node containsString:@"test"]) {
                            hosttype = 1;
                        }
                        
                        [self _initializtionWithAccount:account chatId:chatId node:node nodeUrl:nodeUrl param:param cb:cb];
//                        cb(true, @"初始化holly成功");
                        return;
                    }
                }
            }
            NSLog(@"初始化holly失败：%@", dStr);
            cb(false, @"");
        }
    }];
    [task resume];
}
+(void)_initializtionWithAccount:(NSString*)account chatId:(NSString*)chatId node:(NSString*)node nodeUrl:(NSString*)nodeUrl param:(NSDictionary<NSString *, id>*)param cb:(void(^)(BOOL iss, NSString *mess))cb {
    
//    if(htype == 2){
//        NSString *pars = @"";
//        for (NSString *key in param) {
//            pars = [NSString stringWithFormat:@"%@%@=%@&",pars,key,param[key]];
//        }
//        urlPath = [NSString stringWithFormat: @"https://a6.7x24cc.com/clientPhone?md5=81f0e1f0-32df-11e3-a2e6-1d21429e5f46&flag=401&account=%@&serviceNo=%@",account, chatId];
////        c6Url = urlPath;
//        c6Url = [NSString stringWithFormat:@"%@&%@",urlPath, pars];
//        return;
//    }

    if (![nodeUrl hasSuffix:@"/"]) {
        nodeUrl = [nodeUrl stringByAppendingString:@"/"];
    }
    NSString *urlPath = [NSString stringWithFormat: @"%@commonInte?md5=81f0e1f0-32df-11e3-a2e6-1d21429e5f46&flag=401&accountId=%@&chatId=%@",nodeUrl,account, chatId];

    
    NSString *pars = @"";
    for (NSString *key in param) {
        pars = [NSString stringWithFormat:@"%@%@=%@&",pars,key,param[key]];
    }
    printlog(@"request api: %@", urlPath);
    NSURL *url = [NSURL URLWithString:urlPath];
    NSURLSessionDataTask *task = [NSURLSession.sharedSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"hollysdk 初始化失败，请检查网络，或重新初始化 %@",error);
            cb(false, @"");
            return;
        }
        else{
            NSString *dStr = [[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];
            printlog(@"dStr: %@",dStr);

            NSDictionary *dc = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingAllowFragments error:nil];
            if (dc != nil) {
                NSInteger succ = [dc[@"success"] integerValue];
                if (succ == 1) {
                    NSString *url = dc[@"interface"];
                    if ([url containsString:@"?"]) {
                        c6Url = [NSString stringWithFormat:@"%@&%@",url,pars];
                    }
                    else{
                        c6Url = [NSString stringWithFormat:@"%@?%@",url,pars];
                    }
                    printlog(@"c6Url：%@",c6Url);
                    cb(true, @"初始化holly成功");
                    return;
                }
            }
            cb(false, dStr);
        }
    }];
    [task resume];
    
}

- (void)dealloc
{
    printlog(@"holly webview dealloc");
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

-(WKWebView*)getC6WebViewWithFrame:(CGRect)frame{
    WKWebViewConfiguration *conf = [[WKWebViewConfiguration alloc] init];
    self.webview = [[WKWebView alloc] initWithFrame:frame configuration:conf];
//    _webview.UIDelegate = self;
    _webview.navigationDelegate = self;
    
    [self addHandler];
    
    [self loadUrl: [c6Url stringByAppendingString: sdk_ver]];
    
    return _webview;
}

-(void)addHandler{
    [_webview.configuration.userContentController addScriptMessageHandler:self name:@"recordStart"];
    [_webview.configuration.userContentController addScriptMessageHandler:self name:@"recordStop"];
    [_webview.configuration.userContentController addScriptMessageHandler:self name:@"recordCancel"];
    [_webview.configuration.userContentController addScriptMessageHandler:self name:@"getLocation"];
    [_webview.configuration.userContentController addScriptMessageHandler:self name:@"reqAuthCamera"];
    [_webview.configuration.userContentController addScriptMessageHandler:self name:@"getHollyPermission"];
    [_webview.configuration.userContentController addScriptMessageHandler:self name:@"webrtcEvent"];
    [_webview.configuration.userContentController addScriptMessageHandler:self name:@"webrtcMicEvent"];
    [_webview.configuration.userContentController addScriptMessageHandler:self name:@"xmTrtcCall"];
    
}

-(void)removeHandler{
    [_webview.configuration.userContentController removeScriptMessageHandlerForName:@"recordStart"];
    [_webview.configuration.userContentController removeScriptMessageHandlerForName:@"recordStop"];
    [_webview.configuration.userContentController removeScriptMessageHandlerForName:@"recordCancel"];
    [_webview.configuration.userContentController removeScriptMessageHandlerForName:@"getLocation"];
    [_webview.configuration.userContentController removeScriptMessageHandlerForName:@"reqAuthCamera"];
    [_webview.configuration.userContentController removeScriptMessageHandlerForName:@"getHollyPermission"];
    [_webview.configuration.userContentController removeScriptMessageHandlerForName:@"webrtcEvent"];
    [_webview.configuration.userContentController removeScriptMessageHandlerForName:@"webrtcMicEvent"];
    [_webview.configuration.userContentController removeScriptMessageHandlerForName:@"xmTrtcCall"];
}

-(void)loadUrl:(NSString*)sss{
    NSURL *url = [NSURL URLWithString:sss];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [_webview loadRequest:req];
    [self initRecord];
}

-(void)initRecord{
    __weak HCHollyWebView *wself = self;
    [HCHollyRecord.manager onStart:^{
        NSString *jstr = @"hollyRecordStart()";
        [wself.webview evaluateJavaScript:jstr completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
            
        }];
    }];
    [HCHollyRecord.manager onCancel:^{
        NSString *jstr = @"hollyRecordCancel()";
        [wself.webview evaluateJavaScript:jstr completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
            
        }];
    }];
    
    [HCHollyRecord.manager onFailed:^(NSString * _Nonnull mess) {
        NSString *jstr = [NSString stringWithFormat: @"hollyRecordFailed('%@')", mess];
        [wself.webview evaluateJavaScript:jstr completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
            
        }];
    }];
    [HCHollyRecord.manager onStop:^{
        NSString *jstr = @"hollyRecordStop()";
        [wself.webview evaluateJavaScript:jstr completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
            
        }];
    }];
    [HCHollyRecord.manager onUpload:^(BOOL iss, NSString *downUrl){
        NSString *jstr = [NSString stringWithFormat:@"hollyRecordUpload('%@')", downUrl];
        if (!iss) {
            jstr = @"hollyRecordFailed()";
        }
        [wself.webview evaluateJavaScript:jstr completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
            
        }];
    }];
    HCHollyRecord.manager.delegate = self;
    
}
-(void)onUpload:(BOOL)iss mess:(NSString *)mess{
    NSString *jstr = [NSString stringWithFormat:@"hollyRecordUpload('%@')", mess];
    if (!iss) {
        jstr = @"hollyRecordFailed()";
    }
    [self.webview evaluateJavaScript:jstr completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
        
    }];
}

//  window.webkit.messageHandlers["reqAuthCamera"].postMessage("")
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if ([message.name isEqualToString:@"recordStart"]) {
        [HCHollyRecord.manager start];
    }
    else if ([message.name isEqualToString:@"recordStop"]){
        [HCHollyRecord.manager stop];
    }
    else if ([message.name isEqualToString:@"recordCancel"]){
        [HCHollyRecord.manager cancel];
    }
    else if ([message.name isEqualToString:@"reqAuthCamera"]){
        [self reqTakePhoto];
    }
    else if ([message.name isEqualToString:@"getHollyPermission"]){
        AVAudioSession *session = [AVAudioSession sharedInstance];
//        __block BOOL hasAuth = true;
        __weak HCHollyWebView *wself = self;
        id authType = message.body;
        [session requestRecordPermission:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted){
                }
                NSString *js = [NSString stringWithFormat:@"hollyPermissionCallback('%@','%d')", authType, granted];
                [wself.webview evaluateJavaScript:js completionHandler:nil];
            });
        }];
    }
    else if ([message.name isEqualToString:@"getLocation"]){
        __weak HCHollyWebView *wself = self;
        [HCHollyLocation.share getLocationBack:^(CLLocation * _Nonnull loc) {
            if (loc == nil) {
                return;
            }
            NSString *js = [NSString stringWithFormat:@"hollyGetLocation('%f','%f')", loc.coordinate.latitude, loc.coordinate.longitude];
            [wself.webview evaluateJavaScript:js completionHandler:nil];
        } failed:^(NSError * _Nonnull err) {
            NSString *js = [NSString stringWithFormat:@"hollyGetLocationFailed('%@')", err.localizedDescription];
            [wself.webview evaluateJavaScript:js completionHandler:nil];
        }];
    }
    else if ([message.name isEqualToString:@"webrtcEvent"]){
        if (_messageFromWeb != nil){
            _messageFromWeb(message.body);
        }
    }
    else if ([message.name isEqualToString:@"webrtcMicEvent"]){
        if ([message.body isKindOfClass:[NSString class]]){
            if([message.body isEqual:@"0"]){
                [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
                [[AVAudioSession sharedInstance] setActive:NO error:nil];
            }
            else{
                [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategorySoloAmbient error:nil];
                [[AVAudioSession sharedInstance] setActive:YES error:nil];
            }
        }
    }
#ifdef COCOAPODS_HollyA6Sdk_IMPORT
    else if ([@"xmTrtcCall" isEqualToString:message.name]){
        if([message.body isKindOfClass:[NSDictionary class]]){
            NSDictionary *param = message.body;
            if(![param[@"sdkAppId"] isEqual:[NSNull null]]){
                [[SDKManager shareManager] enterVideoRoomWithA6Params:param];
            }
        }
    }
#endif
    NSLog(@"%@",message.name);
    NSLog(@"%@",message.body);
    
//case "getLocation":
//    weak var wself = self
//
//    let loc = HCHollyLocation.share
//    loc.getLocation(back: { (loc) in
//        if loc == nil {return}
//        let jstr = "hollyGetLocation('\(loc!.coordinate.latitude)','\(loc!.coordinate.longitude)')"
//        wself?.webview.evaluateJavaScript(jstr, completionHandler: { (obj, err) in
//            //                    print(obj)
//            //                    print(err)
//        })
//    }, failed: { err in
//        let jstr = "hollyGetLocationFailed('\(err.localizedDescription)')"
//        wself?.webview.evaluateJavaScript(jstr, completionHandler: { (obj, err) in
//            //                    print(obj)
//            //                    print(err)
//        })
//    })
//default:
//    print("没有匹配到")
//}
}

-(void)onMessageFromWeb:(void (^)(id _Nonnull))fn{
    self.messageFromWeb = fn;
}

@end

@implementation HCHollyWebView (WKNavigationDelegate)
//func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
//    print(navigationAction.request.url)
//    print(navigationAction.navigationType)
//    if let url = navigationAction.request.url, navigationAction.navigationType == .linkActivated {
////            if url.absoluteString.hasSuffix(".pdf") {
////                // 下载 PDF 文件
////                downloadFile(url: url)
////                decisionHandler(.cancel, preferences) // 阻止 WebView 加载链接
////                return
////            }
//        
//        // pdf zip 文件打开 safari
//        if url.absoluteString.hasSuffix(".pdf")
//            || url.absoluteString.hasSuffix(".zip"){
//            decisionHandler(.cancel, preferences)
//            UIApplication.shared.open(url)
//            return
//        }
//    }
//    decisionHandler(.allow, preferences)
//}

// 前往safari 下载： .zip
//- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
//    NSLog(@"%@", navigationAction);
//    
//    NSURL *url = navigationAction.request.URL;
//    if(url != nil && navigationAction.navigationType == WKNavigationTypeLinkActivated){
//        if([url.absoluteString hasSuffix:@".zip"]){
//            decisionHandler(WKNavigationActionPolicyCancel);
//            [UIApplication.sharedApplication openURL: url];
//            return;
//        }
//    }
//    decisionHandler(WKNavigationActionPolicyAllow);
//}
//-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction preferences:(WKWebpagePreferences *)preferences decisionHandler:(void (^)(WKNavigationActionPolicy, WKWebpagePreferences * _Nonnull))decisionHandler{
//    
//    decisionHandler(WKNavigationActionPolicyAllow, )
//}
-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    printlog(@"didFailNavigation -> %@",error);
}
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    printlog(@"didFailProvisionalNavigation -> %@",error);
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    printlog(@"didFinishNavigation -> %@", webView);
}

@end

@implementation HCHollyWebView (Priv)

-(void)reqTakePhoto{
    AVAuthorizationStatus auth = [AVCaptureDevice authorizationStatusForMediaType: AVMediaTypeVideo];
    NSString *mess = @"";
    if (auth == AVAuthorizationStatusNotDetermined) {
        mess = @"还未授权";
    }
    else if(auth == AVAuthorizationStatusDenied){
        mess = @"拒绝";
    }
    else if(auth == AVAuthorizationStatusRestricted){
        
    }
    else if(auth == AVAuthorizationStatusAuthorized){
        mess = @"限制访问";
    }
    
    NSString *jstr = [NSString stringWithFormat:@"hollyAuthCamera('%@')", mess];
    [self.webview evaluateJavaScript:jstr completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
        
    }];
}

@end
