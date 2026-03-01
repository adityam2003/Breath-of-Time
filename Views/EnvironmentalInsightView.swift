import SwiftUI
import FoundationModels

// MARK: - Environmental Insight Inline View

/// A minimal, inline view that allows users to ask a single contextual question
/// about the current air quality simulation. Powered by on-device Apple Intelligence.
/// The response is presented in a clinical modal sheet.
@available(iOS 26, *)
struct EnvironmentalInsightView: View {
    
    let aqi: AQI
    let exposure: TimeExposure
    let oxygenEfficiency: Double
    
    @State private var viewModel = InsightViewModel()
    @State private var isSheetPresented = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Toggle Button
            Button {
                withAnimation(.easeInOut(duration: 0.35)) {
                    viewModel.isExpanded.toggle()
                    if !viewModel.isExpanded {
                        viewModel.reset()
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "sparkle")
                        .font(.caption)
                        .foregroundStyle(aqi.color.opacity(0.7))
                    
                    Text("Have a question about this level?")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color(.secondaryLabel))
                }
            }
            .buttonStyle(.plain)
            
            // Expanded: Input Field
            if viewModel.isExpanded {
                VStack(alignment: .leading, spacing: 14) {
                    
                    // Text Input
                    HStack(spacing: 10) {
                        TextField("Ask about air quality or lung impact…", text: $viewModel.userQuestion)
                            .font(.subheadline)
                            .foregroundStyle(Color(.label))
                            .focused($isTextFieldFocused)
                            .submitLabel(.done)
                            .onSubmit {
                                generateAndPresent()
                            }
                        
                        // Generate Button
                        Button {
                            generateAndPresent()
                        } label: {
                            Text("Generate")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(aqi.color.opacity(0.85))
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(viewModel.userQuestion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
                        .opacity(viewModel.userQuestion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.4 : 1.0)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.systemGray6).opacity(0.5))
                    )
                    
                    // Loading indicator (while generating, before sheet appears)
                    if viewModel.isLoading {
                        HStack(spacing: 8) {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Generating insight…")
                                .font(.caption)
                                .foregroundStyle(Color(.secondaryLabel))
                        }
                        .padding(.leading, 4)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(viewModel.isExpanded ? "Environmental health insight. Ask a question about the current air quality level." : "Have a question about this level? Tap to expand.")
        .sheet(isPresented: $isSheetPresented) {
            InsightResponseSheet(
                aqi: aqi,
                exposure: exposure,
                oxygenEfficiency: oxygenEfficiency,
                question: viewModel.userQuestion,
                response: viewModel.responseText,
                errorMessage: viewModel.errorMessage,
                isPresented: $isSheetPresented
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
    
    private func generateAndPresent() {
        isTextFieldFocused = false
        Task {
            await viewModel.generateInsight(
                aqi: aqi,
                exposure: exposure,
                oxygenEfficiency: oxygenEfficiency
            )
            // Present sheet once response is ready
            HapticManager.success()
            isSheetPresented = true
        }
    }
}

// MARK: - Insight Response Sheet

/// A clinical, AQI-tinted modal sheet that displays the AI-generated health insight.
/// Preserves the cinematic + clinical tone of the app. Not a chat interface.
@available(iOS 26, *)
private struct InsightResponseSheet: View {
    
    let aqi: AQI
    let exposure: TimeExposure
    let oxygenEfficiency: Double
    let question: String
    let response: String
    let errorMessage: String?
    @Binding var isPresented: Bool
    
    @State private var contentOpacity: Double = 0.0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // ── Title ──
                    Text("Environmental Health Insight")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(aqi.color)
                        .padding(.top, 24)
                        .padding(.horizontal, 28)
                    
                    // ── Thin Divider ──
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [aqi.color.opacity(0.3), aqi.color.opacity(0.05)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(height: 1)
                        .padding(.top, 14)
                        .padding(.horizontal, 28)
                    
                    // ── YOUR QUESTION ──
                    VStack(alignment: .leading, spacing: 8) {
                        Text("YOUR QUESTION")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .tracking(1.2)
                            .foregroundStyle(Color(.secondaryLabel).opacity(0.6))
                        
                        Text(question)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(Color(.label).opacity(0.9))
                            .lineSpacing(4)
                    }
                    .padding(.top, 28)
                    .padding(.horizontal, 28)
                    
                    // ── Spacing ──
                    Spacer().frame(height: 24)
                    
                    // ── CLINICAL RESPONSE ──
                    VStack(alignment: .leading, spacing: 10) {
                        Text("CLINICAL RESPONSE")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .tracking(1.2)
                            .foregroundStyle(Color(.secondaryLabel).opacity(0.6))
                        
                        if !response.isEmpty {
                            Text(response)
                                .font(.subheadline)
                                .foregroundStyle(Color(.label).opacity(0.85))
                                .lineSpacing(6)
                        } else if let error = errorMessage {
                            Text(error)
                                .font(.subheadline)
                                .foregroundStyle(Color(.secondaryLabel))
                                .lineSpacing(6)
                        }
                    }
                    .padding(.horizontal, 28)
                    
                    Spacer(minLength: 40)
                    
                    // ── Disclaimer ──
                    Text("This information is general and not medical advice.")
                        .font(.caption2)
                        .foregroundStyle(Color(.tertiaryLabel))
                        .padding(.horizontal, 28)
                        .padding(.bottom, 24)
                }
                .opacity(contentOpacity)
            }
            .background(
                // Soft, AQI-tinted neutral background
                ZStack {
                    Color(.systemBackground)
                    aqi.glowColor.opacity(0.04)
                }
                .ignoresSafeArea()
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .fontWeight(.medium)
                    .foregroundStyle(aqi.color)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5)) {
                contentOpacity = 1.0
            }
        }
    }
}
