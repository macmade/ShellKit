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

void PrintStep( const char * msg );
void PrintStep( const char * msg )
{
    static NSUInteger step = 0;
    
    if( step > 0 )
    {
        printf( "\n" );
    }
    
    printf
    (
        "--------------------------------------------------------------------------------\n"
        "> Example %lu: %s\n"
        "--------------------------------------------------------------------------------\n"
        "\n",
        ( unsigned long )( ++step ),
        msg
    );
}

int main( void )
{
    @autoreleasepool
    {
        [ SKShell currentShell ].promptParts = @[ @"ShellKit-Test" ];
        
        PrintStep( "Simple task" );
        
        {
            SKTask * task;
            
            task = [ SKTask taskWithShellScript: @"ls -al" ];
            
            [ task run ];
        }
        
        PrintStep( "Simple task failure" );
        
        {
            SKTask * task;
            
            task = [ SKTask taskWithShellScript: @"false" ];
            
            [ task run ];
        }
        
        PrintStep( "Simple task failure with failed recovery" );
        
        {
            SKTask * task;
            
            task = [ SKTask taskWithShellScript: @"false" recoverTask: [ SKTask taskWithShellScript: @"false" ] ];
            
            [ task run ];
        }
        
        PrintStep( "Simple task failure with successful recovery (variant 1)" );
        
        {
            SKTask * task;
            
            task = [ SKTask taskWithShellScript: @"false" recoverTasks: @[ [ SKTask taskWithShellScript: @"false" ], [ SKTask taskWithShellScript: @"true" ] ] ];
            
            [ task run ];
        }
        
        PrintStep( "Simple task failure with successful recovery (variant 2)" );
        
        {
            SKTask * task;
            
            task = [ SKTask taskWithShellScript: @"false" recoverTask: [ SKTask taskWithShellScript: @"false" recoverTask: [ SKTask taskWithShellScript: @"true" ] ] ];
            
            [ task run ];
        }
        
        PrintStep( "Task group" );
        
        {
            SKTask      * t1;
            SKTask      * t2;
            SKTaskGroup * group;
            
            t1    = [ SKTask taskWithShellScript: @"true" ];
            t2    = [ SKTask taskWithShellScript: @"true" ];
            group = [ SKTaskGroup taskGroupWithName: @"test-group" tasks: @[ t1, t2 ] ];
            
            [ group run ];
        }
    }
    
    return EXIT_SUCCESS;
}
