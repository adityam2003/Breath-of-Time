import SwiftUI

// MARK: - LungView

struct LungView: View {

    let oxygenEfficiency: Double
    var aqi: AQI = .good
    var exposure: TimeExposure = .oneYear

    // Separate X and Y breath states for organic directional expansion
    @State private var breathX: CGFloat = 1.00
    @State private var breathY: CGFloat = 1.00
    @State private var breathTrachea: Double = 1.00

    // Animated exposure modifiers — transition over 1.8s when exposure changes.
    @State private var exposureDesaturation: Double = 0.0
    @State private var exposureGlowDim: Double      = 0.0
    @State private var exposureAmplitude: Double    = 1.0

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
                LungLobe(widthScale: 1.00)
                    .fill(lungGradient)
                    .opacity(lungOpacity)
                    .frame(width: lobeW, height: lobeH)
                    // Top anchored: expands more horizontally than vertically,
                    // bottom bulges while top stays near the trachea.
                    .scaleEffect(x: breathX, y: breathY, anchor: .top)
                    .position(
                        x: w * 0.5 + gap * 0.5 + lobeW * 0.5,
                        y: lobeY + lobeH * 0.5
                    )

                // ── LEFT LOBE (mirrored + directional breath) ────────────
                LungLobe(widthScale: 0.88)
                    .fill(lungGradient)
                    .opacity(lungOpacity)
                    .frame(width: lobeW, height: lobeH)
                    // Negative breathX preserves mirror while breathing outward
                    .scaleEffect(x: -breathX, y: breathY, anchor: .top)
                    .position(
                        x: w * 0.5 - gap * 0.5 - lobeW * 0.5,
                        y: lobeY + lobeH * 0.5
                    )

                // ── TRACHEA + CARINA ─────────────────────────────────────
                TracheaShape(breathingFactor: breathTrachea)
                    .fill(lungGradient)
                    .opacity(lungOpacity)
                    .frame(width: tracW, height: tracH)
                    .position(x: w * 0.5, y: tracH * 0.5)

                // ── PARTICLE OVERLAY ──────────────────────────────────────
                // Covers the lobe area only. geo.size is reused — no nested GeometryReader.
                LungParticleOverlay(aqi: aqi, size: CGSize(width: w, height: h))
                    .position(x: w * 0.5, y: h * 0.5)
                    .clipShape(
                        // Soft ellipse mask keeps particles inside the lung silhouette.
                        Ellipse().scale(x: 0.88, y: 0.92)
                    )
            }
            // ── TIME-EXPOSURE MODIFIERS ───────────────────────────────────
            // Subtle desaturation + glow dim, animated on exposure change.
            .saturation(1.0 - exposureDesaturation)
            .brightness(-exposureGlowDim)
        }
        .onAppear {
            // Set exposure modifiers immediately (no transition on first appear).
            exposureDesaturation = exposure.desaturationAmount
            exposureGlowDim      = exposure.glowReduction
            exposureAmplitude    = exposure.breathingAmplitudeScale
            startBreathAnimation()
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

    // MARK: - Gradient (lighter at top, richer at bottom)

    private var lungGradient: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: Color(hue: 0.57, saturation: 0.52, brightness: 0.96), location: 0.00),
                .init(color: Color(hue: 0.58, saturation: 0.65, brightness: 0.80), location: 0.45),
                .init(color: Color(hue: 0.61, saturation: 0.70, brightness: 0.58), location: 1.00)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Opacity (dims as oxygenEfficiency drops)

    private var lungOpacity: Double {
        // 0.65 at worst (AQI hazardous) → 1.0 at best (clean air)
        0.65 + 0.35 * oxygenEfficiency
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
