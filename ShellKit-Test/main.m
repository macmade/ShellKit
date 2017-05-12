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
    
    [ [ SKShell currentShell ] printMessage:           @"--------------------------------------------------------------------------------" ];
    [ [ SKShell currentShell ] printMessageWithFormat: @"Example %lu: %@" status: SKStatusIdea color: SKColorPurple, ( unsigned long )++step, msg ];
    [ [ SKShell currentShell ] printMessage:           @"--------------------------------------------------------------------------------" ];
    
    [ SKShell currentShell ].promptParts = prompt;
}

int main( void )
{
    @autoreleasepool
    {
        [ SKShell currentShell ].promptParts = @[ @"ShellKit" ];
        
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
        
        PrintStep( @"Task group" );
        
        {
            SKTask      * t1;
            SKTask      * t2;
            SKTaskGroup * group;
            
            t1    = [ SKTask taskWithShellScript: @"true" ];
            t2    = [ SKTask taskWithShellScript: @"true" ];
            group = [ SKTaskGroup taskGroupWithName: @"task-group" tasks: @[ t1, t2 ] ];
            
            assert( ( [ group run ] == YES ) );
        }
        
        PrintStep( @"Task group failure" );
        
        {
            SKTask      * t1;
            SKTask      * t2;
            SKTaskGroup * group;
            
            t1    = [ SKTask taskWithShellScript: @"true" ];
            t2    = [ SKTask taskWithShellScript: @"false" ];
            group = [ SKTaskGroup taskGroupWithName: @"task-group" tasks: @[ t1, t2 ] ];
            
            assert( ( [ group run ] == NO ) );
        }
        
        PrintStep( @"Task group failure with successful recovery" );
        
        {
            SKTask      * t1;
            SKTask      * t2;
            SKTaskGroup * group;
            
            t1    = [ SKTask taskWithShellScript: @"true" ];
            t2    = [ SKTask taskWithShellScript: @"false" recoverTask: t1 ];
            group = [ SKTaskGroup taskGroupWithName: @"task-group" tasks: @[ t1, t2 ] ];
            
            assert( ( [ group run ] == YES ) );
        }
        
        PrintStep( @"Action" );
        
        {
            SKTask      * t1;
            SKTask      * t2;
            SKTaskGroup * g1;
            SKTaskGroup * g2;
            SKAction    * action;
            
            t1     = [ SKTask taskWithShellScript: @"true" ];
            t2     = [ SKTask taskWithShellScript: @"true" ];
            g1     = [ SKTaskGroup taskGroupWithName: @"task-group-1" tasks: @[ t1, t2 ] ];
            g2     = [ SKTaskGroup taskGroupWithName: @"task-group-2" tasks: @[ t1, t2 ] ];
            action = [ SKAction actionWithName: @"action" taskGroups: @[ g1, g2 ] ];
            
            assert( ( [ action run ] == YES ) );
        }
        
        PrintStep( @"Action failure" );
        
        {
            SKTask      * t1;
            SKTask      * t2;
            SKTask      * t3;
            SKTaskGroup * g1;
            SKTaskGroup * g2;
            SKAction    * action;
            
            t1     = [ SKTask taskWithShellScript: @"true" ];
            t2     = [ SKTask taskWithShellScript: @"true" ];
            t3     = [ SKTask taskWithShellScript: @"false" ];
            g1     = [ SKTaskGroup taskGroupWithName: @"task-group-1" tasks: @[ t1, t2 ] ];
            g2     = [ SKTaskGroup taskGroupWithName: @"task-group-2" tasks: @[ t1, t3 ] ];
            action = [ SKAction actionWithName: @"action" taskGroups: @[ g1, g2 ] ];
            
            assert( ( [ action run ] == NO ) );
        }
        
        PrintStep( @"Action failure with successful recovery" );
        
        {
            SKTask      * t1;
            SKTask      * t2;
            SKTask      * t3;
            SKTaskGroup * g1;
            SKTaskGroup * g2;
            SKAction    * action;
            
            t1     = [ SKTask taskWithShellScript: @"true" ];
            t2     = [ SKTask taskWithShellScript: @"true" ];
            t3     = [ SKTask taskWithShellScript: @"false" recoverTask: t1 ];
            g1     = [ SKTaskGroup taskGroupWithName: @"task-group-1" tasks: @[ t1, t2 ] ];
            g2     = [ SKTaskGroup taskGroupWithName: @"task-group-2" tasks: @[ t1, t3 ] ];
            action = [ SKAction actionWithName: @"action" taskGroups: @[ g1, g2 ] ];
            
            assert( ( [ action run ] == YES ) );
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
        
        PrintStep( @"Done" );
        
        [ [ SKShell currentShell ] printMessage: @"All examples completed successfully" status: SKStatusSuccess color: SKColorGreen ];
    }
    
    return EXIT_SUCCESS;
}
