//
//  Store.swift
//  RSSReader (iOS)
//
//  Created by Omar Estrella on 2/16/21.
//

import Combine
import FeedKit
import Foundation
import Promises
import SwiftUI

struct Notification {
  enum NotificationType {
    case Error
  }

  var id = UUID()
  let type: NotificationType

  init(type: NotificationType) {
    self.type = type
  }
}

struct TwitterConfig {
  let apiKey = "3M3rmTRcsGZvDhWUyxp9htiEx"
  let secret = "d7TerdncRZRUeBis8GZDA7pLMG7seSJU94lkSX38YYmEo4G8jN"
  let bearerToken = "AAAAAAAAAAAAAAAAAAAAAFV3MwEAAAAAD0dB0oj51%2Ba85bHhQJd5XWxzoqo%3DpL8e88281TtyzbJE9HpCoTfz9ett0qFNZTfp9B75ob4JEPMWll"
}

enum FeedState {
  case Loading
  case Loaded(_ feed: Feed)
  case Error(_ error: Error)
}

func load(feedUrl: String) -> Promise<Feed> {
  guard let url = URL(string: feedUrl) else {
    return Promise(Store.StoreError.FeedError)
  }
  let parser = FeedParser(URL: url)
  return Promise { resolve, reject in
    parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { result in
      switch result {
      case let .failure(parseError):
        reject(parseError)
      case let .success(feed):
        resolve(feed)
      }
    }
  }
}

class Store: ObservableObject {
  enum StoreError: Error {
    case FeedError
    case FeedParseError(_ reason: String? = nil)
  }

  @Published var sources = [Source]()
  @Published var categories = [Category]()

  @Published var currentSource: Source?
  @Published var currentRSSFeedItem: RSSFeedItem?

  @Published var loading = false

  @AppStorage("initialized") private var initializeStore = "no"

  var database: DatabaseManager

  var initialized: Bool {
    get {
      initializeStore == "yes"
    }
    set {
      if newValue {
        initializeStore = "yes"
      } else {
        initializeStore = "no"
      }
    }
  }

  init() {
    loading = true
    database = DatabaseManager()
    _ = database.initialize().then {
      self.database.getCategories()
    }.then { categories -> Promise<[Category]> in
      if categories.isEmpty {
        let defaultCategory = Category(name: "Default")
        defaultCategory.isDefault = true
        self.database.save(category: defaultCategory)
          .then { _ in self.database.getCategories() }
      }
      return Promise(categories)
    }.then { categories in
      self.categories.append(contentsOf: categories)
      categories.forEach { category in
        self.sources.append(contentsOf: category.sources)
      }
    }.catch { error in
      debugPrint("Error:", error)
    }.always {
      self.loading = false
    }
  }

  func add(category: Category) {
    categories.append(category)
  }

  func add(url: String, feed: Feed, category: Category? = nil) -> Promise<Source> {
    if initialized == true {
      initialized = false
    }
    var possibleCategory = category
    if category == nil {
      possibleCategory = categories.first(where: { $0.isDefault })
    }
    
    guard let category = possibleCategory else { return Promise(StoreError.FeedParseError("Default Category Not Found")) }
    do {
      let source = try Source(feed: feed, feedUrl: url)
      source._feed = feed
      return database.add(source: source, category: category).then {
        self.sources.append(source)
        return Promise(source)
      }.catch { error in
        debugPrint("ERROR:", error)
      }
    } catch {
      return Promise(error)
    }
  }

  func remove(source: Source) {
    sources.removeAll(where: { $0.id == source.id })
    _ = database.delete(source: source)
  }

  func remove(source: Source, category _: Category) {
    sources.removeAll(where: { $0.id == source.id })
  }

  func loadFeed(feedUrl: String) -> Promise<Feed> {
    load(feedUrl: feedUrl)
  }

  func feedItems(source: Source) -> Promise<[FeedItem]> {
    database.feedItems(source: source)
  }
}
