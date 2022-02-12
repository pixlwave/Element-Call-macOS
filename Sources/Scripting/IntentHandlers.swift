import Intents

class IntentHandler: NSObject, ToggleCameraIntentHandling, ToggleMicrophoneIntentHandling, JoinCallIntentHandling, LeaveCallIntentHandling {
    func handle(intent: ToggleCameraIntent) async -> ToggleCameraIntentResponse {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .toggleDevice, object: CaptureDevice.camera)
        }
        return ToggleCameraIntentResponse(code: .success, userActivity: nil)
    }
    
    func handle(intent: ToggleMicrophoneIntent) async -> ToggleMicrophoneIntentResponse {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .toggleDevice, object: CaptureDevice.microphone)
        }
        return ToggleMicrophoneIntentResponse(code: .success, userActivity: nil)
    }
    
    #warning("callLink parameter needs validation - there's another method to find")
    func handle(intent: JoinCallIntent) async -> JoinCallIntentResponse {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .joinCall, object: intent.callLink)
        }
        return JoinCallIntentResponse(code: .success, userActivity: nil)
    }
    
    func handle(intent: LeaveCallIntent) async -> LeaveCallIntentResponse {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .leaveCall, object: nil)
        }
        return LeaveCallIntentResponse(code: .success, userActivity: nil)
    }
}
