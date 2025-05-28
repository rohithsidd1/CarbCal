import Foundation

// MARK: - Models
struct Ingredient: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var calories: Double
    var carbs: Double
    var protein: Double
    var fats: Double
    
    init(id: UUID = UUID(), name: String, calories: Double, carbs: Double, protein: Double, fats: Double) {
        self.id = id
        self.name = name
        self.calories = calories
        self.carbs = carbs
        self.protein = protein
        self.fats = fats
    }
}

struct NutritionTotal: Codable, Equatable {
    var calories: Double
    var carbs: Double
    var protein: Double
    var fats: Double
    var healthScore: Int
}

struct AnalysisResponse: Codable, Equatable {
    var dishName: String
    var ingredients: [Ingredient]
    var total: NutritionTotal
}

// MARK: - App Models
struct FoodLog: Identifiable, Codable, Equatable {
    var id = UUID()
    var imagePath: String
    var dishName: String
    var date: Date
    var ingredients: [Ingredient]
    var healthScore: Int
    
    init(imagePath: String, dishName: String, date: Date, ingredients: [Ingredient], healthScore: Int) {
        self.id = UUID()
        self.imagePath = imagePath
        self.dishName = dishName
        self.date = date
        self.ingredients = ingredients
        self.healthScore = healthScore
    }
} 