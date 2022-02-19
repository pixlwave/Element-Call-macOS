import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var voipCoordinator: VOIPCoordinator
    
    var body: some View {
        ZStack(alignment: .top) {
            WebView(coordinator: voipCoordinator)
            
            if #available(macOS 12.0, *) {
                ControlsOverlay()
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(WebView.Coordinator(url: ElementCallApp.url))
    }
}
