/*******************************************************************************
 * The MIT License (MIT)
 * 
 * Copyright (c) 2017 Jean-David Gadina - www.xs-labs.com
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

/*!
 * @header      SKTask.h
 * @copyright   (c) 2017, Jean-David Gadina - www.xs-labs.com
 */

#import <Foundation/Foundation.h>
#import <ShellKit/SKObject.h>
#import <ShellKit/SKRunableObject.h>

NS_ASSUME_NONNULL_BEGIN

@class SKTask;

/*!
 * @typedef     SKTaskOutputType
 * @abstract    The type of output of a task
 * @discussion  Used to differenciate output comming from a task's `stdout`
 *              or `stderr`.
 */
typedef NS_ENUM( NSInteger, SKTaskOutputType )
{
    SKTaskOutputTypeStandardOutput, /*! `stdout` output type */
    SKTaskOutputTypeStandardError   /*! `stderr` output type */
};

/*!
 * @protocol    SKTaskDelegate
 * @abstract    Delegate for `SKTask` objects
 * @see         SKTask
 */
@protocol SKTaskDelegate< NSObject >

@optional

/*!
 * @method      taskWillStart:
 * @abstract    Called when a task is about to be run
 * @dicussion   This method is optional.
 * @param       task    The task object
 * @see         SKTask
 */
- ( void )taskWillStart: ( SKTask * )task;

/*!
 * @method      task:didProduceOutput:
 * @abstract    Called when a task has produced output on `stdout` or `stderr`
 * @dicussion   This method is optional.
 *              Note that the output may not be whole/complete lines, as this
 *              method, if implemented by the delagete, will be called as
 *              output is captured.
 * @param       task    The task object
 * @param       output  The produced output string
 * @param       type    The output type
 * @see         SKTask
 * @see         SKTaskOutputType
 */
- ( void )task: ( SKTask * )task didProduceOutput: ( NSString * )output forType: ( SKTaskOutputType )type;

/*!
 * @method      task:didEndWithStatus:
 * @abstract    Called when a task has finished running
 * @dicussion   This method is optional.
 * @param       task    The task object
 * @param       status  The task's exit status
 * @see         SKTask
 */
- ( void )task: ( SKTask * )task didEndWithStatus: ( int )status;

@end

/*!
 * @class       SKTask
 * @discussion  Represents a shell task
 * @see         SKRunableObject
 */
@interface SKTask: SKObject < SKRunableObject >

/*!
 * @property    delegate
 * @abstract    The task's delegate
 * @see         SKTaskDelegate
 */
@property( atomic, readwrite, weak ) id< SKTaskDelegate > delegate;

/*!
 * @method      taskWithShellScript:
 * @abstract    Creates a task from a shell script
 * @param       script  The shell script to execute when the task is run
 * @result      The task object
 */
+ ( instancetype )taskWithShellScript: ( NSString * )script;

/*!
 * @method      taskWithShellScript:recoverTask:
 * @abstract    Creates a task from a shell script
 * @discussion  If a recovery task is passed, it will be executed upon failure.
 *              If the recovery task then succeed, the primary task will also
 *              succeed.
 * @param       script  The shell script to execute when the task is run
 * @param       recover An optional task to execute as recovery if the task fails.
 * @result      The task object
 */
+ ( instancetype )taskWithShellScript: ( NSString * )script recoverTask: ( nullable SKTask * )recover;

/*!
 * @method      taskWithShellScript:recoverTasks:
 * @abstract    Creates a task from a shell script
 * @discussion  If recovery tasks are passed, they will be executed upon
 *              failure, until one of them succeed.
 *              If a recovery task then succeed, the primary task will also
 *              succeed.
 * @param       script  The shell script to execute when the task is run
 * @param       recover An optional array of tasks to execute as recovery if the task fails.
 * @result      The task object
 */
+ ( instancetype )taskWithShellScript: ( NSString * )script recoverTasks: ( nullable NSArray< SKTask * > * )recover;

/*!
 * @method      initWithShellScript:
 * @abstract    Creates a task from a shell script
 * @param       script  The shell script to execute when the task is run
 * @result      The task object
 */
- ( instancetype )initWithShellScript: ( NSString * )script;

/*!
 * @method      initWithShellScript:recoverTask:
 * @abstract    Creates a task from a shell script
 * @discussion  If a recovery task is passed, it will be executed upon failure.
 *              If the recovery task then succeed, the primary task will also
 *              succeed.
 * @param       script  The shell script to execute when the task is run
 * @param       recover An optional task to execute as recovery if the task fails.
 * @result      The task object
 */
- ( instancetype )initWithShellScript: ( NSString * )script recoverTask: ( nullable SKTask * )recover;

/*!
 * @method      initWithShellScript:recoverTasks:
 * @abstract    Creates a task from a shell script
 * @discussion  If recovery tasks are passed, they will be executed upon
 *              failure, until one of them succeed.
 *              If a recovery task then succeed, the primary task will also
 *              succeed.
 * @param       script  The shell script to execute when the task is run
 * @param       recover An optional array of tasks to execute as recovery if the task fails.
 * @result      The task object
 */
- ( instancetype )initWithShellScript: ( NSString * )script recoverTasks: ( nullable NSArray< SKTask * > * )recover NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
