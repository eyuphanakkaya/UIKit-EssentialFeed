//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Eyüphan Akkaya on 13.08.2026.
//
import Foundation

public final class RemoteFeedLoader {
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case invalidData
        case connectivity
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(
        client: HTTPClient,
        url: URL
    ) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result)-> Void = { _ in }) {
        client.get(url: url) { result in

            switch result {
            case let .success(data, response):
                do {
                    let mapper = try RemoteFeedMapper.map(data, from: response)
                    completion(.success(mapper))
                } catch {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

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
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == 200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        let decoder = JSONDecoder()
        let root = try decoder.decode(Root.self, from: data)
        return root.feeds
    }
}


public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}
public protocol HTTPClient {
    func get(url: URL, completion: @escaping (HTTPClientResult)-> Void )
}
