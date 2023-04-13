//
//  ImageLoaderCacheService.swift
//  LTKTest
//
//  Created by Rich Ruais on 4/12/23.
//

import UIKit

class ImageLoaderCacheService {
    
    let cache: URLCache
    let semaphore: DispatchSemaphore
    
    init(cache: URLCache = .shared) {
        self.cache = cache
        self.semaphore = DispatchSemaphore(value: 1)
        cache.removeAllCachedResponses()
    }
    
    func storeURLResponse(request: URLRequest, response: URLResponse, data: Data) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.semaphore.wait()
            let cachedURLResponse = CachedURLResponse(response: response, data: data)
            self?.cache.storeCachedResponse(cachedURLResponse, for: request)
            self?.semaphore.signal()
        }
    }
    
    func loadImageIfAvailable(request: URLRequest, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.semaphore.wait()
            if let data = self?.cache.cachedResponse(for: request)?.data {
               completion(UIImage(data: data))
            } else {
                completion(nil)
            }
            self?.semaphore.signal()
        }
    }
}
