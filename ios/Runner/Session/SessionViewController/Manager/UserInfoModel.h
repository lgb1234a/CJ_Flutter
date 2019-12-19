//
//  UserInfoModel.h
//  IMFrameworkDemo
//
//  Created by Criss on 2017/12/14.
//  Copyright © 2017年 JYang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JrmfPacketKit/JrmfPacketKit.h>
#import <MFRedPacketKit/MFGetCustomerInfo.h>

@interface UserInfoModel : NSObject <JrmfGetCustomerInfo,MFGetCustomerInfo>

@end
