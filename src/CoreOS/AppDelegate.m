//
//  AppDelegate.m
//  CoreOS macOS
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
    
    //check for latest app version and notify user if there is such one
    NSString *popup = [[NSString alloc] init];
    [self checkAppVersionGithub:popup = @"no"];
    
    // get the App's main bundle path
    _resoucesPathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@""];
    NSLog(@"applicationDirectory: '%@'", _resoucesPathFromApp);
    
    NSString *dmgPath = @"/Volumes/CoreOS/CoreOS.app/Contents/Resources";
    NSLog(@"DMG resource path: '%@'", dmgPath);
    
    // check resourcePath and exit the App if it runs from the dmg
    if ( [ _resoucesPathFromApp isEqual: dmgPath] ) {
        // show alert message
        NSString *mText = [NSString stringWithFormat:@"%@", @"CoreOS for macOS App cannot be started from DMG !!!"];
        NSString *infoText = @"Please copy App e.g. to your Applications folder ...";
        [self displayWithMessage:mText infoText:infoText];
        
        // exiting App
        [[NSApplication sharedApplication] terminate:self];
    }
    
    // check that corectl.app is installed at /Applications folder
    if(![[NSWorkspace sharedWorkspace] launchApplication:@"/Applications/corectl.app"]) {
        NSLog(@"corectl failed to launch");

        // show alert message
        NSString *mText = [NSString stringWithFormat:@"%@", @"CoreOS App cannot start !!!"];
        NSString *infoText = @"corectl.app cannot be found in /Applications folder, the download link will be opened in your browser ...";
        [self displayWithMessage:mText infoText:infoText];
        
        // open corectl.app releases URL
        NSString *url = [@[@"https://github.com/TheNewNormal/corectl.app/releases"] componentsJoinedByString:@""];
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
        
        // exiting App
        [[NSApplication sharedApplication] terminate:self];
    }
    

    NSString *home_folder = [NSHomeDirectory() stringByAppendingPathComponent:@"coreos-osx"];
    
    BOOL isDir;
    if([[NSFileManager defaultManager]
        fileExistsAtPath:home_folder isDirectory:&isDir] && isDir)
    {
        // set resouces_path
        NSString *resources_content = _resoucesPathFromApp;
        NSData *fileContents1 = [resources_content dataUsingEncoding:NSUTF8StringEncoding];
        [[NSFileManager defaultManager] createFileAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"coreos-osx/.env/resouces_path"]
                                                contents:fileContents1
                                              attributes:nil];
        
        // write to file App version
        NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSData *app_version = [version dataUsingEncoding:NSUTF8StringEncoding];
        [[NSFileManager defaultManager] createFileAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"coreos-osx/.env/version"]
                                                contents:app_version
                                              attributes:nil];
        
        // kill VM just in case it was left running from the previous instance
        NSString *scriptName = [[NSString alloc] init];
        NSString *arguments = [[NSString alloc] init];
        [self runScript:scriptName = @"kill_VM" arguments:arguments = @""];
        
        [self showVMStatus];
    }
    else
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert setMessageText:@"CoreOS VM was not set."];
        [alert setInformativeText:@"Do you want to set it up?"];
        [alert setAlertStyle:NSWarningAlertStyle];
        
        if ([alert runModal] == NSAlertFirstButtonReturn) {
            // OK clicked
            [self initialInstall:self];
        }
        else
        {
            // Cancel clicked
            NSString *msg = [NSString stringWithFormat:@"%@ ", @" 'Initial setup of CoreOS VM' at any time later one !!! "];
            [self displayWithMessage:@"You can set VM from menu 'Setup':" infoText:msg];
        }
    }
}


- (IBAction)Start:(id)sender {
    // check that corectl.app is installed in /Applications folder
    if(![[NSWorkspace sharedWorkspace] launchApplication:@"/Applications/corectl.app"]) {
        NSLog(@"corectl failed to launch");
        
        // show alert message
        NSString *mText = [NSString stringWithFormat:@"%@", @"Cannot start VM !!!"];
        NSString *infoText = @"corectl.app cannot be found in /Applications folder, the download link will be opened in your browser ...";
        [self displayWithMessage:mText infoText:infoText];
        
        // open corectl.app releases URL
        NSString *url = [@[@"https://github.com/TheNewNormal/corectl.app/releases"] componentsJoinedByString:@""];
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
        
        //
        return;
    }
    
    int vm_status=[self checkVMStatus];
    NSLog (@"VM status:\n%d", vm_status);
    
    if (vm_status == 0) {
        NSLog (@"VM is Off");
        ////
        NSString *home_folder = [NSHomeDirectory() stringByAppendingPathComponent:@"coreos-osx"];
    
        BOOL isDir;
        if([[NSFileManager defaultManager]
            fileExistsAtPath:home_folder isDirectory:&isDir] && isDir)
        {
            // send a notification on to the screen
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            notification.title = @"CoreOS VM will be up shortly";
            notification.informativeText = @"and OS shell will be opened";
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        
            NSString *appName = [[NSString alloc] init];
            NSString *arguments = [[NSString alloc] init];
            [self runApp:appName = @"iTerm" arguments:arguments = [_resoucesPathFromApp stringByAppendingPathComponent:@"up.command"]];
        }
        else
        {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert addButtonWithTitle:@"Cancel"];
            [alert setMessageText:@"CoreOS VM was not set."];
            [alert setInformativeText:@"Do you want to set it up?"];
            [alert setAlertStyle:NSWarningAlertStyle];
        
            if ([alert runModal] == NSAlertFirstButtonReturn) {
                // OK clicked
                [self initialInstall:self];
            }
            else
            {
                // Cancel clicked
                NSString *msg = [NSString stringWithFormat:@"%@ ", @" 'Initial setup of CoreOS VM' at any time later one !!! "];
                [self displayWithMessage:@"You can set VM from menu 'Setup':" infoText:msg];
            }
        }
    }
    else
    {
        NSLog (@"VM is On");
        // send a notification on to the screen
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = @"CoreOS";
        notification.informativeText = @"VM is already running !!!";
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }
}


- (IBAction)Stop:(id)sender {
    int vm_status = [self checkVMStatus];
    //NSLog (@"VM status:\n%d", vm_status);
    
    if (vm_status == 0) {
        NSLog (@"VM is Off");
        // send a notification on to the screen
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = @"CoreOS";
        notification.informativeText = @"VM is already Off !!!";
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }
    else
    {
        NSLog (@"VM is On");
        // send a notification on to the screen
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = @"CoreOS";
        notification.informativeText = @"VM will be stopped";
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
        NSString *scriptName = [[NSString alloc] init];
        NSString *arguments = [[NSString alloc] init];
        [self runScript:scriptName = @"halt" arguments:arguments = @""];
    
        notification.title = @"CoreOS";
        notification.informativeText = @"VM is stopping !!!";
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        
        int vm_status_check = 1;
        while (vm_status_check == 1 ) {
            vm_status_check = [self checkVMStatus];
            if (vm_status_check == 0) {
                notification.title = @"CoreOS";
                notification.informativeText = @"VM is OFF !!!";
                [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
                break;
            }
            else
            {
                NSString *scriptName = [[NSString alloc] init];
                NSString *arguments = [[NSString alloc] init];
                [self runScript:scriptName = @"kill_VM" arguments:arguments = @""];
            }
        }
    }
}

- (IBAction)Restart:(id)sender {
    int vm_status=[self checkVMStatus];
    //NSLog (@"VM status:\n%d", vm_status);
    
    if (vm_status == 0) {
        NSLog (@"VM is Off");
        // send a notification on to the screen
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = @"CoreOS";
        notification.informativeText = @"VM is Off !!!";
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }
    else
    {
        NSLog (@"VM is On");
        // send a notification on to the screen
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = @"CoreOS";
        notification.informativeText = @"VM will be reloaded";
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
        NSString *appName = [[NSString alloc] init];
        NSString *arguments = [[NSString alloc] init];
        [self runApp:appName = @"iTerm" arguments:arguments = [_resoucesPathFromApp stringByAppendingPathComponent:@"reload.command"]];
    }
}


// Updates menu

- (IBAction)checkForAppUpdates:(id)sender {
    
    NSString *popup = [[NSString alloc] init];
    [self checkAppVersionGithub:popup = @"yes"];
}


- (IBAction)updates:(id)sender {
    int vm_status=[self checkVMStatus];
    //NSLog (@"VM status:\n%d", vm_status);
    
    if (vm_status == 0) {
        NSLog (@"VM is Off");
        // send a notification on to the screen
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = @"CoreOS";
        notification.informativeText = @"VM is Off !!!";
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }
    else
    {
        NSLog (@"VM is On");
        // send a notification on to the screen
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = @"CoreOS";
        notification.informativeText = @"macOS clients will be updated";
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
        NSString *appName = [[NSString alloc] init];
        NSString *arguments = [[NSString alloc] init];
        [self runApp:appName = @"iTerm" arguments:arguments = [_resoucesPathFromApp stringByAppendingPathComponent:@"update_osx_clients_files.command"]];
    }
}
// Updates menu


// Setup menu
- (IBAction)changeReleaseChannel:(id)sender {
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"CoreOS";
    notification.informativeText = @"CoreOS release channel change";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *appName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runApp:appName = @"iTerm" arguments:arguments = [_resoucesPathFromApp stringByAppendingPathComponent:@"change_release_channel.command"]];
}


- (IBAction)destroy:(id)sender {
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"CoreOS";
    notification.informativeText = @"VM will be destroyed";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    NSString *appName = [[NSString alloc] init];
    NSString *arguments = [[NSString alloc] init];
    [self runApp:appName = @"iTerm" arguments:arguments = [_resoucesPathFromApp stringByAppendingPathComponent:@"destroy.command"]];
    
    [self showVMStatus];
}

- (IBAction)initialInstall:(id)sender
{
    NSString *home_folder = [NSHomeDirectory() stringByAppendingPathComponent:@"coreos-osx"];
    
    BOOL isDir;
    if([[NSFileManager defaultManager]
        fileExistsAtPath:home_folder isDirectory:&isDir] && isDir){
        NSString *msg = [NSString stringWithFormat:@"%@ %@ %@", @"Folder", home_folder, @"exists, please delete or rename that folder !!!"];
        [self displayWithMessage:@"coreos-osx" infoText:msg];
    }
    else
    {
        NSLog(@"Folder does not exist: '%@'", home_folder);
        // create home folder and .env subfolder
        NSString *env_folder = [home_folder stringByAppendingPathComponent:@".env"];
        NSError * error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:env_folder
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        // write to file App version
        NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSData *app_version = [version dataUsingEncoding:NSUTF8StringEncoding];
        [[NSFileManager defaultManager] createFileAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"coreos-osx/.env/version"]
                                                contents:app_version
                                              attributes:nil];
        // set resouces_path
        NSString *resources_content = _resoucesPathFromApp;
        NSData *fileContents1 = [resources_content dataUsingEncoding:NSUTF8StringEncoding];
        [[NSFileManager defaultManager] createFileAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"coreos-osx/.env/resouces_path"]
                                                contents:fileContents1
                                              attributes:nil];
        
        // run install script

        NSString *scriptName = [[NSString alloc] init];
        NSString *arguments = [[NSString alloc] init];
        [self runScript:scriptName = @"coreos-osx-install" arguments:arguments = _resoucesPathFromApp ];
    }
}
// Setup menu


- (IBAction)About:(id)sender {
    
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
//    NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
//    NSString *app_version = [NSString stringWithFormat:@"%@%@.%@", @"v", version, build];
    NSString *app_version = [NSString stringWithFormat:@"%@%@", @"v", version];
    
    NSString *mText = [NSString stringWithFormat:@"%@ %@", @"CoreOS for macOS", app_version];
    NSString *infoText = @"It is a simple wrapper around the corectl + CoreOS VM, which allows to control VM via the Status Bar App !!!";
    [self displayWithMessage:mText infoText:infoText];
}

//


- (IBAction)runShell:(id)sender {
    int vm_status=[self checkVMStatus];
    //NSLog (@"VM status:\n%d", vm_status);
    
    if (vm_status == 0) {
        NSLog (@"VM is Off");
        // send a notification on to the screen
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = @"CoreOS";
        notification.informativeText = @"VM is Off !!!";
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }
    else
    {
        NSLog (@"VM is On");
        // send a notification on to the screen
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = @"CoreOS";
        notification.informativeText = @"macOS shell will be opened";
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
        NSString *appName = [[NSString alloc] init];
        NSString *arguments = [[NSString alloc] init];
        [self runApp:appName = @"iTerm" arguments:arguments = [_resoucesPathFromApp stringByAppendingPathComponent:@"os_shell.command"]];
    }
}

- (IBAction)runSsh:(id)sender {
    int vm_status=[self checkVMStatus];
    //NSLog (@"VM status:\n%d", vm_status);
    
    if (vm_status == 0) {
        NSLog (@"VM is Off");
        // send a notification on to the screen
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = @"CoreOS";
        notification.informativeText = @"VM is Off !!!";
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }
    else
    {
        NSLog (@"VM is On");
        // send a notification on to the screen
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = @"CoreOS";
        notification.informativeText = @"VM ssh shell will be opened";
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
        NSString *appName = [[NSString alloc] init];
        NSString *arguments = [[NSString alloc] init];
        [self runApp:appName = @"iTerm" arguments:arguments = [_resoucesPathFromApp stringByAppendingPathComponent:@"ssh.command"]];
    }
}


- (IBAction)dockerUI:(id)sender {
    int vm_status=[self checkVMStatus];
    //NSLog (@"VM status:\n%d", vm_status);
    
    if (vm_status == 0) {
        NSLog (@"VM is Off");
        // send a notification on to the screen
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = @"CoreOS";
        notification.informativeText = @"VM is Off !!!";
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }
    else
    {
        NSLog (@"VM is On");
        NSString *file_path = [NSHomeDirectory() stringByAppendingPathComponent:@"coreos-osx/.env/ip_address"];
        // read IP from file
        NSString *vm_ip = [NSString stringWithContentsOfFile:file_path
                                                    encoding:NSUTF8StringEncoding
                                                       error:NULL];
        NSString *url = [@[@"http://",vm_ip,@":9000"] componentsJoinedByString:@""];
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
    }
}


- (IBAction)uploadDockerImages:(id)sender {
    int vm_status=[self checkVMStatus];
    //NSLog (@"VM status:\n%d", vm_status);
    
    if (vm_status == 0) {
        NSLog (@"VM is Off");
        // send a notification on to the screen
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = @"CoreOS";
        notification.informativeText = @"VM is Off !!!";
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }
    else
    {
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = @"CoreOS";
        notification.informativeText = @"Docker images upload window will be opened ...";
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        
        NSString *appName = [[NSString alloc] init];
        NSString *arguments = [[NSString alloc] init];
        [self runApp:appName = @"iTerm" arguments:arguments = [_resoucesPathFromApp stringByAppendingPathComponent:@"upload_docker_images.command"]];
    }
}


- (IBAction)quit:(id)sender {
    int vm_status = [self checkVMStatus];
    //NSLog (@"VM status:\n%d", vm_status);
    
    if (vm_status == 0) {
        NSLog (@"VM is Off");
    }
    else
    {
        NSLog (@"VM is On");
        // send a notification on to the screen
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = @"CoreOS";
        notification.informativeText = @"VM will be stopped";
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        
        NSString *scriptName = [[NSString alloc] init];
        NSString *arguments = [[NSString alloc] init];
        [self runScript:scriptName = @"halt" arguments:arguments = @""];
        
        notification.title = @"CoreOS";
        notification.informativeText = @"VM is stopping !!!";
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        
        int vm_status_check = 1;
        while (vm_status_check == 1 ) {
            vm_status_check = [self checkVMStatus];
            if (vm_status_check == 0) {
                notification.title = @"CoreOS";
                notification.informativeText = @"VM is OFF !!!";
                [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
                break;
            }
            else
            {
                NSString *scriptName = [[NSString alloc] init];
                NSString *arguments = [[NSString alloc] init];
                [self runScript:scriptName = @"kill_VM" arguments:arguments = @""];
            }
        }
    }
    
    // send a notification on to the screen
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"Quitting CoreOS App";
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    
    exit(0);
}


// helping functions

// check and notify about App's new version
- (void)checkAppVersionGithub:(NSString*)popup
{
    // get App's current version'
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *app_version = [NSString stringWithFormat:@"%@%@", @"v", version];
    NSLog (@"Installed App version:\n%@", app_version);
    
    // get lates github version
    NSString *githubVersion = [self getAppVersionGithub];
    
    if (app_version == githubVersion) {
        if ([popup  isEqual: @"yes"]) {
            NSString *mText = [NSString stringWithFormat:@"%@ %@", @"CoreOS for macOS", app_version];
            NSString *infoText = @"You are-up-to-date !!!";
            [self displayWithMessage:mText infoText:infoText];
        }
        else {
            NSLog (@"App is up-to-date!!!");
        }
    }
    else {
        // show alert message
        NSString *mText = [NSString stringWithFormat:@"%@", @"There is a new CoreOS App version available !!!"];
        NSString *infoText = @"The download link will be opened in your browser ...";
        [self displayWithMessage:mText infoText:infoText];
    
        // open coreos.app releases URL
        NSString *url = [@[@"https://github.com/TheNewNormal/coreos-osx/releases"] componentsJoinedByString:@""];
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
    }
}
//

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


- (NSString*)getAppVersionGithub {
    // get App github version and return the shell script output
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] pathForResource:@"check_app_version_github" ofType:@"command"]];
    //    task.arguments  = @[@"status"];
    
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
    NSLog (@"App latest github version:\n%@", string);
    
    return string;
}


- (int)checkVMStatus {
    // check VM status and return the shell script output
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] pathForResource:@"check_vm_status" ofType:@"command"]];
//    task.arguments  = @[@"status"];
    
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
    NSLog (@"Show VM status:\n%@", string);
    
    if ( [string  isEqual: @"VM is stopped"] ) {
        return 0;
    } else {
        return 1;
    }
}


- (void)showVMStatus {
    // check vm status and return the shell script output
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] pathForResource:@"check_vm_status" ofType:@"command"]];
    //    task.arguments  = @[@"status"];
    
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
    NSLog (@"Returned:\n%@", string);
    
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
