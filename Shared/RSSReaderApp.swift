//
//  RSSReaderApp.swift
//  Shared
//
//  Created by Omar Estrella on 2/16/21.
//

import SwiftUI

@main
struct RSSReaderApp: App {
  var store = Store()

  var body: some Scene {
    #if os(macOS)
    WindowGroup {
      MainView()
        .environmentObject(store)
    }.windowToolbarStyle(UnifiedWindowToolbarStyle(showsTitle: false))
    Settings {
      SettingsViewMac().frame(minWidth: 640, minHeight: 480).environmentObject(store)
    }
    #else
    WindowGroup {
      MainView()
        .environmentObject(store)
    }
    #endif
  }
}
