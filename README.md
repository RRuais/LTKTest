# LTKTest
- App uses MVVM architecture and UIKit
- DIContainer sets up dependencies and will create ImagesViewModel and ImagesViewController
- Using reactive programming with Combine framework for communication between ViewModel and ViewController
- ViewModel reaches out to ImageLoaderRepository to fetch data
- ImageLoaderRepository has two dependencies: ImageLoaderCacheService and NetworkService. When loading image data the repository will first check if the url response is cached, if not it will fetch from the network

# Future Improvements 
- Error handling
- Unit tests
