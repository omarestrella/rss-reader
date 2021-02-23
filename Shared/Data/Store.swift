//
//  Store.swift
//  RSSReader (iOS)
//
//  Created by Omar Estrella on 2/16/21.
//

import Combine
import Foundation
import SwiftUI

final class Source: Identifiable, Hashable {
  enum SourceType {
    case RSS
  }
  
  var id = UUID()
  var name: String
  var type: SourceType
  
  // For disclosure group nonsense
  var sources: [Source]? = nil
  
  init(name: String, type: SourceType) {
    self.name = name
    self.type = type
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id.uuidString)
  }

  static func ==(lhs: Source, rhs: Source) -> Bool {
    lhs.id == rhs.id
  }
}

final class Category: Hashable, Identifiable {
  var id = UUID()
  var name: String
  var icon: String?
  var sources: [Source]?
  var isDefault = false

  init(name: String, icon: String? = nil) {
    self.name = name
    self.icon = icon
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id.uuidString)
  }

  static func ==(lhs: Category, rhs: Category) -> Bool {
    lhs.id == rhs.id
  }
}

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

class Store: ObservableObject {
  @Published var sources = [Source]()
  @Published var categories = [Category]()
//  @Published var
  
  @Published var currentSource: Source?
  
  @AppStorage("initialized") private var initializeStored = "no"
  
  var initialized: Bool {
    get {
      initializeStored == "yes"
    }
    set {
      if newValue {
        initializeStored = "yes"
      } else {
        initializeStored = "no"
      }
    }
  }

  init() {
    let defaultCategory = Category(name: "Uncategorized")
    defaultCategory.isDefault = true
    categories.append(defaultCategory)
  }

  func add(category: Category) {
    categories.append(category)
  }
}
