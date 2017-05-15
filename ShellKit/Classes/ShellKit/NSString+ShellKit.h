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
 * @header      NSString+ShellKit.h
 * @copyright   (c) 2017, Jean-David Gadina - www.xs-labs.com
 */

#import <Foundation/Foundation.h>
#import <ShellKit/SKTypes.h>

/*!
 * @category    NSString( ShellKit )
 * @abstract    Additional NSString methods for ShellKit
 */
NS_ASSUME_NONNULL_BEGIN

@interface NSString( ShellKit )

/*!
 * @method      stringForShellStatus:
 * @abstract    Returns an emoji string for a status
 * @discussion  Status icons can be disabled with the `statusIconsEnabled` of
 *              `SKShell`.
 * @result      A string representing the status
 * @see         SKStatus
 * @see         SKShell#statusIconsEnabled
 */
+ ( NSString * )stringForShellStatus: ( SKStatus )status;

/*!
 * @method      stringForShellColor:
 * @abstract    Returns the string used to represent a shell color
 * @discussion  Colors can be disabled with the `colorsEnabled` property of
 *              `SKShell`.
 * @result      A string representing the shell color
 * @see         SKColor
 * @see         SKShell#colorsEnabled
 */
+ ( NSString * )stringForShellColor: ( SKColor )color;

/*!
 * @method      stringWithShellColor:
 * @abstract    Returns a string with a shell color.
 * @discussion  Colors can be disabled with the `colorsEnabled` property of
 *              `SKShell`.
 * @result      The colorized version of the string
 * @see         SKColor
 * @see         SKShell#colorsEnabled
 */
- ( NSString * )stringWithShellColor: ( SKColor )color;

@end

NS_ASSUME_NONNULL_END
