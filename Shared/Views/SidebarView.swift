//
//  NavigationListView.swift
//  RSSReader (macOS)
//
//  Created by Omar Estrella on 2/16/21.
//

import FeedKit
import SwiftUI

struct CategorySectionView: View {
  @EnvironmentObject var store: Store

  var category: Category
  var onDelete: (_: IndexSet, _: Category) -> Void

  @State var expanded: Bool = false
  @State var currentSource: Source?

  init(category: Category, onDelete: @escaping (_: IndexSet, _: Category) -> Void) {
    self.category = category
    self.onDelete = onDelete
  }

  var body: some View {
    if category.sources.isEmpty == true {
      Button(action: {}, label: {
        Text("Add new source")
      })
    } else {
      DisclosureGroup(isExpanded: $expanded, content: {
        ForEach(category.sources, id: \.self) { source in
          NavigationLink(destination: Text("Source: \(source.name) \(source.feedUrl)"), tag: source, selection: $currentSource) {
            Text(source.name)
          }
        }.onDelete(perform: {
          onDelete($0, category)
        })
      }, label: {
        Text(category.name)
      })
    }
  }
}

struct SidebarView: View {
  @EnvironmentObject var store: Store

  @State var addingNewFeed = false

  var body: some View {
    VStack {
      if !store.sources.isEmpty {
        List(store.sources, id: \.id) { source in
          NavigationLink(destination: SourceView(source: source), tag: source, selection: $store.currentSource) {
            Text(source.name)
          }.contextMenu {
            Button(action: {
              if let currentSource = store.currentSource, currentSource == source {
                store.currentSource = nil
              }
              store.remove(source: source)
            }, label: {
              Text("Delete")
            })
          }
        }
      } else {
        EmptyView()
        Spacer()
      }

      #if os(macOS)
      HStack(alignment: .center) {
        Button(action: {
          addingNewFeed.toggle()
        }, label: {
          Label("Add a Feed", systemImage: "plus.circle")
        }).buttonStyle(LinkButtonStyle())
      }.padding(.bottom)
      #endif
    }.sheet(isPresented: $addingNewFeed) {
      AddFeedView(store: store)
        .padding()
        .frame(minWidth: 300, maxWidth: 300)
    }
  }

  func onDelete(index: IndexSet, category: Category) {
    if let idx = index.first {
      let source = category.sources[idx]
      store.remove(source: source, category: category)
    }
  }
}

#if DEBUG
struct NavigationListView_Previews: PreviewProvider {
  static var previews: some View {
    SidebarView()
  }
}
#endif
