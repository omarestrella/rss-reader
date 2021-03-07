//
//  RSSReaderApp.swift
//  Shared
//
//  Created by Omar Estrella on 2/16/21.
//

import SwiftUI

@main
struct RSSReaderApp: App {
  @StateObject var store = Store()

  var body: some Scene {
    WindowGroup {
      MainView()
        .environmentObject(store)
    }
  }
}
