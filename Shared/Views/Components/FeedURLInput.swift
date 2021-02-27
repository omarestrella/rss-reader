//
//  FeedURLInput.swift
//  RSSReader
//
//  Created by Omar Estrella on 2/17/21.
//

import SwiftUI

struct FeedURLInput<Content: View>: View {
  @Binding var value: String
  
  var submit: (() -> Void)?
  var header: Content?
  
  init(
    value: Binding<String>,
    submit: (() -> Void)? = nil,
    @ViewBuilder header: @escaping () -> Content?
  ) {
    self._value = value
    self.submit = submit
    self.header = header()
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      Section(header: Group {
        if let header = header {
          header
        } else {
          Text("URL").font(.caption).bold().offset(x: 0, y: 5)
        }
      }) {
        #if os(macOS)
        TextField("http://feeds.arstechnica.com/arstechnica/index", text: $value, onEditingChanged: editingChanged, onCommit: commit)
          .textFieldStyle(DefaultTextFieldStyle())
        #else
        TextField("http://feeds.arstechnica.com/arstechnica/index", text: $value, onEditingChanged: editingChanged, onCommit: commit)
          .textFieldStyle(DefaultTextFieldStyle())
          .textContentType(.URL)
        #endif
      }
    }
  }
  
  func editingChanged(editing: Bool) {}
  
  func commit() {
    if let submit = submit {
      submit()
    }
  }
}

#if DEBUG
struct FeedURLInput_Previews: PreviewProvider {
  static var previews: some View {
    FeedURLInput(value: .constant("")) {
      Text("Header")
    }.padding()
  }
}
#endif
