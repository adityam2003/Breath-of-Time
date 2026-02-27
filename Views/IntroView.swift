import SwiftUI

/// The landing screen shown when the app first launches.
/// Presents a brief concept summary and a call-to-action to begin.
struct IntroView: View {

    @EnvironmentObject private var state: SimulationState

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            titleSection

            descriptionSection

            Spacer()

            beginButton
        }
        .padding()
    }

    // MARK: - Subviews

    private var titleSection: some View {
        VStack(spacing: 8) {
            Text("Breath of Time")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("A simulation of air quality & its health effects")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            bulletPoint("Choose an AQI level that matches a real location.")
            bulletPoint("Select how long you're exposed to that air.")
            bulletPoint("See the cumulative health impact unfold over time.")
        }
        .padding(.horizontal)
    }

    private func bulletPoint(_ text: String) -> some View {
        Label(text, systemImage: "circle.fill")
            .font(.body)
            .foregroundColor(.primary)
    }

    private var beginButton: some View {
        Button(action: state.beginSimulation) {
            Text("Begin Simulation")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .padding(.horizontal)
        .padding(.bottom)
    }
}

// MARK: - Preview

#Preview {
    IntroView()
        .environmentObject(SimulationState())
}
