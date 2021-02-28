//
//  FeedView.swift
//  RSSReader
//
//  Created by Omar Estrella on 2/24/21.
//

import SwiftUI
import FeedKit

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
    self.loading = true
    store.feedItems(source: source)
      .then { self.feedItems.append(contentsOf: $0) }
      .always {
        self.loading = false
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
        Text("Syncing?")
      } else {
        ForEach(model.feedItems, id: \.id) { item in
          NavigationLink(destination: ScrollView { Text("FEED") }, label: {
            VStack {
              HStack {
                VStack(alignment: .leading) {
                  Text(item.title)
                    .font(.callout)
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
    }.onAppear {
      model.loadFeedItems(store: store)
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
