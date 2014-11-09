// AppDelegate.m
//
// Copyright (c) 2014年 Shinren Pan
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ICServer.h"
#import "AppDelegate.h"
#import <AddressBook/AddressBook.h>


@implementation AppDelegate

#pragma mark - LifeCycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)
launchOptions {
    
    // 不使用 MainStoryboard 當 RootViewController
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    
    [self __checkRootViewController];
    [_window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // 背景執行 support
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // 從背景回到前景要做的事
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[ICServer singleton]stop];
    });
    
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    
    if(status != kABAuthorizationStatusAuthorized)
    {
        [self __checkRootViewController];
    }
}

#pragma mark - 允許
- (void)changeRootViewControllerToICAuthorizedAllowController
{
    UIStoryboard *story        = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _window.rootViewController = [story instantiateViewControllerWithIdentifier:@"Allow"];
}

#pragma mark - 拒絕
- (void)changeRootViewControllerToICAuthorizedDeniedController
{
    UIStoryboard *story        = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _window.rootViewController = [story instantiateViewControllerWithIdentifier:@"Denied"];
}

#pragma mark - 未知
- (void)__changeRootViewControllerToICAuthorizedUnknowController
{
    UIStoryboard *story        = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _window.rootViewController = [story instantiateViewControllerWithIdentifier:@"Unknow"];
}

#pragma mark - 檢查要使用哪個 RootViewController
- (void)__checkRootViewController
{
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    
    switch (status)
    {
        case kABAuthorizationStatusAuthorized:
            [self changeRootViewControllerToICAuthorizedAllowController];
            break;
            
        case kABAuthorizationStatusDenied:
            [self changeRootViewControllerToICAuthorizedDeniedController];
            break;
            
        default:
            // kABAuthorizationStatusRestricted 及 kABAuthorizationStatusNotDetermined
            [self __changeRootViewControllerToICAuthorizedUnknowController];
            break;
    }
}

@end
