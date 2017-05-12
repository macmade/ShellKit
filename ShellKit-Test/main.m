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
 * @header      main.m
 * @copyright   (c) 2017, Jean-David Gadina - www.xs-labs.com
 */

#import <Foundation/Foundation.h>
#import <ShellKit/ShellKit.h>

static NSUInteger step = 0;

void PrintStep( NSString * msg );
void PrintStep( NSString * msg )
{
    NSArray * prompt;
    
    prompt                          = [ SKShell currentShell ].promptParts;
    [ SKShell currentShell ].prompt = @"";
    
    [ [ SKShell currentShell ] printMessage: @"" ];
    [ [ SKShell currentShell ] printMessage: @"Example %lu: %@" status: SKStatusIdea, ( unsigned long )++step, msg ];
    [ [ SKShell currentShell ] printMessage: @"--------------------------------------------------------------------------------" ];
    
    [ SKShell currentShell ].promptParts = prompt;
}

int main( void )
{
    @autoreleasepool
    {
        [ SKShell currentShell ].promptParts = @[ @"ShellKit" ];
        
        PrintStep( @"Shell infos" );
        
        {
            NSString * shell;
            NSString * brew;
            NSString * xcodebuild;
            
            shell      = [ SKShell currentShell ].shell;
            brew       = [ [ SKShell currentShell ] pathForCommand: @"brew" ];
            xcodebuild = [ [ SKShell currentShell ] pathForCommand: @"xcodebuild" ];
            
            assert( shell != nil );
            
            [ [ SKShell currentShell ] printMessage: @"shell:      %@" status: SKStatusSettings, shell ];
            [ [ SKShell currentShell ] printMessage: @"brew:       %@" status: SKStatusSettings, ( brew       ) ? brew       : @"--" ];
            [ [ SKShell currentShell ] printMessage: @"xcodebuild: %@" status: SKStatusSettings, ( xcodebuild ) ? xcodebuild : @"--" ];
        }
        
        PrintStep( @"Executing commands" );
        
        {
            [ [ SKShell currentShell ] printMessage: @"Executing ls -al" status: SKStatusExecute color: SKColorCyan ];
            [ [ SKShell currentShell ] runCommand: @"ls -al" completion: ^( int status, NSString * output, NSString * error )
                {
                    [ [ SKShell currentShell ] printInfoMessage: @"Command exited with status %i", status ];
                    
                    if( output.length )
                    {
                        [ [ SKShell currentShell ] printInfoMessage: @"Standard output:" ];
                        [ [ SKShell currentShell ] printMessage: @"%@", output ];
                    }
                    
                    if( error.length )
                    {
                        [ [ SKShell currentShell ] printInfoMessage: @"Standard error:" ];
                        [ [ SKShell currentShell ] printMessage: @"%@", error ];
                    }
                }
            ];
        }
        
        PrintStep( @"Simple task" );
        
        {
            SKTask * task;
            
            task = [ SKTask taskWithShellScript: @"ls -al" ];
            
            assert( ( [ task run ] == YES ) );
        }
        
        PrintStep( @"Simple task failure" );
        
        {
            SKTask * task;
            
            task = [ SKTask taskWithShellScript: @"false" ];
            
            assert( ( [ task run ] == NO ) );
        }
        
        PrintStep( @"Simple task failure with failed recovery" );
        
        {
            SKTask * task;
            
            task = [ SKTask taskWithShellScript: @"false" recoverTask: [ SKTask taskWithShellScript: @"false" ] ];
            
            assert( ( [ task run ] == NO ) );
        }
        
        PrintStep( @"Simple task failure with successful recovery (variant 1)" );
        
        {
            SKTask * task;
            
            task = [ SKTask taskWithShellScript: @"false" recoverTasks: @[ [ SKTask taskWithShellScript: @"false" ], [ SKTask taskWithShellScript: @"true" ] ] ];
            
            assert( ( [ task run ] == YES ) );
        }
        
        PrintStep( @"Simple task failure with successful recovery (variant 2)" );
        
        {
            SKTask * task;
            
            task = [ SKTask taskWithShellScript: @"false" recoverTask: [ SKTask taskWithShellScript: @"false" recoverTask: [ SKTask taskWithShellScript: @"true" ] ] ];
            
            assert( ( [ task run ] == YES ) );
        }
        
        PrintStep( @"Optional task" );
        
        {
            SKOptionalTask * task;
            
            task = [ SKOptionalTask taskWithShellScript: @"false" ];
            
            assert( ( [ task run ] == YES ) );
        }
        
        PrintStep( @"Task group" );
        
        {
            SKTask      * t1;
            SKTask      * t2;
            SKTaskGroup * group;
            
            t1    = [ SKTask taskWithShellScript: @"true" ];
            t2    = [ SKTask taskWithShellScript: @"true" ];
            group = [ SKTaskGroup taskGroupWithName: @"group" tasks: @[ t1, t2 ] ];
            
            assert( ( [ group run ] == YES ) );
        }
        
        PrintStep( @"Task group failure" );
        
        {
            SKTask      * t1;
            SKTask      * t2;
            SKTaskGroup * group;
            
            t1    = [ SKTask taskWithShellScript: @"true" ];
            t2    = [ SKTask taskWithShellScript: @"false" ];
            group = [ SKTaskGroup taskGroupWithName: @"group" tasks: @[ t1, t2 ] ];
            
            assert( ( [ group run ] == NO ) );
        }
        
        PrintStep( @"Task group failure with successful recovery" );
        
        {
            SKTask      * t1;
            SKTask      * t2;
            SKTaskGroup * group;
            
            t1    = [ SKTask taskWithShellScript: @"true" ];
            t2    = [ SKTask taskWithShellScript: @"false" recoverTask: t1 ];
            group = [ SKTaskGroup taskGroupWithName: @"group" tasks: @[ t1, t2 ] ];
            
            assert( ( [ group run ] == YES ) );
        }
        
        PrintStep( @"Task groups in task group" );
        
        {
            SKTask      * t1;
            SKTask      * t2;
            SKTaskGroup * g1;
            SKTaskGroup * g2;
            SKTaskGroup * group;
            
            t1    = [ SKTask taskWithShellScript: @"true" ];
            t2    = [ SKTask taskWithShellScript: @"true" ];
            g1    = [ SKTaskGroup taskGroupWithName: @"foo" tasks: @[ t1, t2 ] ];
            g2    = [ SKTaskGroup taskGroupWithName: @"bar" tasks: @[ t1, t2 ] ];
            group = [ SKTaskGroup taskGroupWithName: @"group" tasks: @[ g1, g2 ] ];
            
            assert( ( [ group run ] == YES ) );
        }
        
        PrintStep( @"Task groups in task group failure" );
        
        {
            SKTask      * t1;
            SKTask      * t2;
            SKTask      * t3;
            SKTaskGroup * g1;
            SKTaskGroup * g2;
            SKTaskGroup * group;
            
            t1    = [ SKTask taskWithShellScript: @"true" ];
            t2    = [ SKTask taskWithShellScript: @"true" ];
            t3    = [ SKTask taskWithShellScript: @"false" ];
            g1    = [ SKTaskGroup taskGroupWithName: @"foo" tasks: @[ t1, t2 ] ];
            g2    = [ SKTaskGroup taskGroupWithName: @"bar" tasks: @[ t1, t3 ] ];
            group = [ SKTaskGroup taskGroupWithName: @"group" tasks: @[ g1, g2 ] ];
            
            assert( ( [ group run ] == NO ) );
        }
        
        PrintStep( @"Task groups in task group with successful recovery" );
        
        {
            SKTask      * t1;
            SKTask      * t2;
            SKTask      * t3;
            SKTaskGroup * g1;
            SKTaskGroup * g2;
            SKTaskGroup * group;
            
            t1    = [ SKTask taskWithShellScript: @"true" ];
            t2    = [ SKTask taskWithShellScript: @"true" ];
            t3    = [ SKTask taskWithShellScript: @"false" recoverTask: t1 ];
            g1    = [ SKTaskGroup taskGroupWithName: @"foo" tasks: @[ t1, t2 ] ];
            g2    = [ SKTaskGroup taskGroupWithName: @"bar" tasks: @[ t1, t3 ] ];
            group = [ SKTaskGroup taskGroupWithName: @"group" tasks: @[ g1, g2 ] ];
            
            assert( ( [ group run ] == YES ) );
        }
        
        PrintStep( @"Task arguments" );
        
        {
            SKTask * task;

            task = [ SKTask taskWithShellScript: @"ls %{args}% %{dir}%" ];

            assert( ( [ task run: @{ @"args" : @"-al", @"dir" : @"/usr" } ] == YES ) );
        }
        
        PrintStep( @"Task arguments failure" );
        
        {
            SKTask * task;

            task = [ SKTask taskWithShellScript: @"echo %{hello}% %{foo}% %{bar}%" ];

            assert( ( [ task run: @{ @"hello" : @"hello, world" } ] == NO ) );
        }
        
        [ SKShell currentShell ].prompt = @"";
        
        [ [ SKShell currentShell ] printMessage: @"" ];
        [ [ SKShell currentShell ] printSuccessMessage: @"All examples completed successfully" ];
    }
    
    return EXIT_SUCCESS;
}
