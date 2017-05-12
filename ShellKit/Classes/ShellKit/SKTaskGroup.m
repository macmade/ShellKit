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
 * @file        SKTaskGroup.m
 * @copyright   (c) 2017, Jean-David Gadina - www.xs-labs.com
 */

#import <ShellKit/ShellKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SKTaskGroup()

@property( atomic, readwrite, assign           ) BOOL                               running;
@property( atomic, readwrite, strong, nullable ) NSError                          * error;
@property( atomic, readwrite, strong           ) NSString                         * name;
@property( atomic, readwrite, strong           ) NSArray< id< SKRunableObject > > * tasks;
@property( atomic, readwrite, strong, nullable ) id< SKRunableObject >              currentTask;

@end

NS_ASSUME_NONNULL_END

@implementation SKTaskGroup

+ ( instancetype )taskGroupWithName: ( NSString * )name tasks: ( NSArray< id< SKRunableObject > > * )tasks
{
    return [ [ self alloc ] initWithName: name tasks: tasks ];
}

- ( instancetype )init
{
    return [ self initWithName: @"" tasks: @[] ];
}

- ( instancetype )initWithName: ( NSString * )name tasks: ( NSArray< id< SKRunableObject > > * )tasks
{
    if( ( self = [ super init ] ) )
    {
        self.name  = name;
        self.tasks = tasks;
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
    id< SKRunableObject > task;
    NSDate              * date;
    NSString            * time;
    NSUInteger            i;
    
    @synchronized( self )
    {
        self.running = YES;
        
        if( self.name.length )
        {
            [ [ SKShell currentShell ] addPromptPart: self.name ];
        }
        
        if( self.tasks.count == 0 )
        {
            self.error = [ self errorWithDescription: @"No task defined" ];
            
            [ [ SKShell currentShell ] printError: self.error ];
            
            self.running = NO;
            
            if( self.name.length )
            {
                [ [ SKShell currentShell ] removeLastPromptPart ];
            }
            
            return NO;
        }
        
        if( self.tasks.count > 1 )
        {
            [ [ SKShell currentShell ] printMessage: @"Running %lu tasks" status: SKStatusExecute color: SKColorNone, self.tasks.count ];
        }
        
        i    = 0;
        date = [ NSDate date ];
        
        for( task in self.tasks )
        {
            self.currentTask = task;
            
            [ [ SKShell currentShell ] addPromptPart: [ NSString stringWithFormat: @"#%li", ( unsigned long )++i ] ];
            
            if( [ task run: variables ] == NO )
            {
                [ [ SKShell currentShell ] removeLastPromptPart ];
                
                self.currentTask = nil;
                self.error       = task.error;
                
                [ [ SKShell currentShell ] printErrorMessage: @"Failed to execute task group" ];
                
                self.running = NO;
                
                if( self.name.length )
                {
                    [ [ SKShell currentShell ] removeLastPromptPart ];
                }
                
                return NO;
            }
            
            [ [ SKShell currentShell ] removeLastPromptPart ];
        }
        
        time             = date.elapsedTimeStringSinceNow;
        self.currentTask = nil;
        
        if( self.tasks.count > 1 )
        {
            if( time )
            {
                time = [ [ NSString stringWithFormat: @"(%@)", time ] stringWithShellColor: SKColorNone ];

                [ [ SKShell currentShell ] printSuccessMessage: @"%lu tasks completed successfully %@", self.tasks.count, time ];
            }
            else
            {
                [ [ SKShell currentShell ] printSuccessMessage: @"%lu tasks completed successfully", self.tasks.count ];
            }
        }
        
        self.running = NO;
        
        if( self.name.length )
        {
            [ [ SKShell currentShell ] removeLastPromptPart ];
        }
        
        return YES;
    }
}

@end
