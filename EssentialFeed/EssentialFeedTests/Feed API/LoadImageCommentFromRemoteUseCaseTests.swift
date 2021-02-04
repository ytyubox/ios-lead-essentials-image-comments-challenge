//
/*
 *		Created by 游宗諭 in 2021/2/4
 *
 *		Using Swift 5.0
 *
 *		Running on macOS 10.15
 */

import EssentialFeed
import XCTest

final class RemoteImageCommentLoader: LoadFromURLAndCancelableLoader {
    typealias Output = ImageComment

    let client: HTTPClient
    let url: URL
    let mapper: Mapper

    internal init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
        mapper = {
            _, _ in
            ImageComment()
        }
    }

    func load(from url: URL, completion: @escaping Promise) -> FeedImageDataLoaderTask {
        client.get(from: url) {
            [mapper] result in
            completion(
                result.map(mapper)
            )
        }
        return Task()
    }

    class Task: FeedImageDataLoaderTask {
        func cancel() {}
    }
}

struct ImageComment {}

class LoadImageCommentFromRemoteUseCaseTests: XCTestCase {
    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_loadImageDataFromURL_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        _ = sut.load(from: url) { _ in }

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadImageDataFromURLTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        _ = sut.load(from: url) { _ in }
        _ = sut.load(from: url) { _ in }

        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    // MARK: - helper

    func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (RemoteImageCommentLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentLoader(url: url, client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
}
