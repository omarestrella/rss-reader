//
//  FeedView.swift
//  RSSReader
//
//  Created by Omar Estrella on 2/24/21.
//

import FeedKit
import ReadabilityKit
import SwiftUI

class SourceViewModel: ObservableObject {
  @Published var state = FeedState.Loading
  @Published var feed: Feed?
  @Published var loading = false
  @Published var feedItems = [FeedItem]()

  var source: Source

  init(source: Source) {
    self.source = source
  }

  func loadFeedItems(store: Store) {
    loading = true
    store.feedItems(source: source)
      .then { self.feedItems.append(contentsOf: $0) }
      .always {
        self.loading = false
      }
  }
}

struct SourceItemView: View {
  @State var feed: FeedItem

  var body: some View {
    BrowserView(text: feed.content)
  }
}

struct SourceView: View {
  @EnvironmentObject var store: Store
  @ObservedObject var model: SourceViewModel

  init(source: Source) {
    model = SourceViewModel(source: source)
  }
  
  var sortedItems: [FeedItem] {
    model.feedItems.sorted(by: { a, b in
      if let aDate = a.pubDate, let bDate = b.pubDate {
        if aDate < bDate {
          return false
        }
        return true
      }
      return false
    })
  }

  var body: some View {
    List {
      if model.loading {
        Text("")
      } else {
        ForEach(sortedItems, id: \.id) { item in
          NavigationLink(destination: SourceItemView(feed: item), label: {
            VStack {
              HStack {
                VStack(alignment: .leading) {
                  Text(item.title)
                    .font(.system(size: 13))
                    .bold()
                  Text(item.content)
                    .lineLimit(1)
                    .font(.callout)
                }
              }
            }
          })
        }
      }
    }
    .frame(minWidth: 300)
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button(action: {}, label: {
          Label("Reload", systemImage: "arrow.clockwise.circle")
            .labelStyle(IconOnlyLabelStyle())
        })
      }

      ToolbarItem(placement: .principal) {
        if store.loading {
          Text("Loading")
        } else {
          Text(store.currentSource?.name ?? "")
        }
      }
    }
    .onAppear {
      model.loadFeedItems(store: store)
    }
  }
}

// #if DEBUG
// struct SourceView_Previews: PreviewProvider {
//  static var previews: some View {
//    SourceView()
//  }
// }
// #endif
