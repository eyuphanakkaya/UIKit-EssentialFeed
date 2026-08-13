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

final class HTTPClientSpy: HTTPClient {
    var requestURL: URL?
    
    func get(url: URL) {
        requestURL = url
    }
}


final class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let url = URL(string: "https://example.com")!
        let client = HTTPClientSpy()
        let _ = RemoteFeedLoader(client: client, url: url)
        
        XCTAssertNil(client.requestURL)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://example.com")!
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        
        sut.load()
        
        XCTAssertNotNil(client.requestURL)
    }
}
