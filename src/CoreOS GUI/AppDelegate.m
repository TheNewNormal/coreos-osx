//
//  AppDelegate.m
//  CoreOS GUI for OS X
//
//  Created by Rimantas on 01/04/2014.
//  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setImage: [NSImage imageNamed:@"icon"]];
    [self.statusItem setHighlightMode:YES];
    
    // get the App's main bundle path
    _resoucesPathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@""];
//    NSLog(@"applicationDirectory: '%@'", _resoucesPathFromApp);

    NSString *home_folder = [NSHomeDirectory() stringByAppendingPathComponent:@"coreos-osx"];
    
    BOOL isDir;
    if([[NSFileManager defaultManager]
        fileExistsAtPath:home_folder isDirectory:&isDir] && isDir)
    {
        [self checkVMStatus];
    }
    else
    {
        NSString *msg = [NSString stringWithFormat:@"%@ ", @"CoreOS-Vagrant was not set, run from menu 'Setup' - 'Initial setup of CoreOS-Vagrant' to do that !!! "];
        [self displayWithMessage:@"CoreOS-Vagrant" infoText:msg];
    }
}


- (IBAction)Start:(id)sender {
    
    NSString *home_folder = [NSHomeDirectory() stringByAppendingPathComponent:@"coreos-osx"];
    
    BOOL isDir;
    if([[NSFileManager defaultManager]
        fileExistsAtPath:home_folder isDirectory:&isDir] && isDir)
    {
        // send a notification on to the screen
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = @"coreos-vagrant VM will be up shortly";
        notification.informativeText = @"and OS shell will be opened";
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        
        NSString *appName = [[NSString alloc] init];
        NSString *arguments = [[NSString alloc] init];
        [self runApp:appName = @"iTerm" arguments:arguments = [_resoucesPathFromApp stringByAppendingPathComponent:@"vagrant_up.command"]];
    }
    else
    {
        NSString *msg = [NSString stringWithFormat:@"%@ ", @"App was not installed, run from menu 'Setup/Update' - 'Initial setup of CoreOS-Vagrant VM' !!! "];
        [self displayWithMessage:@"CoreOS-Vagrant" infoText:msg];
        
    }
}

- (IBAction)Pause:(id)sender {
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.informativeText = @"coreos-vagrant VM will be suspended";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *scriptName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runScript:scriptName = @"coreos-vagrant" arguments:arguments = @"suspend"];
    
    [self checkVMStatus];
}

- (IBAction)Stop:(id)sender {
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.informativeText = @"coreos-vagrant VM will be stopped";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *scriptName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runScript:scriptName = @"coreos-vagrant" arguments:arguments = @"halt"];
    
    [self checkVMStatus];
}

- (IBAction)Restart:(id)sender {
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.informativeText = @"coreos-vagrant VM will be reloaded";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *appName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runApp:appName = @"iTerm" arguments:arguments = [_resoucesPathFromApp stringByAppendingPathComponent:@"vagrant_reload.command"]];
    
    [self checkVMStatus];
}


// Updates menu
- (IBAction)updates:(id)sender {
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"coreos-vagrant, docker, etcdclt and fleetctl will be updated";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *appName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runApp:appName = @"iTerm" arguments:arguments = [_resoucesPathFromApp stringByAppendingPathComponent:@"update.command"]];
    //     NSLog(@"Apps arguments: '%@'", [_resoucesPathFromApp stringByAppendingPathComponent:@"update.command"]);
}

- (IBAction)force_coreos_update:(id)sender {
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"CoreOS will be forced to be updated !!!";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *appName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runApp:appName = @"iTerm" arguments:arguments = [_resoucesPathFromApp stringByAppendingPathComponent:@"force_coreos_update.command"]];
    //     NSLog(@"Apps arguments: '%@'", [_resoucesPathFromApp stringByAppendingPathComponent:@"update.command"]);
}
// Updates menu


// Setup menu
- (IBAction)changeReleaseChannel:(id)sender {
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.informativeText = @"coreos-vagrant release channel change";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *appName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runApp:appName = @"iTerm" arguments:arguments = [_resoucesPathFromApp stringByAppendingPathComponent:@"change_release_channel.command"]];
    
    [self checkVMStatus];
}

- (IBAction)destroy:(id)sender {
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.informativeText = @"coreos-vagrant VM will be destroyed";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *appName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runApp:appName = @"iTerm" arguments:arguments = [_resoucesPathFromApp stringByAppendingPathComponent:@"vagrant_destroy.command"]];
    
    [self checkVMStatus];
}

- (IBAction)initialInstall:(id)sender
{
    NSString *home_folder = [NSHomeDirectory() stringByAppendingPathComponent:@"coreos-osx"];
    
    BOOL isDir;
    if([[NSFileManager defaultManager]
        fileExistsAtPath:home_folder isDirectory:&isDir] && isDir){
        NSString *msg = [NSString stringWithFormat:@"%@ %@ %@", @"Folder", home_folder, @"exists, please delete or rename that folder !!!"];
        [self displayWithMessage:@"CoreOS-Vagrant" infoText:msg];
    }
    else
    {
//        NSLog(@"Folder does not exist: '%@'", home_folder);
        NSString *scriptName = [[NSString alloc] init];
        NSString *arguments = [[NSString alloc] init];
        [self runScript:scriptName = @"coreos-vagrant-install" arguments:arguments = _resoucesPathFromApp ];
    }
}
// Setup menu


- (IBAction)About:(id)sender {
    
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
//    NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
//    NSString *app_version = [NSString stringWithFormat:@"%@.%@", version, build];
    NSString *app_version = [NSString stringWithFormat:@"%@", version];
    
    NSString *mText = [NSString stringWithFormat:@"%@ %@", @"CoreOS-Vagrant GUI for OS X", app_version];
    NSString *infoText = @"It is a simple wrapper around the CoreOS-Vagrant, which allows to control CoreOS-Vagrant via the Status Bar !!!";
    [self displayWithMessage:mText infoText:infoText];
}


- (IBAction)runSsh:(id)sender {
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.informativeText = @"vagrant ssh shell will be opened";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *appName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runApp:appName = @"iTerm" arguments:arguments = [_resoucesPathFromApp stringByAppendingPathComponent:@"vagrant_ssh.command"]];
}


- (IBAction)fleetUI_dockerUI:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://172.17.8.99:3000"]];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://172.17.8.99:9000"]];
}


- (void)runScript:(NSString*)scriptName arguments:(NSString*)arguments
{
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] pathForResource:scriptName ofType:@"command"]];
    task.arguments  = @[arguments];
    [task launch];
    [task waitUntilExit];
}


- (void)runApp:(NSString*)appName arguments:(NSString*)arguments
{
    // lunch an external App from the mainBundle
    [[NSWorkspace sharedWorkspace] openFile:arguments withApplication:appName];
}


- (void)checkVMStatus {
    // check vm status and and return the shell script output
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] pathForResource:@"coreos-vagrant" ofType:@"command"]];
    task.arguments  = @[@"status"];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    [task waitUntilExit];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    //    NSLog (@"Returned:\n%@", string);
    
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.informativeText = string;
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}


- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}


-(void) displayWithMessage:(NSString *)mText infoText:(NSString*)infoText
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setAlertStyle:NSInformationalAlertStyle];
//    [alert setIcon:[NSImage imageNamed:@"coreos-wordmark-vert-color"]];
    [alert setMessageText:mText];
    [alert setInformativeText:infoText];
    [alert runModal];
}


@end
