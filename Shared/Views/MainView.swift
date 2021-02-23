//
//  ContentView.swift
//  Shared
//
//  Created by Omar Estrella on 2/16/21.
//

import SwiftUI

struct MainView: View {
  @EnvironmentObject var store: Store

  #if os(iOS)
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  #endif

  var body: some View {
    #if os(macOS)
    NavigationView {
      NavigationListView()
        .listStyle(SidebarListStyle())
        .contextMenu(menuItems: {
          Button(action: {}, label: {
            Text("Add Category")
          })
        })
    }
    #else
    MainViewMobile()
    #endif
  }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    MainView()
  }
}
#endif
