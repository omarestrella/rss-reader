//
//  CreateTablesMigration.swift
//  RSSReader
//
//  Created by Omar Estrella on 2/22/21.
//

import FluentKit
import Foundation

struct CreateFeedItemSchema: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    let feedItemSchema = database.schema(FeedItem.schema)
      .id()
      .field("title", .string, .required)
      .field("link", .string, .required)
      .field("content", .string, .required)
      .field("pub_date", .datetime, .required)
      .field("description", .string)
      .field("author", .string)
      .field("comments", .string)
      .field("guid", .string)
      .field("source_id", .uuid, .required, .references(Source.schema, "id"))
      .field("created_at", .string)
      .field("updated_at", .string)
      .unique(on: "title", "link", name: "no_duplicate_feed_items")
      .ignoreExisting()
      .create()

    return feedItemSchema
  }

  func revert(on database: Database) -> EventLoopFuture<Void> {
    database.schema(FeedItem.schema).delete()
  }
}
