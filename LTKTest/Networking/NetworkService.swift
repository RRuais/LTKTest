//
//  NetworkService.swift
//  LTKTest
//
//  Created by Rich Ruais on 4/12/23.
//

import Combine
import Foundation

typealias URLSessionData = (response: URLResponse, data: Data)

protocol NetworkService {
    func fetchImagesMetaData(nextURLString: String?, completion: @escaping (Result<ImagesMetadata, Error>) -> Void)
    func fetchImage(request: URLRequest, completion: @escaping (Result<URLSessionData, Error>) -> Void)
    func cancelLoading(urlString: String)
}

class LTKNetworkService: NetworkService {
    
    private var runningRequests = [String: URLSessionDataTask]()
    private let semaphore = DispatchSemaphore(value: 1)
    private let session = URLSession.shared
    
    enum Endpoint {
        case fetchMetadata
        
        func url() -> URL? {
            switch self {
            case .fetchMetadata:
                var components = URLComponents()
                components.scheme = "https"
                components.host = "api-gateway.rewardstyle.com"
                components.path = "/api/ltk/v2/ltks/"
                components.queryItems = [
                    URLQueryItem(name: "featured", value: "true"),
                    URLQueryItem(name: "limit", value: "20"),
                ]
                return components.url
            }
        }
    }
    
    enum NetworkingError: Error {
        case failedToFetchData
        case failedToGetResponse
        case failedToDecodeModel
        case invalidURL
    }
    
    public func fetchImagesMetaData(nextURLString: String?, completion: @escaping (Result<ImagesMetadata, Error>) -> Void) {
        if let nextURLString = nextURLString, let url = URL(string: nextURLString) {
            fetchImagesMetaData(url: url, completion: completion)
        } else if let url = Endpoint.fetchMetadata.url() {
            fetchImagesMetaData(url: url, completion: completion)
        }
    }
    
    private func fetchImagesMetaData(url: URL, completion: @escaping (Result<ImagesMetadata, Error>) -> Void) {
        
        let request = URLRequest(url: url)
        
        session.dataTask(with: request) { data, response, error in
            guard let _ = response, let data = data else {
                completion(.failure(NetworkingError.failedToGetResponse))
                return
            }
            
            if let _ = error {
                completion(.failure(NetworkingError.failedToFetchData))
            }
            
            let decoder = JSONDecoder()
            
            do {
                let imagesMetadata = try decoder.decode(ImagesMetadata.self, from: data)
                completion(.success(imagesMetadata))
            } catch {
                completion(.failure(NetworkingError.failedToDecodeModel))
            }
            
        }
        .resume()
    }
    
    func fetchImage(request: URLRequest, completion: @escaping (Result<URLSessionData, Error>) -> Void) {
        guard let urlPath = request.url?.absoluteString else {
            completion(.failure(NetworkingError.invalidURL))
            return
        }
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            defer {
                self?.semaphore.wait()
                self?.runningRequests[urlPath] = nil
                self?.semaphore.signal()
            }
            
            guard let response = response else { return }
            
            if let error = error {
                if (error as NSError).code != NSURLErrorCancelled {
                    completion(.failure(error))
                }
                return
            }
            
            if let data = data {
                completion(.success((response, data)))
            }
        }
        
        task.resume()
        semaphore.wait()
        runningRequests[urlPath] = task
        semaphore.signal()
    }
    
    func cancelLoading(urlString: String) {
        semaphore.wait()
        runningRequests[urlString]?.cancel()
        runningRequests[urlString] = nil
        semaphore.signal()
    }
}
