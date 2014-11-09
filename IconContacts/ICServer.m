// ICWebServer.m
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

#include "mongoose.h"
#import "ICServer.h"


@interface ICServer ()

@property (nonatomic, assign) int port;
@property (nonatomic, assign) struct mg_context *ctx;

@end


@implementation ICServer

#pragma mark - LifeCycle
+ (instancetype)singleton
{
    static dispatch_once_t onceToken;
    static ICServer *_singleton;
    
    dispatch_once(&onceToken, ^{
        _singleton = [[ICServer alloc]init];
    });
    
    return _singleton;
}

#pragma mark - properties getter
- (NSURL *)URL
{
    NSString *url = [NSString stringWithFormat:@"http://localhost:%d", _port];
    
    return [NSURL URLWithString:url];
}

#pragma mark - Start
- (void)start
{
    if(_ctx != NULL)
    {
        [self stop];
    }
    
    // 給予亂數 port
    self.ctx        = mg_start();
    self.port       = arc4random_uniform(10000)+80;
    NSString *ports = [NSString stringWithFormat:@"%d", _port];
    
    mg_set_option(_ctx, "root", NSTemporaryDirectory().UTF8String);
    mg_set_option(_ctx, "ports", ports.UTF8String);
}

#pragma mark - Stop
- (void)stop
{
    if(_ctx != NULL)
    {
        mg_stop(_ctx);
        
        self.ctx = NULL;
    }
}

@end
