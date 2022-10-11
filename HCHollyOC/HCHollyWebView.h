//
//  HCHollyWebView.h
//  HCHollyOC
//
//  Created by 林龙成 on 2019/6/20.
//  Copyright © 2019 loganv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

static int hosttype = 0;

@interface HCHollyWebView : NSObject

+(void)initializtionWithAccount:(NSString*)account chatId:(NSString*)chatId htype:(int)htype param:(NSDictionary<NSString *, id>*)param cb:(void(^)(BOOL iss, NSString *mess))cb;

+(void)showlog:(BOOL)iss;

-(WKWebView*)getC6WebViewWithFrame:(CGRect)frame;
-(void)removeHandler;

// 内部网页与第三方客户端通讯
-(void)onMessageFromWeb:(void(^)(id))fn;
@end

@interface HCHollyWebView (WKNavigationDelegate)<WKNavigationDelegate>

@end

@interface HCHollyWebView (Priv)
-(void)reqTakePhoto;
@end

NS_ASSUME_NONNULL_END
