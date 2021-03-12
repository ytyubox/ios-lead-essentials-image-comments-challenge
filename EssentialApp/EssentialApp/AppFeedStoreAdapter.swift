//
/* 
 *		Created by 游宗諭 in 2021/3/12
 *		
 *		Using Swift 5.0
 *		
 *		Running on macOS 11.2
 */


import EssentialFeed
import CoreData

class AppFeedStoreAdapter: FeedStore, FeedImageDataStore {
	let store = try! CoreDataFeedStore(
		storeURL: NSPersistentContainer
			.defaultDirectoryURL()
			.appendingPathComponent("feed-store.sqlite"))
	func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
		store.insert(data, for: url, completion: completion)
	}
	
	func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
		store.retrieve(dataForURL: url, completion: completion)
	}
	
	func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		store.deleteCachedFeed(completion: completion)
	}
	
	func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		store.insert(feed, timestamp: timestamp, completion: completion)
	}
	
	func retrieve(completion: @escaping RetrievalCompletion) {
		store.retrieve(completion: completion)
	}
}
