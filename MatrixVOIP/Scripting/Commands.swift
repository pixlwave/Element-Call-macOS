import Foundation

@objcMembers class ToggleCameraCommand: NSScriptCommand {
    override func performDefaultImplementation() -> Any? {
        NotificationCenter.default.post(name: .toggleCamera, object: nil)
        return nil
    }
}

@objcMembers class ToggleMicrophoneCommand: NSScriptCommand {
    override func performDefaultImplementation() -> Any? {
        NotificationCenter.default.post(name: .toggleMicrophone, object: nil)
        return nil
    }
}

@objcMembers class JoinCallCommand: NSScriptCommand {
    override func performDefaultImplementation() -> Any? {
        guard var callLink = evaluatedArguments?[""] as? String else {
            scriptErrorNumber = -50
            scriptErrorString = "Parameter error: joinCall requires a parameter containing the call link to join."
            return nil
        }
        
        if !callLink.hasPrefix("https://") {
            callLink = "https://\(callLink)"
        }
        
        guard
            let callURL = URL(string: callLink),
            callURL.host == "matrixvoip.dev"
        else {
            scriptErrorNumber = -50
            scriptErrorString = "Parameter error: Invalid call link supplied."
            return nil
        }
        
        NotificationCenter.default.post(name: .joinCall, object: callURL)
        return nil
    }
}

@objcMembers class LeaveCallCommand: NSScriptCommand {
    override func performDefaultImplementation() -> Any? {
        NotificationCenter.default.post(name: .leaveCall, object: nil)
        return nil
    }
}

extension NSNotification.Name {
    static let toggleMicrophone = NSNotification.Name("toggleMicrophone")
    static let toggleCamera = NSNotification.Name("toggleCamera")
    static let joinCall = NSNotification.Name("joinCall")
    static let leaveCall = NSNotification.Name("leaveCall")
}
