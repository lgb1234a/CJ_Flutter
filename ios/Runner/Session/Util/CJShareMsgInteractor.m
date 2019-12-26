//
//  CJShareMsgInteractor.m
//  Runner
//
//  Created by chenyn on 2019/12/25.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJShareMsgInteractor.h"
#import <NIMMessageMaker.h>
#import "CJBusinessCardAttachment.h"

@implementation CJShareMsgInteractor

+ (void)shareModel:(CJShareModel *)shareModel
                to:(NIMSession *)session
{
    co_launch(^{
        if(shareModel.type == CajianShareTypeImage)
        {
            // 分享图片
            CJShareImageModel *imgModel = (CJShareImageModel *)shareModel;
            
            UIImage *img = await([UIImage async_imageWithData:imgModel.imageData]);
            NIMMessage *msg = [NIMMessageMaker msgWithImage:img];
            
            [[[NIMSDK sharedSDK] chatManager] sendMessage:msg toSession:session error:nil];
        }

        if(shareModel.type == CajianShareTypeBusinessCard)
        {
            // 分享个人名片
            CJShareBusinessCardModel *cardModel = (CJShareBusinessCardModel *)shareModel;
            CJBusinessCardAttachment *attachment = [[CJBusinessCardAttachment alloc] initWithShareModel:cardModel];
            
            NIMMessage *msg = [attachment msgFromAttachment];
            [[[NIMSDK sharedSDK] chatManager] sendMessage:msg toSession:session error:nil];
        }

        // 留言
        if(!cj_empty_string(shareModel.leaveMessage)) {
            NIMMessage *msg = [NIMMessageMaker msgWithText:shareModel.leaveMessage];
            [[[NIMSDK sharedSDK] chatManager] sendMessage:msg toSession:session error:nil];
        }
    });
}

@end
