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

@property( atomic, readwrite, assign           ) BOOL       running;
@property( atomic, readwrite, strong, nullable ) NSError  * error;
@property( atomic, readwrite, strong           ) NSString * script;
@property( atomic, readwrite, strong, nullable ) SKTask   * recover;

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
    NSTask * task;
    
    if( self.script.length == 0 )
    {
        self.error = [ self errorWithDescription: @"No script defined" ];
        
        return NO;
    }
    
    [ [ SKShell currentShell ] printMessageWithFormat: @"Running task: %@" status: SKStatusExecute color: SKColorNone, [ self.script stringWithShellColor: SKColorCyan ] ];
    
    task            = [ NSTask new ];
    task.launchPath = @"/bin/sh";
    task.arguments  =
    @[
        @"-l",
        @"-c",
        self.script
    ];
    
    [ task launch ];
    [ task waitUntilExit ];
    
    if( task.terminationStatus != 0 )
    {
        if( self.recover )
        {
            [ [ SKShell currentShell ] printMessage: @"Task failed - Trying to recover..." status: SKStatusWarning color: SKColorYellow ];
            
            {
                BOOL ret;
                
                ret        = [ self.recover run ];
                self.error = self.recover.error;
                
                return ret;
            }
        }
        
        self.error = [ self errorWithDescription: @"Task exited with status %li", ( long )( task.terminationStatus ) ];
        
        return NO;
    }
    
    [ [ SKShell currentShell ] printMessage: @"Task completed successfully" status: SKStatusSuccess color: SKColorGreen ];
    
    return YES;
}

@end
