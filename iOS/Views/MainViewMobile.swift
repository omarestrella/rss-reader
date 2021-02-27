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
    ZStack {
      if horizontalSizeClass == .some(.compact) {
        TabView {
          NavigationView {
            SidebarView()
              .listStyle(InsetGroupedListStyle())
              .navigationTitle("Sources")
              .navigationBarTitleDisplayMode(.inline)
          }
          .tabItem {
            Label("News", systemImage: "book")
          }
        }
      } else {
        NavigationView {
          SidebarView()
            .listStyle(SidebarListStyle())
            .navigationTitle("Sources")
            .toolbar {
              ToolbarItem(placement: .primaryAction, content: {
                Button(action: {
                  showNewSourceForm.toggle()
                }, label: {
                  Label("Add Source", systemImage: "plus.circle")
                    .labelStyle(IconOnlyLabelStyle())
                })
              })
            }

          Text("List of news stories")
        }
      }
    }
    .popover(isPresented: $showIntro, content: {
      IntroViewMobile().environmentObject(store)
    })
    .onAppear {
      if !store.initialized && !store.loading {
        showIntro = true
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
