//
//  NavigationListView.swift
//  RSSReader (macOS)
//
//  Created by Omar Estrella on 2/16/21.
//

import FeedKit
import FetchImage
import SwiftUI

struct SidebarEntry: View {
  var source: Source

  @StateObject private var image = FetchImage()

  var body: some View {
    HStack {
      if let _ = source.icon, let imageView = image.view {
        imageView
          .resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: 16, height: 16)
      } else {
        Text("")
          .frame(width: 16, height: 16)
      }
      Text(source.name)
    }.onAppear {
      if let icon = source.icon, let url = URL(string: icon) {
        image.load(url)
      }
    }.onDisappear {
      image.reset()
    }
  }
}

struct SidebarView: View {
  @EnvironmentObject var store: Store

  var sources: [Source]
  
  @State var addingNewFeed = false

  var body: some View {
    List(store.sources, id: \.id) { source in
      NavigationLink(destination: SourceView(source: source), tag: source, selection: $store.currentSource) {
        SidebarEntry(source: source)
      }.contextMenu {
        Button(action: {
          if let currentSource = store.currentSource, currentSource == source {
            store.currentSource = nil
          }
          store.remove(source: source)
        }, label: {
          Text("Delete")
        })
      }
    }
    .navigationTitle("Feeds")
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: {
          addingNewFeed.toggle()
        }, label: {
          Label("Add New Feed", systemImage: "plus.circle")
            .labelStyle(IconOnlyLabelStyle())
        })
      }
    }
    .sheet(isPresented: $addingNewFeed) {
      AddFeedView(store: store)
        .padding()
    }.onAppear {
      if !store.initialized && !store.loading {
        DispatchQueue.main.async {
          self.addingNewFeed = true
        }
      }
    }
  }
}

#if DEBUG
struct NavigationListView_Previews: PreviewProvider {
  static var previews: some View {
    SidebarView(sources: [])
  }
}
#endif
