//
//  XTSafeCollection.h
//  XTSafeCollection
//
//  Created by Ben on 15/8/25.
//  Copyright (c) 2015年 X-Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XTSafeCollection : NSObject


@end

@interface NSArray (XTSafe)
//objectAtIndex:index 防护方法
- (id)tn_objectAtIndex:(NSUInteger)index;
//arrayWithObjects:count 防护方法
+ (id)tn_arrayWithObjects:(const id [])objects count:(NSUInteger)cnt;
@end


@interface NSMutableArray (XTSafe)
//objectAtIndex 防护方法
- (id)tn_objectAtIndex:(NSUInteger)index;
//addObject
- (void)tn_addObject:(id)anObject;
//replaceObjectAtIndex
- (void)tn_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject;
//insertObject
- (void)tn_insertObject:(id)anObject atIndex:(NSUInteger)index;
@end

@interface NSDictionary (XTSafe)

+ (instancetype)tn_dictionaryWithObjects:(NSArray *)objects forKeys:(NSArray *)keys;

+ (instancetype)tn_dictionaryWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt;
@end

@interface NSMutableDictionary (XTSafe)
- (void)tn_setObject:(id)anObject forKey:(id<NSCopying>)aKey;
@end


