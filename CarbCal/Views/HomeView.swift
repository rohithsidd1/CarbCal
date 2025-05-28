import SwiftUI
import UIKit

struct HomeView: View {
    // MARK: - Properties
    @StateObject private var coordinator = NavigationCoordinator()
    @State private var showCamera = false
    @State private var showGallery = false
    @StateObject private var analysisViewModel = FoodAnalysisViewModel(openAIService: OpenAIService())
    private let logPrefix = "[HomeView]"
    
    // MARK: - Body
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            ZStack {
                VStack(spacing: 20) {
                    // Title
                    Text("CarbCal")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    // Description
                    Text("Take a photo of your food to analyze its nutritional content")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    // Action Buttons
                    VStack(spacing: 16) {
                        Button(action: {
                            print("\(logPrefix) Select from gallery button tapped")
                            showGallery = true
                        }) {
                            HStack {
                                Image(systemName: "photo.on.rectangle")
                                Text("Select from Gallery")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            print("\(logPrefix) Take photo button tapped")
                            showCamera = true
                        }) {
                            HStack {
                                Image(systemName: "camera")
                                Text("Take Photo")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                
                // Loading Overlay
                if analysisViewModel.isAnalyzing {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Analyzing food image...")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .padding(24)
                    .background(Color(.systemGray6).opacity(0.8))
                    .cornerRadius(12)
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .results:
                    if let result = analysisViewModel.analysisResult,
                       let image = analysisViewModel.capturedImage {
                        ResultsView(analysisResult: result, foodImage: image)
                    } else {
                        Text("No analysis results available")
                    }
                case .history:
                    Text("History View") // Placeholder
                case .home, .camera:
                    EmptyView()
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraView(sourceType: .camera, viewModel: analysisViewModel)
            }
            .sheet(isPresented: $showGallery) {
                CameraView(sourceType: .photoLibrary, viewModel: analysisViewModel)
            }
            .onChange(of: analysisViewModel.analysisResult) { _, newValue in
                if newValue != nil {
                    print("\(logPrefix) Analysis completed, showing results")
                    coordinator.navigate(to: .results(FoodLog(
                        imagePath: "",
                        dishName: newValue!.dishName,
                        date: Date(),
                        ingredients: newValue!.ingredients,
                        healthScore: newValue!.total.healthScore
                    )))
                }
            }
            .alert("Error", isPresented: .constant(analysisViewModel.error != nil)) {
                Button("OK") {
                    analysisViewModel.error = nil
                }
            } message: {
                if let error = analysisViewModel.error {
                    Text(error.localizedDescription)
                }
            }
        }
    }
}

#Preview {
    HomeView()
} 