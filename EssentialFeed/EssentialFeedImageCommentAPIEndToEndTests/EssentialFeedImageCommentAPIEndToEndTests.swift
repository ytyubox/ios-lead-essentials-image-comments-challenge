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

class EssentialFeedImageCommentAPIEndToEndTests: XCTestCase {
    func test_endToEndTestServerGetImageCommentResult_matchFixedTestAccountData() {
        let receivedResult = getImageCommentResult()

        switch receivedResult {
        case let .success(imageComment):
            XCTAssertEqual(imageComment.count, 3)
            XCTAssertEqual(imageComment[0], expectedImageComment(at: 0))
            XCTAssertEqual(imageComment[1], expectedImageComment(at: 1))
            XCTAssertEqual(imageComment[2], expectedImageComment(at: 2))
        case let .failure(error):
            XCTFail("Expected successful image comment result, got \(error) instead")

        default:
            XCTFail("Expected successful image comment result, got no result instead")
        }
    }

    // MARK: - helper

    private let endPoint = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/image/54F35D06-9CC6-4294-A0D8-963D397E8B98/comments")!
    private func getImageCommentResult(file: StaticString = #file, line: UInt = #line) -> RemoteImageCommentLoader.Outcome? {
        let loader = RemoteImageCommentLoader(client: ephemeralClient())
        trackForMemoryLeaks(loader, file: file, line: line)
        let exp = expectation(description: "Wait for load completion")

        var receivedResult: RemoteImageCommentLoader.Outcome?
        _ = loader.load(from: endPoint) {
            result in
            receivedResult = result.mapError { $0 }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)

        return receivedResult
    }

    private func ephemeralClient(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        trackForMemoryLeaks(client, file: file, line: line)
        return client
    }

    private func expectedImageComment(at index: Int) -> ImageComment {
        ImageComment(id: id(at: index),
                     message: message(at: index),
                     createdAt: createdAt(at: index),
                     author: author(at: index))
    }

    private func id(at index: Int) -> UUID {
        UUID(uuidString:
            [
                "7019D8A7-0B35-4057-B7F9-8C5471961ED0",
                "1F4A3B22-9E6E-46FC-BB6C-48B33269951B",
                "00D0CD9A-452C-4812-B264-1B73823C94CA",
            ][index]
        )!
    }

    private func message(at index: Int) -> String {
        [
            "message-1",
            "message-2",
            "message-3",
        ][index]
    }

    private func createdAt(at index: Int) -> Date {
        try! dateStringToDate(
            [
                "2020-07-31T11:24:59+0000",
                "2020-07-31T04:23:53+0000",
                "2020-07-26T11:22:59+0000",
            ][index]
        )
    }

    private func author(at index: Int) -> ImageComment.Author {
        ImageComment.Author(username:
            [
                "username-1",
                "username-2",
                "username-3",
            ][index]
        )
    }
}
