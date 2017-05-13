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
 * @file        NSString+ShellKit.m
 * @copyright   (c) 2017, Jean-David Gadina - www.xs-labs.com
 */

#import <ShellKit/ShellKit.h>

#define SK_COLOR_NONE       "\x1B[0m"
#define SK_COLOR_BLACK      "\x1B[30m"
#define SK_COLOR_RED        "\x1B[31m"
#define SK_COLOR_GREEN      "\x1B[32m"
#define SK_COLOR_YELLOW     "\x1B[33m"
#define SK_COLOR_BLUE       "\x1B[34m"
#define SK_COLOR_PURPLE     "\x1B[35m"
#define SK_COLOR_CYAN       "\x1B[36m"
#define SK_COLOR_WHITE      "\x1B[37m"

@implementation NSString( ShellKit )

+ ( NSString * )stringForShellStatus: ( SKStatus )status
{
    switch( status )
    {
        case SKStatusNone:          return @"";
        case SKStatusSuccess:       return @"✅";
        case SKStatusFatal:         return @"💣";
        case SKStatusError:         return @"❌";
        case SKStatusWarning:       return @"⚠️";
        case SKStatusInfo:          return @"ℹ️";
        case SKStatusDebug:         return @"🚸";
        case SKStatusBuild:         return @"🔧";
        case SKStatusInstall:       return @"📦";
        case SKStatusIdea:          return @"💡";
        case SKStatusSettings:      return @"⚙️";
        case SKStatusSecurity:      return @"🔑";
        case SKStatusExecute:       return @"🚦";
        case SKStatusSearch:        return @"🔍";
        case SKStatusTarget:        return @"🎯";
        case SKStatusComment:       return @"💬";
        case SKStatusFile:          return @"📄";
        case SKStatusFolder:        return @"📁";
        case SKStatusTrash:         return @"🗑";
        case SKStatusLink:          return @"🔗";
        case SKStatusMail:          return @"✉️";
        case SKStatusAttachement:   return @"📎";
        case SKStatusEdit:          return @"✏️";
        case SKStatusPin:           return @"📌";
        case SKStatusLock:          return @"🔒";
        case SKStatusRocket:        return @"🚀";
        case SKStatusFire:          return @"🔥";
        case SKStatusLightning:     return @"⚡️";
        case SKStatusBug:           return @"🐛";
    }
    
    return @"";
}

+ ( NSString * )stringForShellColor: ( SKColor )color
{
    if( [ SKShell currentShell ].supportsColor == NO )
    {
        return @"";
    }
    
    switch( color )
    {
        case SKColorNone:      return @SK_COLOR_NONE;
        case SKColorBlack:     return @SK_COLOR_BLACK;
        case SKColorRed:       return @SK_COLOR_RED;
        case SKColorGreen:     return @SK_COLOR_GREEN;
        case SKColorYellow:    return @SK_COLOR_YELLOW;
        case SKColorBlue:      return @SK_COLOR_BLUE;
        case SKColorPurple:    return @SK_COLOR_PURPLE;
        case SKColorWhite:     return @SK_COLOR_WHITE;
        case SKColorCyan:      return @SK_COLOR_CYAN;
    }
}

- ( NSString * )stringWithShellColor: ( SKColor )color
{
    NSString * str;
    
    if( self.length == 0 )
    {
        return @"";
    }
    
    if( [ SKShell currentShell ].supportsColor == NO )
    {
        return [ self copy ];
    }
    
    str = [ NSString stringForShellColor: color ];
    str = [ str stringByAppendingString: self ];
    str = [ str stringByAppendingString: [ NSString stringForShellColor: SKColorNone ] ];
    
    return str;
}

@end
