import SwiftUI
import AVFoundation

struct OpeningStoryView: View {
    @EnvironmentObject private var state: SimulationState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    @State private var storyStep: Int = 0
    @State private var breathScale: CGFloat = 0.95
    
    var body: some View {
        ZStack {
            // Background Layer
            animatedBackground
            
            // Atmospheric breathing gradient
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.04), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 400
                    )
                )
                .scaleEffect(reduceMotion ? 1.0 : breathScale)
                .blur(radius: 60)
                .ignoresSafeArea()
            
            // Subtle Particle Drift & Fog
            SubtleParticleDrift(storyStep: storyStep, reduceMotion: reduceMotion)
            
            // Text Layer
            VStack {
                Spacer()
                
                if storyStep == 0 {
                    Text("Every breath shapes us.")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .transition(.opacity)
                } else if storyStep == 1 {
                    Text("The air we live in shapes our future.")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .transition(.opacity)
                } else if storyStep >= 2 {
                    Text("Explore how time and air shape the body.")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .transition(.opacity)
                }
                
                Spacer()
            }
            .padding(.horizontal, 40)
            .animation(.easeInOut(duration: 1.5), value: storyStep)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(voiceOverLabel)
        .onAppear {
            runStorySequence()
            
            // Start continuous breathing animation (skip if Reduce Motion is on)
            if !reduceMotion {
                withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                    breathScale = 1.05
                }
            }
        }
    }
    
    // MARK: - VoiceOver
    
    private var voiceOverLabel: String {
        switch storyStep {
        case 0:
            return "Dark smog fills the screen. Every breath shapes us."
        case 1:
            return "The air begins to clear. The air we live in shapes our future."
        default:
            return "A calm haze remains. Explore how time and air shape the body."
        }
    }
    
    // MARK: - Animated Background
    
    @ViewBuilder
    private var animatedBackground: some View {
        ZStack {
            let baseColor: Color = {
                switch storyStep {
                case 0: return Color(red: 0.05, green: 0.08, blue: 0.15) // Dark navy
                case 1: return Color(red: 0.25, green: 0.35, blue: 0.45) // Muted blue
                default: return Color(red: 0.15, green: 0.22, blue: 0.30) // Haze
                }
            }()
            
            baseColor
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 2.0), value: storyStep)
            
            // Distant Lightning (Only active during the dark pollution/stormy phase)
            CinematicLightning(
                isActive: storyStep == 0 || storyStep >= 2,
                intensity: storyStep == 0 ? 0.35 : 0.15, // Muted in the final phase
                tintColor: storyStep == 0 ? Color(red: 0.6, green: 0.6, blue: 0.8) : Color(red: 0.8, green: 0.85, blue: 1.0)
            )
            
            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                
                ZStack {
                    Circle()
                        .fill(cloudColor(for: storyStep))
                        .frame(width: w * 0.8)
                        .blur(radius: 60)
                        .offset(x: storyStep == 1 ? -w * 0.2 : w * 0.1,
                                y: storyStep == 1 ? -h * 0.1 : h * 0.2)
                    
                    Circle()
                        .fill(cloudColor(for: storyStep).opacity(0.8))
                        .frame(width: w * 1.2)
                        .blur(radius: 80)
                        .offset(x: storyStep == 1 ? w * 0.3 : -w * 0.2,
                                y: storyStep == 1 ? h * 0.2 : -h * 0.1)
                }
                .animation(.easeInOut(duration: 3.5), value: storyStep)
            }
            .ignoresSafeArea()
            
            NoiseOverlay()
                .opacity(0.04)
                .blendMode(.multiply)
                .ignoresSafeArea()
        }
    }
    
    private func cloudColor(for step: Int) -> Color {
        switch step {
        case 0: return Color(red: 0.10, green: 0.15, blue: 0.25)
        case 1: return Color(red: 0.35, green: 0.45, blue: 0.55)
        default: return Color(red: 0.20, green: 0.28, blue: 0.38)
        }
    }
    
    // MARK: - Sequence Logic
    
    private func runStorySequence() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            storyStep = 1
            HapticManager.soft()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.5) {
            storyStep = 2
            HapticManager.soft()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 13.0) {
            withAnimation(.easeInOut(duration: 1.5)) {
                state.phase = .intro
            }
        }
    }
    
    // MARK: - Components
    
    private struct NoiseOverlay: View {
        var body: some View {
            Canvas { context, size in
                var rng = LCGRandom(seed: 42)
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

// MARK: - Extremely Subtle Particle Drift

// MARK: - Dramatic Particle Drift & Smog

private struct SubtleParticleDrift: View {
    var storyStep: Int
    var reduceMotion: Bool
    
    var body: some View {
        if reduceMotion {
            // Static fallback: a very faint gradient shimmer instead of moving particles
            Color.clear
        } else {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let now = timeline.date.timeIntervalSinceReferenceDate
                var rng = LCGRandom(seed: 88)
                
                // Base configuration alters dramatically based on story context
                let isPollution = storyStep == 0
                let isReflection = storyStep == 1
                
                // Keep pollution dramatic, but bring reflection and clean counts up a bit for better visibility
                let particleCount = isPollution ? 120 : (isReflection ? 55 : 50)
                
                // Smog moves fast, Reflection rises steadily, Clean air floats a bit more actively now
                let speedMult = isPollution ? 0.8 : (isReflection ? 0.25 : 0.35)
                
                // Smog falls heavily (-1.0), Bubbles rise steadily (0.6), Clean air gently rises (0.3)
                let yDirection: Double = isPollution ? -1.0 : (isReflection ? 0.6 : 0.3)
                
                for i in 0..<particleCount {
                    let randomX = Double(rng.nextInt()) / Double(UInt32.max)
                    let randomY = Double(rng.nextInt()) / Double(UInt32.max)
                    let randomSpeed = (Double(rng.nextInt()) / Double(UInt32.max)) * speedMult + (isPollution ? 0.2 : 0.1)
                    
                    let sizeType = Double(rng.nextInt()) / Double(UInt32.max)
                    let randomSize: Double
                    if isPollution {
                        if sizeType > 0.85 {
                            randomSize = (Double(rng.nextInt()) / Double(UInt32.max)) * 25.0 + 10.0
                        } else if sizeType > 0.4 {
                            randomSize = (Double(rng.nextInt()) / Double(UInt32.max)) * 8.0 + 3.0
                        } else {
                            randomSize = (Double(rng.nextInt()) / Double(UInt32.max)) * 2.5 + 1.0
                        }
                    } else if isReflection {
                        // Slightly larger, more pronounced bubbles
                        randomSize = (Double(rng.nextInt()) / Double(UInt32.max)) * 16.0 + 4.0 
                    } else {
                        // Clean air specks are slightly thicker now
                        randomSize = (Double(rng.nextInt()) / Double(UInt32.max)) * 2.5 + 1.0 
                    }
                        
                    // Increase opacities across the board for screens 2 & 3
                    let randomOpt: Double
                    if isPollution {
                        randomOpt = (Double(rng.nextInt()) / Double(UInt32.max)) * 0.6 + 0.2 
                    } else if isReflection {
                        randomOpt = (Double(rng.nextInt()) / Double(UInt32.max)) * 0.15 + 0.05 // Fainter bubbles
                    } else {
                        randomOpt = (Double(rng.nextInt()) / Double(UInt32.max)) * 0.45 + 0.15 
                    }
                    
                    let timeOffset = now * randomSpeed * (isPollution ? 25.0 : 15.0) * yDirection
                    let sway = sin(now * randomSpeed * 0.5 + Double(i)) * (isPollution ? 40.0 : 25.0)
                    
                    let theXOffset = isPollution && sizeType < 0.2 ? now * randomSpeed * 40.0 : 0
                    
                    let xPos = (randomX * size.width) + sway + theXOffset
                    var yPos = (randomY * size.height) - timeOffset
                    
                    // Wrap around
                    yPos = yPos.truncatingRemainder(dividingBy: size.height + 200)
                    if yPos < -100 { yPos += size.height + 200 }
                    
                    var xWrap = xPos.truncatingRemainder(dividingBy: size.width + 200)
                    if xWrap < -100 { xWrap += size.width + 200 }
                    
                    var path = Path()
                    path.addEllipse(in: CGRect(x: xWrap, y: yPos, width: randomSize, height: randomSize))
                    
                    if isReflection {
                        // Solid glowing edge for bubbles
                        context.stroke(path, with: .color(.white.opacity(randomOpt)), lineWidth: max(1.0, randomSize * 0.08))
                        // Extremely faint inner fill for depth
                        context.fill(path, with: .color(.white.opacity(randomOpt * 0.15)))
                    } else {
                        let colorTypes: [Color] = [
                            Color(red: 0.05, green: 0.05, blue: 0.08), 
                            Color(red: 0.15, green: 0.12, blue: 0.10), 
                            Color(red: 0.25, green: 0.25, blue: 0.30)  
                        ]
                        let colorIndex = Int(Double(rng.nextInt()) / Double(UInt32.max) * 3)
                        
                        let color: Color = isPollution ? colorTypes[colorIndex % 3] : .white
                        
                        context.fill(path, with: .color(color.opacity(randomOpt)))
                    }
                }
            }
        }
        .allowsHitTesting(false)
        // Reduced heavy blur so shapes stay sharp and identifiable
        .blur(radius: storyStep == 0 ? 0.8 : (storyStep == 1 ? 1.0 : 0.0))
        .opacity(1.0) // Kept at full 1.0 opacity on the container, control opacity purely via Canvas
        .animation(.easeInOut(duration: 2.0), value: storyStep)
        } // end if !reduceMotion
    }
    
    // Quick local LCG for the timeline view so it doesn't collide with the noise layer
    private struct LCGRandom {
        private var state: UInt32
        init(seed: UInt32) { state = seed }
        mutating func nextInt() -> UInt32 {
            state = state &* 1664525 &+ 1013904223
            return state
        }
    }
}

// MARK: - Minimal Ambient Sound Manager
// Generates an incredibly soft, low-passed white noise that simulates quiet breathing/wind.

final class AmbientSoundManager: @unchecked Sendable {
    static let shared = AmbientSoundManager()
    
    private let engine = AVAudioEngine()
    private var isSetup = false
    private var volumeTimer: Timer?
    
    private var currentTargetVolume: Float = 0.0
    private var currentActualVolume: Float = 0.0
    
    private init() { }
    
    private func setup() {
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)
        
        let sourceNode = AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            for frame in 0..<Int(frameCount) {
                // Highly muted white noise generator
                let val = Float.random(in: -1...1) * 0.04
                for buffer in ablPointer {
                    let buf = UnsafeMutableBufferPointer<Float>(buffer)
                    if frame < buf.count {
                        buf[frame] = val
                    }
                }
            }
            return noErr
        }
        
        let filter = AVAudioUnitEQ(numberOfBands: 1)
        filter.bands[0].filterType = .lowPass
        filter.bands[0].frequency = 300.0 // Super muddy, distant wind/breath
        filter.bands[0].bandwidth = 1.0
        
        engine.attach(sourceNode)
        engine.attach(filter)
        
        engine.connect(sourceNode, to: filter, format: format)
        engine.connect(filter, to: engine.mainMixerNode, format: format)
        isSetup = true
    }
    
    @MainActor
    func start() {
        if !isSetup { setup() }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            engine.mainMixerNode.volume = 0.0
            currentActualVolume = 0.0
            currentTargetVolume = 0.6 // Starts softly
            
            try engine.start()
            
            volumeTimer?.invalidate()
            volumeTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                // Ease volume smoothly preventing audio popping
                self.currentActualVolume += (self.currentTargetVolume - self.currentActualVolume) * 0.015
                self.engine.mainMixerNode.volume = self.currentActualVolume
            }
        } catch {
            print("AmbientSoundManager error: \(error)")
        }
    }
    
    @MainActor
    func setPresence(_ presence: Float) {
        currentTargetVolume = presence
    }
    
    @MainActor
    func stop() {
        currentTargetVolume = 0.0
        // Wait for volume to fade before stopping engine
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.engine.stop()
            self?.volumeTimer?.invalidate()
            self?.volumeTimer = nil
        }
    }
}

#Preview {
    OpeningStoryView()
        .environmentObject(SimulationState())
}
