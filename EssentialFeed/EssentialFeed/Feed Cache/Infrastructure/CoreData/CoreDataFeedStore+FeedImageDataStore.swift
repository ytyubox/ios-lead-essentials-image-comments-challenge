import Foundation
import LoadingSystem

extension CoreDataFeedStore: FeedImageDataStore {
	public func insert(_ data: Data, for url: URL, completion: @escaping (DataStore.InsertionResult) -> Void) {
		perform { context in
			completion(Result {
				try ManagedFeedImage.first(with: url, in: context)
					.map { $0.data = data }
					.map(context.save)
			})
		}
	}

	public func retrieve(dataForURL url: URL, completion: @escaping (DataStore.RetrievalResult) -> Void) {
		perform { context in
			completion(Result {
				try ManagedFeedImage.first(with: url, in: context)?.data
			})
		}
	}
}
