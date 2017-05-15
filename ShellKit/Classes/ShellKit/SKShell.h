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
 * @header      SKShell.h
 * @copyright   (c) 2017, Jean-David Gadina - www.xs-labs.com
 */

#import <Foundation/Foundation.h>
#import <ShellKit/SKTypes.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 * @typedef     SKShellCommandCompletion
 * @abstract    Completion block for a shell command
 * @param       status          The command's exit status
 * @param       stdandardOutput The command's standard output, if any
 * @param       standardError   The command's standard error, if any
 */
typedef void ( ^ SKShellCommandCompletion )( int status, NSString * stdandardOutput, NSString * standardError );

/*!
 * @class       SKShell
 * @abstract    An object representing the current shell
 */
@interface SKShell: NSObject

/*!
 * @property    supportsColors
 * @abstract    Set if the current erminal supports color
 */
@property( atomic, readonly ) BOOL supportsColors;

/*!
 * @property    colorsEnabled
 * @abstact     Used to enable/disable the use of shell colors
 * @discussion  Enabled by default. Only applicable if the current terminal
 *              supports colors.
 * @see         supportsColors
 * @see         SKColor
 */
@property( atomic, readonly ) BOOL colorsEnabled;

/*!
 * @property    statusIconsEnabled
 * @abstact     Used to enable/disable the use of status icons
 * @discussion  Enabled by default. Status icons are reprensented by unicode
 *              emojis.
 * @see         SKSTatus
 */
@property( atomic, readonly ) BOOL statusIconsEnabled;

/*!
 * @property    prompt
 * @abstract    Used to get/set the current prompt
 * @discussion  If a prompt is set, all messages printed with `SKShell` will
 *              be prefixed by the prompt.
 */
@property( atomic, readwrite, strong, nullable ) NSString * prompt;

/*!
 * @property    promptParts
 * @abstract    Used to get/set the promt parts
 * @discussion  Prompt parts may be set to reflect a hierarchy in the prompt.
 *              For instance, setting `@[ @"foo", @"bar" ]` as prompt parts will
 *              result in a `[ foo ]> [ bar ]>` prompt.
 */
@property( atomic, readwrite, strong, nullable ) NSArray< NSString * > * promptParts;

/*!
 * @property    allowPromptHierarchy
 * @abstract    Enables/Disables prompt hierarchy
 * @discussion  Enabled by default. If disabled, setting prompt parts will have
 *              no effect.
 * @see         promptParts
 */
@property( atomic, readwrite, assign ) BOOL allowPromptHierarchy;

/*!
 * @property    shell
 * @property    The path of the current shell
 * @discussion  Retrieved using the `SHELL` environment variable.
 */
@property( atomic, readonly, nullable ) NSString * shell;

/*!
 * @method      currentShell
 * @abstract    Gets the instance representing the current shell
 * @discussion  Although a `SKShell` can be instanciated, it is advised
 *              to alyways use this shared instance.
 */
+ ( instancetype )currentShell;

/*!
 * @method      pathForCommand:
 * @abstract    Gets the paths of a shell command
 * @discussion  Commands are found using `which`, invoked through the logn shell.
 * @param       command The command name
 * @result      The full path to the command, or nil
 */
- ( nullable NSString * )pathForCommand: ( NSString * )command;

/*!
 * @method      commandIsAvailable:
 * @abstract    Checks if a shell command is available
 * @discussion  Commands are found using `which`, invoked through the logn shell.
 * @param       command The command name
 * @result      YES is the command is available, otherwise NO
 */
- ( BOOL )commandIsAvailable: ( NSString * )command;

/*!
 * @method      runCommand:
 * @abstract    Executes a shell command synchronously
 * @discussion  Command can be a complex shell commands.
 * @param       command The command to execute
 * @result      YES if the command executed successfully, otherwise NO
 */
- ( BOOL )runCommand: ( NSString * )command;

/*!
 * @method      runCommand:
 * @abstract    Executes a shell command synchronously
 * @discussion  Command can be a complex shell commands.
 * @param       command The command to execute
 * @param       input   An optional string to use as standard input for the command
 * @result      YES if the command executed successfully, otherwise NO
 */
- ( BOOL )runCommand: ( NSString * )command stdandardInput: ( nullable NSString * )input;

/*!
 * @method      runCommand:
 * @abstract    Executes a shell command synchronously
 * @discussion  Command can be a complex shell commands.
 * @param       command The command to execute
 * @param       completion  An optional completion block
 * @result      YES if the command executed successfully, otherwise NO
 * @see         SKShellCommandCompletion
 */
- ( BOOL )runCommand: ( NSString * )command completion: ( nullable SKShellCommandCompletion )completion;

/*!
 * @method      runCommand:
 * @abstract    Executes a shell command synchronously
 * @discussion  Command can be a complex shell commands.
 * @param       command The command to execute
 * @param       input       An optional string to use as standard input for the command
 * @param       completion  An optional completion block
 * @result      YES if the command executed successfully, otherwise NO
 * @see         SKShellCommandCompletion
 */
- ( BOOL )runCommand: ( NSString * )command stdandardInput: ( nullable NSString * )input completion: ( nullable SKShellCommandCompletion )completion;

/*!
 * @method      runCommand:
 * @abstract    Executes a shell command asynchronously
 * @discussion  Command can be a complex shell commands.
 * @param       command The command to execute
 */
- ( void )runCommandAsynchronously: ( NSString * )command;

/*!
 * @method      runCommand:
 * @abstract    Executes a shell command asynchronously
 * @discussion  Command can be a complex shell commands.
 * @param       command The command to execute
 * @param       input   An optional string to use as standard input for the command
 */
- ( void )runCommandAsynchronously: ( NSString * )command stdandardInput: ( nullable NSString * )input;

/*!
 * @method      runCommand:
 * @abstract    Executes a shell command asynchronously
 * @discussion  Command can be a complex shell commands.
 * @param       command The command to execute
 * @param       completion  An optional completion block
 * @see         SKShellCommandCompletion
 */
- ( void )runCommandAsynchronously: ( NSString * )command completion: ( nullable SKShellCommandCompletion )completion;

/*!
 * @method      runCommand:
 * @abstract    Executes a shell command asynchronously
 * @discussion  Command can be a complex shell commands.
 * @param       command The command to execute
 * @param       input       An optional string to use as standard input for the command
 * @param       completion  An optional completion block
 * @see         SKShellCommandCompletion
 */
- ( void )runCommandAsynchronously: ( NSString * )command stdandardInput: ( nullable NSString * )input completion: ( nullable SKShellCommandCompletion )completion;

/*!
 * @method      printError:
 * @abstract    Prints an error
 * @discussion  If the `error` param is nil, this method will print a generic
 *              error message.
 *              Errors are printed in red if colors are available/enabled and
 *              with an error sign if status icons are enabled.
 * @param       error   The error object to print
 */
- ( void )printError: ( nullable NSError * )error;

/*!
 * @method      printErrorMessage:
 * @abstract    Prints an error message
 * @param       format  The error message format
 * @param       ...     Optional parameters for the format string
 * @see         printError:
 */
- ( void )printErrorMessage: ( NSString * )format, ... NS_FORMAT_FUNCTION( 1, 2 );

/*!
 * @method      printWarningMessage:
 * @abstract    Prints an warning message
 * @discussion  Warnings are printed in yellow if colors are available/enabled
 *              and with an warning sign if status icons are enabled.
 * @param       format  The warning message format
 * @param       ...     Optional parameters for the format string
 */
- ( void )printWarningMessage: ( NSString * )format, ... NS_FORMAT_FUNCTION( 1, 2 );

/*!
 * @method      printSuccessMessage:
 * @abstract    Prints a success message
 * @discussion  Success messages are printed in green if colors are
 *              available/enabled and with a checkmark sign if status icons are
 *              enabled.
 * @param       format  The success message format
 * @param       ...     Optional parameters for the format string
 */
- ( void )printSuccessMessage: ( NSString * )format, ... NS_FORMAT_FUNCTION( 1, 2 );

/*!
 * @method      printInfoMessage:
 * @abstract    Prints an info message
 * @discussion  Info messages are printed in blue if colors are
 *              available/enabled and with an info sign if status icons are
 *              enabled.
 * @param       format  The info message format
 * @param       ...     Optional parameters for the format string
 */
- ( void )printInfoMessage: ( NSString * )format, ... NS_FORMAT_FUNCTION( 1, 2 );

/*!
 * @method      printMessage:
 * @abstract    Prints a message
 * @param       format  The message format
 * @param       ...     Optional parameters for the format string
 */
- ( void )printMessage: ( NSString * )format, ... NS_FORMAT_FUNCTION( 1, 2 );

/*!
 * @method      printMessage:status:
 * @abstract    Prints a message with a status
 * @discussion  Statuses will be printed as an emoji, if status icons are
 *              enabled.
 * @param       format  The message format
 * @param       status  The message status
 * @param       ...     Optional parameters for the format string
 * @see         SKSTatus
 * @see         statusIconsEnabled
 */
- ( void )printMessage: ( NSString * )format status: ( SKStatus )status, ... NS_FORMAT_FUNCTION( 1, 3 );

/*!
 * @method      printMessage:color:
 * @abstract    Prints a message with a color
 * @discussion  Colors will only be printed if the terminal supports them and
 *              if they are enabled.
 * @param       format  The message format
 * @param       color   The message color
 * @param       ...     Optional parameters for the format string
 * @see         SKColor
 * @see         supportsColors
 * @see         colorsEnabled
 */
- ( void )printMessage: ( NSString * )format color: ( SKColor )color, ... NS_FORMAT_FUNCTION( 1, 3 );

/*!
 * @method      printMessage:color:
 * @abstract    Prints a message with a color
 * @discussion  Statuses will be printed as an emoji, if status icons are
 *              enabled. Colors will only be printed if the terminal supports
 *              them and if they are enabled.
 * @param       format  The message format
 * @param       status  The message status
 * @param       color   The message color
 * @param       ...     Optional parameters for the format string
 * @see         SKSTatus
 * @see         statusIconsEnabled
 * @see         SKColor
 * @see         supportsColors
 * @see         colorsEnabled
 */
- ( void )printMessage: ( NSString * )format status: ( SKStatus )status color: ( SKColor )color, ... NS_FORMAT_FUNCTION( 1, 4 );

/*!
 * @method      addPromptPart:
 * @abstract    Adds a part to the current prompt parts
 * @discussion  Only applicable if the prompt hierarchy is enabled.
 * @see         promptParts
 * @see         allowPromptHierarchy
 */
- ( void )addPromptPart:( NSString * )part;

/*!
 * @method      removeLastPromptPart:
 * @abstract    Removes the last part of the current prompt parts
 * @discussion  Only applicable if the prompt hierarchy is enabled.
 * @see         promptParts
 * @see         allowPromptHierarchy
 */
- ( void )removeLastPromptPart;

@end

NS_ASSUME_NONNULL_END
