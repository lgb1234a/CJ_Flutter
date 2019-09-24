
#import "CJCustomAttachmentDefines.h"

NSDictionary *attachmentMapping()
{
    NSDictionary *d = @{
                        @(CustomMessageTypeYeeRedPacket): @"CJYeePayRedPacketAtachment"
                        };
    
    return d;
}

NSString *attachmentNameForType(CJCustomMessageType type)
{
    NSDictionary *d = attachmentMapping();
    return [d objectForKey:@(type)];
}
