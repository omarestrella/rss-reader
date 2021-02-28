//
//  CreateTablesMigration.swift
//  RSSReader
//
//  Created by Omar Estrella on 2/22/21.
//

import FluentKit
import Foundation

struct CreateTablesMigration: Migration {
  func prepare(on database: Database) -> EventLoopFuture<Void> {
    let categorySchema = database.schema(Category.schema)
      .id()
      .field("name", .string, .required)
      .field("icon", .string)
      .field("is_default", .bool)
      .field("created_at", .string)
      .field("updated_at", .string)
      .ignoreExisting()
      .create()
    
    let sourceSchema = database.schema(Source.schema)
      .id()
      .field("name", .string, .required)
      .field("link", .string, .required)
      .field("feed_url", .string, .required)
      .field("feed_id", .string, .required)
      .field("type", .string, .required)
      .field("icon", .string)
      .field("category_id", .uuid, .required, .references("category", "id"))
      .field("created_at", .string)
      .field("updated_at", .string)
      .ignoreExisting()
      .create()

    return database.eventLoop.flatten([
      categorySchema,
      sourceSchema
    ])
  }

  func revert(on database: Database) -> EventLoopFuture<Void> {
    database.schema(Category.schema).delete()
  }
}
