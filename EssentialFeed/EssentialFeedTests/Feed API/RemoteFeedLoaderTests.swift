//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Eyüphan Akkaya on 13.08.2026.
//

import XCTest
import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestURLs.isEmpty)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://example.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load()
        
        XCTAssertEqual(client.requestURLs, [url])
    }
    
    func test_load_requestsDataFromURLTwice() {
        let url = URL(string: "https://example.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .failure(.connectivity)) {
            let clientError = NSError(domain: "Error", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_load_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithResult: .failure(.invalidData)) {
                client.complete(data: makeItemsJSON([]), statusCode: code, at: index)
            }
        }
    }
    
    func test_load_deliversInvalidDataErrorOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .failure(.invalidData)) {
            let jsonData = Data("invalid".utf8)
            client.complete(data: jsonData, statusCode: 200)
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .success([])) {
            let emptyListJSON = makeItemsJSON([])
            client.complete(data: emptyListJSON, statusCode: 200)
        }
    }
    
    func test_load_deliversItemsOn200HttpResponseWithJSONList() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(
            id: UUID(),
            imageURL: URL(string: "http://another-url.com")!
        )
        
        let item2 = makeItem(
            id: UUID(),
            description: "a description",
            location: "a location",
            imageURL: URL(string: "http://another-url.com")!
        )
        
        expect(sut, toCompleteWithResult: .success([item1.model, item2.model])) {
            let json = makeItemsJSON([item1.json, item2.json])
            client.complete(data: json, statusCode: 200)
        }
    }
    
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        let url = URL(string: "https://example.com")!
        var sut: RemoteFeedLoader? = RemoteFeedLoader(client: client, url: url)
        
        var capturedResults = [RemoteFeedLoader.Result]()
        sut?.load { capturedResults.append($0) }
        
        sut = nil
        client.complete(data: makeItemsJSON([]), statusCode: 200)
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://example.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        
        return (sut, client)
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have dealocatted. Potential memory leak.", file: file, line: line)
        }
    }
    
    private final class HTTPClientSpy: HTTPClient {
        var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestURLs: [URL] {
            messages.map { $0.url }
        }
        
        func get(url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(data: Data, statusCode code: Int, at index: Int = 0) {
            let httpURLResponse = HTTPURLResponse(
                url: URL(string: "https://example.com")!,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            
            messages[index].completion(.success((data, httpURLResponse)))
        }
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
        let item = FeedItem(
            id: id,
            description: description,
            location: location,
            imageURL: imageURL)
        
        let json = [
            "id": item.id.uuidString,
            "description": item.description,
            "location": item.location,
            "image": item.imageURL.absoluteString
        ].compactMapValues { $0 }
        
        return (item, json)
    }
    
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let itemsJSON = [
            "items": items
        ]
        
        let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
        return json
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWithResult expectedResult: RemoteFeedLoader.Result, file: StaticString = #file, line: UInt = #line, when action: () -> Void) {
        let exp = expectation(description: "wait for load to complete")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success(let receivedItem), .success(let expectedItem)) :
                XCTAssertEqual(receivedItem, expectedItem, file: file, line: line)
                
            case (.failure(let receivedError as RemoteFeedLoader.Error), .failure(let expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
            XCTFail("Expected \(expectedResult), but got none", file: file, line: line)
                
            }
            
            exp.fulfill()
        }
 
        action()
        
        wait(for: [exp], timeout: 1)
    }

}
