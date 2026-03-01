import SwiftUI
import FoundationModels

// MARK: - Environmental Insight ViewModel

/// Manages on-device Apple Intelligence interactions for health insights.
/// Fully offline — runs entirely on Apple Silicon via the FoundationModels framework.
@available(iOS 26, *)
@Observable
final class InsightViewModel {
    
    // MARK: - State
    
    var userQuestion: String = ""
    var responseText: String = ""
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var isExpanded: Bool = false
    
    // MARK: - Cache
    
    /// Caches responses keyed by "aqi-exposure-question" to avoid redundant generation.
    private var cache: [String: String] = [:]
    
    // MARK: - System Prompt
    
    private let systemPrompt = """
    You are a clinical environmental health assistant.
    Provide concise, neutral explanations about air quality and lung function.
    Avoid emotional language. Do not provide medical diagnosis.
    Limit response to 2–3 sentences.
    """
    
    // MARK: - Guardrail Response
    
    private let guardrailResponse = "I can provide general information about air quality and respiratory health, but I cannot give medical advice."
    
    // MARK: - Generate Insight
    
    /// Generates a clinical insight using the on-device language model.
    /// - Parameters:
    ///   - aqi: Current AQI selection
    ///   - exposure: Current exposure duration
    ///   - oxygenEfficiency: Current oxygen efficiency (0.0–1.0)
    @MainActor
    func generateInsight(aqi: AQI, exposure: TimeExposure, oxygenEfficiency: Double) async {
        let trimmedQuestion = userQuestion.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuestion.isEmpty else { return }
        
        // Check cache first
        let cacheKey = "\(aqi.displayName)-\(exposure.displayName)-\(trimmedQuestion.lowercased())"
        if let cached = cache[cacheKey] {
            withAnimation(.easeInOut(duration: 0.5)) {
                responseText = cached
            }
            return
        }
        
        isLoading = true
        errorMessage = nil
        responseText = ""
        
        let userPrompt = """
        AQI level: \(aqi.displayName)
        Exposure duration: \(exposure.displayName == "1Y" ? "1 year" : exposure.displayName == "5Y" ? "5 years" : "10 years")
        Oxygen efficiency: \(String(format: "%.2f", oxygenEfficiency))
        User question: \(trimmedQuestion)
        """
        
        do {
            let session = LanguageModelSession(instructions: systemPrompt)
            let response = try await session.respond(to: userPrompt)
            let text = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Basic guardrail: if response is empty or suspiciously short
            let finalText = text.isEmpty ? guardrailResponse : text
            
            cache[cacheKey] = finalText
            
            withAnimation(.easeInOut(duration: 0.5)) {
                responseText = finalText
            }
        } catch {
            withAnimation(.easeInOut(duration: 0.5)) {
                errorMessage = guardrailResponse
            }
        }
        
        isLoading = false
    }
    
    /// Resets the insight state for a fresh question.
    @MainActor
    func reset() {
        responseText = ""
        errorMessage = nil
        userQuestion = ""
    }
}
