//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol LoadFromURLAndCancelableLoader {
    associatedtype Output
    typealias Outcome = Swift.Result<Output, Error>
    typealias Promise = (Outcome) -> Void
    typealias Mapper = (Data, HTTPURLResponse) throws -> Output

    func load(from url: URL, completion: @escaping Promise) -> FeedImageDataLoaderTask
}

public protocol FeedImageDataLoader: LoadFromURLAndCancelableLoader where Output == Data {
    typealias Result = Swift.Result<Data, Error>

    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}

public extension FeedImageDataLoader {
    func load(from url: URL, completion: @escaping (Outcome) -> Void) -> FeedImageDataLoaderTask {
        loadImageData(from: url, completion: completion)
    }
}
