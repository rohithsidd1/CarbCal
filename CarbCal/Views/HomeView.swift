import SwiftUI

struct HomeView: View {
    // MARK: - Properties
    @StateObject private var coordinator = NavigationCoordinator()
    @State private var showCamera = false
    @State private var showGallery = false
    
    // MARK: - Body
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            VStack(spacing: 20) {
                // Title
                Text("CarbCal")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Main buttons
                VStack(spacing: 16) {
                    // Capture Food Button
                    Button(action: {
                        print("[HomeView] Capture food button tapped")
                        showCamera = true
                    }) {
                        Label("Capture Food", systemImage: "camera.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    // Select from Gallery Button
                    Button(action: {
                        print("[HomeView] Select from gallery button tapped")
                        showGallery = true
                    }) {
                        Label("Select from Gallery", systemImage: "photo.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    // View History Button
                    Button(action: {
                        print("[HomeView] View history button tapped")
                        coordinator.navigate(to: .history)
                    }) {
                        Label("View History", systemImage: "clock.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .results(_):
                    Text("Results View") // Placeholder
                case .history:
                    Text("History View") // Placeholder
                case .home, .camera:
                    EmptyView()
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraView(sourceType: .camera)
            }
            .sheet(isPresented: $showGallery) {
                CameraView(sourceType: .photoLibrary)
            }
        }
    }
}

#Preview {
    HomeView()
} 