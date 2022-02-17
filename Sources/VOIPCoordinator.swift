import WebKit
import Combine

class VOIPCoordinator: NSObject, ObservableObject {
    @objc let webView = WKWebView()
    let url: URL
    
    @Published private(set) var isInCall = false
    
    var cancellables: Set<AnyCancellable> = []
    
    init(url: URL) {
        self.url = url
        
        super.init()
        
        // Observe the capture state
        // TODO: Observe the state in the web view?
        
        // Listen for notifications published by AppleScript commands
        NotificationCenter.default.publisher(for: .toggleDevice, object: nil)
            .sink(receiveValue: toggleDevice)
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .joinCall, object: nil)
            .sink(receiveValue: joinCall)
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .leaveCall, object: nil)
            .sink { _ in self.leaveCall() }
            .store(in: &cancellables)
        
        // Configure web view and load the base url.
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.load(URLRequest(url: url))
    }
    
    func toggleDevice(_ notification: Notification) {
        guard let device = notification.object as? CaptureDevice else { return }
        
        switch device {
        case .camera:
            toggleCamera()
        case .microphone:
            toggleMicrophone()
        }
    }
    
    func joinCall(_ notification: Notification) {
        guard let callURL = notification.object as? URL else { return }
        webView.load(URLRequest(url: callURL))
    }
    
    func toggleCamera() {
        webView.evaluateJavaScript("groupCall.setLocalVideoMuted(!groupCall.isLocalVideoMuted())", completionHandler: nil)
    }
    
    func toggleMicrophone() {
        webView.evaluateJavaScript("groupCall.setMicrophoneMuted(!groupCall.isMicrophoneMuted())", completionHandler: nil)
    }
    
    func leaveCall() {
        webView.load(URLRequest(url: url))
    }
    
    func goBack() {
        webView.goBack()
    }
    
    func goForward() {
        webView.goForward()
    }
    
    func copyURL() {
        guard let webViewURL = webView.url else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setData(webViewURL.dataRepresentation, forType: .URL)
    }
}

// MARK: WebKit Delegates
extension VOIPCoordinator: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        // Allow any content from the main URL.
        if navigationAction.request.url?.host == url.host {
            return .allow
        }
        
        // Additionally allow any embedded content such as captchas.
        if let targetFrame = navigationAction.targetFrame, !targetFrame.isMainFrame {
            return .allow
        }
        
        // Otherwise the request is invalid.
        return .cancel
    }
    
    #warning("Not called whilst navigating through app")
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isInCall = webView.url != url
    }
    
    @available(macOS 12.0, *)
    func webView(_ webView: WKWebView, decideMediaCapturePermissionsFor origin: WKSecurityOrigin, initiatedBy frame: WKFrameInfo, type: WKMediaCaptureType) async -> WKPermissionDecision {
        guard origin.host == url.host else { return .deny }
        return .grant
    }
}
