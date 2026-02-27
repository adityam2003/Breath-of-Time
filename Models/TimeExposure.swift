import Foundation

/// Long-term exposure duration affecting lung vitality.
enum TimeExposure: CaseIterable, Identifiable {
    case oneYear
    case fiveYears
    case tenYears

    var id: Self { self }

    /// Display label used in segmented control.
    var displayName: String {
        switch self {
        case .oneYear: return "1Y"
        case .fiveYears: return "5Y"
        case .tenYears: return "10Y"
        }
    }

    /// Subtle vitality reduction factor (0.0 – 1.0)
    var vitalityMultiplier: Double {
        switch self {
        case .oneYear: return 0.95
        case .fiveYears: return 0.85
        case .tenYears: return 0.75
        }
    }

    /// How much to desaturate the lung gradient (0 = none, 1 = full grey).
    /// Kept subtle: 1Y touches are almost invisible; 10Y is just noticeable.
    var desaturationAmount: Double {
        switch self {
        case .oneYear:   return 0.00
        case .fiveYears: return 0.10
        case .tenYears:  return 0.22
        }
    }

    /// Fraction by which the lung glow/brightness is dimmed (0 = no change).
    var glowReduction: Double {
        switch self {
        case .oneYear:   return 0.00
        case .fiveYears: return 0.07
        case .tenYears:  return 0.16
        }
    }

    /// Multiplier on breathing amplitude (1.0 = full, lower = shallower breaths).
    var breathingAmplitudeScale: Double {
        switch self {
        case .oneYear:   return 1.00
        case .fiveYears: return 0.88
        case .tenYears:  return 0.75
        }
    }
}