import SwiftUI

@main
struct MatrixVOIPApp: App {
    @NSApplicationDelegateAdaptor var appDelegate: AppDelegate
    @StateObject var voipCoordinator = VOIPCoordinator(url: URL(string: "https://matrixvoip.dev/")!)
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(voipCoordinator)
        }
        .commands {
            CommandMenu("Call") {
                if #available(macOS 12.0, *) {
                    Button("Toggle Camera", action: voipCoordinator.toggleCamera)
                        .keyboardShortcut("v", modifiers: [])
                
                    Button("Toggle Microphone", action: voipCoordinator.toggleMicrophone)
                        .keyboardShortcut("m", modifiers: [])
                
                    Divider()
                }
                
                Button("Leave", action: voipCoordinator.leaveCall)
                    .keyboardShortcut("l", modifiers: .command)
            }
        }
    }
}
