ShellKit
========

[![Build Status](https://img.shields.io/travis/macmade/ShellKit.svg?branch=master&style=flat)](https://travis-ci.org/macmade/ShellKit)
[![Coverage Status](https://img.shields.io/coveralls/macmade/ShellKit.svg?branch=master&style=flat)](https://coveralls.io/r/macmade/ShellKit?branch=master)
[![Issues](http://img.shields.io/github/issues/macmade/ShellKit.svg?style=flat)](https://github.com/macmade/ShellKit/issues)
![Status](https://img.shields.io/badge/status-active-brightgreen.svg?style=flat)
![License](https://img.shields.io/badge/license-mit-brightgreen.svg?style=flat)
[![Contact](https://img.shields.io/badge/contact-@macmade-blue.svg?style=flat)](https://twitter.com/macmade)  
[![Donate-Patreon](https://img.shields.io/badge/donate-patreon-yellow.svg?style=flat)](https://patreon.com/macmade)
[![Donate-Gratipay](https://img.shields.io/badge/donate-gratipay-yellow.svg?style=flat)](https://www.gratipay.com/macmade)
[![Donate-Paypal](https://img.shields.io/badge/donate-paypal-yellow.svg?style=flat)](https://paypal.me/xslabs)

About
-----

Objective-C framework for running shell scripts.

Code Examples
-------------

`ShellKit` provides a test executable.  
For complete examples, please take a look at the [source code](https://github.com/macmade/ShellKit/blob/master/ShellKit-Test/main.m).

### Running shell script tasks

A shell command can by run by using the `SKTask` object:

    SKTask * task;
    
    task = [ SKTask taskWithShellScript: @"ls -al" ];
    
    [ task run ];

The task is run synchronously, and its output, if any, will be automatically printed to `stdout`.

The task will print the executed command prior to running, and print a status message once it's terminated:

    [ ShellKit ]> 🚦  Running task: ls -al
    total 536
    drwxr-xr-x  5 macmade  staff     170 May 11 23:49 .
    drwxr-xr-x@ 4 macmade  staff     136 May 11 22:18 ..
    -rwxr-xr-x  1 macmade  staff  124624 May 11 23:49 ShellKit-Test
    drwxr-xr-x  7 macmade  staff     238 May 11 23:48 ShellKit.framework
    -rw-r--r--  1 macmade  staff  143936 May 11 23:48 libShellKit-Static.a
    [ ShellKit ]> ✅  Task completed successfully
    
A task can have sub-tasks, to try to recover from a failure:

    SKTask * task;
    
    task = [ SKTask taskWithShellScript: @"false" recoverTask: [ SKTask taskWithShellScript: @"true" ] ];
    
    [ task run ];

Here, the `false` task will obviously fail, but it will then execute the `true` task, set as recovery.  
As `true` will succeed, the `false` task will also succeed:

    [ ShellKit ]> 🚦  Running task: false
    [ ShellKit ]> ⚠️  Task failed - Trying to recover...
    [ ShellKit ]> 🚦  Running task: true
    [ ShellKit ]> ✅  Task completed successfully
    [ ShellKit ]> ✅  Task recovered successfully

### Running task groups

Multiple tasks can be grouped in a `SKTaskGroup` object:


    SKTask      * t1;
    SKTask      * t2;
    SKTaskGroup * group;
    
    t1    = [ SKTask taskWithShellScript: @"true" ];
    t2    = [ SKTask taskWithShellScript: @"true" ];
    group = [ SKTaskGroup taskGroupWithName: @"task-group" tasks: @[ t1, t2 ] ];
            
    [ group run ];

The group will try to run each task.  
If a task fails, the whole group will also fail.

    [ ShellKit ]> [ task-group ]> 🚦  Running 2 tasks
    [ ShellKit ]> [ task-group ]> [ #1 ]> 🚦  Running task: true
    [ ShellKit ]> [ task-group ]> [ #1 ]> ✅  Task completed successfully
    [ ShellKit ]> [ task-group ]> [ #2 ]> 🚦  Running task: true
    [ ShellKit ]> [ task-group ]> [ #2 ]> ✅  Task completed successfully
    [ ShellKit ]> [ task-group ]> ✅  2 tasks completed successfully

Running actions
---------------

Actions, represented by the `SKAction` class, consist of a group of task groups (`SKTaskGroups`):

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
    
    [ action run ];

The action will try to run each task group.  
If a task group fails, the whole action will also fail.

    [ ShellKit ]> [ action ]> 🚦  Running 2 task groups
    [ ShellKit ]> [ action ]> [ #1 ]> [ task-group-1 ]> 🚦  Running 2 tasks
    [ ShellKit ]> [ action ]> [ #1 ]> [ task-group-1 ]> [ #1 ]> 🚦  Running task: true
    [ ShellKit ]> [ action ]> [ #1 ]> [ task-group-1 ]> [ #1 ]> ✅  Task completed successfully
    [ ShellKit ]> [ action ]> [ #1 ]> [ task-group-1 ]> [ #2 ]> 🚦  Running task: true
    [ ShellKit ]> [ action ]> [ #1 ]> [ task-group-1 ]> [ #2 ]> ✅  Task completed successfully
    [ ShellKit ]> [ action ]> [ #1 ]> [ task-group-1 ]> ✅  2 tasks completed successfully
    [ ShellKit ]> [ action ]> [ #2 ]> [ task-group-2 ]> 🚦  Running 2 tasks
    [ ShellKit ]> [ action ]> [ #2 ]> [ task-group-2 ]> [ #1 ]> 🚦  Running task: true
    [ ShellKit ]> [ action ]> [ #2 ]> [ task-group-2 ]> [ #1 ]> ✅  Task completed successfully
    [ ShellKit ]> [ action ]> [ #2 ]> [ task-group-2 ]> [ #2 ]> 🚦  Running task: true
    [ ShellKit ]> [ action ]> [ #2 ]> [ task-group-2 ]> [ #2 ]> ✅  Task completed successfully
    [ ShellKit ]> [ action ]> [ #2 ]> [ task-group-2 ]> ✅  2 tasks completed successfully
    [ ShellKit ]> [ action ]> ✅  2 task groups completed successfully

Arguments substitution
----------------------

...

Printing messages
-----------------

Messages can be printed very easily.  
For this purpose, the `SKShell` class provides several methods, like the following one:

    - ( void )printMessage: ( NSString * )message
              status:       ( SKStatus )status
              color:        ( SKColor )color;

The status represents an optional icon.  
Colors can also be used, if the terminal supports it.

As an example:

    [ [ SKShell currentShell ] printMessage: @"hello, world"
                               status:       SKStatusDebug
                               color:        SKColorCyan
    ];

will produce:

    🚸 hello, world

Customising prompt
------------------

The prompt can be customised to reflect the hierarchy of the invoked commands.

For instance:

    [ SKShell currentShell ].promptParts = @[ @"foo", @"bar" ];

Then, every printed message will be prefixed by:

    [ foo ]> [ bar ]> ... message ...

License
-------

ShellKit is released under the terms of the MIT license.

Repository Infos
----------------

    Owner:			Jean-David Gadina - XS-Labs
    Web:			www.xs-labs.com
    Blog:			www.noxeos.com
    Twitter:		@macmade
    GitHub:			github.com/macmade
    LinkedIn:		ch.linkedin.com/in/macmade/
    StackOverflow:	stackoverflow.com/users/182676/macmade
