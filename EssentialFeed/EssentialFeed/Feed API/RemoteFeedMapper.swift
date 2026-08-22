//
//  RemoteFeedMapper.swift
//  EssentialFeed
//
//  Created by Eyüphan Akkaya on 22.08.2026.
//

import Foundation

enum RemoteFeedMapper {
    private struct Root: Decodable {
        private let items: [FeedItemDTO]
        
        private struct FeedItemDTO: Decodable {
            public let id: UUID
            public let description: String?
            public let location: String?
            public let image: URL
        }
        
        var feeds: [FeedItem] {
            items.map {
                FeedItem(
                    id: $0.id,
                    description: $0.description,
                    location: $0.location,
                    imageURL: $0.image
                )
            }
        }
    }
    
    private static var OK_200: Int { return 200 }
    
    static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(.invalidData)
        }

        return .success(root.feeds)
    }
}
