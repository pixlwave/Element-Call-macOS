import Foundation

@objcMembers class ToggleDeviceCommand: NSScriptCommand {
    override func performDefaultImplementation() -> Any? {
        guard
            let rawValue = evaluatedArguments?[""] as? Int,
            let device = CaptureDevice(rawValue: rawValue)
        else {
            scriptErrorNumber = Self.parameterErrorNumber
            scriptErrorString = "Pass one of camera|microphone to the toggle command."
            return nil
        }
        
        NotificationCenter.default.post(name: .toggleDevice, object: device)
        return nil
    }
}

@objcMembers class JoinCallCommand: NSScriptCommand {
    override func performDefaultImplementation() -> Any? {
        guard var callLink = evaluatedArguments?[""] as? String else {
            scriptErrorNumber = Self.parameterErrorNumber
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

extension NSScriptCommand {
    static let parameterErrorNumber = -50
}

extension NSNotification.Name {
    static let toggleDevice = NSNotification.Name("toggleDevice")
    static let joinCall = NSNotification.Name("joinCall")
    static let leaveCall = NSNotification.Name("leaveCall")
}
