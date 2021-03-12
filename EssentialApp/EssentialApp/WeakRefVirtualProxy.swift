//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import UIKit
import EssentialFeed

final class WeakRefVirtualProxy<T: AnyObject> {
	private weak var object: T?
	
	init(_ object: T) {
		self.object = object
	}
}

extension WeakRefVirtualProxy: FeedErrorView where T: FeedErrorView {
	func display(_ viewModel: FeedErrorViewModel) {
		object?.display(viewModel)
	}
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
	func display(_ viewModel: FeedLoadingViewModel) {
		object?.display(viewModel)
	}
}


extension WeakRefVirtualProxy: UniversalView where T: FeedImageView {
	func display(_ model: FeedImageViewModel<T.Image>) {
		object?.display(model)
	}
	
	typealias Union = FeedImageViewModel<T.Image>
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
	typealias Image = UIImage
	func display(_ model: FeedImageViewModel<UIImage>) {
		object?.display(model)
	}
}
