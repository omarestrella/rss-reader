//
//  NavigationListView.swift
//  RSSReader (macOS)
//
//  Created by Omar Estrella on 2/16/21.
//

import SwiftUI

enum MenuSelection {
  case First
  case Second
  case Third
}

struct CategorySectionView: View {
  @EnvironmentObject var store: Store
  @State var category: Category
  
  var body: some View {
    if category.sources?.isEmpty == true {
      Button(action: {}, label: {
        Text("Add new source")
      })
    } else {
      OutlineGroup(category.sources ?? [], children: \.sources) { source in
        NavigationLink(destination: Text("Source: \(source.name)"), tag: source, selection: $store.currentSource) {
          Text(source.name)
        }
      }
    }
  }
}

struct NavigationListView: View {
  @EnvironmentObject var store: Store

  var body: some View {
    List {
      ForEach(store.categories, id: \.id) { category in
        Section(header: Text(category.name)) {
          CategorySectionView(category: category)
        }
      }
    }
  }
}

#if DEBUG
struct NavigationListView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationListView()
  }
}
#endif
