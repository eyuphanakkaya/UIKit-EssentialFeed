//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Eyüphan Akkaya on 13.08.2026.
//

import XCTest

final class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.get(url: URL(string: "https://example.com/feed")!)
    }
}

class HTTPClient {
    static var shared = HTTPClient()

    func get(url: URL) {}
}

class HTTPClientSpy: HTTPClient {
    var requestURL: URL?
    
    override func get(url: URL) {
        requestURL = url
    }
}


final class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        let _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestURL)
    }
    
    func test_load_requestDataFromURL() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestURL)
    }
    
}
