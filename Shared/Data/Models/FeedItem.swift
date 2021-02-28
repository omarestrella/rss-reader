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
  @Field(key: "content") var content: String
  @Field(key: "pub_date") var pubDate: Date?
  @OptionalField(key: "description") var desc: String?
  @OptionalField(key: "author") var author: String?
  @OptionalField(key: "comments") var comments: String?
  @OptionalField(key: "guid") var guid: String?
  
  @Timestamp(key: "created_at", on: .create, format: .iso8601) var createdAt: Date?
  @Timestamp(key: "updated_at", on: .update, format: .iso8601) var updatedAt: Date?
  
  @Parent(key: "source_id") var source: Source
  
  init() {}
  
  init(feedItem: RSSFeedItem) {
    title = feedItem.title ?? "Empty Title"
    link = feedItem.link ?? "Empty Link"
    pubDate = feedItem.pubDate ?? Date()
    author = feedItem.author
    comments = feedItem.comments
    guid = feedItem.guid?.value
    
    if let feedContent = feedItem.content, let encoded = feedContent.contentEncoded {
      content = encoded
    } else if let feedDescription = feedItem.description {
      content = feedDescription
    } else {
      content = "Empty Content"
    }
    
    desc = feedItem.description
  }
  
  init(feedItem: AtomFeedEntry) {
    title = feedItem.title ?? "Empty Title"
    link = feedItem.links?.first?.attributes?.href ?? "Empty Link"
    pubDate = feedItem.published ?? feedItem.updated ?? Date()
    author = feedItem.authors?.first?.name
    comments = nil
    guid = feedItem.id
    
    if let feedContent = feedItem.content, let value = feedContent.value {
      content = value
    } else if let feedContent = feedItem.summary, let value = feedContent.value {
      content = value
    }
    
    desc = feedItem.summary?.value
  }
  
  init(feedItem: JSONFeedItem) {
    title = feedItem.title ?? "Empty Title"
    link = feedItem.url ?? "Empty Link"
    pubDate = feedItem.datePublished ?? Date()
    author = feedItem.author?.name
    comments = nil
    guid = feedItem.id
    
    if let feedContent = feedItem.contentHtml {
      content = feedContent
    } else if let feedContent = feedItem.contentText {
      content = feedContent
    } else {
      content = "Empty Content"
    }
    
    desc = feedItem.contentHtml ?? feedItem.contentText
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
