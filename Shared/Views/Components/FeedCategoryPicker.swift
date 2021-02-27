//
//  FeedCategoryPicker.swift
//  RSSReader
//
//  Created by Omar Estrella on 2/22/21.
//

import SwiftUI

struct FeedCategoryPicker: View {
  @EnvironmentObject var store: Store

  @Binding var category: Category?

  var body: some View {
    Section(header: Text("Category").font(.caption).bold()) {
      Picker(selection: $category, label: Group {
        if let category = category {
          Text(category.name)
        } else {
          Text("Default")
        }
      }) {
        ForEach(store.categories, id: \.self) { c in
          Text(c.name)
        }
      }
    }
  }
}

#if DEBUG
struct FeedCategoryPicker_Previews: PreviewProvider {
  static var previews: some View {
    FeedCategoryPicker(category: .constant(nil))
  }
}
#endif
