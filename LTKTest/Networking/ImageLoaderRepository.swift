//
//  ImageLoaderRepository.swift
//  LTKTest
//
//  Created by Rich Ruais on 4/12/23.
//

import UIKit

class ImageLoaderRepository {
    
    let cacheService: ImageLoaderCacheService
    let networkService: NetworkService
    
    init(cacheService: ImageLoaderCacheService, networkService: NetworkService) {
        self.cacheService = cacheService
        self.networkService = networkService
    }
    
    func loadImage(urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        let request = URLRequest(url: url)
        
        cacheService.loadImageIfAvailable(request: request) { image in
            if let image = image {
                completion(image)
            } else {
                self.networkService.fetchImage(request: request) { result in
                    switch result {
                    case .success(let urlSessionData):
                        if let image = UIImage(data: urlSessionData.data) {
                            completion(image)
                        } else {
                            completion(nil)
                        }
                    case .failure(_):
                        completion(nil)
                    }
                }
            }
        }
    }
    
    public func fetchImagesMetaData(nextURLString: String?, completion: @escaping (Result<ImagesMetadata, Error>) -> Void) {
        networkService.fetchImagesMetaData(nextURLString: nextURLString, completion: completion)
    }
    
    func cancelImageLoadIfNeeded(urlString: String) {
        networkService.cancelLoading(urlString: urlString)
    }
    
}
