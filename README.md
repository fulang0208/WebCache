# WebCache
利用iOS原生的NSURLCache最简单的实现网络请求的离线缓存
* 选个地儿注册FLURLProtocol就可以了，建议在application:application didFinishLaunchingWithOptions:方法中注册

        [NSURLProtocol registerClass:[FLURLProtocol class]];
* 设置缓存大小，不设置也行，系统默认是4M内存和20M磁盘缓存
        NSURLCache *urlCache = [[NSURLCache alloc] initWithMemoryCapacity:4*1024*1024 diskCapacity:20 * 1024 * 1024 diskPath:nil];
        [NSURLCache setSharedURLCache:urlCache];
* 通过+(void)setSupportedSchemes:(NSSet *)supportedSchemes设置你需要缓存的请求，或自定义筛选条件，默认所有http请求

        + (BOOL)canInitWithRequest:(NSURLRequest *)request {
            if ([[self supportedSchemes] containsObject:request.URL.scheme] &&
                [request valueForHTTPHeaderField:FLURLHeader] == nil) {
                return YES;
            }
            return NO;
        }
* 网络不通时，使用缓存的数据，若没有缓存，则请求失败。有网络时，发送请求，在请求头里包含上一次服务器返回的Etag值和"Last-Modified"的值，让服务器判断是否需要更新数据，若服务器返回304状态码，则使用缓存，否则使用服务器发送的新数据。

* iOS原生的NSURLCache已经可以满足大部分的缓存需求，所以很多情况并不需要写什么复杂的缓存机制。更多信息参见https://github.com/ChenYilong/ParseSourceCodeStudy/blob/master/02_Parse%E7%9A%84%E7%BD%91%E7%BB%9C%E7%BC%93%E5%AD%98%E4%B8%8E%E7%A6%BB%E7%BA%BF%E5%AD%98%E5%82%A8/iOS%E7%BD%91%E7%BB%9C%E7%BC%93%E5%AD%98%E6%89%AB%E7%9B%B2%E7%AF%87.md

