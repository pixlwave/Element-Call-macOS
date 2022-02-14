import Foundation
import Sparkle

class SparkleUpdater: ObservableObject {
    private let updaterController: SPUStandardUpdaterController
    
    @Published var canCheckForUpdates = false
    
    init() {
        updaterController = SPUStandardUpdaterController(updaterDelegate: nil, userDriverDelegate: nil)
        updaterController.updater.publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
    }
    
    func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }
}
