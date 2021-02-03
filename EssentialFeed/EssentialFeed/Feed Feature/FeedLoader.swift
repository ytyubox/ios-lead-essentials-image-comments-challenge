//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public protocol FeedLoader {
    associatedtype Output: ExpressibleByArrayLiteral
    typealias Outcome = Swift.Result<Output, Error>
    typealias Promise = (Outcome) -> Void

    func load(completion: @escaping Promise)
}

public protocol EmptyDefault {
    static var empty: Self { get }
}

private class FeedLoaderBaseBox<Output: ExpressibleByArrayLiteral>: FeedLoader {
    init() {}
    func load(completion _: @escaping Promise) {
        fatalError()
    }
}

private final class FeedLoaderBox<FeedLoaderType: FeedLoader>: FeedLoaderBaseBox<FeedLoaderType.Output> {
    let base: FeedLoaderType
    init(base: FeedLoaderType) {
        self.base = base
        super.init()
    }

    override func load(completion: @escaping Promise) {
        base.load(completion: completion)
    }
}

struct AnyFeedLoader<Output: ExpressibleByArrayLiteral>: FeedLoader {
    private let box: FeedLoaderBaseBox<Output>

    init<F: FeedLoader>(_ future: F) where Output == F.Output {
        if let earsed = future as? AnyFeedLoader<Output> {
            box = earsed.box
        } else {
            box = FeedLoaderBox(base: future)
        }
    }

    func load(completion: @escaping Promise) {
        box.load(completion: completion)
    }
}
