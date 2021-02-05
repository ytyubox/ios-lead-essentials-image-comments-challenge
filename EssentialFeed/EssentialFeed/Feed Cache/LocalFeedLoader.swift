//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

public class LocalLoader<Output: ExpressibleByArrayLiteral, Store: FeedStore> {
    private let store: Store
    private let currentDate: () -> Date
    public typealias Mapper = (Store.Retrieval) -> Output
    private let mapper: Mapper

    public init(store: Store, currentDate: @escaping () -> Date, mapper: @escaping Mapper) {
        self.store = store
        self.currentDate = currentDate
        self.mapper = mapper
    }
}

extension LocalLoader: FeedCache {
    public typealias SaveResult = FeedCache.Result

    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] deletionResult in
            guard let self = self else { return }

            switch deletionResult {
            case .success:
                self.cache(feed, with: completion)

            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(feed.toLocal(), timestamp: currentDate()) { [weak self] insertionResult in
            guard self != nil else { return }

            completion(insertionResult)
        }
    }
}

extension LocalLoader: FeedLoader {
    //	public typealias LoadResult = FeedLoader.Result
    enum LocalError: Error {
        case noValue
    }

    public func load(completion: @escaping (Outcome) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .failure(error):
                completion(.failure(error))

            case let .success(.some(cache)) where FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                let output = self.mapper(cache)
                completion(.success(output))

            case .success:
                completion(.success([]))
            }
        }
    }
}

public extension LocalLoader {
    typealias ValidationResult = Result<Void, Error>

    func validateCache(completion: @escaping (ValidationResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure:
                self.store.deleteCachedFeed(completion: completion)

            case let .success(.some(cache)) where !FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed(completion: completion)

            case .success:
                completion(.success(()))
            }
        }
    }
}

public final class LocalFeedLoader<Store: FeedStore>: LocalLoader<[FeedImage], Store> {
    public convenience init(store: Store, currentDate: @escaping () -> Date) {
        self.init(store: store, currentDate: currentDate) {
            cache in
            cache.feed.toModels()
        }
    }
}

internal extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}

internal extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}
