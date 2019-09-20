//
//  CJMoreContainerConfig.m
//  Runner
//
//  Created by chenyn on 2019/9/20.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJMoreContainerConfig.h"

@implementation CJMoreContainerConfig

- (NSArray<NIMMediaItem *> *)mediaItems
{
    NSMutableArray *mediaItems = @[[NIMMediaItem item:@"onTapMediaItemPicture:"
                                         normalImage:[UIImage imageNamed:@"bk_media_picture_normal"]
                                       selectedImage:[UIImage imageNamed:@"bk_media_picture_nomal_pressed"]
                                               title:@"照片"],
                                   
                                  [NIMMediaItem item:@"onTapMediaItemShoot:"
                                         normalImage:[UIImage imageNamed:@"bk_media_shoot_normal"]
                                       selectedImage:[UIImage imageNamed:@"bk_media_shoot_pressed"]
                                               title:@"拍摄"]].mutableCopy;
    
    NIMMediaItem *cajianRP  = [NIMMediaItem item:@"onTapMediaItemCajianRP:"
                                      normalImage:[UIImage imageNamed:@"icon_redpacket_normal"]
                                    selectedImage:[UIImage imageNamed:@"icon_redpacket_pressed"]
                                            title:@"红包"];
    
    
    NIMMediaItem *cloudRP  = [NIMMediaItem item:@"onTapMediaItemCloudRedPacket:"
                                     normalImage:[UIImage imageNamed:@"icon_MFRedpacket"]
                                   selectedImage:[UIImage imageNamed:@"icon_MFRedpacket_pressed"]
                                           title:@"云红包"];
    
    NIMMediaItem *yeeRP  = [NIMMediaItem item:@"onTapMediaItemYeePacket:"
                                     normalImage:[UIImage imageNamed:@"icon_yee_normal"]
                                   selectedImage:[UIImage imageNamed:@"icon_yee_pressed"]
                                           title:@"易红包"];
    
    NIMMediaItem *yeeTransfer  = [NIMMediaItem item:@"onTapMediaItemYXTransfer:"
                                       normalImage:[UIImage imageNamed:@"icon_yee_transfer_normal"]
                                     selectedImage:[UIImage imageNamed:@"icon_yee_transfer_pressed"]
                                             title:@"易转账"];
    
    NIMMediaItem *profileCard  = [NIMMediaItem item:@"onTapMediaItemProfileCard:"
                                       normalImage:[UIImage imageNamed:@"bk_media_card_normal"]
                                     selectedImage:[UIImage imageNamed:@"bk_media_card_pressed"]
                                             title:@"名片"];
    
    NIMMediaItem *aliPayCode  = [NIMMediaItem item:@"onTapMediaItemAliPayCode:"
                                         normalImage:[UIImage imageNamed:@"icon_team_paycode_normal"]
                                       selectedImage:[UIImage imageNamed:@"icon_team_paycode_pressed"]
                                               title:@"收款码"];
    
    NIMMediaItem *personStamp  = [NIMMediaItem item:@"onTapMediaItemPersonalstamp:"
                                        normalImage:[UIImage imageNamed:@"icon_team_stamp_normal"]
                                      selectedImage:[UIImage imageNamed:@"icon_team_stamp_pressed"]
                                              title:@"抖一抖"];
    
    NIMMediaItem *teamNotice  = [NIMMediaItem item:@"onTapMediaItemTeamNotice:"
                                       normalImage:[UIImage imageNamed:@"icon_team_notice_normal"]
                                     selectedImage:[UIImage imageNamed:@"icon_team_notice_pressed"]
                                             title:@"群通知"];
    
    NIMMediaItem *collection = [NIMMediaItem item:@"onTapMediaItemCollection:"
                                            normalImage:[UIImage imageNamed:@"icon_team_collection_normal"]
                                          selectedImage:[UIImage imageNamed:@"icon_team_collection_pressed"]
                                                  title:@"收藏"];
    
    NIMMediaItem *location = [NIMMediaItem item:@"onTapMediaItemLocation:"
                                          normalImage:[UIImage imageNamed:@"bk_media_position_normal"]
                                        selectedImage:[UIImage imageNamed:@"bk_media_position_pressed"]
                                                title:@"位置"];
    
    [mediaItems addObjectsFromArray:@[cajianRP, cloudRP, yeeRP, yeeTransfer, profileCard, aliPayCode, personStamp, teamNotice, collection, location]];
    
    return mediaItems;
}


@end
