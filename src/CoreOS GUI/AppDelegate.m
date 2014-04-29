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
                  
    [self checkVMStatus];
}


- (IBAction)Start:(id)sender {
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"coreos-vagrant will be up shortly";
    notification.informativeText = @"and OS shell will be opened";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *scriptName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runScript:scriptName = @"iTerm-vagrant-up" arguments:arguments = _resoucesPathFromApp ];
}

- (IBAction)Pause:(id)sender {
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"coreos-vagrant";
    notification.informativeText = @"coreos-vagrant will be suspended";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *scriptName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runScript:scriptName = @"coreos-vagrant" arguments:arguments = @"suspend"];
    
    [self checkVMStatus];
}

- (IBAction)Stop:(id)sender {
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"coreos-vagrant";
    notification.informativeText = @"coreos-vagrant will be stopped";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *scriptName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runScript:scriptName = @"coreos-vagrant" arguments:arguments = @"halt"];
    
    [self checkVMStatus];
}

- (IBAction)Restart:(id)sender {
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"coreos-vagrant";
    notification.informativeText = @"coreos-vagrant will be reloaded";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *scriptName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runScript:scriptName = @"coreos-vagrant" arguments:arguments = @"reload"];
    
    [self checkVMStatus];
}

- (IBAction)updates:(id)sender {
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"coreos-vagrant";
    notification.informativeText = @"docker, etcdclt and fleetctl will be updated";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *scriptName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runScript:scriptName = @"iTerm-update" arguments:arguments = _resoucesPathFromApp];
}

- (IBAction)initialInstall:(id)sender {
    NSString *scriptName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runScript:scriptName = @"coreos-vagrant-install" arguments:arguments = _resoucesPathFromApp ];
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
    [self runScript:scriptName = @"iTerm-vagrant-ssh" arguments:arguments = _resoucesPathFromApp ];
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
    notification.title = @"coreos-vagrant";
    notification.informativeText = string;
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    

}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}


@end
