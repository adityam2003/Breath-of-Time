import SwiftUI

// MARK: - App Phase

enum AppPhase {
    case story
    case intro
    case simulation
}

// MARK: - SimulationState

final class SimulationState: ObservableObject {

    // MARK: Navigation
    
    @Published var phase: AppPhase = .story

    // MARK: Simulation Inputs
    
    @Published var selectedAQI: AQI = .good {
        didSet { updateOxygenEfficiency() }
    }
    @Published var selectedExposure: TimeExposure = .oneYear {
        didSet { updateOxygenEfficiency() }
    }

    // MARK: Derived State
    
    /// Oxygen efficiency (0.0 – 1.0)
    @Published var oxygenEfficiency: Double = 1.0

    // MARK: Intents
    
    func beginSimulation() {
        phase = .simulation
    }
    func returnToIntro() {
        resetToBaseline()
        phase = .intro
    }

    func resetToBaseline() {
        selectedAQI = .good
        selectedExposure = .oneYear
        oxygenEfficiency = 1.0
    }
    
    /// Recalculate oxygen efficiency based on AQI + exposure
//    func updateOxygenEfficiency() {
//        let newValue = selectedAQI.severityLevel * selectedExposure.vitalityMultiplier
//        oxygenEfficiency = max(0.0, min(newValue, 1.0))
//    }
    func updateOxygenEfficiency() {
        let pollutionDamage = 1.0 - selectedAQI.severityLevel
        let exposureWeight = (selectedExposure == .oneYear) ? 0.3 :
                             (selectedExposure == .fiveYears) ? 0.6 : 1.0

        let damage = pollutionDamage * exposureWeight
        oxygenEfficiency = 1.0 - damage
    }
}
