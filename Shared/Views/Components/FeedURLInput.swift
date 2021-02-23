//
//  FeedURLInput.swift
//  RSSReader
//
//  Created by Omar Estrella on 2/17/21.
//

import SwiftUI

struct FeedURLInput: View {
  @Binding var value: String
  
  var submit: (() -> Void)?
  var edit: ((_ editing: Bool) -> Void)?
  
  var body: some View {
    VStack(alignment: .leading) {
      Section(header: Text("URL").font(.caption).bold()) {
        TextField("http://feeds.arstechnica.com/arstechnica/index", text: $value, onEditingChanged: editingChanged, onCommit: commit)
          .textFieldStyle(DefaultTextFieldStyle())
          .textContentType(.URL)
      }
    }
  }
  
  func editingChanged(editing: Bool) {
    if editing == false, let edit = edit {
      edit(editing)
    }
  }
  
  func commit() {
    if let submit = submit {
      submit()
    }
  }
}

#if DEBUG
struct FeedURLInput_Previews: PreviewProvider {
  static var previews: some View {
    FeedURLInput(value: .constant("Testing"))
      .padding()
  }
}
#endif
