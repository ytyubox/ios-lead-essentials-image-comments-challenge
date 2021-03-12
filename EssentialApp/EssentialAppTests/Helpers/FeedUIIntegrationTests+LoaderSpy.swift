//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import EssentialFeed
import EssentialFeediOS
import Foundation
extension Loader {
	typealias Result = Outcome

}

extension FeedUIIntegrationTests {
	class LoaderSpy: Loader {
		typealias Output = [FeedImage]
        // MARK: - FeedLoader

        private var feedRequests = [(Outcome) -> Void]()

        var loadFeedCallCount: Int {
            return feedRequests.count
        }

        func load(completion: @escaping (Outcome) -> Void) {
            feedRequests.append(completion)
        }

        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            feedRequests[index](.success(feed))
        }

        func completeFeedLoadingWithError(at index: Int = 0) {
            let error = NSError(domain: "an error", code: 0)
            feedRequests[index](.failure(error))
        }
    }
	class ImageLoaderSpy: FeedImageDataLoader {
		

		// MARK: - FeedImageDataLoader

		private struct TaskSpy: FeedImageDataLoaderTask {
			let cancelCallback: () -> Void
			func cancel() {
				cancelCallback()
			}
		}

		private var imageRequests = [(url: URL, completion: (Outcome) -> Void)]()

		var loadedImageURLs: [URL] {
			return imageRequests.map { $0.url }
		}

		private(set) var cancelledImageURLs = [URL]()
		func load(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> CancellabelTask {
		imageRequests.append((url, completion))
			return TaskSpy { [weak self] in self?.cancelledImageURLs.append(url) }
		}

		func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
			imageRequests[index].completion(.success(imageData))
		}

		func completeImageLoadingWithError(at index: Int = 0) {
			let error = NSError(domain: "an error", code: 0)
			imageRequests[index].completion(.failure(error))
		}
	}
}
