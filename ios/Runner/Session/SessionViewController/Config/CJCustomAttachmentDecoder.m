//
//  CJCustomAttachmentDecoder.m
//  Runner
//
//  Created by chenyn on 2019/9/23.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "CJCustomAttachmentDecoder.h"
#import "CJCustomAttachmentDefines.h"

@implementation CJCustomAttachmentDecoder

- (id<CJCustomAttachment>)decodeAttachment:(NSString *)content
{
    id<CJCustomAttachment> attachment = nil;
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    if(!data) {
        return nil;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                         options:0
                                                           error:nil];
    if (data && [dict isKindOfClass:[NSDictionary class]]) {
        NSInteger type     = [[dict objectForKey:@"type"] integerValue];
        NSDictionary *data = [dict objectForKey:@"data"];
        
        NSString *className = attachmentNameForType(type);
        Class cls = NSClassFromString(className);
        if([cls instancesRespondToSelector:@selector(initWithPrepareData:)])
        {
            attachment = [[cls alloc] initWithPrepareData:data];
        }
    }
    
    attachment = [attachment isValid]? attachment : nil;
    return attachment;
}

@end
