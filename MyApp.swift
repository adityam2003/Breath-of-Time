import SwiftUI

@main
struct BreathOfTimeApp: App {

    /// Single source of truth. Created once, injected via environment.
    @StateObject private var simulationState = SimulationState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(simulationState)
        }
    }
}
