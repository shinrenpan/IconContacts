// ICNotDeterminedController.m
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

#import "AppDelegate.h"
#import "ICAuthorizedUnknowController.h"

#import <AddressBook/AddressBook.h>

@interface ICAuthorizedUnknowController ()

@property (nonatomic, weak) IBOutlet UILabel *noticeLabel;

@end


@implementation ICAuthorizedUnknowController

#pragma mark - LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _noticeLabel.text = @"本程式需要使用您的通訊錄\n請按下方允許按鈕後開始使用";
}

#pragma mark - IBAction
#pragma mark 按下允許
- (IBAction)allowButtonClicked:(id)sender
{
    __block BOOL allow;
    
    ABAddressBookRef addressBook;
    
    addressBook               = ABAddressBookCreateWithOptions(NULL, NULL);
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error){
        allow = granted;
        dispatch_semaphore_signal(sema);
    }); 
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER); 
    
    [self __handleAllow:allow];
}

#pragma mark - Private
#pragma mark 處理允許結果
- (void)__handleAllow:(BOOL)allow
{
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    
    if(allow)
    {
        [delegate changeRootViewControllerToICAuthorizedAllowController];
    }
    else
    {
        [delegate changeRootViewControllerToICAuthorizedDeniedController];
    }
}

@end
