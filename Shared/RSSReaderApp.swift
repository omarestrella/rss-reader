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
    WindowGroup {
      MainView()
        .environmentObject(store)
    }
    
    #if os(macOS)
    Settings {
      SettingsViewMac().frame(minWidth: 640, minHeight: 480).environmentObject(store)
    }
    #endif
  }
}
