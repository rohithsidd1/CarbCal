import Foundation
import SwiftUI

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

// MARK: - Food Log Store
@Observable class FoodLogStore {
    private let logPrefix = "[FoodLogStore]"
    private let storage = UserDefaults.standard
    private let foodLogsKey = "foodLogs"
    
    var foodLogs: [FoodLog] = []
    
    init() {
        loadLogs()
    }
    
    func saveLog(_ log: FoodLog) {
        print("\(logPrefix) Saving food log: \(log.dishName)")
        foodLogs.append(log)
        saveToStorage()
    }
    
    func getLogs(for date: Date) -> [FoodLog] {
        return foodLogs.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    private func loadLogs() {
        do {
            if let data = storage.data(forKey: foodLogsKey) {
                foodLogs = try JSONDecoder().decode([FoodLog].self, from: data)
                print("\(logPrefix) Loaded \(foodLogs.count) food logs")
            }
        } catch {
            print("\(logPrefix) Error loading food logs: \(error)")
            foodLogs = []
        }
    }
    
    private func saveToStorage() {
        do {
            let data = try JSONEncoder().encode(foodLogs)
            storage.set(data, forKey: foodLogsKey)
            print("\(logPrefix) Saved \(foodLogs.count) food logs to storage")
        } catch {
            print("\(logPrefix) Error saving food logs: \(error)")
        }
    }
} 