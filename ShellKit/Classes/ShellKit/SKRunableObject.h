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
 * @header      SKRunableObject.h
 * @copyright   (c) 2017, Jean-David Gadina - www.xs-labs.com
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 * @protocol    SKRunableObject
 * @abstract    Protocol for runnable objects
 * @discussion  Represents an object that can be run (like a task).
 */
@protocol SKRunableObject< NSObject >

@required

/*!
 * @property    running
 * @abstract    Set when the runnable object is currently running
 */
@property( atomic, readonly ) BOOL running;

/*!
 * @property    error
 * @abstract    An optional error, possibly set after the task has run
 */
@property( atomic, readonly, nullable ) NSError * error;

/*!
 * @method      run
 * @abstract    Runs the task (synchronously)
 * @result      YES if the runnable object has run successfully, otherwise NO
 */
- ( BOOL )run;

/*!
 * @method      run
 * @abstract    Runs the task with variables (synchronously)
 * @param       variables   Optional variables
 * @result      YES if the runnable object has run successfully, otherwise NO
 */
- ( BOOL )run: ( nullable NSDictionary< NSString *, NSString * > * )variables;

@end

NS_ASSUME_NONNULL_END
