//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Combine
import EssentialFeed
import EssentialFeediOS

final class FeedLoaderPresentationAdapter<View:FeedView>: FeedViewControllerDelegate {
    private let feedLoader: () -> Loader.Publisher
    private var cancellable: Cancellable?
	var presenter: FeedPresenter<View>?

    init(feedLoader: @escaping () -> Loader.Publisher) {
        self.feedLoader = feedLoader
    }

    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()

        cancellable = feedLoader()
            .dispatchOnMainQueue()
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished: break

                    case let .failure(error):
                        self?.presenter?.didFinishLoadingFeed(with: error)
                    }
                }, receiveValue: { [weak self] feed in
                    self?.presenter?.didFinishLoadingFeed(with: feed)
                }
            )
    }
}
