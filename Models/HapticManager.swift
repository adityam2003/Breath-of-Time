import UIKit

// MARK: - Haptic Manager

/// Centralized haptic feedback helper.
/// Keeps views clean by providing simple static methods.
enum HapticManager {
    
    /// Very light tap — narrative transitions, subtle confirmations.
    static func soft() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred(intensity: 0.5)
    }
    
    /// Medium impact — confident button taps, significant actions.
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    /// Selection tick — picker changes, segment switches.
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    /// Success notification — task completion, response received.
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
