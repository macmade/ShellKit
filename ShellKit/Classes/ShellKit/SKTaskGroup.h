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
 * @header      SKTaskGroup.h
 * @copyright   (c) 2017, Jean-David Gadina - www.xs-labs.com
 */

#import <Foundation/Foundation.h>
#import <ShellKit/SKObject.h>
#import <ShellKit/SKRunableObject.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 * @class       SKTaskGroup
 * @abstract    Represents a group of tasks that may be run
 * @see         SKRunableObject
 */
@interface SKTaskGroup: SKObject < SKRunableObject >

/*!
 * @property    name
 * @abstract    The name of the task group
 */
@property( atomic, readonly ) NSString * name;

/*!
 * @property    tasks
 * @abstract    The tasks contained in the task group
 * @see         SKRunableObject
 */
@property( atomic, readonly ) NSArray< id< SKRunableObject > > * tasks;

/*!
 * @property    currentTask
 * @abstract    The task currently executing
 * @discussion  This property will be nil if the task group isn't running,
 *              or if no task is actually executing.
 * @see         SKRunableObject
 */
@property( atomic, readonly, nullable ) id< SKRunableObject > currentTask;

/*!
 * @method      taskGroupWithName:tasks:
 * @abstract    Creates a task group object
 * @param       name    The name of the task group
 * @param       tasks   The tasks to execute when the task group is run
 * @result      The task group object
 * @see         SKRunableObject
 */
+ ( instancetype )taskGroupWithName: ( NSString * )name tasks: ( NSArray< id< SKRunableObject > > * )tasks;

/*!
 * @method      initWithName:tasks:
 * @abstract    Creates a task group object
 * @param       name    The name of the task group
 * @param       tasks   The tasks to execute when the task group is run
 * @result      The task group object
 * @see         SKRunableObject
 */
- ( instancetype )initWithName: ( NSString * )name tasks: ( NSArray< id< SKRunableObject > > * )tasks NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
