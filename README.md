NSObject+Invoke and NSObject+Queue
==================================

Synopsis
--------

    #import "NSObject+Invoke.h"
    #import "NSObject+Queue.h"

    // Immediately invoke a method on the main thread.
    [[table invokeOnMainThread] setEditing:YES animated:YES];

    // Queue an invocation to run on the next iteration of the main run loop.
    [[table queueOnMainThread] insertRowsAtIndexPaths:insertPaths
                                     withRowAnimation:UITableViewRowAnimationTop];

Description
-----------

If you've used [`-performSelectorOnMainThread:withObject:waitUntilDone:`](http://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSObject_Class/Reference/Reference.html#//apple_ref/doc/uid/20000050-CJBEHAEF) and related methods much, you're aware of their limitations. For one, you can pass only a single parameter (which must be an object), and for another, it executes right away, regardless of what the main run loop is already doing. Sure you could manually create an `NSInvocation` object, but what a pain!

These categories offer two ways to execute code on the main thread much more simply. The first, `NSObject+Invoke` (poached verbatim from Dave Dribin's [DDFoundation project](http://www.dribin.org/dave/hg/DDFoundation/), allows you simply call a method on the returnvalue of `invokeOnMainThread` and have it just do the right thing.

The second, `NSObject+Queue` (based on code by [Milo Bird](http://www.phatomfish.com/), does the same, except that it queues the invocation to run on the next iteration of the main run loop. This can be useful for relatively expensive operations that might otherwise make your UI freeze. By waiting until the run loop is available, the app stays more responsive for the user.

Both techniques are built on Dave Dribin's
[`DDInvocationGrabber`](http://www.dribin.org/dave/hg/DDFoundation/file/tip/lib/DDInvocationGrabber.h), which is where all the magic happens. In fact, if you don't need the queueing support, I suggest that you just go to [the source](http://www.dribin.org/dave/hg/DDFoundation/). I've created this project on GitHub to integrate the queueing magic.

### Usage ###

Just drag this folder into your project, then import `NSObject+Invoke.h` or `NSObject+Queue.h` as appropriate.

NSObject+Invoke
---------------

### -invokeOnMainThread ##

    - (id)invokeOnMainThread;

#### Discussion ####

Creates and returns a `DDInvocationGrabber` object primed to invoke the grabbed invocation on the main thread. To use it, simply invoke the method to be invoked on the return value, like so:

    [[table invokeOnMainThread] setEditing:YES animated:YES];

This method executes immediately after the invocation is created, and does not block on its execution.

### -invokeOnMainThreadAndWaitUntilDone: ###

    - (id)invokeOnMainThreadAndWaitUntilDone:(BOOL)wait;

#### Parameters ####

*wait* -
A Boolean that specifies whether the current thread blocks until after the specified selector is performed on the receiver on the main thread. Specify `YES` to block this thread; otherwise, specify `NO` to have this method return immediately.

If the current thread is also the main thread, and you specify `YES` for this parameter, the message is delivered and processed immediately.

#### Discussion ####

Creates and returns a `DDInvocationGrabber` object primed to invoke the grabbed invocation on the main thread. To use it, simply invoke the method to be invoked on the return value, like so:

    [[table invokeOnMainThreadAndWaitUntilDone:NO] setEditing:YES animated:YES];

NSObject+Queue
--------------

### -queueOnMainThread ###

- (id)queueOnMainThread;

#### Discussion ####

Creates and returns a `DDInvocationGrabber` object primed to invoke the grabbed invocation on next iteration of the main run loop. To use it, simply invoke the method to be invoked on the return value, like so:

    [[table queueOnMainThread] insertRowsAtIndexPaths:insertPaths
                                     withRowAnimation:UITableViewRowAnimationTop];

The method will return as soon as the invocation is queued, without waiting for its execution to complete.

Authors
-------

* DDFoundation by [Dave Dribin](http://www.dribin.org/dave/)
* Main run loop queuing by [Milo Bird](http://www.phatomfish.com/)
* Integration by [David E. Wheeler](http://justatheory.com/)

Copyright and License
---------------------
(c) 2007 by Toxic Software.
(c) 2007-2009 by Dave Dribin.
(c) 2011 by Milo Bird.
(c) 2011 by David E. Wheeler.

See individual files for licenses.
