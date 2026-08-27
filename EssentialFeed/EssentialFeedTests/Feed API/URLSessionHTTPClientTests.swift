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
    
    init(session: URLSession = .shared) {
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
    
    func test_getFromURL_failsOnRequestError() async throws {
        let url = URL(string: "https://example.com")!
        let error = NSError(domain: "error", code: 1)
        URLProtocolStub.stub(url: url, with: error)
        
        let sut = URLSessionHTTPClient()
        
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
    
    private final class URLProtocolStub: URLProtocol {
        private static var stubs = [URL: Stub]()
        
        static func stub(url: URL, with error: Error? = nil) {
            stubs[url] = Stub(error: error)
        }
        
        private struct Stub {
            let error: Error?
        }

        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            
            return URLProtocolStub.stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else {
                return
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() { }

    }
}
