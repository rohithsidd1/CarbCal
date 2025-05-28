import SwiftUI

// MARK: - Navigation Routes
enum AppRoute: Hashable {
    case home
    case camera
    case results(FoodLog)
    case history
    
    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        switch self {
        case .home:
            hasher.combine(0)
        case .camera:
            hasher.combine(1)
        case .results(let foodLog):
            hasher.combine(2)
            hasher.combine(foodLog.id)
        case .history:
            hasher.combine(3)
        }
    }
    
    // Implement Equatable
    static func == (lhs: AppRoute, rhs: AppRoute) -> Bool {
        switch (lhs, rhs) {
        case (.home, .home):
            return true
        case (.camera, .camera):
            return true
        case (.results(let lhsLog), .results(let rhsLog)):
            return lhsLog.id == rhsLog.id
        case (.history, .history):
            return true
        default:
            return false
        }
    }
}

// MARK: - Navigation Coordinator
final class NavigationCoordinator: ObservableObject {
    // Debug log prefix
    private let logPrefix = "[Navigation]"
    
    // Navigation path for programmatic navigation
    @Published var path = NavigationPath()
    
    // Current route
    @Published var currentRoute: AppRoute = .home
    
    // Navigation methods
    func navigate(to route: AppRoute) {
        print("\(logPrefix) Navigating to: \(route)")
        currentRoute = route
        path.append(route)
    }
    
    func navigateBack() {
        print("\(logPrefix) Navigating back")
        path.removeLast()
    }
    
    func navigateToRoot() {
        print("\(logPrefix) Navigating to root")
        path.removeLast(path.count)
    }
} 