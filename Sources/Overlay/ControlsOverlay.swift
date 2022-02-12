import SwiftUI

@available(macOS 12.0, *)
struct ControlsOverlay: View {
    @EnvironmentObject private var voipCoordinator: VOIPCoordinator
    @AppStorage("showBackButton") private var showBackButton = false
    
    private var cameraIsActive: Bool {
        voipCoordinator.cameraCaptureState == .active
    }
    
    private var microphoneIsActive: Bool {
        voipCoordinator.microphoneCaptureState == .active
    }
    
    var body: some View {
        HStack(spacing: 8) {
            if showBackButton {
                OverlayButton(imageName: "chevron.left", action: voipCoordinator.goBack)
                    .transition(.scale(scale: 0, anchor: .trailing))
                Divider()
                    .frame(height: 22)
            }
            
            CaptureDeviceToggle(device: .camera,
                                isOn: cameraIsActive,
                                action: voipCoordinator.toggleCamera)
            
            CaptureDeviceToggle(device: .microphone,
                                isOn: microphoneIsActive,
                                action: voipCoordinator.toggleMicrophone)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 6)
        .background(.thinMaterial, in: Capsule())
        .padding(.top)
    }
}


@available(macOS 12.0, *)
struct Previews_ControlsOverlay_Previews: PreviewProvider {
    static var previews: some View {
        ControlsOverlay()
            .padding()
            .background(Color.gray)
            .environmentObject(VOIPCoordinator(url: MatrixVOIPApp.url))
    }
}
