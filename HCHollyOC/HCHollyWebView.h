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

static int hosttype = 0; // 0 正式，1测试， 3 imxg1autni82


typedef void(^SaveCompletion)(BOOL success, NSError *error);
typedef void(^webmsg)(id body);

@interface HCHollyWebView : NSObject

// 国内
+(void)initializtionWithAccount:(NSString*)account chatId:(NSString*)chatId param:(NSDictionary<NSString *, id>*)param cb:(void(^)(BOOL iss, NSString *mess))cb;
// 国际
+(void)initializtionWithImxgAccount:(NSString*)account chatId:(NSString*)chatId param:(NSDictionary<NSString *, id>*)param cb:(void(^)(BOOL iss, NSString *mess))cb;

+(void)showlog:(BOOL)iss;

-(WKWebView*)getC6WebViewWithFrame:(CGRect)frame;
/// top、bottom 传 nil 时，分别取设备顶部、底部安全区高度，再从 frame 中减去后调用 getC6WebViewWithFrame:。
-(WKWebView*)getC6WebViewSafeWithFrame:(CGRect)frame top:(nullable NSNumber *)top bottom:(nullable NSNumber *)bottom;
-(void)removeHandler;

// 内部网页与第三方客户端通讯
-(void)onMessageFromWeb:(void(^)(id))fn;

// 监听：web 的 downloadFile
-(void)onElseMsg:(webmsg)fn;
@end

@interface HCHollyWebView (WKNavigationDelegate)<WKNavigationDelegate>

@end

@interface HCHollyWebView (Priv)
-(void)reqTakePhoto;
-(void)reqCamera;
-(void)reqAudio;
-(void)reqLocation;
- (void)saveImageFromURL:(NSURL *)imageURL completion:(SaveCompletion)completion;
@end

NS_ASSUME_NONNULL_END
