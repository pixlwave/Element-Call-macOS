import SwiftUI

@available(macOS 12.0, *)
struct OverlayButton: View {
    let imageName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: imageName)
        }
        .buttonStyle(OverlayButtonStyle(backgroundMaterial: .thickMaterial))
    }
}


@available(macOS 12.0, *)
struct OverlayButtonStyle: ButtonStyle {
    let backgroundMaterial: Material
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(6)
            .frame(width: 30, height: 30)
            .background(
                Circle()
                    .foregroundStyle(backgroundMaterial)
                    .blendMode(configuration.isPressed ? .multiply : .normal)
            )
    }
}


@available(macOS 12.0, *)
struct OverlayButton_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            OverlayButton(imageName: "chevron.left", action: { })
            OverlayButton(imageName: "chevron.right", action: { })
        }
        .padding()
        .background(Color.gray)
    }
}
