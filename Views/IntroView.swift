import SwiftUI

/// A clean, airy bridge between the opening atmospheric story and the clinical simulation.
struct IntroView: View {

    @EnvironmentObject private var state: SimulationState

    var body: some View {
        ZStack {
            // Soft, desaturated light gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.94, green: 0.95, blue: 0.96), // Pale blue-grey top
                    Color(red: 0.98, green: 0.98, blue: 0.99), // Soft neutral white center
                    Color(red: 0.96, green: 0.97, blue: 0.98)  // Subtle atmospheric tint bottom
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Shift interior block slightly upward (Offset by -6%)
                VStack(spacing: 52) {
                    
                    // Title: Slightly reduced size, slightly bold, clean dark charcoal
                    Text("Breath of Time")
                        .font(.system(size: 26, weight: .semibold, design: .serif))
                        .foregroundStyle(Color(red: 0.11, green: 0.11, blue: 0.12)) // Dark charcoal
                    
                    // Body: Darkened text (contrast +10%), increased line spacing
                    VStack(spacing: 36) { // Increased from 28 to 36
                        Text("Set the air.")
                        Text("Set the time.")
                        Text("Observe what changes.")
                    }
                    .font(.body)
                    .fontWeight(.regular)
                    // Darkened slightly from (0.35...) to (0.30...) for better but soft contrast
                    .foregroundStyle(Color(red: 0.30, green: 0.30, blue: 0.33))
                }
                .offset(y: UIScreen.main.bounds.height * -0.05)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Breath of Time. Set the air. Set the time. Observe what changes.")
                
                Spacer()
                
                // Button
                Button {
                    HapticManager.medium()
                    withAnimation(.easeInOut(duration: 0.5)) {
                        state.beginSimulation()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text("Begin Simulation")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Image(systemName: "arrow.right")
                            .font(.footnote.weight(.semibold))
                    }
                    // More generous horizontal and vertical padding inside the button
                    .padding(.horizontal, 28)
                    .padding(.vertical, 16)
                    .foregroundStyle(Color(red: 0.95, green: 0.95, blue: 0.96)) // Off-white text
                    .background(
                        Capsule()
                            .fill(Color(red: 0.25, green: 0.30, blue: 0.35)) // Deep slate
                    )
                    // Extremely soft, grounded shadow matching the constraints
                    .shadow(color: Color(red: 0.25, green: 0.30, blue: 0.35).opacity(0.12), radius: 10, y: 5)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Begin Simulation")
                .accessibilityHint("Starts the lung simulation")
                // Increased spacing from bottom safe area from 40 to 64
                .padding(.bottom, 64)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    IntroView()
        .environmentObject(SimulationState())
}
