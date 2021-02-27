//
//  Feed.swift
//  RSSReader
//
//  Created by Omar Estrella on 2/24/21.
//

import Foundation
import FluentKit
import FeedKit
import Promises


final class Source: Model, Hashable {  
  static let schema = "source"
  
  enum SourceType: String, Codable {
    case RSS
  }
  
  @ID(key: .id) var id: UUID?
  
  @Field(key: "name") var name: String
  @Field(key: "feed_url") var feedUrl: String
  @Field(key: "link") var link: String
  @Field(key: "type") var type: SourceType
  @Parent(key: "category_id") var category: Category
  
  @Timestamp(key: "created_at", on: .create, format: .iso8601) var createdAt: Date?
  @Timestamp(key: "updated_at", on: .update, format: .iso8601) var updatedAt: Date?
  
  init() {}
  
  init(name: String, feedUrl: String, link: String, type: SourceType = .RSS) {
    self.name = name
    self.feedUrl = feedUrl
    self.link = link
    self.type = type
  }
  
  var _feed: Feed?
  var feed: Promise<Feed> {
    get {
      if let feed = _feed {
        return Promise(feed)
      }
      return load(feedUrl: feedUrl).then { feed -> Promise<Feed> in
        self._feed = feed
        return Promise(feed)
      }
    }
  }
  
  func hash(into hasher: inout Hasher) {
    if let id = id {
      hasher.combine(id.uuidString)
    } else {
      hasher.combine(feedUrl)
    }
  }

  static func ==(lhs: Source, rhs: Source) -> Bool {
    lhs.id == rhs.id
  }
}
