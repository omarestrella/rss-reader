//
//  FeedView.swift
//  RSSReader
//
//  Created by Omar Estrella on 2/24/21.
//

import FeedKit
import SwiftSoup
import SwiftUI

class SourceViewModel: ObservableObject {
  @Published var state = FeedState.Loading
  @Published var feed: Feed?
  @Published var loading = false
  @Published var loaded = false
  @Published var feedItems = [FeedItem]()

  var source: Source

  init(source: Source) {
    self.source = source
  }

  func loadFeedItems(store: Store) {
    if loaded {
      return
    }
    loading = true
    store.feedItems(source: source)
      .then { items in
        let filtered = items.filter { !self.feedItems.contains($0) }
        self.feedItems.append(contentsOf: filtered)
      }
      .always {
        self.loaded = true
        self.loading = false
      }
  }
}

struct SourceItemView: View {
  @State var item: FeedItem

  var body: some View {
    HStack {
      BrowserView(text: item.content)
        .navigationTitle(item.title)
    }
  }
}

struct SourceItemListView: View {
  var item: FeedItem

  var body: some View {
    HStack(alignment: .top) {
      VStack(alignment: .leading) {
        Text(item.title)
          .font(.system(size: 13))
          .bold()
        Text(trimmedDescription)
          .lineLimit(2)
          .font(.callout)
      }
    }
  }

  var trimmedDescription: String {
    let size = 150
    if description.count > size {
      let range = description.index(description.startIndex, offsetBy: 0) ..< description.index(description.startIndex, offsetBy: size)
      return String(description[range])
    }
    return description
  }

  var description: String {
    if item.desc != item.content, let html = try? SwiftSoup.parse(item.desc ?? ""), let text = try? html.text() {
      return text
    }
    if let html = try? SwiftSoup.parse(item.content) {
      if let img = try? html.getElementsByTag("img"), let title = try? img.attr("title"), !title.isEmpty {
        return title
      }
      if let text = try? html.text() {
        return text
      }
      return item.content
    }
    return item.content
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
    if model.loading {
      VStack {
        ProgressView()
          .progressViewStyle(CircularProgressViewStyle())
      }
    } else {
      List {
        ForEach(sortedItems, id: \.id) { item in
          NavigationLink(destination: SourceItemView(item: item), tag: item, selection: $store.currentFeedItem) {
            SourceItemListView(item: item)
          }
        }
      }
      .navigationTitle(Text(model.source.name))
      .navigationBarTitleDisplayMode(.inline)
      .frame(minWidth: 300)
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button(action: {}, label: {
            Label("Reload", systemImage: "arrow.clockwise.circle")
              .labelStyle(IconOnlyLabelStyle())
          })
        }
      }
      .onAppear {
        DispatchQueue.main.async {
          model.loadFeedItems(store: store)
        }
      }
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
