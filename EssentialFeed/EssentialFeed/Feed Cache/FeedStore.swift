//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation
import LoadingSystem

public protocol FeedStore: Store where Local == LocalFeedImage  {
	
	
}

private class StoreBaseBox<L:LocalModel>: Store {
	func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		fatalError()
	}
	
	func insert(_ feed: [L], timestamp: Date, completion: @escaping InsertionCompletion) {
		fatalError()
	}
	
	func retrieve(completion: @escaping RetrievalCompletion) {
		fatalError()
	}
	

	typealias Local = L
	

	
	
}

private final class StoreBox<StoreType: Store>: StoreBaseBox<StoreType.Local> {
	let base: StoreType
	init(base: StoreType) {
		self.base = base
		super.init()
	}
	override func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		base.deleteCachedFeed(completion: completion)
	}
	
	override func insert(_ feed: [StoreType.Local], timestamp: Date, completion: @escaping InsertionCompletion) {
		base.insert(feed, timestamp: timestamp, completion: completion)
	}
	
	override func retrieve(completion: @escaping RetrievalCompletion) {
		base.retrieve(completion: completion)
	}
	
}
//
public struct AnyStore<Local: LocalModel>: Store {

	
	
	private let box: StoreBaseBox<Local>

	public init<S: Store>(_ future: S) where Local == S.Local {
		if let earsed = future as? AnyStore<Local> {
			box = earsed.box
		} else {
			box = StoreBox(base: future)
		}
	}

	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		box.deleteCachedFeed(completion: completion)
	}
	
	public func insert(_ feed: [Local], timestamp: Date, completion: @escaping InsertionCompletion) {
		box.insert(feed, timestamp: timestamp, completion: completion)
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		box.retrieve(completion: completion)
	}
}
