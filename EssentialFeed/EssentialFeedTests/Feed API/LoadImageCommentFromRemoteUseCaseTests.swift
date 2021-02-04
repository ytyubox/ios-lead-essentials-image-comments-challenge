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
    typealias Output = [ImageComment]

    let client: HTTPClient
    let url: URL
    let mapper: Mapper

    internal init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
        mapper = {
            data, response in
            try Self.thowIfNot2XX(response: response)
            return try ImageCommendMapper.map(data, from: response).map(\.model)
        }
    }

    func load(from url: URL, completion: @escaping Promise) -> FeedImageDataLoaderTask {
        client.get(from: url) {
            [mapper] result in
            completion(
                result
                    .flatMap {
                        data, response in
                        Result { try mapper(data, response) }
                    }
            )
        }
        return Task()
    }

    private static func thowIfNot2XX(response: HTTPURLResponse) throws {
        guard (200 ..< 300).contains(response.statusCode) else {
            throw RemoteError.invalidData
        }
    }

    class Task: FeedImageDataLoaderTask {
        func cancel() {}
    }
}

enum ImageCommendMapper {
    private struct Root: Decodable {
        let items: [RemoteImageCommentItem]
    }

    static func map(_ data: Data, from _: HTTPURLResponse) throws -> [RemoteImageCommentItem] {
        guard let root = try? JSONDecoder()
            .decode(Root.self, from: data)
        else {
            throw RemoteError.invalidData
        }

        return root.items
    }
}

struct RemoteImageCommentItem: Codable {
    let id: String
    let message: String
    let createdAt: Date
    let author: Author

    enum CodingKeys: String, CodingKey {
        case id
        case message
        case createdAt = "created_at"
        case author
    }

    // MARK: - Author

    struct Author: Codable {
        let username: String

        enum CodingKeys: String, CodingKey {
            case username
        }
    }
}

extension RemoteImageCommentItem {
    var model: ImageComment {
        .init(id: id, message: message, createdAt: createdAt, author: ImageComment.Author(username: author.username))
    }
}

struct ImageComment: Equatable {
    let id: String
    let message: String
    let createdAt: Date
    let author: Author
    struct Author: Equatable {
        let username: String
    }
}

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

    func test_loadImageDataFromURL_deliversInvalidDataErrorOnNon2xxHTTPResponse() {
        let (sut, client) = makeSUT()

        let samples = [199, 300, 400, 500]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                client.complete(withStatusCode: code, data: anyData(), at: index)
            })
        }
    }

    func test_loadImageDataFromURL_deliversInvalidDataErrorOn2xxHTTPResponseWithEmptyData() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let emptyData = Data()
            client.complete(withStatusCode: 200, data: emptyData)
        })
    }

    // MARK: - helper

    func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (RemoteImageCommentLoader, HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentLoader(url: url, client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }

    private func failure(_ error: RemoteError) -> RemoteImageCommentLoader.Outcome {
        return .failure(error)
    }

    private func expect(_ sut: RemoteImageCommentLoader, toCompleteWith expectedResult: RemoteImageCommentLoader.Outcome, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let url = URL(string: "https://a-given-url.com")!
        let exp = expectation(description: "Wait for load completion")

        _ = sut.load(from: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedComment), .success(expectedComment)):
                XCTAssertEqual(receivedComment, expectedComment, file: file, line: line)

            case let (.failure(receivedError as RemoteFeedImageDataLoader.Error), .failure(expectedError as RemoteFeedImageDataLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
    }
}
