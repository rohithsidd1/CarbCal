import SwiftUI
import UIKit

// MARK: - Shared State
@Observable class AppState {
    var shouldRefreshHomeView = false
}

// MARK: - Theme
struct Theme {
    static let background = Color(.systemGroupedBackground)
    static let cardBackground = Color(.systemBackground)
    static let primaryText = Color(.label)
    static let secondaryText = Color(.secondaryLabel)
    static let accentGreen = Color.green
    static let accentBlue = Color.blue
    static let accentOrange = Color.orange
    static let shadowColor = Color(.sRGBLinear, white: 0, opacity: 0.1)
}

// MARK: - Supporting Views
struct HeaderSection: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("CarbCal")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.primaryText)
            
            Text("Track your nutrition with AI")
                .font(.subheadline)
                .foregroundStyle(Theme.secondaryText)
        }
        .padding(.top, 20)
    }
}

struct DateAndStatsCard: View {
    @Binding var selectedDate: Date
    let logsForDate: [FoodLog]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Date")
                    .padding(.leading, 24)
                    .font(.headline)
                    .foregroundStyle(Theme.primaryText)
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .padding(.horizontal)
                    .onChange(of: selectedDate) { oldValue, newValue in
                        print("[History] Selected date changed: \(newValue)")
                    }
            }
            
            let totalCalories = logsForDate.reduce(0) { $0 + $1.ingredients.reduce(0) { $0 + Int($1.calories) } }
            
            HStack(spacing: 20) {
                StatCard(
                    title: "Calories",
                    value: "\(totalCalories)",
                    unit: "kcal",
                    color: Theme.accentOrange
                )
                
                StatCard(
                    title: "Meals",
                    value: "\(logsForDate.count)",
                    unit: "today",
                    color: Theme.accentBlue
                )
            }
            .padding(.horizontal)
            
            if !logsForDate.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Today's Meals")
                        .font(.headline)
                        .foregroundStyle(Theme.primaryText)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(logsForDate) { log in
                                MealCard(log: log)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .padding(.vertical, 16)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Theme.shadowColor, radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
}

struct ActionButtonsSection: View {
    let onTakePhoto: () -> Void
    let onChooseFromGallery: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            ActionButton(
                title: "Take Photo",
                icon: "camera.fill",
                color: .primary,
                action: onTakePhoto,
                isFilled: true
            )
            
            ActionButton(
                title: "Choose from Gallery",
                icon: "photo.fill",
                color: .primary,
                action: onChooseFromGallery,
                isFilled: false
            )
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

struct LoadingOverlay: View {
    var body: some View {
        Color.primary.opacity(0.8)
            .ignoresSafeArea()
        
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.primary)
            Text("Analyzing food image...")
                .foregroundColor(.primary)
                .font(.headline)
        }
        .padding(24)
        .background(Theme.cardBackground.opacity(1))
        .cornerRadius(12)
    }
}

struct HomeView: View {
    // MARK: - Properties
    @StateObject private var coordinator = NavigationCoordinator()
    @State private var showCamera = false
    @State private var showGallery = false
    @StateObject private var analysisViewModel = FoodAnalysisViewModel(openAIService: OpenAIService())
    @State private var selectedDate: Date = Date()
    @State private var foodLogStore = FoodLogStore()
    @State private var isAnimating = false
    @State private var appState = AppState()
    private let logPrefix = "[HomeView]"
    
    // MARK: - Body
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            ZStack {
                // Background
                Theme.background
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    HeaderSection()
                    
                    let logsForDate = foodLogStore.getLogs(for: selectedDate)
                    DateAndStatsCard(selectedDate: $selectedDate, logsForDate: logsForDate)
                    
                    ActionButtonsSection(
                        onTakePhoto: {
                            print("\(logPrefix) Take photo button tapped")
                            showCamera = true
                        },
                        onChooseFromGallery: {
                            print("\(logPrefix) Select from gallery button tapped")
                            showGallery = true
                        }
                    )
                }
                .padding(.bottom, 32)
                
                if analysisViewModel.isAnalyzing {
                    LoadingOverlay()
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .results:
                    if let result = analysisViewModel.analysisResult,
                       let image = analysisViewModel.capturedImage {
                        ResultsView(analysisResult: result, foodImage: image, appState: appState)
                    } else {
                        Text("No analysis results available")
                    }
                case .history:
                    Text("History View")
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
            .onChange(of: appState.shouldRefreshHomeView) { oldValue, newValue in
                if newValue {
                    print("\(logPrefix) Refreshing home view")
                    foodLogStore = FoodLogStore() // Reload the store
                    appState.shouldRefreshHomeView = false
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

// MARK: - Supporting Views
struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(Theme.secondaryText)
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            
            Text(unit)
                .font(.caption)
                .foregroundStyle(Theme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct MealCard: View {
    let log: FoodLog
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(log.dishName)
                .font(.headline)
                .foregroundStyle(Theme.primaryText)
                .lineLimit(1)
            
            HStack {
                Text("\(Int(log.ingredients.reduce(0) { $0 + $1.calories })) kcal")
                    .font(.subheadline)
                    .foregroundStyle(Theme.secondaryText)
                
                Spacer()
                
                Text("Score: \(log.healthScore)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.accentGreen.opacity(0.2))
                    .foregroundStyle(Theme.accentGreen)
                    .clipShape(Capsule())
            }
        }
        .padding()
        .frame(width: 200)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Theme.shadowColor, radius: 5, x: 0, y: 2)
        .padding(.bottom, 8)
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    let isFilled: Bool

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.headline)
                Text(title)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isFilled ? color : Color.clear)
            .foregroundColor(isFilled ? (colorScheme == .light ? .white : .black) : color)
            .overlay(
                RoundedRectangle(cornerRadius: 50)
                    .stroke(color, lineWidth: isFilled ? 0 : 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 50))
        }
    }
}

#Preview {
    HomeView()
} 
