//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Combine
import CoreData
import EssentialFeed
import UIKit
func CoreDataStore() -> CoreDataFeedStore {
	try! CoreDataFeedStore(
		storeURL: NSPersistentContainer
			.defaultDirectoryURL()
			.appendingPathComponent("feed-store.sqlite"))
}
func makeHTTPClient() -> HTTPClient {
	
	   URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
   
}
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
extension LocalFeedLoader: FeedCache{}
extension LocalFeedImageDataLoader: FeedImageDataLoader{}
extension RemoteFeedImageDataLoader: FeedImageDataLoader{}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

  

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: scene)
        configureWindow()
    }

    func configureWindow() {
//        window?.rootViewController = UINavigationController(
//            rootViewController: FeedUIComposer.feedComposedWith(
//                feedLoader: makeRemoteFeedLoaderWithLocalFallback,
//                imageLoader: makeLocalImageLoaderWithRemoteFallback
//            ))

        window?.makeKeyAndVisible()
    }

    func sceneWillResignActive(_: UIScene) {
//		localFeedLoader.validateCache { _ in }
    }

   
}
