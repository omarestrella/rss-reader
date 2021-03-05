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
    case Atom
    case JSON
  }
  
  enum SourceError: Error {
    case NoFeedFound
    case ParseError
  }
  
  @ID(key: .id) var id: UUID?
  
  @Field(key: "name") var name: String
  @Field(key: "feed_id") var feedId: String
  @Field(key: "feed_url") var feedUrl: String
  @Field(key: "link") var link: String
  @Field(key: "type") var type: SourceType
  @OptionalField(key: "icon") var icon: String?
  
  @Parent(key: "category_id") var category: Category
  
  @Timestamp(key: "created_at", on: .create, format: .iso8601) var createdAt: Date?
  @Timestamp(key: "updated_at", on: .update, format: .iso8601) var updatedAt: Date?
  
  @Children(for: \.$source) var feedItems: [FeedItem]
  
  init() {}
  
  init(name: String, feedUrl: String, link: String, type: SourceType = .RSS) {
    self.name = name
    self.feedUrl = feedUrl
    self.link = link
    self.type = type
  }
  
  init(feed: Feed, feedUrl: String) throws {
    guard let link = getLink(feed) else { throw SourceError.ParseError }
    let name = getName(feed)
    let id = getId(feed)
    let type = getType(feed)
    let icon = getIcon(feed)
    
    self.name = name
    self.feedId = id
    self.link = link
    self.feedUrl = feedUrl
    self.type = type
    self.icon = icon
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

func getType(_ feed: Feed) -> Source.SourceType {
  switch feed {
  case .atom(_):
    return .Atom
  case .rss(_):
    return .RSS
  case .json(_):
    return .JSON
  }
}

func getName(_ feed: Feed) -> String {
  let defaultTitle = "Empty Title"
  switch feed {
  case .atom(let atom):
    if let title = atom.title {
      return title
    }
    return defaultTitle
  case .json(let json):
    if let title = json.title {
      return title
    }
    return defaultTitle
  case .rss(let rss):
    if let title = rss.title {
      return title
    }
    return defaultTitle
  }
}

func getLink(_ feed: Feed) -> String? {
  switch feed {
  case .atom(let atom):
    guard let links = atom.links else { return nil }
    return links.first?.attributes?.href
  case .json(let json):
    return json.homePageURL ?? json.feedUrl
  case .rss(let rss):
    return rss.link
  }
}

func getId(_ feed: Feed) -> String {
  let defaultId = UUID().uuidString
  switch feed {
  case .atom(let atom):
    if let id = atom.id {
      return id
    }
    if let title = atom.title, let subtitle = atom.subtitle?.value {
      return title + subtitle
    }
    return defaultId
  case .json(let json):
    if let id = json.version, let title = json.title {
      return id + title
    }
    return defaultId
  case .rss(let rss):
    if let title = rss.title, let description = rss.description {
      return title + description
    }
    return defaultId
  }
}

func getIcon(_ feed: Feed) -> String? {
  switch feed {
  case .json(let json):
    return json.icon
  case .rss(let rss):
    return rss.image?.url
  case .atom(let atom):
    return atom.icon
  }
}
