//
//  CustomURLProtocol.h
//  WebCacheTest
//
//  Created by 傅浪 on 16/2/25.
//  Copyright © 2016年 傅浪. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLURLProtocol : NSURLProtocol
+ (NSSet *)supportedSchemes;
+ (void)setSupportedSchemes:(NSSet *)supportedSchemes;
@end
