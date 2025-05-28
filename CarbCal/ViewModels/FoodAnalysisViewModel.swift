import SwiftUI
import UIKit

@MainActor
final class FoodAnalysisViewModel: ObservableObject {
    // MARK: - Properties
    private let openAIService: OpenAIService
    private let logPrefix = "[FoodAnalysis]"
    
    @Published var isAnalyzing = false
    @Published var error: Error?
    @Published var analysisResult: AnalysisResponse?
    @Published var capturedImage: UIImage?
    
    // MARK: - Initialization
    init(openAIService: OpenAIService) {
        self.openAIService = openAIService
        print("\(logPrefix) Initialized FoodAnalysisViewModel")
    }
    
    // MARK: - Methods
    func analyzeImage(_ image: UIImage) async {
        print("\(logPrefix) Starting image analysis")
        isAnalyzing = true
        error = nil
        capturedImage = image
        
        do {
            let result = try await openAIService.analyzeFoodImage(image)
            print("\(logPrefix) Analysis completed successfully")
            analysisResult = result
        } catch {
            print("\(logPrefix) Analysis failed: \(error.localizedDescription)")
            self.error = error
        }
        
        isAnalyzing = false
    }
} 