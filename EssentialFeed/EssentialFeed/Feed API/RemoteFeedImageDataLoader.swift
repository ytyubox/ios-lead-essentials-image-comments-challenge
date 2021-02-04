//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedImageDataLoader: FeedImageDataLoader {
    private let client: HTTPClient

    public init(client: HTTPClient) {
        self.client = client
    }

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }

            task.complete(with: result
                .mapError { _ in Error.connectivity }
                .flatMap { data, response in
                    let isValidResponse = response.isOK && !data.isEmpty
                    return isValidResponse ? .success(data) : .failure(Error.invalidData)
                })
        }
        return task
    }
}

internal final class HTTPClientTaskWrapper<Output>: FeedImageDataLoaderTask {
    typealias Outcome = Result<Output, Error>
    private var completion: ((Outcome) -> Void)?

    var wrapped: HTTPClientTask?

    init(_ completion: @escaping (Outcome) -> Void) {
        self.completion = completion
    }

    func complete(with result: Outcome) {
        completion?(result)
    }

    func cancel() {
        preventFurtherCompletions()
        wrapped?.cancel()
    }

    private func preventFurtherCompletions() {
        completion = nil
    }
}
