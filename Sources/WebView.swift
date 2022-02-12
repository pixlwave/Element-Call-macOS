import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
    let coordinator: VOIPCoordinator
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = context.coordinator.webView
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.load(URLRequest(url: context.coordinator.url))
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        // nothing to update
    }
    
    func makeCoordinator() -> VOIPCoordinator {
        coordinator
    }
}
