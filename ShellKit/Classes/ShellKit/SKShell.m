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

@property( atomic, readwrite, assign           ) BOOL                    observingPrompt;
@property( atomic, readwrite, assign           ) BOOL                    hasPromptParts;
@property( atomic, readwrite, strong           ) NSArray< NSString * > * promptStrings;
@property( atomic, readwrite, strong           ) dispatch_queue_t        dispatchQueue;
@property( atomic, readwrite, strong, nullable ) NSString              * shell;

- ( void )observerPrompt: ( BOOL )observe;

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

- ( instancetype )init
{
    if( ( self = [ super init ] ) )
    {
        self.shell                = [ NSProcessInfo processInfo ].environment[ @"SHELL" ];
        self.promptStrings        = @[];
        self.allowPromptHierarchy = YES;
        self.dispatchQueue        = dispatch_queue_create( "com.xs-labs.ShellKit.SKShell", DISPATCH_QUEUE_CONCURRENT );
        
        [ self observerPrompt: YES ];
    }
    
    return self;
}

- ( void )dealloc
{
    [ self observerPrompt: NO ];
}

- ( void )observerPrompt: ( BOOL )observe
{
    if( observe && self.observingPrompt == NO )
    {
        [ self addObserver: self forKeyPath: NSStringFromSelector( @selector( prompt ) ) options: NSKeyValueObservingOptionNew context: NULL ];
        
        self.observingPrompt = YES;
    }
    else if( observe == NO && self.observingPrompt )
    {
        [ self removeObserver: self forKeyPath: NSStringFromSelector( @selector( prompt ) ) ];
        
        self.observingPrompt = NO;
    }
}

- ( void )observeValueForKeyPath: ( NSString * )keyPath ofObject: ( id )object change: ( NSDictionary * )change context: ( void * )context
{
    if( object == self && [ keyPath isEqualToString: NSStringFromSelector( @selector( prompt ) )  ] )
    {
        @synchronized( self )
        {
            self.promptStrings = @[];
        }
    }
    else
    {
        [ super observeValueForKeyPath: keyPath ofObject: object change: change context: context ];
    }
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

- ( nullable NSString * )pathForCommand: ( NSString * )command
{
    __block BOOL             success;
    __block NSString       * output;
    SKShellCommandCompletion completion;
    
    completion = ^( int status, NSString * stdandardOutput, NSString * standardError )
    {
        success = status == EXIT_SUCCESS;
        output  = stdandardOutput;
        
        ( void )standardError;
    };
    
    @try
    {
        if( [ self runCommand: [ NSString stringWithFormat: @"which %@", command ] completion: completion ] == NO )
        {
            return nil;
        }
    }
    @catch( NSException * exception )
    {
        ( void )exception;
        
        return nil;
    }
    
    if( success == NO || output.length == 0 )
    {
        return nil;
    }
    
    output = [ output stringByTrimmingCharactersInSet: [ NSCharacterSet whitespaceAndNewlineCharacterSet ] ];
    
    if( output.length == 0 || [ [ NSFileManager defaultManager ] fileExistsAtPath: output ] == NO )
    {
        return nil;
    }
    
    return output;
}

- ( BOOL )isCommandAvailable: ( NSString * )command
{
    return [ self pathForCommand: command ] != nil;
}

- ( BOOL )runCommand: ( NSString * )command
{
    return [ self runCommand: command stdandardInput: nil ];
}

- ( BOOL )runCommand: ( NSString * )command stdandardInput: ( nullable NSString * )input
{
    return [ self runCommand: command stdandardInput: input completion: NULL ];
}

- ( BOOL )runCommand: ( NSString * )command completion: ( nullable SKShellCommandCompletion )completion
{
    return [ self runCommand: command stdandardInput: nil completion: completion ];
}

- ( BOOL )runCommand: ( NSString * )command stdandardInput: ( nullable NSString * )input completion: ( nullable  void ( ^ )( int status, NSString * stdandardOutput, NSString * standardError ) )completion
{
    NSTask       * task;
    NSPipe       * stdinPipe;
    NSPipe       * stdoutPipe;
    NSPipe       * stderrPipe;
        
    if( self.shell.length == NO || [ [ NSFileManager defaultManager ] fileExistsAtPath: self.shell ] == NO )
    {
        @throw [ NSException exceptionWithName: @"com.xs-labs.ShellKit.SKShellException" reason: @"SHELL environment variable is not defined" userInfo: [ NSProcessInfo processInfo ].environment ];
    }
    
    stdinPipe           = [ NSPipe pipe ];
    stdoutPipe          = [ NSPipe pipe ];
    stderrPipe          = [ NSPipe pipe ];
    task                = [ NSTask new ];
    task.launchPath     = self.shell;
    task.arguments      = @[ @"-l", @"-c", command ];
    task.standardOutput = stdoutPipe;
    task.standardError  = stderrPipe;
    
    if( input )
    {
        task.standardInput = stdinPipe;
    }
    
    [ task launch ];
    
    if( input )
    {
        [ stdinPipe.fileHandleForWriting writeData: [ input dataUsingEncoding: NSUTF8StringEncoding ] ];
    }
    
    [ task waitUntilExit ];
    
    if( completion )
    {
        {
            NSString * output;
            NSString * error;
            
            @try
            {
                output = [ [ NSString alloc ] initWithData: [ stdoutPipe.fileHandleForReading readDataToEndOfFile ] encoding: NSUTF8StringEncoding ];
            }
            @catch( NSException * exception )
            {
                ( void )exception;
                
                output = nil;
            }
            
            @try
            {
                error = [ [ NSString alloc ] initWithData: [ stdoutPipe.fileHandleForReading readDataToEndOfFile ] encoding: NSUTF8StringEncoding ];
            }
            @catch( NSException * exception )
            {
                ( void )exception;
                
                error = nil;
            }
            
            completion
            (
                task.terminationStatus,
                ( output ) ? output : @"",
                ( error  ) ? error  : @""
            );
        }
    }
    
    return task.terminationStatus == EXIT_SUCCESS;
}

- ( void )runCommandAsynchronously: ( NSString * )command;
{
    [ self runCommandAsynchronously: command stdandardInput: nil ];
}

- ( void )runCommandAsynchronously: ( NSString * )command stdandardInput: ( nullable NSString * )input
{
    [ self runCommandAsynchronously: command stdandardInput: input completion: NULL ];
}

- ( void )runCommandAsynchronously: ( NSString * )command stdandardInput: ( nullable NSString * )input completion: ( nullable void ( ^ )( int status, NSString * stdandardOutput, NSString * standardError ) )completion
{
    dispatch_async
    (
        self.dispatchQueue,
        ^( void )
        {
            [ self runCommand: command stdandardInput: input completion: completion ];
        }
    );
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

- ( void )printErrorMessageWithFormat: ( NSString * )format, ...
{
    NSString * message;
    va_list    ap;
    
    va_start( ap, format );
    
    message = [ [ NSString alloc ] initWithFormat: format arguments: ap ];
    
    va_end( ap );
    
    [ self printErrorMessage: message ];
}

- ( void )printWarningMessage: ( NSString * )message
{
    [ self printMessage: message status: SKStatusWarning color: SKColorYellow ];
}

- ( void )printWarningMessageWithFormat: ( NSString * )format, ...
{
    NSString * message;
    va_list    ap;
    
    va_start( ap, format );
    
    message = [ [ NSString alloc ] initWithFormat: format arguments: ap ];
    
    va_end( ap );
    
    [ self printWarningMessage: message ];
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
    NSString * p;
    NSString * s;
    
    @synchronized( self )
    {
        p = ( self.prompt ) ? self.prompt : @"";
        s = [ NSString stringForShellStatus: status ];
        
        if( s.length > 0 )
        {
            s = [ s stringByAppendingString: @"  " ];
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
}

- ( void )printMessageWithFormat: ( NSString * )format, ...
{
    NSString * message;
    va_list    ap;
    
    va_start( ap, format );
    
    message = [ [ NSString alloc ] initWithFormat: format arguments: ap ];
    
    va_end( ap );
    
    [ self printMessage: message ];
}

- ( void )printMessageWithFormat: ( NSString * )format status: ( SKStatus )status, ...
{
    NSString * message;
    va_list    ap;
    
    va_start( ap, status );
    
    message = [ [ NSString alloc ] initWithFormat: format arguments: ap ];
    
    va_end( ap );
    
    [ self printMessage: message status: status ];
}

- ( void )printMessageWithFormat: ( NSString * )format color: ( SKColor )color, ...
{
    NSString * message;
    va_list    ap;
    
    va_start( ap, color );
    
    message = [ [ NSString alloc ] initWithFormat: format arguments: ap ];
    
    va_end( ap );
    
    [ self printMessage: message color: color ];
}

- ( void )printMessageWithFormat: ( NSString * )format status: ( SKStatus )status color: ( SKColor )color, ...
{
    NSString * message;
    va_list    ap;
    
    va_start( ap, color );
    
    message = [ [ NSString alloc ] initWithFormat: format arguments: ap ];
    
    va_end( ap );
    
    [ self printMessage: message status: status color: color ];
}

- ( NSArray< NSString * > * )promptParts
{
    @synchronized( self )
    {
        return self.promptStrings.copy;
    }
}

- ( void )setPromptParts: ( NSArray< NSString * > * )parts
{
    NSUInteger        i;
    NSString        * part;
    NSMutableString * prompt;
    SKColor           colors[] = { SKColorCyan, SKColorBlue, SKColorPurple };
    
    @synchronized( self )
    {
        self.promptStrings = parts.copy;
        
        if( parts.count == 0 )
        {
            self.prompt = @"";
        }
        
        prompt = [ NSMutableString new ];
        i      = 0;
        
        for( part in parts )
        {
            part = [ part stringWithShellColor: colors[ i % ( sizeof( colors ) / sizeof( SKColor ) ) ] ];
            
            [ prompt appendFormat: @"[ %@ ]> ", part ];
            
            i++;
        }
        
        [ self observerPrompt: NO ];
        
        self.prompt = prompt;
        
        [ self observerPrompt: YES ];
    }
}

- ( void )addPromptPart:( NSString * )part
{
    if( self.allowPromptHierarchy == NO )
    {
        return;
    }
    
    self.promptParts = [ self.promptParts arrayByAddingObject: part ];
}

- ( void )removeLastPromptPart
{
    NSMutableArray * parts;
    
    if( self.allowPromptHierarchy == NO )
    {
        return;
    }
    
    parts = self.promptParts.mutableCopy;
    
    if( parts.count )
    {
        [ parts removeLastObject ];
        
        self.promptParts = parts;
    }
}

@end
