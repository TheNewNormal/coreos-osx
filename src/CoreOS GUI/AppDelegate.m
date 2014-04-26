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
    [self.statusItem setAlternateImage: [NSImage imageNamed:@"icon_or"]];
    [self.statusItem setHighlightMode:YES];
    // set image depending on the status
    [self setIcon];
    
}


- (IBAction)Start:(id)sender {
    
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"coreos-vagrant will be up shortly";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *scriptName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runScript:scriptName = @"coreos-vagrant" arguments:arguments = @"up"];
}

- (IBAction)Pause:(id)sender {
    NSString *scriptName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runScript:scriptName = @"coreos-vagrant" arguments:arguments = @"suspend"];
}

- (IBAction)Stop:(id)sender {
    NSString *scriptName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runScript:scriptName = @"coreos-vagrant" arguments:arguments = @"halt"];
}

- (IBAction)Restart:(id)sender {
    NSString *scriptName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runScript:scriptName = @"coreos-vagrant" arguments:arguments = @"reload"];
}

- (IBAction)updateDockerClient:(id)sender {
    
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"docker OS X Client";
    notification.informativeText = @"will be updated";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *scriptName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runScript:scriptName = @"coreos-update" arguments:arguments = @"docker"];
}


- (IBAction)About:(id)sender {
    
//    [NSBundle loadNibNamed:@"About" owner:self ];
    
    self.myWindowController= [[NSWindowController alloc] initWithWindowNibName:@"About"];
    [self.myWindowController showWindow:self];
}


- (IBAction)runSsh:(id)sender {
    
    [[NSWorkspace sharedWorkspace] launchApplication:@"ssh.command"];
}


- (IBAction)osShell:(id)sender {
    
    [[NSWorkspace sharedWorkspace] launchApplication:@"shell.command"];
}



- (void)runScript:(NSString*)scriptName arguments:(NSString*)arguments
{
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] pathForResource:scriptName ofType:@"command"]];
    task.arguments  = @[arguments];
    [task launch];
    [task waitUntilExit];
    
    // set image depending on the status
    [self setIcon];
}


- (void)runApp:(NSString*)appName {
    NSString *scriptName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runScript:scriptName = @"coreos-vagrant" arguments:arguments = @"halt"];
    
    // set image depending on the status
    [self setIcon];
    
    // lunch external App from the mainBundle
    [[NSWorkspace sharedWorkspace] launchApplication:appName];
}


- (void)setIcon {
    // check coreos-vagrant status and and return the shell script output
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
    notification.title = @"coreos-vagrant";
    notification.informativeText = string;
//    notification.soundName = NSUserNotificationDefaultSoundName;
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    // check the status and set the correct icon
    if([string rangeOfString:@"running"].location != NSNotFound){
        [self.statusItem setImage:[NSImage imageNamed:@"icon"]];
    }
    else{
        [self.statusItem setImage:[NSImage imageNamed:@"icon_bw"]];
    }
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}


@end
