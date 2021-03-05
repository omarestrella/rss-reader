//
//  HTMLView.swift
//  RSSReader
//
//  Created by Omar Estrella on 2/28/21.
//

import SwiftUI

#if os(macOS)
import AppKit
#else
import UIKit
#endif

import WebKit

class BrowserViewModel: NSObject, ObservableObject, WKNavigationDelegate {
  @Published var text: String
  @Published var didFinishLoading: Bool = false

  init(text: String) {
    self.text = text
  }
}

#if os(macOS)
struct BrowserView: NSViewRepresentable {
  public typealias NSViewType = WKWebView

  @ObservedObject var model: BrowserViewModel

  private let webView = WKWebView()

  init(text: String) {
    model = BrowserViewModel(text: text)
  }

  func makeNSView(context: Context) -> WKWebView {
    let css = """
    * {
      font-family: -apple-system, BlinkMacSystemFont, Helvetica, Arial, sans-serif, "Apple Color Emoji";
    }
    """
    let cssScript = WKUserScript(source: css, injectionTime: .atDocumentStart, forMainFrameOnly: false)
    webView.configuration.userContentController.addUserScript(cssScript)
    return webView
  }

  func updateNSView(_ nsView: WKWebView, context _: Context) {
    let css = """
    * {
      font-family: -apple-system, BlinkMacSystemFont, Helvetica, Arial, sans-serif, "Apple Color Emoji";
    }
    body {
      padding: 20px;
    }

    img {
      max-width: 100%;
    }

    ul {
      list-style-type: none;
    }
    """
    let html = """
    <!doctype html>
    <html><head><style type="text/css">\(css)</style></head><body>\(model.text)</body></html>
    """
    nsView.loadHTMLString(html, baseURL: nil)
  }
}
#else
struct BrowserView: UIViewRepresentable {
  @Binding var text: String
}
#endif

#if DEBUG
struct BrowserView_Previews: PreviewProvider {
  static var previews: some View {
    HStack {
      BrowserView(text: "Test")
    }
  }
}
#endif
