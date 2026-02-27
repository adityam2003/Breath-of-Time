import SwiftUI

struct MainSimulationView: View {
    
    @EnvironmentObject private var state: SimulationState
    @State private var isAQISheetPresented = false
    
    /// Projected lung vitality as a percentage, derived from oxygen efficiency.
    private var projectedVitalityPercent: Int {
        Int((state.oxygenEfficiency * 100).rounded())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  GROUP A — Status                                        ║
            // ╚══════════════════════════════════════════════════════════╝
            
            VStack(spacing: 4) {
                // AQI name — large, semibold, AQI-colored
                Text(state.selectedAQI.displayName)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(state.selectedAQI.color)
                    .animation(.easeInOut(duration: 0.35), value: state.selectedAQI)

                // AQI numeric range mapping
                Text("AQI \(state.selectedAQI.rangeDescription)")
                    .font(.subheadline)
                    .foregroundStyle(Color(.secondaryLabel).opacity(0.65))
                    .animation(.none, value: state.selectedAQI)
                
                // Exposure — muted secondary
                Text(state.selectedExposure.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color(.secondaryLabel))
                
                // Data line — projected vitality metric
                HStack(spacing: 4) {
                    Text("Projected Lung Vitality:")
                        .font(.caption)
                        .foregroundStyle(Color(.secondaryLabel))
                    Text("\(projectedVitalityPercent)%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(state.selectedAQI.color)
                        .animation(.easeInOut(duration: 0.4), value: projectedVitalityPercent)
                }
                .padding(.top, 2)
            }
            .padding(.top, 10)
            
            // ── Gap A→B
            Spacer().frame(height: 20)
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  GROUP B — Lung Visualisation                            ║
            // ╚══════════════════════════════════════════════════════════╝
            
            LungView(oxygenEfficiency: state.oxygenEfficiency,
                     aqi: state.selectedAQI,
                     exposure: state.selectedExposure)
            .frame(width: 320, height: 340)   // +6% from 300×320
            .shadow(color: .black.opacity(0.06), radius: 20, x: 0, y: 12)
            
            // ── Gap B→C
            Spacer().frame(height: 18)
            
            // ╔══════════════════════════════════════════════════════════╗
            // ║  GROUP C — Metrics + Controls                            ║
            // ╚══════════════════════════════════════════════════════════╝
            
            VStack(spacing: 10) {
                
                // Metric: progress bar with percentage
                VStack(spacing: 5) {
                    HStack {
                        Text("Oxygen Efficiency")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(Color(.secondaryLabel))
                        Spacer()
                        Text("\(projectedVitalityPercent)%")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(state.selectedAQI.color)
                            .animation(.easeInOut(duration: 0.4), value: projectedVitalityPercent)
                            .monospacedDigit()
                    }
                    .padding(.horizontal, 2)
                    
                    OxygenProgressBar(value: state.oxygenEfficiency, aqi: state.selectedAQI)
                }
                .frame(maxWidth: 260)
                
                // Insight sentence — AQI-keyed health copy
                Text(state.selectedAQI.insightText)
                    .font(.footnote)
                    .foregroundStyle(Color(.secondaryLabel))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .frame(maxWidth: 280)
                    .animation(.easeInOut(duration: 0.3), value: state.selectedAQI)
            }
            
            // Push controls to bottom
            Spacer()
            
            // ── Glass Control Panel
            VStack(spacing: 20) {
                
                // AQI Status Selector (Compact)
                VStack(spacing: 6) {
                    Text("AQI Status")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(Color(.secondaryLabel))
                    
                    Button {
                        isAQISheetPresented = true
                    } label: {
                        HStack(spacing: 6) {
                            Text(state.selectedAQI.displayName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(state.selectedAQI.color)
                            
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(state.selectedAQI.color.opacity(0.8))
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            Capsule()
                                .fill(state.selectedAQI.color.opacity(0.10))
                        )
                    }
                    .buttonStyle(.plain)
                }

                
                // Custom Exposure Picker
                CustomGlassPillPicker(
                    options: TimeExposure.allCases,
                    selection: $state.selectedExposure,
                    activeColor: state.selectedAQI.color,
                    labelFor: { $0.displayName }
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(.systemBackground).opacity(0.45))
                    .background(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .fill(state.selectedAQI.glowColor.opacity(0.04))
                    )
                    .background(.ultraThinMaterial)
            )
            .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 4)
            .padding(.horizontal, 8)
            .padding(.bottom, 12)
            
            Spacer().frame(height: 10)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(atmosphericBackground)
        .navigationTitle("Breath of Time")
        // ── AQI Bottom Sheet ───────────────────────────────────────────────
        .sheet(isPresented: $isAQISheetPresented) {
            AQISelectionSheet(
                selectedAQI: $state.selectedAQI,
                isPresented: $isAQISheetPresented
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    state.returnToIntro()
                }
            }
        }
    }
    
    // MARK: - Atmospheric Background
    
    @ViewBuilder
    private var atmosphericBackground: some View {
        ZStack {
            Color(.systemBackground)
            
            // Wide ambient layer — covers the whole screen softly.
            Ellipse()
                .fill(state.selectedAQI.glowColor.opacity(0.10))
                .frame(width: 620, height: 720)
                .blur(radius: 80)
                .animation(.easeInOut(duration: 0.8), value: state.selectedAQI)
            
            // Focused radial behind lungs — stronger, tighter.
            Ellipse()
                .fill(state.selectedAQI.glowColor.opacity(0.09))
                .frame(width: 300, height: 340)
                .blur(radius: 55)
                .offset(y: -40)
                .animation(.easeInOut(duration: 0.8), value: state.selectedAQI)
            
            // Noise grain — removes digital flatness.
            NoiseOverlay()
                .opacity(0.025)
                .blendMode(.multiply)
        }
        .ignoresSafeArea()
    }
    // MARK: - Helpers
    
    private func label(for aqi: AQI) -> String {
        switch aqi {
        case .good:               return "Good"
        case .moderate:           return "Moderate"
        case .unhealthySensitive: return "Sensitive"
        case .unhealthy:          return "Unhealthy"
        case .veryUnhealthy:      return "V.Unhealthy"
        case .hazardous:          return "Hazardous"
        }
    }
    
    // MARK: - Custom Glass Pill Picker
    
    
    /// A fully custom segmented control that floats inside the glass panel.
    /// Uses `matchedGeometryEffect` for a smooth sliding pill animation.
    private struct CustomGlassPillPicker<T: Hashable>: View {
        let options: [T]
        @Binding var selection: T
        let activeColor: Color
        let labelFor: (T) -> String
        
        @Namespace private var namespace
        
        var body: some View {
            HStack(spacing: 0) {
                ForEach(options, id: \.self) { option in
                    let isSelected = selection == option
                    
                    ZStack {
                        if isSelected {
                            // The sliding active pill background
                            Capsule()
                                .fill(Color(.systemBackground).opacity(0.85))
                                .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
                                .overlay(
                                    Capsule()
                                        .strokeBorder(activeColor.opacity(0.15), lineWidth: 0.5)
                                )
                                .matchedGeometryEffect(id: "pillBacking", in: namespace)
                        }
                        
                        Text(labelFor(option))
                            .font(.footnote)
                            .fontWeight(isSelected ? .semibold : .medium)
                        // Selected: full contrast. Unselected: muted secondary.
                            .foregroundStyle(isSelected ? Color(.label) : Color(.secondaryLabel).opacity(0.8))
                        // Optional subtle color tinting on selected text:
                        // .foregroundStyle(isSelected ? activeColor : Color(.secondaryLabel))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            selection = option
                        }
                    }
                }
            }
            .frame(height: 36)
            // The track behind the pills
            .background(
                Capsule()
                    .fill(Color(.systemGray6).opacity(0.5))
            )
        }
    }
    
    // MARK: - Custom Oxygen Progress Bar
    
    /// Rounded-capsule bar: AQI-tinted gradient fill, animated width + color.
    private struct OxygenProgressBar: View {
        var value: Double
        var aqi: AQI
        
        var body: some View {
            let (leadColor, trailColor) = aqi.progressGradientColors
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Track
                    Capsule()
                        .fill(Color(.systemGray5).opacity(0.55))
                    
                    // Fill with subtle inner glow via overlay
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [leadColor, trailColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(value))
                        .overlay(
                            // Subtle top highlight — inner glow effect
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.30), Color.clear],
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                )
                                .frame(width: geo.size.width * CGFloat(value))
                        )
                        .animation(.spring(response: 0.55, dampingFraction: 0.72), value: value)
                        .animation(.easeInOut(duration: 0.45), value: aqi)
                }
            }
            .frame(height: 10)
        }
    }
    
    // MARK: - Noise Grain Overlay
    
    private struct NoiseOverlay: View {
        var body: some View {
            Canvas { context, size in
                var rng = LCGRandom(seed: 137)
                let count = Int(size.width * size.height / 80)
                for _ in 0..<count {
                    let x = Double(rng.nextInt()) / Double(UInt32.max) * size.width
                    let y = Double(rng.nextInt()) / Double(UInt32.max) * size.height
                    let opacity = Double(rng.nextInt()) / Double(UInt32.max) * 0.55
                    context.fill(
                        Path(CGRect(x: x, y: y, width: 1.2, height: 1.2)),
                        with: .color(.black.opacity(opacity))
                    )
                }
            }
            .allowsHitTesting(false)
            .drawingGroup()
        }
    }
    
    private struct LCGRandom {
        private var state: UInt32
        init(seed: UInt32) { state = seed }
        mutating func nextInt() -> UInt32 {
            state = state &* 1664525 &+ 1013904223
            return state
        }
    }
}
// MARK: - AQI Selection Sheet

/// A clean vertical list presented as a bottom sheet for selecting the AQI level.
private struct AQISelectionSheet: View {
    @Binding var selectedAQI: AQI
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            List(AQI.allCases) { aqi in
                Button {
                    // Update state. updateOxygenEfficiency is called via property observer.
                    selectedAQI = aqi
                    isPresented = false
                } label: {
                    HStack(spacing: 14) {
                        // Colored Dot
                        Circle()
                            .fill(aqi.color)
                            .frame(width: 10, height: 10)
                        
                        // Full Text
                        VStack(alignment: .leading, spacing: 2) {
                            Text(aqi.displayName)
                                .font(.body)
                                .fontWeight(selectedAQI == aqi ? .semibold : .regular)
                                .foregroundColor(Color(.label))
                            
                            // Optional description
                            Text(aqi.rangeDescription + " AQI")
                                .font(.caption)
                                .foregroundColor(Color(.secondaryLabel))
                        }
                        
                        Spacer()
                        
                        // Checkmark
                        if selectedAQI == aqi {
                            Image(systemName: "checkmark")
                                .font(.body.weight(.semibold))
                                .foregroundColor(aqi.color)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(Color.clear)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Select AQI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .fontWeight(.medium)
                }
            }
        }
    }
}
