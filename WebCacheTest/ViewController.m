//
//  ViewController.m
//  WebCacheTest
//
//  Created by 傅浪 on 16/2/24.
//  Copyright © 2016年 傅浪. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSMutableURLRequest *request= [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://baidu.com"] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    
    [self.webView loadRequest:request];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
