import SwiftUI

@main
struct MatrixVOIPApp: App {
    @NSApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    static let url = URL(string: "https://matrixvoip.dev/")!
    
    @AppStorage("showNavigation") private var showNavigation = false
    @AppStorage("developerExtrasEnabled") private var developerExtrasEnabled = false
    
    @StateObject private var voipCoordinator = VOIPCoordinator(url: MatrixVOIPApp.url)
    @StateObject private var sparkleUpdater = SparkleUpdater()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(voipCoordinator)
        }
        .commands {
            CommandMenu("Call") {
                Button("Toggle Camera", action: voipCoordinator.toggleCamera)
                    .keyboardShortcut("v", modifiers: [])
                
                Button("Toggle Microphone", action: voipCoordinator.toggleMicrophone)
                    .keyboardShortcut("m", modifiers: [])
                
                Divider()
                
                Button("Copy Link", action: voipCoordinator.copyURL)
                
                Divider()
                
                Button("Leave", action: voipCoordinator.leaveCall)
                    .keyboardShortcut("l", modifiers: .command)
            }
            
            CommandMenu("Develop") {
                Toggle("Enable Web Inspector", isOn: $developerExtrasEnabled)
                
                if #available(macOS 12.0, *) {
                    Toggle("Show Navigation", isOn: $showNavigation.animation())
                }
            }
            
            CommandGroup(after: .appInfo) {
                Button("Check for Updates…", action: sparkleUpdater.checkForUpdates)
                    .disabled(!sparkleUpdater.canCheckForUpdates)
            }
        }
    }
}
