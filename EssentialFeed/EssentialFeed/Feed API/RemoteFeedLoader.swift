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
        client.get(url: url) { [weak self] result in
        guard self != nil else { return }
            switch result {
            case let .success(data, response):
                completion(RemoteFeedMapper.map(data, from: response))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}
