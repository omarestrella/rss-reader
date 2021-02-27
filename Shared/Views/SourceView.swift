//
//  FeedView.swift
//  RSSReader
//
//  Created by Omar Estrella on 2/24/21.
//

import SwiftUI
import FeedKit

class SourceViewModel: ObservableObject {
  enum FeedState {
    case Loading
    case Error
    case Loaded(feed: Feed)
  }
  
  @Published var state = FeedState.Loading
  
  var source: Source
  
  init(source: Source) {
    self.source = source
    
    self.source.feed.then { feed in
      self.state = .Loaded(feed: feed)
    }
  }
  
  var loading: Bool {
    switch state {
    case .Loading:
      return true
    default:
      return false
    }
  }
  
  var rssFeed: RSSFeed {
    let defaultFeed = RSSFeed()
    switch state {
    case .Loaded(let feed):
      if let rss = feed.rssFeed {
        return rss
      }
      return defaultFeed
    default:
      return defaultFeed
    }
  }
}

struct SourceView: View {
  @EnvironmentObject var store: Store
  @ObservedObject var model: SourceViewModel
  
  init(source: Source) {
    self.model = SourceViewModel(source: source)
  }

  var body: some View {
    List {
      if model.loading {
        Text("Loading?")
      } else {
        ForEach(model.rssFeed.items ?? [], id: \.title) { (item: RSSFeedItem) in
          NavigationLink(destination: Text(item.title ?? ""), label: {
            Text(item.title ?? "")
          })
        }
      }
    }
  }
}

//#if DEBUG
//struct SourceView_Previews: PreviewProvider {
//  static var previews: some View {
//    SourceView()
//  }
//}
//#endif
