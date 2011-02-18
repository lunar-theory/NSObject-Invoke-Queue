/*
 * Copyright (c) 2011 by David E. Wheeler
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#import "NSObject+Queue.h"
#import "DDInvocationGrabber.h"

static NSMutableArray *staticMainThreadQueue = nil;
static NSTimer *staticMainThreadTimer = nil;

@interface NSObject (QueuePrivate)
+ (void)enqueueMainThreadInvocation:(NSInvocation *)invocation;
+ (void)dequeueMainThreadInvocation:(NSTimer *)timer;
@end

@implementation NSObject (Queue)

- (id)queueOnMainThread;
{
    DDInvocationGrabber * grabber = [DDInvocationGrabber invocationGrabber];
    [grabber setQueueInvokesOnMainThread:YES];
    return [grabber prepareWithInvocationTarget:self];
}

//
//  NSObject+MBMainThreadQueue.m
//  Byline
//
//  Created by Milo on 25/01/2011.
//  It’s public domain, use it as you wish!
//

+ (void)enqueueMainThreadInvocation:(NSInvocation *)invocation;
{
    if (!staticMainThreadQueue)
        staticMainThreadQueue = [[NSMutableArray alloc] initWithCapacity:1];
    [staticMainThreadQueue addObject:invocation];
    if (!staticMainThreadTimer)
        staticMainThreadTimer = [[NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(dequeueMainThreadInvocation:) userInfo:nil repeats:YES] retain];
}

+ (void)dequeueMainThreadInvocation:(NSTimer *)timer;
{
    if ([staticMainThreadQueue count] > 0)
    {
        [[staticMainThreadQueue objectAtIndex:0] invoke];
        [staticMainThreadQueue removeObjectAtIndex:0];
    }
    else
    {
        [staticMainThreadQueue release];
        staticMainThreadQueue = nil;
        [staticMainThreadTimer invalidate];
        [staticMainThreadTimer release];
        staticMainThreadTimer = nil;
    }
}

- (void)queueSelectorOnMainThread:(SEL)selector withObject:(id)object;
{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
    [invocation setTarget:self];
    [invocation setSelector:selector];
    if (object)
        [invocation setArgument:&object atIndex:2];
    [invocation retainArguments];
    [NSObject performSelectorOnMainThread:@selector(enqueueMainThreadInvocation:) withObject:invocation waitUntilDone:NO];
}

- (void)queueInvocationOnMainThread:(NSInvocation *)invocation {
    [NSObject performSelectorOnMainThread:@selector(enqueueMainThreadInvocation:) withObject:invocation waitUntilDone:NO];
}

@end
