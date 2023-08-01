import WebKit
import Combine
import AVFoundation
import CallKit

class VOIPCoordinator: NSObject, ObservableObject {
    private let url: URL
    
    @objc let webView: WKWebView
    private var webViewURLObservation: NSKeyValueObservation?
    @Published private(set) var webViewURL: URL?
    
    var isInCall: Bool { webViewURL != url }
    let callController = CXCallController()
    let callProvider = CXProvider(configuration: .init())
    
    var cancellables: Set<AnyCancellable> = []
    
    init(url: URL) {
        self.url = url
        self.webViewURL = url
        
        let configuration = WKWebViewConfiguration()
        #if !os(macOS)
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = true
        #endif
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        
        super.init()
        
        // Observe the capture state
        // TODO: Observe the state in the web view?
        
        // Handle changes to the web view's URL
        webViewURLObservation = observe(\.webView.url) { coordinator, _ in
            if coordinator.webViewURL != coordinator.webView.url {
                coordinator.webViewURL = coordinator.webView.url
                Task { await self.handleURLChange() }
            }
        }
        
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
        webView.customUserAgent = userAgent()
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.load(URLRequest(url: url))
    }
    
    private var callID: UUID?
    func handleURLChange() async {
        do {
            if isInCall {
                try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .videoChat, options: [])
                print("Playback OK")
                try AVAudioSession.sharedInstance().setActive(true)
                print("Session is Active")
                
                let uuid = UUID()
                let handle = CXHandle(type: .generic, value: webViewURL?.absoluteString ?? "")
                let startCallAction = CXStartCallAction(call: uuid, handle: handle)
                 
                let transaction = CXTransaction(action: startCallAction)
                try await callController.request(transaction)
                print("Call started successfully")
                callID = uuid
            } else {
                try AVAudioSession.sharedInstance().setActive(false)
                print("Session is Inactive")
                
                if let callID {
                    let endCallAction = CXEndCallAction(call: callID)
                    self.callID = nil
                    try await callController.requestTransaction(with: endCallAction)
                    print("Call ended successfully")
                }
            }
        } catch {
            print(error)
        }
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
        
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setData(webViewURL.dataRepresentation, forType: .URL)
        #else
        UIPasteboard.general.url = webViewURL
        #endif
    }
    
    
    // MARK: - Private
    
    private func userAgent() -> String {
        let macOSMajor = ProcessInfo.processInfo.operatingSystemVersion.majorVersion
        let macOSMinor = ProcessInfo.processInfo.operatingSystemVersion.minorVersion
        let macOSPatch = ProcessInfo.processInfo.operatingSystemVersion.patchVersion
        
        return "Element Call \(ElementCallApp.version) / Safari \(safariVersion()) / macOS \(macOSMajor).\(macOSMinor).\(macOSPatch)"
    }
    
    private func safariVersion() -> String {
        #if !os(macOS)
        return ""
        #else
        let script = NSAppleScript(source: "version of application \"Safari\"")
        
        guard
            let result = script?.executeAndReturnError(nil),
            let version = result.stringValue
        else { return "" }
        
        return version
        #endif
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
    
    @available(macOS 12.0, *)
    func webView(_ webView: WKWebView, decideMediaCapturePermissionsFor origin: WKSecurityOrigin, initiatedBy frame: WKFrameInfo, type: WKMediaCaptureType) async -> WKPermissionDecision {
        guard origin.host == url.host else { return .deny }
        return .grant
    }
}

extension VOIPCoordinator: CXCallObserverDelegate, CXProviderDelegate {
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        print("Call changed: \(call)")
    }
    
    func providerDidReset(_ provider: CXProvider) {
        print("Provider did reset: \(provider)")
    }
}
