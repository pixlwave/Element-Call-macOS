import WebKit
import Combine

class VOIPCoordinator: NSObject, ObservableObject {
    @objc let webView = WKWebView()
    let url: URL
    
    @available(macOS 12.0, *)
    @Published private(set) var cameraCaptureState: WKMediaCaptureState?
    @available(macOS 12.0, *)
    @Published private(set) var microphoneCaptureState: WKMediaCaptureState?
    
    @Published private(set) var isInCall = false
    
    private var cameraCaptureStateObservation: NSKeyValueObservation?
    private var microphoneCaptureStateObservation: NSKeyValueObservation?
    
    var cancellables: Set<AnyCancellable> = []
    
    init(url: URL) {
        self.url = url
        
        if #available(macOS 12.0, *) {
            cameraCaptureState = webView.cameraCaptureState
            microphoneCaptureState = webView.microphoneCaptureState
        }
        
        super.init()
        
        if #available(macOS 12.0, *) {
            // Observe the capture state
            cameraCaptureStateObservation = observe(\.webView.cameraCaptureState) { coordinator, change in
                coordinator.cameraCaptureState = coordinator.webView.cameraCaptureState
            }
            microphoneCaptureStateObservation = observe(\.webView.microphoneCaptureState) { coordinator, _ in
                coordinator.microphoneCaptureState = coordinator.webView.microphoneCaptureState
            }
            
            // Listen for notifications published by AppleScript commands
            NotificationCenter.default.publisher(for: .toggleCamera, object: nil)
                .sink { _ in self.toggleCamera() }
                .store(in: &cancellables)
            
            NotificationCenter.default.publisher(for: .toggleMicrophone, object: nil)
                .sink { _ in self.toggleMicrophone() }
                .store(in: &cancellables)
        }
        
        NotificationCenter.default.publisher(for: .joinCall, object: nil)
            .sink { self.joinCall($0) }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .leaveCall, object: nil)
            .sink { _ in self.leaveCall() }
            .store(in: &cancellables)
    }
    
    func joinCall(_ notification: Notification) {
        guard let callURL = notification.object as? URL else { return }
        webView.load(URLRequest(url: callURL))
    }
    
    @available(macOS 12.0, *)
    func toggleCamera() {
        webView.setCameraCaptureState(webView.cameraCaptureState == .active ? .muted : .active)
    }
    
    @available(macOS 12.0, *)
    func toggleMicrophone() {
        webView.setMicrophoneCaptureState(webView.microphoneCaptureState == .active ? .muted : .active)
    }
    
    func leaveCall() {
        webView.load(URLRequest(url: url))
    }
}

// MARK: WebKit Delegates
extension VOIPCoordinator: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        guard navigationAction.request.url?.host == url.host else { return .cancel }
        return .allow
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isInCall = webView.url != url
    }
    
    @available(macOS 12.0, *)
    func webView(_ webView: WKWebView, decideMediaCapturePermissionsFor origin: WKSecurityOrigin, initiatedBy frame: WKFrameInfo, type: WKMediaCaptureType) async -> WKPermissionDecision {
        guard origin.host == url.host else { return .deny }
        return .grant
    }
}