//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Eyüphan Akkaya on 13.08.2026.
//

import XCTest

final class RemoteFeedLoader {
    private let client: HTTPClient
    private let url: URL
    
    init(
        client: HTTPClient,
         url: URL
    ) {
        self.client = client
        self.url = url
    }
    
    func load() {
        client.get(url: url)
    }
}

protocol HTTPClient {
    func get(url: URL)
}

final class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertNil(client.requestURL)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://example.com")!
        let (sut, client) = makeSUT(url: url)

        
        sut.load()
        
        XCTAssertNotNil(client.requestURL)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://example.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        
        return (sut, client)
    }
    
    private final class HTTPClientSpy: HTTPClient {
        var requestURL: URL?
        
        func get(url: URL) {
            requestURL = url
        }
    }

}
