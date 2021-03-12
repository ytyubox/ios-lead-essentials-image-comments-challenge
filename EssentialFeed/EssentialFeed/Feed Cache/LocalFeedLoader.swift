//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation
import LoadingSystem

public final class LocalFeedLoader<AStore: Store>: LocalLoader<[FeedImage], AStore> where AStore.Local == LocalFeedImage {
	public convenience init(store: AStore, currentDate: @escaping () -> Date) {
		self.init(store: store, currentDate: currentDate) {
			cache in
			cache.feed.toModels()
		}
	}
}
