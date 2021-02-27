//
//  MainViewMac.swift
//  RSSReader (macOS)
//
//  Created by Omar Estrella on 2/26/21.
//

import SwiftUI

struct MainViewMac: View {
  @EnvironmentObject var store: Store
  
  @State var addFeed = false

  var body: some View {
    NavigationView {
      SidebarView()
        .environmentObject(store)
        .listStyle(SidebarListStyle())
        .contextMenu(menuItems: {
          Button(action: {}, label: {
            Text("Add Category")
          })
        })
        .toolbar(content: {
          ToolbarItem(placement: .primaryAction) {
            Button(action: {
              NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
            }, label: {
              Label("Toggle Sidebar", systemImage: "sidebar.leading")
                .labelStyle(IconOnlyLabelStyle())
            })
          }
        })
      
      Text("First Panel")
      if false {
        Text("Second Panel")
      }
    }
  }
}

#if DEBUG
struct MainViewMac_Previews: PreviewProvider {
  static var previews: some View {
    MainViewMac()
  }
}
#endif
