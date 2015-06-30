// User.m
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

#import "ICUserContact.h"

@interface ICUserContact ()

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, strong) UIImage *userImage;
@property (nonatomic, strong) NSMutableArray *userPhones;
@property (nonatomic, strong) NSMutableArray *userEmails;

@end


@implementation ICUserContact

#pragma mark - LifeCycle
- (instancetype)initWithPerson:(ABRecordRef)person
{
    self = [super init];
    
    if(self)
    {
        [self __configureWithPerson:person];
    }
    
    return self;
}

#pragma mark - Properties Getter
- (NSString *)name
{
    return _userName;
}

- (NSArray *)phones
{
    return _userPhones;
}

- (NSArray *)emails
{
    return _userEmails;
}

- (UIImage *)image
{
    return _userImage;
}

#pragma mark - Private
#pragma mark 初始設置
- (void)__configureWithPerson:(ABRecordRef)person
{
    // Get User image
    NSData *imgData = CFBridgingRelease(ABPersonCopyImageData(person));
    _userImage      = [UIImage imageWithData:imgData];
    
    
    // Get User name
    NSString *lastName  = CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
    NSString *firstName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
    
    lastName  = lastName.length ? lastName : @"";
    firstName = firstName.length ? firstName : @"";
    
    // 判斷 firstName 在前還是在後
    if(ABPersonGetSortOrdering() == kABPersonCompositeNameFormatFirstNameFirst)
    {
        _userName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    }
    else
    {
        _userName = [NSString stringWithFormat:@"%@ %@", lastName, firstName];
    }
    
    
    // Get User phones
    _userPhones            = [NSMutableArray array];
    ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
    
    for(CFIndex i=0; i!=ABMultiValueGetCount(phones); i++)
    {
        NSString *phoneNum = CFBridgingRelease(ABMultiValueCopyValueAtIndex(phones, i));
        
        [_userPhones addObject:phoneNum];
    }
    
    CFRelease(phones);
    
    
    // Get User Emails
    _userEmails            = [NSMutableArray array];
    ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
    
    for(CFIndex i=0; i!=ABMultiValueGetCount(emails); i++)
    {
        NSString *email = CFBridgingRelease(ABMultiValueCopyValueAtIndex(emails, i));
        
        [_userEmails addObject:email];
    }
    
    CFRelease(emails);
}

@end
