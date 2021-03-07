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
  enum FeedItems {
    case Empty
    case Loading
    case Loaded(feedItems: [FeedItem])
  }
  
  @Published var feedItems = FeedItems.Empty
  
  var sortedItems: [FeedItem] {
    switch feedItems {
    case .Empty:
      return []
    case .Loading:
      return []
    case .Loaded(let items):
      return items.sorted(by: { a, b in
        if let aDate = a.pubDate, let bDate = b.pubDate {
          if aDate < bDate {
            return false
          }
          return true
        }
        return false
      })
    }
  }

  func load(store: Store, source: Source) {
    feedItems = .Loading
    store.feedItems(source: source).then { items in
      self.feedItems = .Loaded(feedItems: items)
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
  @StateObject var model = SourceViewModel()

  var source: Source

  var body: some View {
    List {
      ForEach(model.sortedItems, id: \.id) { item in
        NavigationLink(destination: SourceItemView(item: item), tag: item, selection: $store.currentFeedItem) {
          SourceItemListView(item: item)
        }
      }
    }
    .navigationTitle(Text(source.name))
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button(action: {}, label: {
          Label("Reload", systemImage: "arrow.clockwise.circle")
            .labelStyle(IconOnlyLabelStyle())
        })
      }
    }
    .onAppear {
      model.load(store: store, source: source)
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
