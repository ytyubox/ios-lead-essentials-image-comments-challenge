//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation
import LoadingSystem
public typealias LoadFromURLAndCancelableLoader = CancelableLoader

public typealias FeedImageDataLoaderTask = CancellabelTask
public protocol FeedImageDataLoader: LoadFromURLAndCancelableLoader where Output == Data {
}
