import SwiftUI

/// Animated lightning flashes that appear randomly in the background
struct CinematicLightning: View {
    @State private var flashOpacity: Double = 0.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // Configurable parameters
    var isActive: Bool = true
    var intensity: Double = 0.4
    var tintColor: Color = Color(red: 0.8, green: 0.85, blue: 1.0)
    
    var body: some View {
        ZStack {
            // Screen-wide flash
            Color.white
                .opacity(flashOpacity * intensity)
                .blendMode(.overlay)
                .ignoresSafeArea()
            
            // Localized core flash matching tint
            RadialGradient(
                colors: [tintColor.opacity(flashOpacity * intensity * 1.5), .clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: UIScreen.main.bounds.height * 0.8
            )
            .blendMode(.plusLighter)
            .ignoresSafeArea()
        }
        .allowsHitTesting(false)
        .onAppear {
            if isActive {
                scheduleNextStrike()
            }
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                scheduleNextStrike()
            } else {
                flashOpacity = 0.0
            }
        }
    }
    
    private func scheduleNextStrike() {
        guard isActive, !reduceMotion else { return }
        
        let delay = Double.random(in: 2.0...6.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard isActive else { return }
            
            // Trigger a single dramatic flash or a double-flutter flash
            let isDouble = Bool.random()
            let duration = Double.random(in: 0.05...0.15)
            
            withAnimation(.easeInOut(duration: duration)) {
                flashOpacity = Double.random(in: 0.4...1.0)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                withAnimation(.easeOut(duration: duration * 2.5)) {
                    flashOpacity = isDouble ? 0.3 : 0.0
                }
                
                if isDouble {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration * 3.5) {
                        withAnimation(.easeInOut(duration: 0.08)) {
                            flashOpacity = Double.random(in: 0.5...0.9)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                            withAnimation(.easeOut(duration: 0.4)) {
                                flashOpacity = 0.0
                            }
                            scheduleNextStrike()
                        }
                    }
                } else {
                    scheduleNextStrike()
                }
            }
        }
    }
}
