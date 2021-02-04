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
            return try ImageCommendMapper.map(data, from: response).map(\.model)
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

    class Task: FeedImageDataLoaderTask {
        func cancel() {}
    }
}

enum ImageCommendMapper {
    private struct Root: Decodable {
        let items: [RemoteImageCommentItem]
    }

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss+0000"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return decoder
    }()

    static func map(_ data: Data, from _: HTTPURLResponse) throws -> [RemoteImageCommentItem] {
        guard let root = try? decoder
            .decode(Root.self, from: data)
        else {
            throw RemoteError.invalidData
        }

        return root.items
    }
}

extension RemoteImageCommentItem {
    var model: ImageComment {
        .init(id: id, message: message, createdAt: createdAt, author: ImageComment.Author(username: author.username))
    }
}

public struct ImageComment: Equatable {
    public init(id: UUID, message: String, createdAt: Date, author: ImageComment.Author) {
        self.id = id
        self.message = message
        self.createdAt = createdAt
        self.author = author
    }

    let id: UUID
    let message: String
    let createdAt: Date
    let author: Author
    public struct Author: Equatable {
        public init(username: String) {
            self.username = username
        }

        let username: String
    }
}
