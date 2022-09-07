import SwiftUI

@main
struct ElementCallApp: App {
    #if os(macOS)
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @StateObject private var sparkleUpdater = SparkleUpdater()
    #endif
    
    static let url = URL(string: "https://call.element.io/")!
    static var version: String { Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "" }
    
    @AppStorage("showNavigation") private var showNavigation = false
    @AppStorage("developerExtrasEnabled") private var developerExtrasEnabled = false
    
    @StateObject private var voipCoordinator = VOIPCoordinator(url: ElementCallApp.url)
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(voipCoordinator)
                #if !os(macOS)
                .preferredColorScheme(.dark)
                #endif
        }
        .commands {
            CommandMenu("Call") {
                Button("Toggle Camera", action: voipCoordinator.toggleCamera)
                    .keyboardShortcut("v", modifiers: [])
                    .disabled(!voipCoordinator.isInCall)
                
                Button("Toggle Microphone", action: voipCoordinator.toggleMicrophone)
                    .keyboardShortcut("m", modifiers: [])
                    .disabled(!voipCoordinator.isInCall)
                
                Divider()
                
                Button("Copy Link", action: voipCoordinator.copyURL)
                    .disabled(!voipCoordinator.isInCall)
                
                Divider()
                
                Button("Leave", action: voipCoordinator.leaveCall)
                    .keyboardShortcut("l", modifiers: .command)
                    .disabled(!voipCoordinator.isInCall)
            }
            
            CommandMenu("Develop") {
                Toggle("Enable Web Inspector", isOn: $developerExtrasEnabled)
                
                if #available(macOS 12.0, *) {
                    Toggle("Show Navigation", isOn: $showNavigation.animation())
                }
            }
            
            #if os(macOS)
            CommandGroup(after: .appInfo) {
                Button("Check for Updates…", action: sparkleUpdater.checkForUpdates)
                    .disabled(!sparkleUpdater.canCheckForUpdates)
            }
            #endif
            
            // Remove the New Window menu item.
            CommandGroup(replacing: CommandGroupPlacement.newItem) {
                EmptyView()
            }
        }
    }
}
