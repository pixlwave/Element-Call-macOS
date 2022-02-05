import SwiftUI

@available(macOS 12.0, *)
struct ControlsOverlay: View {
    @EnvironmentObject private var voipCoordinator: VOIPCoordinator
    
    private var cameraIsActive: Bool {
        voipCoordinator.cameraCaptureState == .active
    }
    
    private var microphoneIsActive: Bool {
        voipCoordinator.microphoneCaptureState == .active
    }
    
    var body: some View {
        HStack(spacing: 8) {
            CaptureDeviceToggle(device: .camera,
                                isEnabled: cameraIsActive,
                                action: voipCoordinator.toggleCamera)
            
            CaptureDeviceToggle(device: .microphone,
                                isEnabled: microphoneIsActive,
                                action: voipCoordinator.toggleMicrophone)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 6)
        .background(.thinMaterial, in: Capsule())
        .padding(.top)
    }
}

