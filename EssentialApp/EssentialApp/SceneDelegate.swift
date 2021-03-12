//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import EssentialFeed
import UIKit

protocol Root {
	func makeRootViewController() -> UIViewController
	func validateCache()
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
	var root: Root = Container(httpClient: makeHTTPClient(),
							   store: AppFeedStoreAdapter())
	convenience init(root: Root) {
		self.init()
		self.root = root
	}

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: scene)
        configureWindow()
    }

    func configureWindow() {
		window?.rootViewController = root.makeRootViewController()
        window?.makeKeyAndVisible()
    }

    func sceneWillResignActive(_: UIScene) {
		root.validateCache()
    }
}

func makeHTTPClient() -> HTTPClient {
	   URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
}
