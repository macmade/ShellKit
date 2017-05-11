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
 * @file        SKAction.m
 * @copyright   (c) 2017, Jean-David Gadina - www.xs-labs.com
 */

#import <ShellKit/ShellKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SKAction()

@property( atomic, readwrite, assign           ) BOOL                       running;
@property( atomic, readwrite, strong, nullable ) NSError                  * error;
@property( atomic, readwrite, strong           ) NSString                 * name;
@property( atomic, readwrite, strong           ) NSArray< SKTaskGroup * > * taskGroups;
@property( atomic, readwrite, strong, nullable ) SKTaskGroup              * currentTaskGroup;

@end

NS_ASSUME_NONNULL_END

@implementation SKAction

+ ( instancetype )actionWithName: ( NSString * )name taskGroups: ( NSArray< SKTaskGroup * > * )groups
{
    return [ [ self alloc ] initWithName: name taskGroups: groups ];
}

- ( instancetype )init
{
    return [ self initWithName: @"" taskGroups: @[] ];
}

- ( instancetype )initWithName: ( NSString * )name taskGroups: ( NSArray< SKTaskGroup * > * )groups
{
    if( ( self = [ super init ] ) )
    {
        self.name       = name;
        self.taskGroups = groups;
    }
    
    return self;
}

#pragma mark - SKRunableObject

- ( BOOL )run
{
    SKTaskGroup * group;
    NSUInteger    i;
        
    self.running = YES;
    
    if( self.name.length )
    {
        [ [ SKShell currentShell ] addPromptPart: self.name ];
    }
    
    if( self.taskGroups.count == 0 )
    {
        self.error = [ self errorWithDescription: @"No task group defined" ];
        
        [ [ SKShell currentShell ] printError: self.error ];
        
        self.running = NO;
        
        if( self.name.length )
        {
            [ [ SKShell currentShell ] removeLastPromptPart ];
        }
        
        return NO;
    }
    
    if( self.taskGroups.count > 1 )
    {
        [ [ SKShell currentShell ] printMessageWithFormat: @"Running %lu task groups" status: SKStatusExecute color: SKColorNone, self.taskGroups.count ];
    }
    
    i = 0;
    
    for( group in self.taskGroups )
    {
        self.currentTaskGroup = group;
        
        [ [ SKShell currentShell ] addPromptPart: [ NSString stringWithFormat: @"#%li", ( unsigned long )++i ] ];
        
        if( [ group run ] == NO )
        {
            [ [ SKShell currentShell ] removeLastPromptPart ];
            
            self.currentTaskGroup = nil;
            self.error           = group.error;
            
            [ [ SKShell currentShell ] printErrorMessage: @"Failed to execute action" ];
            
            self.running = NO;
            
            if( self.name.length )
            {
                [ [ SKShell currentShell ] removeLastPromptPart ];
            }
            
            return NO;
        }
        
        [ [ SKShell currentShell ] removeLastPromptPart ];
    }
    
    self.currentTaskGroup = nil;
    
    if( self.taskGroups.count > 1 )
    {
        [ [ SKShell currentShell ] printMessageWithFormat: @"%lu task groups completed successfully" status: SKStatusSuccess color: SKColorGreen, self.taskGroups.count ];
    }
    
    self.running = NO;
    
    if( self.name.length )
    {
        [ [ SKShell currentShell ] removeLastPromptPart ];
    }
    
    return YES;
}

@end
