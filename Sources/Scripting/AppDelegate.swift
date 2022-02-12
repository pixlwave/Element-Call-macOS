import Cocoa
import Intents

class AppDelegate: NSObject, NSApplicationDelegate {
    @available(macOS 12.0, *)
    func application(_ application: NSApplication, handlerFor intent: INIntent) -> Any? {
        guard intent is ToggleCameraIntent || intent is ToggleMicrophoneIntent || intent is JoinCallIntent || intent is LeaveCallIntent else {
            return nil
        }
        
        return IntentHandler()
    }
}