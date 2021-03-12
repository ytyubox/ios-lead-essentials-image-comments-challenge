//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation
import LoadingSystem

public protocol FeedCache: ItemCache where Item == FeedImage {
	typealias Result = Swift.Result<Void, Error>
	
	func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}
