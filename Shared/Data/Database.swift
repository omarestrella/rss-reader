//
//  Database.swift
//  RSSReader
//
//  Created by Omar Estrella on 2/17/21.
//

import FluentKit
import FluentSQL
import FluentSQLiteDriver
import Foundation
import Promises

enum DatabaseError: Error {
  case DatabaseFileNotFound
  case NoConnection
  case NotFound
  case NoMangaId
}

func databaseUrl() -> URL? {
  let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
  if let url = urls.first {
    let finalUrl = url.appendingPathComponent("db.sqlite")
    return finalUrl
  }
  return nil
}

struct DatabaseManager {
  var databases: Databases
  var threadpool: NIOThreadPool
  var eventLoopGroup: MultiThreadedEventLoopGroup
  var migrator: Migrator

  init() {
    threadpool = NIOThreadPool(numberOfThreads: 2)
    eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 2)
    threadpool.start()
    databases = Databases(threadPool: threadpool, on: eventLoopGroup)

    do {
      guard let path = databaseUrl() else {
        throw DatabaseError.DatabaseFileNotFound
      }
      let config: SQLiteConfiguration = .file(path.absoluteString)

      print("Using database: \(path)")

      databases.use(.sqlite(config), as: .sqlite)
    } catch {
      print("Error loading database. Using in-memory database: \(error)")
      databases.use(.sqlite(.memory), as: .sqlite)
    }

    databases.default(to: .sqlite)

    let migrations = Migrations()
    migrations.add([
      CreateTablesMigration(),
      CreateFeedItemSchema()
    ])
    migrator = Migrator(databases: databases, migrations: migrations, logger: .init(label: "database.migrator"), on: eventLoopGroup.next())
  }

  var database: FluentKit.Database? {
    databases.database(logger: .init(label: "database"), on: eventLoopGroup.next())
  }

  func initialize() -> Promise<Void> {
    do {
      try migrator.setupIfNeeded().wait()
      try migrate()
      return Promise(())
    } catch {
      return Promise(error)
    }
  }

  func save(category: Category) -> Promise<Category> {
    guard let db = database else {
      return Promise(DatabaseError.NoConnection)
    }
    return Promise { resolve, reject in
      category.save(on: db)
        .whenComplete { result in
          switch result {
          case .success:
            resolve(category)
          case let .failure(error):
            reject(error)
          }
        }
    }
  }

  func add(source: Source, category: Category) -> Promise<Void> {
    guard let db = database else {
      return Promise(DatabaseError.NoConnection)
    }
    return Promise { resolve, reject in
      do {
        try category.$sources.create(source, on: db).wait()
        if let items = source._feed?.rssFeed?.items {
          let feedItems = items.map {
            FeedItem(feedItem: $0)
          }
          try source.$feedItems.create(feedItems, on: db).wait()
        }
        resolve(())
      } catch {
        reject(error)
      }
    }
  }
  
  func delete(source: Source) -> Promise<Void> {
    guard let db = database else {
      return Promise(DatabaseError.NoConnection)
    }
    return Promise { resolve, reject in
      do {
        let feedItems = try source.$feedItems.query(on: db).all().wait()
        try feedItems.delete(on: db).wait()
        try source.delete(on: db).wait()
        resolve(())
      } catch {
        reject(error)
      }
    }
  }

  func getCategories() -> Promise<[Category]> {
    guard let db = database else {
      return Promise(DatabaseError.NoConnection)
    }
    return Promise { resolve, reject in
      Category.query(on: db).with(\.$sources) { source in
        source
          .with(\.$category)
//          .with(\.$feedItems)
      }.all().whenComplete { result in
        switch result {
        case let .success(categories):
          resolve(categories)
        case let .failure(error):
          reject(error)
        }
      }
    }
  }

  private func migrate() throws {
    let migrations = try migrator.previewPrepareBatch().wait()
    guard migrations.count > 0 else {
      print("No new migrations.")
      return
    }
    print("The following migration(s) will be prepared:")
    let logs = migrations.map { (migration, dbid) -> String in
      let name = dbid?.string ?? "default"
      return "+ \(migration.name) on \(name)"
    }
    print("\(logs.joined(separator: "\n"))")
    try migrator.prepareBatch().wait()
    print("Migration successful")
  }
}
