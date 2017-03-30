//
//  YQHttpTool.m
//
//  Created by tiantian on 15/3/12.
//  Copyright (c) 2015年 tiantian. All rights reserved.
//

#import "YQHttpTool.h"
#import "AFNetworking.h"

@implementation YQHttpTool

+ (void)get:(NSString *)url params:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(NSError *error))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    manager.requestSerializer.timeoutInterval = 5;
    
    [manager.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];

    [manager GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    }
    success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"url:%@",task.currentRequest);
        if (success) {
            success(responseObject);
        }
    }
    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull   error) {
        if (failure) {
            failure(error);
        }
        NSLog(@"url:%@",task.currentRequest);
    }];
}

+ (void)post:(NSString *)url params:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(NSError *error))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 5;

    [manager.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];

    [manager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"url:%@",task.currentRequest);
        
        if (success) {
            success(responseObject);
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"url:%@",task.currentRequest);

        NSError *underError = error.userInfo[@"NSUnderlyingError"];
        NSData *responseData = underError.userInfo[@"com.alamofire.serialization.response.error.data"];
        if (failure) {
            failure(error);
        }
        NSString *errorStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"error:%@",errorStr);
    }];
}
//https证书，客户端验证
+ (AFSecurityPolicy*)customSecurityPolicy
{
    // 先导入证书
//    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"cer"];//证书的路径
//    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    
    // AFSSLPinningModeCertificate 使用证书验证模式
//    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];

    // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    // 如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    
    //validatesDomainName 是否需要验证域名，默认为YES；
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    //如置为NO，建议自己添加对应域名的校验逻辑。
    securityPolicy.validatesDomainName = NO;
    
//    securityPolicy.pinnedCertificates = @[certData];
    
    return securityPolicy;
}

@end
