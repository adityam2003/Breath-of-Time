import SwiftUI

/// Root router. Reads `AppPhase` from `SimulationState` and
/// displays the correct top-level view. No logic lives here.
struct ContentView: View {

    @EnvironmentObject private var state: SimulationState

    var body: some View {
        switch state.phase {
        case .intro:
            IntroView()
        case .simulation:
            MainSimulationView()
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(SimulationState())
}
