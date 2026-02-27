import SwiftUI

struct MainSimulationView: View {

    @EnvironmentObject private var state: SimulationState

    var body: some View {
        VStack(spacing: 24) {

            // MARK: AQI Label
            VStack(spacing: 4) {
                Text(state.selectedAQI.displayName)
                    .font(.title2)
                    .bold()

                Text(state.selectedExposure.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // MARK: Lung Visualisation
            LungView(oxygenEfficiency: state.oxygenEfficiency,
                     aqi: state.selectedAQI,
                     exposure: state.selectedExposure)
                .frame(width: 300, height: 320)

            // MARK: Oxygen Efficiency Display
            VStack(spacing: 8) {
                Text("Oxygen Efficiency")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                ProgressView(value: state.oxygenEfficiency)
                    .tint(.blue)
                    .frame(maxWidth: 200)
            }

            Spacer()

            // MARK: AQI Picker
            Picker("AQI Level", selection: $state.selectedAQI) {
                ForEach(AQI.allCases) { level in
                    Text(level.displayName).tag(level)
                }
            }
            .pickerStyle(.segmented)

            // MARK: Exposure Picker
            Picker("Exposure", selection: $state.selectedExposure) {
                ForEach(TimeExposure.allCases) { duration in
                    Text(duration.displayName).tag(duration)
                }
            }
            .pickerStyle(.segmented)

        }
        .padding()
        .navigationTitle("Breath of Time")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    state.returnToIntro()
                }
            }
        }
    }
}
