//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Eyüphan Akkaya on 27.08.2026.
//

import XCTest
import EssentialFeed

final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
    
}


final class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_resumesDataTaskWithURL() {
        let url = URL(string: "https://example.com")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(url: url) { _ in}
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromURL_failsOnRequestError() async throws {
        let url = URL(string: "https://example.com")!
        let session = URLSessionSpy()
        let error = NSError(domain: "error", code: 1)
        session.stub(url: url, with: error)
        
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(url: url) { result in
            switch result {
            case .failure(let receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default:
                XCTFail("Expected failure with error \(error), got \(result) instead")
            }
        }
        
    }
    
    // MARK: - Helpers
    
    private final class URLSessionSpy: URLSession {
        private var stubs = [URL: Stub]()
        
        func stub(url: URL, task: URLSessionDataTask = URLSessionDataTaskSpy(), with error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
        
        private struct Stub {
            let task: URLSessionDataTask
            let error: Error?
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
            guard let stub = stubs[url] else {
                fatalError("Couln't find stub for \(url)")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
        }


        
    }
    
    private final class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCount = 0
        
        override func resume() {
            resumeCallCount += 1
        }
        
    }
}
