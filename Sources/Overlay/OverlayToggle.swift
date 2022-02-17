import SwiftUI

@available(macOS 12.0, *)
struct OverlayToggle: View {
    let onImage: Image
    let offImage: Image
    
    let isOn: Bool
    let action: () -> Void
    
    var image: Image {
        isOn ? onImage : offImage
    }
    
    var backgroundMaterial: Material {
        isOn ? .thickMaterial : .ultraThinMaterial
    }
    
    var body: some View {
        Button(action: action) {
            image
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
            OverlayToggle(onImage: Image(systemName: "video.fill"),
                          offImage: Image(systemName: "video.slash"),
                          isOn: isOn) { }
            OverlayToggle(onImage: Image(systemName: "mic.fill"),
                          offImage: Image(systemName: "mic.slash"),
                          isOn: isOn) { }
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
