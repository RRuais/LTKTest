//
//  ImagesViewModel.swift
//  LTKTest
//
//  Created by Rich Ruais on 4/12/23.
//

import Combine
import Foundation
import UIKit

class ImagesViewModel {
    
    let imageLoaderRepository: ImageLoaderRepository
    
    @Published var images: [Image] = []
    
    var nextURLString: String?
    let newIndexPaths = PassthroughSubject<[IndexPath], Never>()
    var disposeBag = Set<AnyCancellable>()
    
    init(imageLoaderRepository: ImageLoaderRepository) {
        self.imageLoaderRepository = imageLoaderRepository
        loadImageMetadata()
    }
    
    func loadImageMetadata() {
        imageLoaderRepository.fetchImagesMetaData(nextURLString: nextURLString) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let imagesMetadata):
                self.nextURLString = imagesMetadata.metadata.nextURL
                
                let lastIndexPath = self.images.count - 1
                var newIndexPaths: [IndexPath] = []
                
                for i in (lastIndexPath + 1)..<(lastIndexPath + 1 + imagesMetadata.images.count) {
                    newIndexPaths.append(IndexPath(row: i, section: 0))
                }
                
                var currentImages = self.images
                currentImages.append(contentsOf: imagesMetadata.images)
                self.images = currentImages
                self.newIndexPaths.send(newIndexPaths)
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    func image(for indexPath: IndexPath) -> Image? {
        guard indexPath.row < images.count else { return nil }
        return images[indexPath.row]
    }
    
    func loadImageData(for indexPath: IndexPath, completion: @escaping (UIImage?) -> Void) {
        guard let image = image(for: indexPath) else { return }
        imageLoaderRepository.loadImage(urlString: image.heroImage, completion: completion)
    }
    
    func cancelLoading(for indexPath: IndexPath) {
        guard let image = image(for: indexPath) else { return }
        imageLoaderRepository.cancelImageLoadIfNeeded(urlString: image.heroImage)
    }
    
    func didSelectImage(for indexPath: IndexPath) {
        guard let _ = image(for: indexPath) else { return }
    }
}
