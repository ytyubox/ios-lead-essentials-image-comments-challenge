//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyData() -> Data {
    return Data("any data".utf8)
}

func anyUUID() -> String {
    UUID().uuidString
}

func dateStringToDate(_ string: String) throws -> Date {
    let jsonString =
        """
        	{ "date": "\(string)" }
        """
    let json = jsonString.data(using: .utf8)!
    let decoder = JSONDecoder()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    decoder.dateDecodingStrategy = .formatted(dateFormatter)
    let date = try decoder.decode(DateModel.self, from: json).date
    print(date.timeIntervalSince1970)
    return date
}

private struct DateModel: Decodable {
    let date: Date
}
