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

typedef void ( ^ SKShellCommandCompletion )( int status, NSString * stdandardOutput, NSString * standardError );

@interface SKShell: NSObject

@property( atomic, readonly                    ) BOOL                    supportsColors;
@property( atomic, readonly                    ) BOOL                    colorsEnabled;
@property( atomic, readonly                    ) BOOL                    statusIconsEnabled;
@property( atomic, readwrite, strong, nullable ) NSString              * prompt;
@property( atomic, readwrite, strong, nullable ) NSArray< NSString * > * promptParts;
@property( atomic, readwrite, assign           ) BOOL                    allowPromptHierarchy;
@property( atomic, readonly,          nullable ) NSString              * shell;

+ ( instancetype )currentShell;

- ( nullable NSString * )pathForCommand: ( NSString * )command;
- ( BOOL )commandIsAvailable: ( NSString * )command;

- ( BOOL )runCommand: ( NSString * )command;
- ( BOOL )runCommand: ( NSString * )command stdandardInput: ( nullable NSString * )input;
- ( BOOL )runCommand: ( NSString * )command completion: ( nullable SKShellCommandCompletion )completion;
- ( BOOL )runCommand: ( NSString * )command stdandardInput: ( nullable NSString * )input completion: ( nullable SKShellCommandCompletion )completion;
- ( void )runCommandAsynchronously: ( NSString * )command;
- ( void )runCommandAsynchronously: ( NSString * )command stdandardInput: ( nullable NSString * )input;
- ( void )runCommandAsynchronously: ( NSString * )command stdandardInput: ( nullable NSString * )input completion: ( nullable SKShellCommandCompletion )completion;

- ( void )printError: ( nullable NSError * )error;
- ( void )printErrorMessage: ( NSString * )format, ... NS_FORMAT_FUNCTION( 1, 2 );
- ( void )printWarningMessage: ( NSString * )format, ... NS_FORMAT_FUNCTION( 1, 2 );
- ( void )printSuccessMessage: ( NSString * )format, ... NS_FORMAT_FUNCTION( 1, 2 );
- ( void )printInfoMessage: ( NSString * )format, ... NS_FORMAT_FUNCTION( 1, 2 );

- ( void )printMessage: ( NSString * )format, ... NS_FORMAT_FUNCTION( 1, 2 );
- ( void )printMessage: ( NSString * )format status: ( SKStatus )status, ... NS_FORMAT_FUNCTION( 1, 3 );
- ( void )printMessage: ( NSString * )format color: ( SKColor )color, ... NS_FORMAT_FUNCTION( 1, 3 );
- ( void )printMessage: ( NSString * )format status: ( SKStatus )status color: ( SKColor )color, ... NS_FORMAT_FUNCTION( 1, 4 );

- ( void )addPromptPart:( NSString * )part;
- ( void )removeLastPromptPart;

@end

NS_ASSUME_NONNULL_END
