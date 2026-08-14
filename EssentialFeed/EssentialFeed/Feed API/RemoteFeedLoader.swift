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
        case connectivity
    }
    
    public init(
        client: HTTPClient,
         url: URL
    ) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Error?)-> Void = { _ in }) {
        client.get(url: url) { error in
            completion(.connectivity)
        }
    }
}

public protocol HTTPClient {
    func get(url: URL, completion: @escaping (Error)-> Void )
}
