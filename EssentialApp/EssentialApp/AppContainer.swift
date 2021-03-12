//
/* 
 *		Created by 游宗諭 in 2021/3/12
 *		
 *		Using Swift 5.0
 *		
 *		Running on macOS 11.2
 */


import EssentialFeed
import UIKit

class Container <Store: FeedStore & FeedImageDataStore> {
	
	private var httpClient: HTTPClient

	private var _store:Store
	
	private lazy var localFeedStore:AnyStore<LocalFeedImage> =
		AnyStore.init(_store)
	private lazy var imageDataStore:DataStore = _store

	private lazy var remoteFeedLoader: RemoteFeedLoader = {
		RemoteFeedLoader(
			url: URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!,
			client: httpClient
		)
	}()

	private lazy var localFeedLoader: LocalFeedLoader = {
		LocalFeedLoader(store: localFeedStore, currentDate: Date.init)
	}()

	private lazy var remoteImageLoader: RemoteFeedImageDataLoader = {
		RemoteFeedImageDataLoader(client: httpClient)
	}()

	private lazy var localImageLoader: LocalFeedImageDataLoader = {
		LocalFeedImageDataLoader(store: imageDataStore)
	}()
	init(httpClient: HTTPClient, store: Store) where Store: FeedStore & FeedImageDataStore {
		self.httpClient = httpClient
		self._store = store
	}
	private func makeRemoteFeedLoaderWithLocalFallback() -> Loader.Publisher {
		return remoteFeedLoader
			.loadPublisher()
			.caching(to: localFeedLoader)
			.fallback(to: localFeedLoader.loadPublisher)
	}

	private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
		return localImageLoader
			.loadImageDataPublisher(from: url)
			.fallback(to: { [remoteImageLoader, localImageLoader] in
				remoteImageLoader
					.loadImageDataPublisher(from: url)
					.caching(to: localImageLoader, using: url)
			})
	}
}

extension Container: Root {
	func makeRootViewController() -> UIViewController {
		UINavigationController(
					rootViewController: FeedUIComposer.feedComposedWith(
						feedLoader: makeRemoteFeedLoaderWithLocalFallback,
						imageLoader: makeLocalImageLoaderWithRemoteFallback
					))
	}
	
	func validateCache() {
		localFeedLoader.validateCache { _ in }
	}
}

extension LocalFeedLoader: FeedCache{}
extension LocalFeedImageDataLoader: FeedImageDataLoader{}
extension RemoteFeedImageDataLoader: FeedImageDataLoader{}
