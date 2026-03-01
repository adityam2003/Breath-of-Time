import SwiftUI

/// Root router. Reads `AppPhase` from `SimulationState` and
/// displays the correct top-level view. No logic lives here.
struct ContentView: View {

    @EnvironmentObject private var state: SimulationState

    var body: some View {
        ZStack {
            switch state.phase {
            case .story:
                OpeningStoryView()
                    .transition(.opacity)
            case .intro:
                IntroView()
                    .transition(.opacity)
            case .simulation:
                MainSimulationView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.6), value: state.phase)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(SimulationState())
}
