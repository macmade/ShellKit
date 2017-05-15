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
 * @header      SKTypes.h
 * @copyright   (c) 2017, Jean-David Gadina - www.xs-labs.com
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 * @typedef     SKStatus
 * @abstract    Defines status icons
 */
typedef NS_ENUM( NSInteger, SKStatus )
{
    SKStatusNone,           /*! No status */
    SKStatusSuccess,        /*! Sucess status icon */
    SKStatusFatal,          /*! Fatal error status icon */
    SKStatusError,          /*! Error status icon */
    SKStatusWarning,        /*! Warning status icon */
    SKStatusInfo,           /*! Info status icon */
    SKStatusDebug,          /*! Debug status icon */
    SKStatusBuild,          /*! Build status icon */
    SKStatusInstall,        /*! Install status icon */
    SKStatusIdea,           /*! Idea status icon */
    SKStatusSettings,       /*! Settings status icon */
    SKStatusSecurity,       /*! Security status icon */
    SKStatusExecute,        /*! Executing status icon */
    SKStatusSearch,         /*! Search status icon */
    SKStatusTarget,         /*! Target status icon */
    SKStatusComment,        /*! Comment status icon */
    SKStatusFile,           /*! File status icon */
    SKStatusFolder,         /*! Folder status icon */
    SKStatusTrash,          /*! Trash status icon */
    SKStatusLink,           /*! Link status icon */
    SKStatusMail,           /*! Mail message status icon */
    SKStatusAttachement,    /*! Message attachmnet status icon */
    SKStatusEdit,           /*! Edit status icon */
    SKStatusPin,            /*! Push pin status icon */
    SKStatusLock,           /*! Lock status icon */
    SKStatusRocket,         /*! Rocket status icon */
    SKStatusFire,           /*! Fire status icon */
    SKStatusLightning,      /*! Lightning status icon */
    SKStatusBug             /*! Bug status icon */
};

/*!
 * @typedef     SKColor
 * @abstract    Shell color type
 */
typedef NS_ENUM( NSInteger, SKColor )
{
    SKColorNone,    /*! No color (clear) */
    SKColorBlack,   /*! Black color */
    SKColorRed,     /*! Red color */
    SKColorGreen,   /*! Green color */
    SKColorYellow,  /*! Yellow color */
    SKColorBlue,    /*! Blue color */
    SKColorPurple,  /*! Purple color */
    SKColorWhite,   /*! White color */
    SKColorCyan     /*! Cyan color */
};

NS_ASSUME_NONNULL_END
