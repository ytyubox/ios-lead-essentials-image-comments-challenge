import LoadingSystem
public typealias FeedViewModel = ItemsViewModel<FeedImage>

//public struct FeedViewModel {
//    public let feed: [FeedImage]
//}
extension FeedViewModel {
    public init(feed: [FeedImage]) {
        self.init(items: feed)
    }
    public var feed: [FeedImage] {
        self.items
    }
}
