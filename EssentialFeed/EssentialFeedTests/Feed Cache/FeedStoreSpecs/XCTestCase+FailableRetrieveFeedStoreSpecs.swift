//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import EssentialFeed

extension FailableRetrieveFeedStoreSpecs where Self: XCTestCase {
	func assertThatRetrieveDeliversFailureOnRetrievalError<SUT: Store>(on sut: SUT, file: StaticString = #filePath, line: UInt = #line) where SUT.Local == LocalFeedImage {
		expect(sut, toRetrieve: .failure(anyNSError()), file: file, line: line)
	}

	func assertThatRetrieveHasNoSideEffectsOnFailure<SUT: Store>(on sut: SUT, file: StaticString = #filePath, line: UInt = #line) where SUT.Local == LocalFeedImage {
		expect(sut, toRetrieveTwice: .failure(anyNSError()), file: file, line: line)
	}
}
