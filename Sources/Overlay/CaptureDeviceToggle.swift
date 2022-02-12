import SwiftUI

@available(macOS 12.0, *)
struct CaptureDeviceToggle: View {
    enum Device {
        case camera, microphone
    }
    
    let device: Device
    let isOn: Bool
    let action: () -> Void
    
    var imageName: String {
        switch device {
        case .camera:
            return isOn ? "video.fill" : "video.slash"
        case .microphone:
            return isOn ? "mic.fill" : "mic.slash"
        }
    }
    
    var backgroundMaterial: Material {
        isOn ? .thickMaterial : .ultraThinMaterial
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: imageName)
                .symbolRenderingMode(.palette)
                .foregroundStyle(isOn ? Color.primary : .red, .primary)
        }
        .buttonStyle(OverlayButtonStyle(backgroundMaterial: backgroundMaterial))
    }
}


@available(macOS 12.0, *)
struct CaptureDeviceButton_Previews: PreviewProvider {
    static func makeStack(isOn: Bool) -> some View {
        HStack(spacing: 8) {
            CaptureDeviceToggle(device: .camera, isOn: isOn) { }
            CaptureDeviceToggle(device: .microphone, isOn: isOn) { }
        }
        .padding(8)
        .background(Color.primary.opacity(0.2), in: Capsule())
    }
    
    static var previews: some View {
        VStack {
            makeStack(isOn: false)
            makeStack(isOn: true)
        }
        .padding()
        .background(Color.gray)
    }
}
