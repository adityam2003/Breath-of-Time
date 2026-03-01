import SwiftUI

struct MainSimulationView: View {
    
    @EnvironmentObject private var state: SimulationState
    @State private var isAQISheetPresented = false
    
    /// Tracks scroll position to slightly fade lungs natively
    @State private var scrollOffset: CGFloat = 0
    
    /// Projected lung vitality as a percentage, derived from oxygen efficiency.
    private var projectedVitalityPercent: Int {
        Int((state.oxygenEfficiency * 100).rounded())
    }
    
    var body: some View {
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    // MAIN SCREEN VSTACK (Pre-scroll identical layout)
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
            
            LungView(
                oxygenEfficiency: state.oxygenEfficiency,
                aqi: state.selectedAQI,
                exposure: state.selectedExposure
            )
            .frame(width: 320, height: 340)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Interactive lung simulation showing effects of \(state.selectedAQI.displayName) air quality over \(state.selectedExposure.displayName)")
            .shadow(color: .black.opacity(0.06), radius: 20, x: 0, y: 12)
            // Progressively fade lungs slightly out as user scrolls up
            .opacity(max(0.92, 1.0 - (max(0, -scrollOffset) / 800.0)))
            
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
                        HapticManager.soft()
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
                    .accessibilityLabel("Air Quality Index: \(state.selectedAQI.displayName)")
                    .accessibilityHint("Opens AQI selection")
                }

                
                // Custom Exposure Picker
                CustomGlassPillPicker(
                    options: TimeExposure.allCases,
                    selection: $state.selectedExposure,
                    activeColor: state.selectedAQI.color,
                    labelFor: { $0.displayName }
                )
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Exposure Duration: \(state.selectedExposure.displayName)")
                .accessibilityAddTraits(.isButton)
                .onChange(of: state.selectedExposure) { _, _ in
                    HapticManager.selection()
                }
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
            
            // ── Scroll Indicator (Animated Bouncing Arrow) ──
            ScrollIndicatorChevron(color: state.selectedAQI.color)
                .opacity(max(0, 1.0 - (max(0, scrollOffset) / 20.0))) // Fades out as user scrolls down
            
            Spacer().frame(height: 10)
                    }
                    .frame(minHeight: geo.size.height)
                    
                    // ── SCROLL SECTION: Subtle Gradient Divider ────────
                    VStack(spacing: 0) {
                        LinearGradient(
                            colors: [Color.clear, state.selectedAQI.glowColor.opacity(0.12)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 80)
                        .padding(.top, 10)
                        
                        // Invisible tracker to measure scroll
                        GeometryReader { innerGeo in
                            Color.clear
                                .onChange(of: innerGeo.frame(in: .global).minY) { _, newValue in
                                    scrollOffset = newValue
                                }
                        }
                        .frame(height: 0)

                        // ── SCROLL SECTION: Health Risks (Redesigned) ──────
                        VStack(alignment: .leading, spacing: 24) {
                            // Section Header
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Air Quality Profile")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .tracking(1.5)
                                    .foregroundStyle(state.selectedAQI.color)
                                
                                Text("Health Impact")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color(.label).opacity(0.9))
                            }
                            
                            // Main Impact Text (Two-tier, Left-aligned)
                            VStack(alignment: .leading, spacing: 8) {
                                Text(state.selectedAQI.healthRisks.primary)
                                    .font(.system(size: 18, weight: .regular, design: .serif))
                                    .foregroundStyle(Color(.label).opacity(0.9))
                                    .lineSpacing(4)
                                
                                Text(state.selectedAQI.healthRisks.secondary)
                                    .font(.subheadline)
                                    .foregroundStyle(Color(.secondaryLabel))
                                    .lineSpacing(4)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 32)
                        .padding(.top, 32)
                        .accessibilityElement(children: .combine)
                        .scrollTransition(.animated.threshold(.visible(0.9))) { effect, phase in
                            effect.opacity(phase.isIdentity ? 1 : 0.6)
                        }
                        
                        // ── Soft Divider ──
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.clear, Color(.systemGray4).opacity(0.4), .clear],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .frame(height: 1)
                            .padding(.vertical, 40)
                            .padding(.horizontal, 40)

                        // ── SCROLL SECTION: Preventive Actions (Redesigned) ─
                        VStack(alignment: .leading, spacing: 32) {
                            Text("Recommended Precautions")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color(.label).opacity(0.85))
                                .scrollTransition(.animated.threshold(.visible(0.9))) { effect, phase in
                                    effect.opacity(phase.isIdentity ? 1 : 0.6)
                                }
                            
                            // Using standard whitespace instead of hard lines
                            VStack(alignment: .leading, spacing: 24) {
                                ForEach(Array(state.selectedAQI.preventiveMessages.enumerated()), id: \.element) { index, msg in
                                    HStack(alignment: .top, spacing: 16) {
                                        Image(systemName: "checkmark.seal.fill")
                                            .font(.title3.weight(.medium))
                                            .foregroundStyle(state.selectedAQI.color)
                                            .opacity(0.8)
                                        
                                        Text(msg)
                                            .font(.subheadline)
                                            .foregroundStyle(Color(.secondaryLabel).opacity(0.85))
                                            .lineSpacing(4)
                                        
                                        Spacer(minLength: 0)
                                    }
                                    .padding(.horizontal, 8)
                                    .scrollTransition(.animated.threshold(.visible(0.9))) { effect, phase in
                                        effect
                                            .opacity(phase.isIdentity ? 1 : 0.6)
                                            .offset(y: phase.isIdentity ? 0 : 8)
                                    }
                                }
                            }
                            .frame(maxWidth: 340)
                            .animation(.easeInOut(duration: 0.35), value: state.selectedAQI)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 40)
                        .accessibilityElement(children: .combine)
                        
                        // ── INLINE: Environmental Health Insight (Apple Intelligence) ──
                        if #available(iOS 26, *) {
                            EnvironmentalInsightView(
                                aqi: state.selectedAQI,
                                exposure: state.selectedExposure,
                                oxygenEfficiency: state.oxygenEfficiency
                            )
                            .padding(.horizontal, 32)
                            .padding(.bottom, 40)
                        }
                        
                        // ── Scroll Indicator to final page ──
                        ScrollIndicatorChevron(color: state.selectedAQI.color)
                            .padding(.bottom, 60)
                        
                        // ── SCROLL SECTION: Reflection (Full Screen Page 3) ──
                        VStack(spacing: 40) {
                            Spacer()
                            
                            VStack(spacing: 16) {
                                Text("A Moment to Reflect")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color(.label).opacity(0.85))
                                
                                Text("Long-term exposure shapes lung health.\nEvery breath and daily choice determines your recovery.")
                                    .font(.subheadline)
                                    .foregroundStyle(Color(.secondaryLabel))
                                    .multilineTextAlignment(.center)
                                    .lineSpacing(6)
                                    .padding(.horizontal, 40)
                            }
                            
                            // A lightweight guided breathing circle
                            ReflectionBreathingView(color: state.selectedAQI.color)
                                .padding(.vertical, 20)
                                .accessibilityLabel("Guided breathing exercise")
                            
                            Spacer()
                            
                            // Footer marking the end (Animated 20s delay)
                            ReflectionFooterView(color: state.selectedAQI.color) {
                                state.returnToIntro()
                            }
                        }
                        .containerRelativeFrame(.vertical) // Makes it take up exactly 1 screen height
                        .frame(maxWidth: .infinity)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("A Moment to Reflect. Long-term exposure shapes lung health. Every breath and daily choice determines your recovery.")
                        .background(
                            RadialGradient(
                                colors: [state.selectedAQI.glowColor.opacity(0.08), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 250
                            )
                        )
                        .scrollTransition(.animated.threshold(.visible(0.8))) { effect, phase in
                            effect.opacity(phase.isIdentity ? 1 : 0.0)
                        }
                    }
                    .background(Color.white.opacity(0.03))
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
        }
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

// MARK: - Scroll Indicator Chevron

/// A subtle, animated bouncing chevron to indicate scrollability without adding clutter.
private struct ScrollIndicatorChevron: View {
    var color: Color
    @State private var bounceOffset: CGFloat = 0
    
    var body: some View {
        Image(systemName: "chevron.compact.down")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(color.opacity(0.6))
            .offset(y: bounceOffset)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    bounceOffset = 4.0
                }
            }
    }
}

// MARK: - Reflection Breathing View

/// A calming, slow-pulsing circle that encourages the user to match their breathing.
/// It uses a 4-second inhale and 6-second exhale rhythm, universally recognized as relaxing.
private struct ReflectionBreathingView: View {
    var color: Color
    
    @State private var isInhaling = false
    @State private var phaseText = "Breathe in"
    @State private var timeRemaining = 4
    @State private var contextMessage = ""
    
    private let inhaleDuration = 4
    private let exhaleDuration = 6
    
    private let inhaleMessages = [
        "Draw in the air you have left.",
        "A deep breath, despite it all.",
        "Fill your lungs."
    ]
    
    private let exhaleMessages = [
        "Release the tension.",
        "Let the air go.",
        "A quiet moment."
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                // Outer ambient glow
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: isInhaling ? 140 : 80, height: isInhaling ? 140 : 80)
                    .blur(radius: isInhaling ? 16 : 8)
                
                // Inner solid core
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.6), color.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: isInhaling ? 90 : 60, height: isInhaling ? 90 : 60)
            }
            .frame(height: 140)
            
            VStack(spacing: 6) {
                Text(phaseText)
                    .font(.subheadline)
                    .tracking(1.0)
                    .foregroundStyle(Color(.label).opacity(0.8))
                    .id(phaseText)
                    .transition(.opacity.animation(.easeInOut(duration: 1.0)))
                
                Text(contextMessage)
                    .font(.footnote)
                    .foregroundStyle(Color(.secondaryLabel))
                    .id(contextMessage)
                    .transition(.opacity.animation(.easeInOut(duration: 1.0)))
            }
        }
        .onAppear {
            startBreathingCycle()
        }
    }
    
    private func startBreathingCycle() {
        // Run immediately without waiting for timer
        triggerInhale()
        
        let totalCycleTime = Double(inhaleDuration + exhaleDuration)
        
        // Timer for the overarching phase changes (every 10 seconds)
        Timer.scheduledTimer(withTimeInterval: totalCycleTime, repeats: true) { _ in
            triggerExhale()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(exhaleDuration)) {
                triggerInhale()
            }
        }
        
        // Timer for the 1-second countdown ticks
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 1 {
                timeRemaining -= 1
            }
        }
    }
    
    private func triggerInhale() {
        withAnimation(.easeInOut(duration: Double(inhaleDuration))) {
            isInhaling = true
            phaseText = "Breathe in"
            timeRemaining = inhaleDuration
        }
        
        // Randomly pick a message for the inhale
        withAnimation(.easeInOut(duration: 1.0)) {
            contextMessage = inhaleMessages.randomElement() ?? ""
        }
    }
    
    private func triggerExhale() {
        withAnimation(.easeInOut(duration: Double(exhaleDuration))) {
            isInhaling = false
            phaseText = "Breathe out"
            timeRemaining = exhaleDuration
        }
        
        // Randomly pick a message for the exhale
        withAnimation(.easeInOut(duration: 1.0)) {
            contextMessage = exhaleMessages.randomElement() ?? ""
        }
    }
}

// MARK: - Reflection Footer View

/// Handles the 20-second delay to transition the bottom text into a glowing completion button.
private struct ReflectionFooterView: View {
    var color: Color
    var onComplete: () -> Void
    
    @State private var isComplete = false
    
    var body: some View {
        ZStack {
            if !isComplete {
                Text("Breathe with the rhythm.")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(Color(.tertiaryLabel))
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                Button(action: onComplete) {
                    VStack(spacing: 8) {
                        Text("Simulation Ended")
                            .font(.headline)
                            .tracking(1.2)
                            .foregroundStyle(color)
                            .shadow(color: color.opacity(0.8), radius: 6, x: 0, y: 0)
                        
                        Text("Tap here to Continue...")
                            .font(.caption)
                            .foregroundStyle(Color(.secondaryLabel))
                    }
                }
                .buttonStyle(.plain)
                .transition(.opacity.combined(with: .scale(scale: 1.05)))
            }
        }
        .multilineTextAlignment(.center)
        .padding(.bottom, 80)
        // Invisible tracker to start the 20s timer ONLY when the user actually scrolls to this page.
        .background(
            GeometryReader { geo in
                Color.clear
                    .onChange(of: geo.frame(in: .global).minY) { _, newValue in
                        // When the footer comes into the safe visible area of the screen
                        let screenHeight = UIScreen.main.bounds.height
                        if newValue < screenHeight && !hasStartedTimer {
                            startCompletionTimer()
                        }
                    }
            }
        )
    }
    
    @State private var hasStartedTimer = false
    
    private func startCompletionTimer() {
        hasStartedTimer = true
        // Exactly 2 breathing cycles (4s inhale + 6s exhale) * 2 = 20 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
            withAnimation(.easeInOut(duration: 1.5)) {
                isComplete = true
            }
        }
    }
}
