import SwiftUI

// MARK: - LungView

struct LungView: View {

    let oxygenEfficiency: Double
    var aqi: AQI = .good
    var exposure: TimeExposure = .oneYear
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // Separate X and Y breath states for organic directional expansion
    @State private var breathX: CGFloat = 1.00
    @State private var breathY: CGFloat = 1.00
    @State private var breathTrachea: Double = 1.00

    // Animated exposure modifiers — transition over 1.8s when exposure changes.
    @State private var exposureDesaturation: Double = 0.0
    @State private var exposureGlowDim: Double      = 0.0
    @State private var exposureAmplitude: Double    = 1.0
    
    @State private var isAppeared: Bool = false

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            let lobeW: CGFloat = w * 0.42
            let lobeH: CGFloat = h * 0.86
            let gap:   CGFloat = w * 0.13
            let lobeY: CGFloat = h * 0.15

            let tracW: CGFloat = w
            let tracH: CGFloat = h * 0.28

            ZStack {

                // ── RIGHT LOBE ───────────────────────────────────────────
                ZStack {
                    LungLobe(widthScale: 1.00)
                        .fill(clinicalBaseGradient)
                        .overlay(
                            LungLobe(widthScale: 1.00)
                                .fill(aqiStrainOverlayColor)
                                .blendMode(.multiply)
                        )
                        // Inner shadow for anatomical depth, slightly deeper as vitality drops
                        .overlay(
                            LungLobe(widthScale: 1.00)
                                .stroke(Color.black.opacity(0.15 + (1.0 - aqi.severityLevel) * 0.1), lineWidth: 1.5)
                                .blur(radius: 4)
                                .blendMode(.multiply)
                                .mask(LungLobe(widthScale: 1.00))
                        )
                }
                .opacity(isAppeared ? lungOpacity : 0.0)
                .frame(width: lobeW, height: lobeH)
                // Top anchored: expands more horizontally than vertically,
                // bottom bulges while top stays near the trachea.
                .scaleEffect(x: breathX, y: breathY, anchor: .top)
                .position(
                    x: w * 0.5 + gap * 0.5 + lobeW * 0.5,
                    y: lobeY + lobeH * 0.5
                )

                // ── LEFT LOBE (mirrored + directional breath) ────────────
                ZStack {
                    LungLobe(widthScale: 0.88)
                        .fill(clinicalBaseGradient)
                        .overlay(
                            LungLobe(widthScale: 0.88)
                                .fill(aqiStrainOverlayColor)
                                .blendMode(.multiply)
                        )
                        .overlay(
                            LungLobe(widthScale: 0.88)
                                .stroke(Color.black.opacity(0.15 + (1.0 - aqi.severityLevel) * 0.1), lineWidth: 1.5)
                                .blur(radius: 4)
                                .blendMode(.multiply)
                                .mask(LungLobe(widthScale: 0.88))
                        )
                }
                .opacity(isAppeared ? lungOpacity : 0.0)
                .frame(width: lobeW, height: lobeH)
                // Negative breathX preserves mirror while breathing outward
                .scaleEffect(x: -breathX, y: breathY, anchor: .top)
                .position(
                    x: w * 0.5 - gap * 0.5 - lobeW * 0.5,
                    y: lobeY + lobeH * 0.5
                )

                // ── TRACHEA + CARINA ─────────────────────────────────────
                TracheaShape(breathingFactor: breathTrachea)
                    .fill(clinicalBaseGradient)
                    .overlay(
                        TracheaShape(breathingFactor: breathTrachea)
                            .fill(aqiStrainOverlayColor)
                            .blendMode(.multiply)
                    )
                    .opacity(isAppeared ? lungOpacity : 0.0)
                    .frame(width: tracW, height: tracH)
                    .position(x: w * 0.5, y: tracH * 0.5)


                // ── PARTICLE OVERLAY ──────────────────────────────────────
                // Covers the lobe area only. geo.size is reused — no nested GeometryReader.
                LungParticleOverlay(aqi: aqi, size: CGSize(width: w, height: h))
                    .position(x: w * 0.5, y: h * 0.5)
                    .opacity(isAppeared ? .init(lungOpacity) : 0.0)
                    .clipShape(
                        // Soft ellipse mask keeps particles inside the lung silhouette.
                        Ellipse().scale(x: 0.88, y: 0.92)
                    )

            }
            // ── TIME-EXPOSURE MODIFIERS ───────────────────────────────────
            // Subtle desaturation + glow dim, animated on exposure change.
            // If AQI is Good (.severityLevel == 1.0), decay is almost completely mitigated.
            // Decay impact ramps up as severityLevel drops (worsening AQI).
            .saturation(1.0 - exposureDesaturation * ((1.05 - aqi.severityLevel) * 2.0))
            .brightness(-exposureGlowDim * ((1.05 - aqi.severityLevel) * 2.0))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Lung visualization")
        .onAppear {
            // Set exposure modifiers immediately (no transition on first appear).
            exposureDesaturation = exposure.desaturationAmount
            exposureGlowDim      = exposure.glowReduction
            exposureAmplitude    = exposure.breathingAmplitudeScale
            if !reduceMotion {
                startBreathAnimation()
            }
            
            // Soft delayed fade-in when the simulation starts
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    isAppeared = true
                }
            }
        }
        .onChange(of: exposure) { _, newExposure in
            // Animate any exposure change over 1.8 seconds.
            withAnimation(.easeInOut(duration: 1.8)) {
                exposureDesaturation = newExposure.desaturationAmount
                exposureGlowDim      = newExposure.glowReduction
                exposureAmplitude    = newExposure.breathingAmplitudeScale
            }
        }
    }

    // MARK: - Breath animation

    private func startBreathAnimation() {
        let amp = CGFloat(oxygenEfficiency * exposureAmplitude)

        // Horizontal expands more (organic feel — ribs push outward)
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            breathX = 1.0 + 0.065 * amp    // ±6.5% horizontal
        }
        // Vertical is subtler (diaphragm drops, but less visible change)
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            breathY = 1.0 + 0.028 * amp    // ±2.8% vertical
        }
        // Trachea breathes very slightly
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            breathTrachea = 1.0 + 0.015 * amp
        }
    }

    // MARK: - Base Anatomical Gradient (Medically Neutral Blue)
    
    // A clean, clinical blue that looks healthy and premium
    private var clinicalBaseGradient: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: Color(hue: 0.59, saturation: 0.45, brightness: 0.95), location: 0.00),
                .init(color: Color(hue: 0.60, saturation: 0.55, brightness: 0.82), location: 0.45),
                .init(color: Color(hue: 0.63, saturation: 0.65, brightness: 0.65), location: 1.00)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Environmental Strain Modifiers
    
    // Subtle atmospheric tint using the active AQI color (max 12% opacity)
    private var aqiStrainOverlayColor: Color {
        // Less overall visibility of the tint if the air is Good (severity close to 1.0)
        let intensity = 0.12 * (1.1 - aqi.severityLevel)
        return aqi.color.opacity(max(0.02, intensity))
    }

    private var lungOpacity: Double {
        // Keeps the lung structure highly visible but slightly fades at extreme hazard levels
        0.85 + 0.15 * aqi.severityLevel
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 24) {
        LungView(oxygenEfficiency: 1.0, aqi: .good,      exposure: .oneYear)
            .frame(width: 320, height: 360)
        LungView(oxygenEfficiency: 0.6, aqi: .unhealthy, exposure: .fiveYears)
            .frame(width: 320, height: 360)
        LungView(oxygenEfficiency: 0.3, aqi: .hazardous, exposure: .tenYears)
            .frame(width: 320, height: 360)
    }
    .background(Color.white)
}
