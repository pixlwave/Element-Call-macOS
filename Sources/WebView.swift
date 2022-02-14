import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
    @AppStorage("developerExtrasEnabled") private var developerExtrasEnabled = false
    
    let coordinator: VOIPCoordinator
    
    func makeNSView(context: Context) -> WKWebView {
        context.coordinator.webView
    }
    
    func updateNSView(_ view: WKWebView, context: Context) {
        view.configuration.preferences.setValue(developerExtrasEnabled, forKey: "developerExtrasEnabled")
    }
    
    func makeCoordinator() -> VOIPCoordinator {
        coordinator
    }
}
