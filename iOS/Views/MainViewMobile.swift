//
//  MainViewMobile.swift
//  RSSReader (iOS)
//
//  Created by Omar Estrella on 2/17/21.
//

import SwiftUI

struct MainViewMobile: View {
  @EnvironmentObject var store: Store

  #if os(iOS)
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  #endif

  @State var showNewSourceForm = false
  @State var showIntro = false

  var body: some View {
    NavigationView {
      SidebarView()
      
      if let source = store.currentSource {
        SourceView(source: source)
      } else {
        Text("No Source")
      }
      
      if let item = store.currentFeedItem {
        SourceItemView(item: item)
      } else {
        EmptyView()
      }
    }
  }

  func addCategory() {
    store.add(category: Category(name: "ASDF"))
  }
}

#if DEBUG
struct MainViewMobile_Previews: PreviewProvider {
  static var previews: some View {
    MainViewMobile()
  }
}
#endif
