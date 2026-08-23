//
//  Copyright © Essential Developer. All rights reserved.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedItem], Error>

protocol FeedLoader {
	func load(completion: @escaping (LoadFeedResult) -> Void)
}
