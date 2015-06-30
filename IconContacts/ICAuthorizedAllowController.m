// ICAuthorizedAllowController.m
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
#import "ICUserContact.h"
#import "ICAuthorizedAllowController.h"

#import <AddressBookUI/AddressBookUI.h>

@interface ICAuthorizedAllowController ()
<
    UITableViewDataSource,
    ABPeoplePickerNavigationControllerDelegate
>

@property (nonatomic, weak) IBOutlet UILabel *noticeLabel;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) ICUserContact *user;

@end


@implementation ICAuthorizedAllowController

#pragma mark - LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _noticeLabel.text = @"\n目前沒有選取聯絡人\n請點選下方選取按鈕";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self __resetUI];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return 1;
            break;
            
        case 1:
            return [_user.phones count];
            break;
            
        default:
            return [_user.emails count];
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:
  (NSIndexPath *)indexPath
{
    NSString *title;
    NSInteger row         = indexPath.row;
    NSInteger section     = indexPath.section;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    switch (section)
    {
        case 0:
            title = _user.name;
            break;
            
        case 1:
            title = _user.phones[row];
            break;
            
        default:
            title = _user.emails[row];
            break;
    }
    
    cell.textLabel.text = title;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return @"姓名";
            break;
    
        case 1:
            return @"電話";
            break;
    
        default:
            return @"Email";
            break;
    }
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
                         didSelectPerson:(ABRecordRef)person
{
    _user = [[ICUserContact alloc]initWithPerson:person];
}

#pragma mark - IBAction
#pragma mark 按下選取聯絡人
- (IBAction)selectButtonClicked:(UIButton *)sender
{
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc]init];
    
    picker.peoplePickerDelegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark 按下左上角 Item
- (IBAction)leftItemClicked:(UIBarButtonItem *)sender
{
    if(!_user)
    {
        UIAlertController *alert =
          [UIAlertController alertControllerWithTitle:nil
                                              message:@"請先選取聯絡人"
                                       preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *OK = [UIAlertAction actionWithTitle:@"確定"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
        
        [alert addAction:OK];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self __copyHTMLToNSTemporaryDirectory];
            [self __copyManifestToNSTemporaryDirectory];
            [self __copyIconToNSTemporaryDirectory];
            [[ICServer singleton]start];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication]openURL:[ICServer singleton].URL];
            });
        });
    }
}

#pragma mark - Private
#pragma mark Reset UI
- (void)__resetUI
{
    BOOL selected       = _user != nil;
    _tableView.hidden   = !selected;
    _noticeLabel.hidden = selected;
    
    [_tableView reloadData];
}

#pragma mark Copy index.html
- (void)__copyHTMLToNSTemporaryDirectory
{
    NSString *path = [[NSBundle mainBundle]pathForResource:@"index"
                                                    ofType:@"html"];
    
    NSString *HTML = [NSString stringWithContentsOfFile:path
                                               encoding:NSUTF8StringEncoding
                                                  error:nil];
    
    NSMutableString *body = [NSMutableString string];
    
    [_user.phones enumerateObjectsUsingBlock:^(NSString *tel, NSUInteger idx, BOOL *stop) {
        [body appendString:[self __HTMLCodeForPhoneNumber:tel]];
    }];
    
    [_user.emails enumerateObjectsUsingBlock:^(NSString *mail, NSUInteger idx, BOOL *stop) {
        [body appendString:[self __HTMLCodeForEmail:mail]];
    }];
    
    HTML = [NSString stringWithFormat:HTML, _user.name, _user.name, body];
    
    [HTML writeToFile:[NSTemporaryDirectory()stringByAppendingPathComponent:@"index.html"]
           atomically:YES
             encoding:NSUTF8StringEncoding
                error:nil];
}

#pragma mark Copy cache.manifest
- (void)__copyManifestToNSTemporaryDirectory
{
    NSString *path = [[NSBundle mainBundle]pathForResource:@"cache"
                                                    ofType:@"manifest"];
    
    NSString *manifest = [NSString stringWithContentsOfFile:path
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil];
    
    [manifest writeToFile:[NSTemporaryDirectory()stringByAppendingPathComponent:@"cache.manifest"]
               atomically:YES
                 encoding:NSUTF8StringEncoding
                    error:nil];
}

#pragma mark Copy Icon
- (void)__copyIconToNSTemporaryDirectory
{
    UIImage *icon = _user.image;
    
    if(!icon)
    {
        icon = [UIImage imageNamed:@"Icon"];
    }
    else
    {
        icon = [self __imageToIcon:icon];
    }
    
    NSData *data = UIImagePNGRepresentation(icon);
    
    [data writeToFile:[NSTemporaryDirectory()stringByAppendingPathComponent:@"Icon.png"]
              options:NSDataWritingAtomic
                error:nil];
}

#pragma mark 撥打電話 HTML code
- (NSString *)__HTMLCodeForPhoneNumber:(NSString *)phoneNumber
{
    NSString *HTML =
    @"<br/>"
    @"<br/>"
    @"<label style='font-size:150%%;color:#FF6666'>%@</label>"
    @"<br/>"
    @"<select style='font-size:100%%;color:#555555'"
    @"onchange='location = this.options[this.selectedIndex].value;'>"
    
    @"<option value='#'>請選擇要執行的動作</option>"
    @"<option value='tel:%@'>播打電話</option>"
    @"<option value='sms:%@'>傳訊簡訊</option>"
    @"<option value='facetime:%@'>Facetime</option>"
    
    @"</select>";
    
    return [NSString stringWithFormat:HTML, phoneNumber, phoneNumber, phoneNumber, phoneNumber];
}

#pragma mark Send email HTML code
- (NSString *)__HTMLCodeForEmail:(NSString *)email
{
    NSString *HTML =
    @"<br/>"
    @"<br/>"
    @"<label style='font-size:150%%;color:#FF6666'>%@</label>"
    @"<br/>"
    @"<select style='font-size:100%%;color:#555555'"
    @"onchange='location = this.options[this.selectedIndex].value;'>"
    
    @"<option value='#'>請選擇要執行的動作</option>"
    @"<option value='mailto:%@'>寄送 Email</option>"
    @"<option value='facetime:%@'>Facetime</option>"
    
    @"</select>";
    
    return [NSString stringWithFormat:HTML, email, email, email];
}

#pragma mark UIImage to desktop Icon size
- (UIImage *)__imageToIcon:(UIImage *)image
{
    float scale         = 180.f / image.size.width;
    float newHeight     = image.size.height * scale;
    CGRect newRect      = CGRectMake(0, 0, 180.0, newHeight);
    CGImageRef imageRef = image.CGImage;
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef));

    CGContextSetInterpolationQuality(bitmap, kCGInterpolationHigh);
    CGContextDrawImage(bitmap, newRect, imageRef);
    
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    
    CGImageRef finalImageRef =
      CGImageCreateWithImageInRect(newImageRef, CGRectMake(0, 0, 180.0, 180.0));
    
    UIImage *newImage = [UIImage imageWithCGImage:finalImageRef];
    
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    CGImageRelease(finalImageRef);
    
    return newImage;
}

@end
