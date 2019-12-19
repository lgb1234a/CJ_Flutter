
#import "CJCustomAttachmentDefines.h"

NSDictionary *attachmentMapping()
{
    NSDictionary *d = @{
                        @(CustomMessageTypeYeeRedPacket): @"CJYeePayRedPacketAtachment",
                        @(CustomMessageTypeYeeRedPacketTip): @"CJYeePayRedPacketTipAttachment",
                        @(CustomMessageTypeRedPacket): @"CJMFRedPacketAttachment",
                        @(CustomMessageTypeRedPacketTip): @"CJMFRedPacketTipAttachment",
                        @(CustomMessageTypeCloudRedPacket): @"CJCloudRedPacketAttachment",
                        @(CustomMessageTypeCloudRedPacketTip): @"CJCloudRedPacketTipAttachment"
                        };
    
    return d;
}

NSString *attachmentNameForType(CJCustomMessageType type)
{
    NSDictionary *d = attachmentMapping();
    return [d objectForKey:@(type)];
}
