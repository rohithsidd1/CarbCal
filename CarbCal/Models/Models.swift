import Foundation

// MARK: - Models
struct Ingredient: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let calories: Double
    let carbs: Double
    let protein: Double
    let fats: Double
    
    init(name: String, calories: Double, carbs: Double, protein: Double, fats: Double) {
        self.id = UUID()
        self.name = name
        self.calories = calories
        self.carbs = carbs
        self.protein = protein
        self.fats = fats
    }
}

struct NutritionTotal: Codable, Equatable {
    let calories: Double
    let carbs: Double
    let protein: Double
    let fats: Double
    let healthScore: Int
}

struct AnalysisResponse: Codable, Equatable {
    let dishName: String
    let ingredients: [Ingredient]
    let total: NutritionTotal
}

// MARK: - App Models
struct FoodLog: Identifiable, Codable, Equatable {
    let id: UUID
    let imagePath: String
    let dishName: String
    let date: Date
    let ingredients: [Ingredient]
    let healthScore: Int
    
    init(imagePath: String, dishName: String, date: Date, ingredients: [Ingredient], healthScore: Int) {
        self.id = UUID()
        self.imagePath = imagePath
        self.dishName = dishName
        self.date = date
        self.ingredients = ingredients
        self.healthScore = healthScore
    }
} 