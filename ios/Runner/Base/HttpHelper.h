//
//  HttpHelper.h
//  CaJian
//
//  Created by Apple on 2018/11/10.
//  Copyright © 2018 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class BaseModel;

NS_ASSUME_NONNULL_BEGIN

@interface HttpHelper : NSObject

/**
 发送一个POST请求

 @param url 请求路径
 @param params 请求参数
 */
+ (void)postWithURL:(NSString *)url
             params:(NSDictionary *)params
            success:(void (^)(BaseModel *model))success
            failure:(void (^)(NSError *error))failure;


/**
 *  发送一个GET请求
 *
 *  @param url     请求路径
 *  @param params  请求参数
 *  @param success 请求成功后的回调
 *  @param failure 请求失败后的回调
 */
+ (void)getWithURL:(NSString *)url
            params:(NSDictionary *)params
           success:(void (^)(id json))success
           failure:(void (^)(NSError *error))failure;


/**
 上传文件

 @param url 请求路径
 @param parame 请求参数
 @param path 请求文件路径
 */
+ (void)postInforTopImgWithUrl:(NSString *)url
                        parame:(NSDictionary *)parame
                          path:(NSString *)path
                       success:(void (^)(id json))success
                       failure:(void (^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
