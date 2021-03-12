//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation
import LoadingSystem
public typealias LocalFeedImageDataLoader = LocalDataLoader
extension LocalFeedImageDataLoader {
	public func loadImageData(from url: URL, completion: @escaping Promise) -> CancellabelTask {
		load(from: url, completion: completion)
	}
}
