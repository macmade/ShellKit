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
 * @file        SKTask.m
 * @copyright   (c) 2017, Jean-David Gadina - www.xs-labs.com
 */

#import <ShellKit/ShellKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SKTask()

@property( atomic, readwrite, assign           ) BOOL                  running;
@property( atomic, readwrite, strong, nullable ) NSError             * error;
@property( atomic, readwrite, strong           ) NSString            * script;
@property( atomic, readwrite, strong, nullable ) NSArray< SKTask * > * recover;

@end

NS_ASSUME_NONNULL_END

@implementation SKTask

+ ( instancetype )taskWithShellScript: ( NSString * )script
{
    return [ [ self alloc ] initWithShellScript: script ];
}

+ ( instancetype )taskWithShellScript: ( NSString * )script recoverTask: ( nullable SKTask * )recover;
{
    return [ [ self alloc ] initWithShellScript: script recoverTask: recover ];
}

+ ( instancetype )taskWithShellScript: ( NSString * )script recoverTasks: ( nullable NSArray< SKTask * > * )recover
{
    return [ [ self alloc ] initWithShellScript: script recoverTasks: recover ];
}

- ( instancetype )init
{
    return [ self initWithShellScript: @"" ];
}

- ( instancetype )initWithShellScript: ( NSString * )script
{
    return [ self initWithShellScript: script recoverTask: nil ];
}

- ( instancetype )initWithShellScript: ( NSString * )script recoverTask: ( nullable SKTask * )recover
{
    return [ self initWithShellScript: script recoverTasks: ( recover ) ? @[ recover ] : nil ];
}

- ( instancetype )initWithShellScript: ( NSString * )script recoverTasks: ( nullable NSArray< SKTask * > * )recover
{
    if( ( self = [ super init ] ) )
    {
        self.script  = script;
        self.recover = recover;
    }
    
    return self;
}

#pragma mark - SKRunableObject

- ( BOOL )run
{
    return [ self run: nil ];
}

- ( BOOL )run: ( nullable NSDictionary< NSString *, NSString * > * )variables
{
    NSTask               * task;
    NSString             * key;
    NSString             * var;
    NSString             * script;
    NSRegularExpression  * regex;
    NSArray              * matches;
    NSTextCheckingResult * match;
    NSDate               * date;
    NSString             * time;
    
    @synchronized( self )
    {
        if( self.script.length == 0 )
        {
            self.error = [ self errorWithDescription: @"No script defined" ];
            
            [ [ SKShell currentShell ] printError: self.error ];
            
            return NO;
        }
        
        script = self.script.copy;
        
        for( key in variables )
        {
            var    = [ NSString stringWithFormat: @"%%{%@}%%", key ];
            script = [ script stringByReplacingOccurrencesOfString: var withString: variables[ key ] ];
        }
        
        self.running = YES;
        
        [ [ SKShell currentShell ] printMessageWithFormat: @"Running task: %@" status: SKStatusExecute color: SKColorNone, [ script stringWithShellColor: SKColorCyan ] ];
        
        regex   = [ NSRegularExpression regularExpressionWithPattern: @"%\\{([A-Za-z0-9]+)\\}%" options: NSRegularExpressionCaseInsensitive error: NULL ];
        matches = [ regex matchesInString: script options: ( NSMatchingOptions )0 range: NSMakeRange( 0, script.length ) ];
        
        if( matches.count != 0 )
        {
            for( match in matches )
            {
                [ [ SKShell currentShell ] printWarningMessageWithFormat: @"No value provided value for variable: %@", [ script substringWithRange: [ match rangeAtIndex: 1 ] ] ];
            }
            
            self.error = [ self errorWithDescription: @"Script contains unsubstituted variables" ];
            
            [ [ SKShell currentShell ] printError: self.error ];
            
            return NO;
        }
        
        task            = [ NSTask new ];
        task.launchPath = @"/bin/sh";
        task.arguments  =
        @[
            @"-l",
            @"-c",
            script
        ];
        
        date = [ NSDate date ];
        
        [ task launch ];
        [ task waitUntilExit ];
        
        time = date.elapsedTimeStringSinceNow;
        
        if( task.terminationStatus != 0 )
        {
            if( self.recover.count )
            {
                {
                    SKTask * recover;
                    BOOL     ret;
                    
                    for( recover in self.recover )
                    {
                        [ [ SKShell currentShell ] printMessageWithFormat: @"Task failed - Trying to recover..." status: SKStatusWarning color: SKColorYellow ];
                        
                        ret          = [ recover run: variables ];
                        self.error   = recover.error;
                        
                        if( ret )
                        {
                            time = date.elapsedTimeStringSinceNow;
                            
                            [ [ SKShell currentShell ] printMessageWithFormat: @"Task recovered successfully%@"
                                                       status:                 SKStatusSuccess
                                                       color:                  SKColorGreen,
                                                       ( time ) ? [ [ NSString stringWithFormat: @" (%@)", time ] stringWithShellColor: SKColorWhite ] : @""
                            ];
                            
                            self.running = NO;
                            
                            return YES;
                        }
                    }
                    
                    [ [ SKShell currentShell ] printErrorMessage: @"Task failed to recover" ];
                    
                    self.running = NO;
                    
                    return NO;
                }
            }
            
            self.error = [ self errorWithDescription: @"Task exited with status %li", ( long )( task.terminationStatus ) ];
            
            [ [ SKShell currentShell ] printError: self.error ];
            
            self.running = NO;
            
            return NO;
        }
        
        [ [ SKShell currentShell ] printMessageWithFormat: @"Task completed successfully%@"
                                   status:                 SKStatusSuccess
                                   color:                  SKColorGreen,
                                   ( time ) ? [ [ NSString stringWithFormat: @" (%@)", time ] stringWithShellColor: SKColorWhite ] : @""
        ];
        
        self.running = NO;
        
        return YES;
    }
}

@end
