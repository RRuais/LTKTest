//
//  DIContainer.swift
//  LTKTest
//
//  Created by Rich Ruais on 4/12/23.
//

import Foundation

class DIContainer {
    
    private let networkService: NetworkService
    private let imageLoaderCacheService: ImageLoaderCacheService
    private let imageLoaderRepository: ImageLoaderRepository
    
    public init() {
        self.imageLoaderCacheService = ImageLoaderCacheService()
        self.networkService = LTKNetworkService()
        self.imageLoaderRepository = ImageLoaderRepository(cacheService: imageLoaderCacheService, networkService: networkService)
    }
    
    public func makeImagesViewModel() -> ImagesViewModel {
        return ImagesViewModel(imageLoaderRepository: imageLoaderRepository)
    }
    
    public func makeImagesViewController() -> ImagesViewController {
        let viewModel = makeImagesViewModel()
        return ImagesViewController(viewModel: viewModel)
    }
}
