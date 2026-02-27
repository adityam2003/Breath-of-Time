import SwiftUI

// MARK: - Particle model

/// Immutable data bag created once per particle.
/// All animation offsets are pre-seeded so there are no random calls at render time.
private struct Particle: Identifiable {
    let id: Int

    // Normalised position within the lobe frame (0…1 each axis).
    let normX: CGFloat
    let normY: CGFloat

    // Pre-computed per-particle timing offsets (seconds) — keeps animations desynchronised.
    let phaseOffset: Double   // stagger for opacity pulse
    let riseOffset:  Double   // stagger for upward drift
    let driftOffset: Double   // stagger for lateral micro-drift

    // Particle geometry
    let radius:      CGFloat
    let blurRadius:  CGFloat   // pre-seeded, 0.5 – 0.8 pt
}

// MARK: - Factory

private enum ParticleFactory {
    /// Build a fixed-size array seeded deterministically from `count`.
    /// Using a predictable sequence avoids different particles each time the view
    /// is constructed while still spreading them evenly.
    static func make(count: Int) -> [Particle] {
        // Simple deterministic pseudo-random using a linear congruential step.
        var seed: UInt64 = 0xDEAD_BEEF_CAFE_F00D
        func next() -> Double {
            seed = seed &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
            return Double(seed >> 33) / Double(1 << 31)   // 0.0 ..< 2.0 → clamp below
        }
        func rand() -> Double { abs(next()).truncatingRemainder(dividingBy: 1.0) }

        return (0 ..< count).map { i in
            Particle(
                id:          i,
                normX:       CGFloat(rand()),
                normY:       CGFloat(rand()),
                phaseOffset: rand() * 4.0,          // 0 … 4 s
                riseOffset:  rand() * 6.0,          // 0 … 6 s
                driftOffset: rand() * 3.0,          // 0 … 3 s
                radius:      CGFloat(2.0 + rand() * 6.0),   // 2 … 8 pt
                blurRadius:  CGFloat(0.5 + rand() * 0.3)    // 0.5 … 0.8 pt
            )
        }
    }
}

// MARK: - Single animated particle

private struct ParticleView: View {

    let particle:     Particle
    let tint:         Color
    let baseOpacity:  Double   // max opacity ceiling set by AQI
    let useMultiply:  Bool     // blend mode for heavy pollution tiers

    // Tick that advances every animation cycle — drives the offset calculations.
    @State private var phase: Bool = false

    var body: some View {
        Circle()
            .fill(tint)
            // Opacity pulses between 15 % and baseOpacity on a staggered timer.
            .opacity(phase ? baseOpacity : baseOpacity * 0.15)
            .frame(width: particle.radius * 2, height: particle.radius * 2)
            // Subtle pre-seeded blur — kept small to avoid softness artifacts.
            .blur(radius: particle.blurRadius)
            // Multiply blend only for veryUnhealthy / hazardous; integrates with lung gradient.
            .blendMode(useMultiply ? .multiply : .normal)
            .animation(
                .easeInOut(duration: 2.8 + particle.phaseOffset * 0.4)
                    .repeatForever(autoreverses: true)
                    .delay(particle.phaseOffset),
                value: phase
            )
            .offset(
                x: phase ? particle.radius * 1.2  : -particle.radius * 0.8,
                y: phase ? -particle.radius * 3.0 :  particle.radius * 0.5
            )
            .animation(
                .easeInOut(duration: 3.5 + particle.riseOffset * 0.5)
                    .repeatForever(autoreverses: true)
                    .delay(particle.riseOffset),
                value: phase
            )
            .onAppear { phase = true }
    }
}

// MARK: - Overlay

/// Drop this on top of the lung lobes.  Pass the lobe frame size so particles
/// are placed relative to it — no nested GeometryReader needed.
struct LungParticleOverlay: View {

    // MARK: Inputs

    /// Current AQI. Controls particle count and opacity.
    let aqi: AQI

    /// Size of the *combined* lung area (both lobes + gap) in points.
    /// Caller supplies this from its own GeometryReader — no nesting.
    let size: CGSize

    // MARK: Derived constants

    private static let maxParticles = 40

    /// Exact per-AQI particle count per spec.
    private var activeCount: Int {
        switch aqi {
        case .good:               return 2
        case .moderate:           return 4
        case .unhealthySensitive: return 8
        case .unhealthy:          return 14
        case .veryUnhealthy:      return 22
        case .hazardous:          return 32
        }
    }

    /// Exact per-AQI max opacity per spec.
    /// Values are applied smoothly via the per-particle pulse animation.
    private var particleOpacity: Double {
        switch aqi {
        case .good:               return 0.08
        case .moderate:           return 0.18
        case .unhealthySensitive: return 0.30
        case .unhealthy:          return 0.42
        case .veryUnhealthy:      return 0.55
        case .hazardous:          return 0.75
        }
    }

    /// Whether to apply .multiply blend mode (heavy pollution tiers only).
    private var useMultiply: Bool {
        aqi == .veryUnhealthy || aqi == .hazardous
    }

    /// Muted environmental tints — dusty, desaturated, not colorful.
    /// Good: slate-gray haze. Moderate: greenish smog. Then rust → soot progression.
    private var particleTint: Color {
        switch aqi {
        case .good:               Color(hue: 0.58, saturation: 0.12, brightness: 0.62)  // slate mist
        case .moderate:           Color(hue: 0.22, saturation: 0.18, brightness: 0.55)  // dusty khaki
        case .unhealthySensitive: Color(hue: 0.10, saturation: 0.30, brightness: 0.50)  // warm dust
        case .unhealthy:          Color(hue: 0.07, saturation: 0.45, brightness: 0.42)  // rust-tan
        case .veryUnhealthy:      Color(hue: 0.05, saturation: 0.55, brightness: 0.34)  // dark rust
        case .hazardous:          Color(hue: 0.03, saturation: 0.60, brightness: 0.26)  // soot-brown
        }
    }

    // MARK: Fixed pool — created once, never reallocated

    private let pool: [Particle] = ParticleFactory.make(count: maxParticles)

    // MARK: Body

    var body: some View {
        // Render only the first `activeCount` particles from the fixed pool.
        ZStack {
            ForEach(pool.prefix(activeCount)) { p in
                ParticleView(
                    particle:    p,
                    tint:        particleTint,
                    baseOpacity: particleOpacity,
                    useMultiply: useMultiply
                )
                // Place relative to the overlay's own coordinate space — no GeometryReader.
                .position(
                    x: p.normX * size.width,
                    y: p.normY * size.height
                )
            }
        }
        // Allow rendering to the whole overlay frame without clipping.
        .frame(width: size.width, height: size.height)
        .allowsHitTesting(false)   // Never intercept touches
    }
}
