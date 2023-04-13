//
//  ImagesMetadata.swift
//  LTKTest
//
//  Created by Rich Ruais on 4/12/23.
//

import Foundation

struct ImagesMetadata: Decodable {
    let images: [Image]
    let metadata: Metadata
    let profiles: [Profile]
    
    enum CodingKeys: String, CodingKey {
        case images = "ltks"
        case metadata = "meta"
        case profiles
    }
}

struct Metadata: Decodable {
    let numberOfResults: Int
    let totalResults: Int
    let nextURL: String
    
    enum CodingKeys: String, CodingKey {
        case numberOfResults = "num_results"
        case totalResults = "total_results"
        case nextURL = "next_url"
    }
}

struct Profile: Decodable {
    let id: String
    let avatarURL: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case avatarURL = "avatar_url"
    }
}

struct Image: Decodable {
    let heroImage: String
    let id: String
    let caption: String
    
    enum CodingKeys: String, CodingKey {
        case heroImage = "hero_image"
        case id
        case caption
    }
}
