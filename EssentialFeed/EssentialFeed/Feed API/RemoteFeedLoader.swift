//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation
public enum RemoteError: Swift.Error {
    case connectivity
    case invalidData
}

public class RemoteLoader<Output: ExpressibleByArrayLiteral>: FeedLoader {
    private let url: URL
    private let client: HTTPClient
    private let mapper: Mapper
    public typealias Mapper = (Data, HTTPURLResponse) throws -> Output
    public typealias Error = RemoteError

    //	public typealias Result = FeedLoader.Result

    public init(url: URL, client: HTTPClient, mapper: @escaping Mapper) {
        self.url = url
        self.client = client
        self.mapper = mapper
    }

    public func load(completion: @escaping (Outcome) -> Void) {
        client.get(from: url) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success((data, response)):
                completion(self.map(data, from: response))

            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }

    private func map(_ data: Data, from response: HTTPURLResponse) -> Outcome {
        do {
            let items = try mapper(data, response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
}

public final class RemoteFeedLoader: RemoteLoader<[FeedImage]> {
    public convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client) {
            data, response in
            try FeedItemsMapper.map(data, from: response).toModels()
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image) }
    }
}
