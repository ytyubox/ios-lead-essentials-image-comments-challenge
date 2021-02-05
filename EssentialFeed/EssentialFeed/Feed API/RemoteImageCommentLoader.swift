//
/*
 *		Created by 游宗諭 in 2021/2/4
 *
 *		Using Swift 5.0
 *
 *		Running on macOS 10.15
 */

import Foundation
public final class RemoteImageCommentLoader: LoadFromURLAndCancelableLoader {
    public typealias Output = [ImageComment]

    let client: HTTPClient
    let mapper: Mapper

    public init(client: HTTPClient) {
        self.client = client
        mapper = {
            data, response in
            try Self.thowIfNot2XX(response: response)
            return try ImageCommentMapper.map(data, from: response).map(\.model)
        }
    }

    public func load(from url: URL, completion: @escaping Promise) -> FeedImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion)
        task.wrapped = client.get(from: url) {
            [weak self, task] result in
            guard let self = self else { return }
            task.complete(
                with: result.flatMap {
                    data, response in
                    Result { try self.mapper(data, response) }
                }
            )
        }
        return task
    }

    private static func thowIfNot2XX(response: HTTPURLResponse) throws {
        guard (200 ..< 300).contains(response.statusCode) else {
            throw RemoteError.invalidData
        }
    }
}

extension RemoteImageCommentItem {
    var model: ImageComment {
        .init(id: id, message: message, createdAt: createdAt, author: ImageComment.Author(username: author.username))
    }
}
