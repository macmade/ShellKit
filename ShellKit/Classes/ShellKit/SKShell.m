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
 * @file        SKShell.m
 * @copyright   (c) 2017, Jean-David Gadina - www.xs-labs.com
 */

#import <ShellKit/ShellKit.h>
#import <curses.h>
#import <term.h>

NS_ASSUME_NONNULL_BEGIN

@interface SKShell()

@end

NS_ASSUME_NONNULL_END

@implementation SKShell

+ ( instancetype )currentShell
{
    static dispatch_once_t once;
    static id              instance;
    
    dispatch_once
    (
        &once,
        ^( void )
        {
            instance = [ self new ];
        }
    );
    
    return instance;
}

- ( BOOL )supportsColor
{
    int err;
    
    if( setupterm( NULL, 1, &err ) == ERR )
    {
        return NO;
    }
    
    return YES;
}

- ( void )printError: ( nullable NSError * )error
{
    NSString * message;
    
    if( error.localizedDescription.length )
    {
        message = [ NSString stringWithFormat: @"Error - %@", error.localizedDescription ];
    }
    else
    {
        message = @"An unknown error occured";
    }
    
    [ self printMessage: message status: SKStatusError color: SKColorRed ];
}

- ( void )printErrorMessage: ( NSString * )message
{
    NSError * error;
    
    error = [ NSError errorWithDomain: NSPOSIXErrorDomain code: 0 userInfo: @{ NSLocalizedDescriptionKey : message } ];
    
    [ self printError: error ];
}

- ( void )printMessage: ( NSString * )message
{
    [ self printMessage: message status: SKStatusNone color: SKColorNone ];
}

- ( void )printMessage: ( NSString * )message status: ( SKStatus )status
{
    [ self printMessage: message status: status color: SKColorNone ];
}

- ( void )printMessage: ( NSString * )message color: ( SKColor )color
{
    [ self printMessage: message status: SKStatusNone color: color ];
}

- ( void )printMessage: ( NSString * )message status: ( SKStatus )status color: ( SKColor )color
{
    NSString * s;
    NSString * p;
    
    s = [ NSString stringForShellStatus: status ];
    p = self.prompt;
    
    if( s.length > 0 )
    {
        s = [ s stringByAppendingString: @"  " ];
    }
    
    if( p.length > 0 )
    {
        p = [ s stringByAppendingString: @" " ];
    }
    
    fprintf
    (
        stdout,
        "%s%s%s\n",
        p.UTF8String,
        s.UTF8String,
        [ message stringWithShellColor: color ].UTF8String
    );
}

@end
