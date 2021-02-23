//
//  IntroViewMobile.swift
//  RSSReader (iOS)
//
//  Created by Omar Estrella on 2/17/21.
//

import FeedKit
import SwiftUI

enum FeedURLState: Equatable {
  case None
  case Loading
  case Ok(feed: Feed)
  case Error(message: String)

  static func == (lhs: FeedURLState, rhs: FeedURLState) -> Bool {
    switch (lhs, rhs) {
    case (.None, .None), (.Loading, .Loading):
      return true
    case let (.Ok(lhsFeed), .Ok(rhsFeed)):
      return equalFeeds(a: lhsFeed, b: rhsFeed)
    case let (.Error(msgA), .Error(msgB)):
      return msgA == msgB
    default:
      return false
    }
  }

  static func equalFeeds(a: Feed, b: Feed) -> Bool {
    if let feedA = a.rssFeed, let feedB = b.rssFeed {
      return feedA.link == feedB.link
    } else if let feedA = a.jsonFeed, let feedB = b.jsonFeed {
      return feedA.feedUrl == feedB.feedUrl
    } else if let feedA = a.atomFeed, let feedB = b.atomFeed {
      return feedA.id == feedB.id
    }
    return false
  }
}

private class IntroViewModel: ObservableObject {
  @Published var feedURLState = FeedURLState.None
  @Published var category: Category?

  @Published var feedUrl: String {
    didSet {
      feedURLState = .None
    }
  }

  @Published var showErrorAlert: Bool {
    didSet {
      if !showErrorAlert {
        feedURLState = .None
      }
    }
  }

  init() {
    feedUrl = ""
    showErrorAlert = false
  }

  var feed: Feed? {
    switch feedURLState {
    case let .Ok(feed):
      return feed
    default:
      return nil
    }
  }

  var errorMessage: String {
    switch feedURLState {
    case let .Error(msg):
      return msg
    default:
      return "An unknown error occurred."
    }
  }

  var isErrorState: Bool {
    switch feedURLState {
    case .Error:
      return true
    default:
      return false
    }
  }

  var disableButton: Bool {
    switch feedURLState {
    case .Loading, .Error:
      return true
    default:
      return false
    }
  }

  var allowSubmit: Bool {
    feedURLState == .None
  }

  var haveFeed: Bool {
    feed != nil
  }

  func checkFeedUrl() {
    if feedURLState == .Loading {
      return
    }

    if !feedUrl.starts(with: "http") {
      feedURLState = .Error(message: "Invalid Feed URL")
      return
    }

    guard let url = URL(string: feedUrl) else {
      feedURLState = .Error(message: "Invalid Feed URL")
      return
    }

    feedURLState = .Loading

    let parser = FeedParser(URL: url)
    parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { result in
      switch result {
      case .failure:
        DispatchQueue.main.async {
          self.feedURLState = .Error(message: "Error processing the feed")
        }
      case let .success(feed):
        DispatchQueue.main.async {
          self.feedURLState = .Ok(feed: feed)
        }
      }
    }
  }
}

struct IntroViewMobile: View {
  @EnvironmentObject var store: Store

  @ObservedObject fileprivate var model = IntroViewModel()

  var body: some View {
    NavigationView {
      VStack(alignment: .leading) {
        FeedURLInput(value: $model.feedUrl, submit: model.checkFeedUrl)
          .padding()

        if model.haveFeed {
          VStack {
            FeedCategoryPicker(category: $model.category)
          }.padding(.bottom)
        }

        HStack {
          Spacer()
          Button(action: {
            if model.allowSubmit {
              model.checkFeedUrl()
            }
          }, label: {
            if model.feedURLState == .Loading {
              ProgressView()
            } else if model.isErrorState {
              Text(model.errorMessage)
            } else {
              Text("Continue")
            }
          }).disabled(model.disableButton)
          Spacer()
        }

        Spacer()
      }
      .navigationTitle("Add Feed")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading, content: {
          Image("Logo")
            .resizable()
            .frame(width: 32, height: 32)
            .cornerRadius(10)
        })
      }
    }
    .onAppear {
      if model.category == nil {
        model.category = store.categories.first(where: { $0.isDefault })
      }
    }
  }
}

#if DEBUG
struct IntroViewMobile_Previews: PreviewProvider {
  static var previews: some View {
    IntroViewMobile()
  }
}
#endif
