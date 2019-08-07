//
//  XTSafeCollection.m
//  XTSafeCollection
//
//  Created by Ben on 15/8/25.
//  Copyright (c) 2015年 X-Team. All rights reserved.
//

#import "XTSafeCollection.h"
#import <objc/runtime.h>

#define XT_SC_LOG 1

#if (XT_SC_LOG)
#define XTSCLOG(...) NSLog(__VA_ARGS__)
#else
#define XTSCLOG(...)
#endif

#pragma mark - NSArray

@implementation NSArray (XTSafe)


- (id)tn_objectAtIndex:(NSUInteger)index
{
    if (index >= self.count)
    {
        XTSCLOG(@"[%@ %@] index {%lu} beyond bounds [0...%lu]",
                NSStringFromClass([self class]),
                NSStringFromSelector(_cmd),
                (unsigned long)index,
                MAX((unsigned long)self.count - 1, 0));
        return nil;
    }
    
    return [self objectAtIndex:index];
}

+ (id)tn_arrayWithObjects:(const id [])objects count:(NSUInteger)cnt
{
    id validObjects[cnt];
    NSUInteger count = 0;
    for (NSUInteger i = 0; i < cnt; i++)
    {
        if (objects[i])
        {
            validObjects[count] = objects[i];
            count++;
        }
        else
        {
            XTSCLOG(@"[%@ %@] NIL object at index {%lu}",
                    NSStringFromClass([self class]),
                    NSStringFromSelector(_cmd),
                    (unsigned long)i);
            
        }
    }
    
    return [self arrayWithObjects:validObjects count:count];
}

@end

#pragma mark - NSMutableArray


@implementation NSMutableArray (XTSafe)

- (id)tn_objectAtIndex:(NSUInteger)index
{
    if (index >= self.count)
    {
        XTSCLOG(@"[%@ %@] index {%lu} beyond bounds [0...%lu]",
                NSStringFromClass([self class]),
                NSStringFromSelector(_cmd),
                (unsigned long)index,
                MAX((unsigned long)self.count - 1, 0));
        return nil;
    }
    
    return [self objectAtIndex:index];
}

- (void)tn_addObject:(id)anObject
{
    if (!anObject)
    {
        XTSCLOG(@"[%@ %@], NIL object.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return;
    }
    [self addObject:anObject];
}

- (void)tn_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    if (index >= self.count)
    {
        XTSCLOG(@"[%@ %@] index {%lu} beyond bounds [0...%lu].",
                NSStringFromClass([self class]),
                NSStringFromSelector(_cmd),
                (unsigned long)index,
                MAX((unsigned long)self.count - 1, 0));
        return;
    }
    
    if (!anObject)
    {
        XTSCLOG(@"[%@ %@] NIL object.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return;
    }
    
    [self replaceObjectAtIndex:index withObject:anObject];
}

- (void)tn_insertObject:(id)anObject atIndex:(NSUInteger)index
{
    if (index > self.count)
    {
        XTSCLOG(@"[%@ %@] index {%lu} beyond bounds [0...%lu].",
                NSStringFromClass([self class]),
                NSStringFromSelector(_cmd),
                (unsigned long)index,
                MAX((unsigned long)self.count - 1, 0));
        return;
    }
    
    if (!anObject)
    {
        XTSCLOG(@"[%@ %@] NIL object.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return;
    }
    
    [self insertObject:anObject atIndex:index];
}

@end

#pragma mark - NSDictionary


@implementation NSDictionary (XTSafe)
+ (instancetype)tn_dictionaryWithObjects:(NSArray *)objects forKeys:(NSArray *)keys{
    if (objects && keys) {
      return [self dictionaryWithObject:objects forKey:keys];
    }
    
    XTSCLOG(@"[%@ %@] NIL object and key",NSStringFromClass(self),NSStringFromSelector(_cmd));
    return nil;
}

+ (instancetype)tn_dictionaryWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt
{
    id validObjects[cnt];
    id<NSCopying> validKeys[cnt];
    NSUInteger count = 0;
    for (NSUInteger i = 0; i < cnt; i++)
    {
        if (objects[i] && keys[i])
        {
            validObjects[count] = objects[i];
            validKeys[count] = keys[i];
            count ++;
        }
        else
        {
            XTSCLOG(@"[%@ %@] NIL object or key at index{%lu}.",
                    NSStringFromClass(self),
                    NSStringFromSelector(_cmd),
                    (unsigned long)i);
        }
    }
    
    return [self dictionaryWithObjects:validObjects forKeys:validKeys count:count];
}

@end

#pragma mark - NSMutableDictionary


@implementation NSMutableDictionary (XTSafe)

- (void)tn_setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    if (!aKey || [self isEmptyStr:aKey])
    {
        XTSCLOG(@"[%@ %@] NIL key.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return;
    }
    if (!anObject)
    {
        XTSCLOG(@"[%@ %@] NIL object.", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return;
    }
    
    [self setObject:anObject forKey:aKey];
}

- (BOOL)isEmptyStr:(id)obj {
    if ([obj isKindOfClass:[NSString class]]
        && [self isEmpty:(NSString *)obj]) {
        return YES;
    }

    return NO;
}

- (BOOL)isEmpty:(NSString *)str
{
    return [self isEmptyIgnoringWhitespace:YES str:str];
}

- (BOOL)isEmptyIgnoringWhitespace:(BOOL)ignoreWhitespace str:(NSString *)str
{
    NSString *toCheck = (ignoreWhitespace) ? [self stringByTrimmingWhitespace:str] : self;
    return [toCheck isEqualToString:@""];
}

- (NSString *)stringByTrimmingWhitespace:(NSString *)str
{
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}
             
@end

#pragma mark - Mama

@implementation XTSafeCollection


@end
