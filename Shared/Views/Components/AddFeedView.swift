//
//  AddFeedView.swift
//  RSSReader (macOS)
//
//  Created by Omar Estrella on 2/26/21.
//

import FeedKit
import SwiftUI

class AddFeedViewModel: ObservableObject {
  @Published var feedState: FeedState?

  @Published var feedUrl: String {
    didSet {
      feedState = .Loading
      store.loadFeed(feedUrl: feedUrl).then { feed in
        self.feedState = .Loaded(feed)
      }.catch { error in
        self.feedState = .Error(error)
      }
    }
  }

  let store: Store

  init(store: Store) {
    feedState = nil
    feedUrl = ""
    self.store = store
  }

  var isLoading: Bool {
    switch feedState {
    case .Loading:
      return true
    default:
      return false
    }
  }

  var isLoaded: Bool {
    switch feedState {
    case .Loaded:
      return true
    default:
      return false
    }
  }

  var feed: Feed? {
    switch feedState {
    case let .Loaded(feed):
      return feed
    default:
      return nil
    }
  }
}

struct AddFeedView: View {
  @ObservedObject var store: Store
  @ObservedObject var model: AddFeedViewModel

  @Environment(\.presentationMode) var presentationMode

  init(store: Store) {
    self.store = store
    model = AddFeedViewModel(store: store)
  }

  var body: some View {
    VStack {
      HStack {
        Text("Add Feed")
          .font(.largeTitle)
          .bold()
          .padding(.bottom, 3)

        Spacer()
      }

      if !store.initialized {
        Text("Welcome to Columns, a simple RSS reader. Let's get you started by adding a new feed to follow.")
          .font(.callout)
          .multilineTextAlignment(.center)
          .fixedSize(horizontal: false, vertical: true)
          .padding(.bottom, 3)
      }

      VStack {
        FeedURLInput(value: $model.feedUrl, submit: {}) {
          HStack {
            Text("URL").font(.caption).bold().offset(x: 0, y: 5)
          }
        }.textFieldStyle(PlainTextFieldStyle())
      }.padding(.bottom)

      HStack {
        Spacer()

        Button(action: {
          presentationMode.wrappedValue.dismiss()
        }, label: {
          Text("Cancel")
            .foregroundColor(.red)
        }).keyboardShortcut(.cancelAction)

        Button(action: {
          if let feed = model.feed {
            store.add(url: model.feedUrl, feed: feed).then { source in
              if store.currentSource == nil {
                store.currentSource = source
              }
              presentationMode.wrappedValue.dismiss()
            }.catch { error in
              debugPrint("AddFeedView Add Feed:", error)
            }
          }
        }, label: {
          Text("Add")
        })
          .keyboardShortcut(.return)
          .disabled(!model.isLoaded)
      }
    }
  }
}

#if DEBUG
struct AddFeedView_Previews: PreviewProvider {
  static var previews: some View {
    AddFeedView(store: Store())
  }
}
#endif
