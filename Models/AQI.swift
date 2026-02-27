import Foundation
import SwiftUI

/// Air Quality Index categories aligned with standard AQI classification.
/// Used for visualization purposes (not real-time reporting).
enum AQI: CaseIterable, Identifiable {

    case good
    case moderate
    case unhealthySensitive
    case unhealthy
    case veryUnhealthy
    case hazardous

    var id: Self { self }

    // MARK: - Official Display Name

    var displayName: String {
        switch self {
        case .good:
            return "Good"
        case .moderate:
            return "Moderate"
        case .unhealthySensitive:
            return "Unhealthy for Sensitive Groups"
        case .unhealthy:
            return "Unhealthy"
        case .veryUnhealthy:
            return "Very Unhealthy"
        case .hazardous:
            return "Hazardous"
        }
    }

    // MARK: - Official AQI Range

    var rangeDescription: String {
        switch self {
        case .good:
            return "0–50"
        case .moderate:
            return "51–100"
        case .unhealthySensitive:
            return "101–150"
        case .unhealthy:
            return "151–200"
        case .veryUnhealthy:
            return "201–300"
        case .hazardous:
            return "301+"
        }
    }

    // MARK: - Health Insight

    /// A single-sentence health insight keyed to each AQI level.
    /// Shown below the oxygen bar to make the simulation feel like a health product.
    var insightText: String {
        switch self {
        case .good:
            return "Clean air supports optimal long-term oxygen absorption."
        case .moderate:
            return "Mild pollutants may slightly reduce respiratory efficiency over time."
        case .unhealthySensitive:
            return "Sensitive groups experience reduced airway function at this level."
        case .unhealthy:
            return "Prolonged exposure begins to compromise lung tissue elasticity."
        case .veryUnhealthy:
            return "Persistent inflammation reduces your lungs' capacity to recover."
        case .hazardous:
            return "At this level, irreversible lung damage can develop within years."
        }
    }


    /// The official color associated with each AQI band.
    /// Used to tint UI elements (title text, picker segments, etc.)
    var color: Color {
        switch self {
        case .good:
            return Color(red: 0.20, green: 0.72, blue: 0.30)   // green
        case .moderate:
            return Color(red: 0.95, green: 0.76, blue: 0.10)   // yellow-amber
        case .unhealthySensitive:
            return Color(red: 1.00, green: 0.55, blue: 0.10)   // orange
        case .unhealthy:
            return Color(red: 0.88, green: 0.22, blue: 0.20)   // red
        case .veryUnhealthy:
            return Color(red: 0.52, green: 0.15, blue: 0.70)   // purple
        case .hazardous:
            return Color(red: 0.38, green: 0.06, blue: 0.12)   // deep burgundy
        }
    }

    // MARK: - Glow Color (for radial soft glow behind lungs)

    /// Very low-opacity, low-saturation tint of the AQI color.
    /// Used as the radial glow overlaid on the lung background.
    var glowColor: Color {
        switch self {
        case .good:               return Color(red: 0.34, green: 0.76, blue: 0.42)  // soft sage green
        case .moderate:           return Color(red: 0.90, green: 0.78, blue: 0.20)
        case .unhealthySensitive: return Color(red: 0.95, green: 0.58, blue: 0.22)
        case .unhealthy:          return Color(red: 0.80, green: 0.25, blue: 0.22)
        case .veryUnhealthy:      return Color(red: 0.72, green: 0.66, blue: 0.84)  // dusty gray-lavender
        case .hazardous:          return Color(red: 0.79, green: 0.63, blue: 0.58)  // warm dusty clay
        }
    }

    // MARK: - Progress Bar Gradient Colors

    /// Slightly muted two-stop gradient for the oxygen capsule bar.
    /// Leading stop is lighter, trailing is deeper — same hue family.
    var progressGradientColors: (Color, Color) {
        switch self {
        case .good:
            return (Color(red: 0.35, green: 0.82, blue: 0.45),
                    Color(red: 0.12, green: 0.55, blue: 0.25))
        case .moderate:
            return (Color(red: 0.95, green: 0.82, blue: 0.25),
                    Color(red: 0.78, green: 0.60, blue: 0.05))
        case .unhealthySensitive:
            return (Color(red: 0.98, green: 0.62, blue: 0.22),
                    Color(red: 0.82, green: 0.40, blue: 0.08))
        case .unhealthy:
            return (Color(red: 0.88, green: 0.35, blue: 0.30),
                    Color(red: 0.65, green: 0.15, blue: 0.12))
        case .veryUnhealthy:
            return (Color(red: 0.62, green: 0.28, blue: 0.80),
                    Color(red: 0.38, green: 0.10, blue: 0.55))
        case .hazardous:
            return (Color(red: 0.52, green: 0.12, blue: 0.20),
                    Color(red: 0.30, green: 0.04, blue: 0.10))
        }
    }

    // MARK: - Relative Severity Level (For Visualization Only)

    /// A normalized severity value (0.0 – 1.0)
    /// Used to drive visual intensity like particle density and vitality reduction.
    var severityLevel: Double {
        switch self {
        case .good:
            return 1.0
        case .moderate:
            return 0.9
        case .unhealthySensitive:
            return 0.8
        case .unhealthy:
            return 0.7
        case .veryUnhealthy:
            return 0.6
        case .hazardous:
            return 0.5
        }
    }
}