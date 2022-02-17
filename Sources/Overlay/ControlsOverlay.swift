import SwiftUI

@available(macOS 12.0, *)
struct ControlsOverlay: View {
    @EnvironmentObject private var voipCoordinator: VOIPCoordinator
    
    @AppStorage("showNavigation") private var showNavigation = false
    
    var body: some View {
        ZStack {
            if showNavigation {
                HStack(spacing: 8) {
                    OverlayButton(imageName: "chevron.left", action: voipCoordinator.goBack)
                    OverlayButton(imageName: "chevron.right", action: voipCoordinator.goForward)
                    
                    Divider()
                        .frame(height: 22)
                    
                    // Add url bar and copy button
                    
                    OverlayButton(imageName: "doc.on.doc", action: voipCoordinator.copyURL)
                }
                .padding(.horizontal, 7)
                .padding(.vertical, 6)
                .background(.thinMaterial, in: Capsule())
                .padding(.top)
                .transition(.offset(y: -30).combined(with: .opacity))
            }
        }
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
