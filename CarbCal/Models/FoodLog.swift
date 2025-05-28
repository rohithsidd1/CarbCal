import Foundation

// MARK: - Models
struct Ingredient: Identifiable, Codable {
    var id = UUID()
    var name: String
    var calories: Int
    var carbs: Int
    var protein: Int
    var fats: Int
}

struct FoodLog: Identifiable, Codable {
    var id = UUID()
    var imagePath: String
    var dishName: String
    var date: Date
    var ingredients: [Ingredient]
    var healthScore: Int
} 