//
//  Category.swift
//  RSSReader
//
//  Created by Omar Estrella on 2/22/21.
//

import Foundation
import FluentKit

final class Category: Model, Hashable {
  static let schema = "category"
  
  @ID(key: .id)
  var id: UUID?
  
  @Field(key: "name") var name: String
  
  @OptionalField(key: "icon") var icon: String?
  
  @Field(key: "is_default") var isDefault: Bool
  
  @Timestamp(key: "created_at", on: .create, format: .iso8601) var createdAt: Date?
  @Timestamp(key: "updated_at", on: .update, format: .iso8601) var updatedAt: Date?
  
  @Children(for: \.$category) var sources: [Source]
  
  init() {}

  init(name: String, isDefault: Bool = false, icon: String? = nil) {
    self.name = name
    self.icon = icon
    self.isDefault = isDefault
  }
  
  func hash(into hasher: inout Hasher) {
    if let id = id {
      hasher.combine(id)
    } else {
      hasher.combine(name)
    }
  }

  static func ==(lhs: Category, rhs: Category) -> Bool {
    if let lid = lhs.id, let rid = rhs.id {
      return lid == rid
    }
    return lhs.name == rhs.name
  }
}
