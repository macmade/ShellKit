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
 * @header      SKShell.h
 * @copyright   (c) 2017, Jean-David Gadina - www.xs-labs.com
 */

#import <Foundation/Foundation.h>
#import <ShellKit/SKTypes.h>

NS_ASSUME_NONNULL_BEGIN

@interface SKShell: NSObject

@property( atomic, readonly                    ) BOOL                    supportsColor;
@property( atomic, readwrite, strong, nullable ) NSString              * prompt;
@property( atomic, readwrite, strong, nullable ) NSArray< NSString * > * promptParts;

+ ( instancetype )currentShell;

- ( void )printError: ( nullable NSError * )error;
- ( void )printErrorMessage: ( NSString * )message;
- ( void )printMessage: ( NSString * )message;
- ( void )printMessage: ( NSString * )message status: ( SKStatus )status;
- ( void )printMessage: ( NSString * )message color: ( SKColor )color;
- ( void )printMessage: ( NSString * )message status: ( SKStatus )status color: ( SKColor )color;
- ( void )addPromptPart:( NSString * )part;
- ( void )removeLastPromptPart;

@end

NS_ASSUME_NONNULL_END
