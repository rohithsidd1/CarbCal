import SwiftUI

struct ResultsView: View {
    // MARK: - Properties
    let analysisResult: AnalysisResponse
    let foodImage: UIImage?
    private let logPrefix = "[ResultsView]"
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Food Image Section
                if let image = foodImage {
                    VStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 250)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 16)
                    .transition(.opacity)
                    .onAppear {
                        print("\(logPrefix) Displaying food image")
                    }
                }
                
                // Dish Name Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Dish Name")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(analysisResult.dishName)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.primary)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .onAppear {
                    print("\(logPrefix) Displaying dish name: \(analysisResult.dishName)")
                }
                
                // Health Score Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Health Score")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(1...10, id: \.self) { score in
                                Circle()
                                    .fill(score <= analysisResult.total.healthScore ? 
                                        Color.green.opacity(0.8) : 
                                        Color.gray.opacity(0.2))
                                    .frame(width: 20, height: 20)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                            }
                        }
                    }
                }
                .padding(16)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal, 16)
                
                // Total Nutrition Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Total Nutrition")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 12) {
                        NutritionCard(
                            title: "Calories",
                            value: "\(Int(analysisResult.total.calories))",
                            unit: "kcal",
                            color: .orange
                        )
                        
                        NutritionCard(
                            title: "Carbs",
                            value: String(format: "%.1f", analysisResult.total.carbs),
                            unit: "g",
                            color: .blue
                        )
                        
                        NutritionCard(
                            title: "Protein",
                            value: String(format: "%.1f", analysisResult.total.protein),
                            unit: "g",
                            color: .green
                        )
                        
                        NutritionCard(
                            title: "Fats",
                            value: String(format: "%.1f", analysisResult.total.fats),
                            unit: "g",
                            color: .red
                        )
                    }
                }
                .padding(16)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal, 16)
                
                // Ingredients Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Ingredients")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    ForEach(analysisResult.ingredients) { ingredient in
                        IngredientCard(ingredient: ingredient)
                            .transition(.opacity)
                    }
                }
                .padding(16)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 16)
        }
        .navigationTitle("Analysis Results")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Supporting Views
struct NutritionCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title3)
                .bold()
                .foregroundColor(color)
            
            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct IngredientCard: View {
    let ingredient: Ingredient
    private let logPrefix = "[IngredientCard]"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(ingredient.name)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    NutritionBadge(label: "Cal", value: "\(Int(ingredient.calories))", color: .orange)
                    NutritionBadge(label: "Carbs", value: String(format: "%.1fg", ingredient.carbs), color: .blue)
                    NutritionBadge(label: "Prot", value: String(format: "%.1fg", ingredient.protein), color: .green)
                    NutritionBadge(label: "Fats", value: String(format: "%.1fg", ingredient.fats), color: .red)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onAppear {
            print("\(logPrefix) Displaying ingredient: \(ingredient.name)")
        }
    }
}

struct NutritionBadge: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .bold()
                .foregroundColor(color)
        }
        .frame(minWidth: 50)
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    NavigationStack {
        ResultsView(analysisResult: AnalysisResponse(
            dishName: "Sample Dish",
            ingredients: [
                Ingredient(name: "Ingredient 1", calories: 100, carbs: 20, protein: 5, fats: 2),
                Ingredient(name: "Ingredient 2", calories: 150, carbs: 25, protein: 8, fats: 3)
            ],
            total: NutritionTotal(
                calories: 250,
                carbs: 45,
                protein: 13,
                fats: 5,
                healthScore: 8
            )
        ), foodImage: UIImage(named: "sample_food_image"))
    }
} 
