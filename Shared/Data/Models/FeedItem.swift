//
//  File.swift
//  RSSReader
//
//  Created by Omar Estrella on 2/27/21.
//

import Foundation
import FluentKit
import FeedKit

final class FeedItem: Model, Hashable {
  static let schema = "feed_item"
  
  enum FeedItemType: String, Codable {
    case RSS
  }
  
  @ID(key: .id) var id: UUID?
  
  @Field(key: "title") var title: String
  @Field(key: "link") var link: String
  @Field(key: "description") var description: String
  @Field(key: "pub_date") var pubDate: Date?
  @OptionalField(key: "author") var author: String?
  @OptionalField(key: "comments") var comments: String?
  @OptionalField(key: "guid") var guid: String?
  
  @Timestamp(key: "created_at", on: .create, format: .iso8601) var createdAt: Date?
  @Timestamp(key: "updated_at", on: .update, format: .iso8601) var updatedAt: Date?
  
  @Parent(key: "source_id") var source: Source
  
  init() {}
  
  init(feedItem: RSSFeedItem) {
    title = feedItem.title ?? "TITLE ERROR"
    link = feedItem.link ?? "LINK ERROR"
    description = feedItem.description ?? "DESCRIPTION ERROR"
    pubDate = feedItem.pubDate ?? Date()
    author = feedItem.author
    comments = feedItem.comments
    guid = feedItem.guid?.value
  }
  
  func hash(into hasher: inout Hasher) {
    if let id = id {
      hasher.combine(id.uuidString)
    } else {
      hasher.combine(title)
    }
  }

  static func ==(lhs: FeedItem, rhs: FeedItem) -> Bool {
    lhs.id == rhs.id
  }
}
