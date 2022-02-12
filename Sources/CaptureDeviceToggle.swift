import SwiftUI

@available(macOS 12.0, *)
struct CaptureDeviceToggle: View {
    enum Device {
        case camera, microphone
    }
    
    let device: Device
    let isEnabled: Bool
    let action: () -> Void
    
    var imageName: String {
        switch device {
        case .camera:
            return isEnabled ? "video.fill" : "video.slash"
        case .microphone:
            return isEnabled ? "mic.fill" : "mic.slash"
        }
    }
    
    @ViewBuilder
    var background: some View {
        Circle()
            .foregroundStyle(isEnabled ? .thickMaterial : .ultraThinMaterial)
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: imageName)
                .symbolRenderingMode(.palette)
                .foregroundStyle(isEnabled ? Color.primary : .red, .primary)
                .padding(6)
                .frame(width: 30, height: 30)
                .background(background)
        }
        .buttonStyle(.borderless)
    }
}

@available(macOS 12.0, *)
struct Previews_CaptureDeviceButton_Previews: PreviewProvider {
    static func makeStack(isEnabled: Bool) -> some View {
        HStack(spacing: 8) {
            CaptureDeviceToggle(device: .camera, isEnabled: isEnabled) { }
            CaptureDeviceToggle(device: .microphone, isEnabled: isEnabled) { }
        }
        .padding(8)
        .background(Color.primary.opacity(0.2), in: Capsule())
    }
    
    static var previews: some View {
        VStack {
            makeStack(isEnabled: false)
            makeStack(isEnabled: true)
        }
        .padding()
        .background(Color.gray)
    }
}
