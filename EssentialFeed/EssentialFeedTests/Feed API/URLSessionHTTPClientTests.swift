//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Eyüphan Akkaya on 27.08.2026.
//

import XCTest
import EssentialFeed

final class URLSessionHTTPClient {

    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(url: URL) {
        session.dataTask(with: url)
    }
}


final class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_createsDataTaskWithURL() {
        let url = URL(string: "https://example.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(url: url)
        
        XCTAssertEqual(session.requestURLs, [url])
    }
    
    // MARK: - Helpers
    
    private final class URLSessionSpy: URLSession {
        var requestURLs = [URL]()
        
        override func dataTask(with url: URL) -> URLSessionDataTask {
            requestURLs.append(url)
            
            return URLSessionDataTaskSpy()
        }
        
    }
    
    private final class URLSessionDataTaskSpy: URLSessionDataTask {  }
}
