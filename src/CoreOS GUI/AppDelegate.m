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
}


- (IBAction)Start:(id)sender {
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"coreos-vagrant will be up shortly";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *scriptName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runScript:scriptName = @"iTerm-vagrant-up" arguments:arguments = @"~/coreos-osx/bin/vagrant_up.command"];
}

- (IBAction)Pause:(id)sender {
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"coreos-vagrant";
    notification.informativeText = @"coreos-vagrant be suspended";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *scriptName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runScript:scriptName = @"coreos-vagrant" arguments:arguments = @"suspend"];
}

- (IBAction)Stop:(id)sender {
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"coreos-vagrant";
    notification.informativeText = @"coreos-vagrant be stoped";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *scriptName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runScript:scriptName = @"coreos-vagrant" arguments:arguments = @"halt"];
}

- (IBAction)Restart:(id)sender {
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"coreos-vagrant";
    notification.informativeText = @"coreos-vagrant be reloaded";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *scriptName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runScript:scriptName = @"coreos-vagrant" arguments:arguments = @"reload"];
}

- (IBAction)updateDockerClient:(id)sender {
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"coreos-vagrant";
    notification.informativeText = @"docker OS X Client will be updated";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *scriptName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runScript:scriptName = @"iTerm-docker-update" arguments:arguments = @""];
}

- (IBAction)initialInstall:(id)sender {
    NSString *scriptName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runScript:scriptName = @"coreos-vagrant-install" arguments:arguments = @""];
}


- (IBAction)About:(id)sender {
//    [NSBundle loadNibNamed:@"About" owner:self ];
    
    self.myWindowController= [[NSWindowController alloc] initWithWindowNibName:@"About"];
    [self.myWindowController showWindow:self];
}


- (IBAction)runSsh:(id)sender {
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"coreos-vagrant";
    notification.informativeText = @"vagrant ssh shell will be opened";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *scriptName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runScript:scriptName = @"iTerm-vagrant-ssh" arguments:arguments = @""];
}


- (IBAction)osShell:(id)sender {
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"coreos-vagrant";
    notification.informativeText = @"OS shell will be opened";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *scriptName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runScript:scriptName = @"iTerm-shell" arguments:arguments = @""];
}

- (IBAction)dockerUI:(id)sender {
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


- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}


@end
