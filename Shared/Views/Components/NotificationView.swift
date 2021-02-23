//
//  NotificationView.swift
//  RSSReader
//
//  Created by Omar Estrella on 2/20/21.
//

import SwiftUI

struct NotificationView<Content: View>: View {
  var notification: Notification
  var content: Content
  
  var systemColor = Color(UIColor.systemBackground)
  
  init(notification: Notification, @ViewBuilder content: () -> Content) {
    self.notification = notification
    self.content = content()
  }
  
  var body: some View {
    VStack {
      Image(systemName: icon)
        .renderingMode(.template)
        .foregroundColor(systemColor)
        .font(.largeTitle)
      Group {
        content
      }.padding(.all, 20)
    }
    .frame(width: 250)
    .background(Color.blue)
    .cornerRadius(10)
  }
  
  var icon: String {
    switch notification.type {
    case .Error:
      return "xmark.circle.fill"
    }
  }
}

#if DEBUG
struct NotificationView_Previews: PreviewProvider {
  static var previews: some View {
    NotificationView(notification: .init(type: .Error)) {
      Text("Hello!")
    }
    .preferredColorScheme(.dark)
  }
}
#endif
