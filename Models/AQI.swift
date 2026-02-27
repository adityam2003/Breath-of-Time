import Foundation

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
            return "301–500"
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