import SwiftUI

struct ResultsView: View {
    // MARK: - Properties
    let analysisResult: AnalysisResponse
    let foodImage: UIImage?
    let appState: AppState
    private let logPrefix = "[ResultsView]"
    @Environment(\.dismiss) private var dismiss
    @State private var foodLogStore = FoodLogStore()
    @Environment(\.colorScheme) private var colorScheme
    // State for editing
    @State private var isEditing = false
    @State private var editedIngredients: [Ingredient]
    @State private var editedTotal: NutritionTotal
    @State private var editedDishName: String
    @State private var showingSaveAlert = false
    @State private var showingSaveSuccess = false
    
    // MARK: - Initialization
    init(analysisResult: AnalysisResponse, foodImage: UIImage?, appState: AppState) {
        self.analysisResult = analysisResult
        self.foodImage = foodImage
        self.appState = appState
        // Initialize state with current values
        _editedIngredients = State(initialValue: analysisResult.ingredients)
        _editedTotal = State(initialValue: analysisResult.total)
        _editedDishName = State(initialValue: analysisResult.dishName)
    }
    
    // MARK: - Body
    var body: some View {
        VStack{
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
                                .shadow(color: Theme.shadowColor, radius: 8, x: 0, y: 4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Theme.cardBackground.opacity(0.2), lineWidth: 1)
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
                            .foregroundStyle(Theme.secondaryText)
                        
                        if isEditing {
                            TextField("Dish Name", text: $editedDishName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.title2)
                        } else {
                            Text(editedDishName)
                                .font(.title2)
                                .bold()
                                .foregroundStyle(Theme.primaryText)
                                .lineLimit(2)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    
                    // Health Score Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Health Score")
                            .font(.headline)
                            .foregroundStyle(Theme.secondaryText)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(1...10, id: \.self) { score in
                                    Circle()
                                        .fill(score <= editedTotal.healthScore ?
                                              Theme.accentGreen.opacity(0.8) :
                                                Theme.secondaryText.opacity(0.2))
                                        .frame(width: 20, height: 20)
                                        .overlay(
                                            Circle()
                                                .stroke(Theme.cardBackground.opacity(0.2), lineWidth: 1)
                                        )
                                        .shadow(color: Theme.shadowColor, radius: 2, x: 0, y: 1)
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(Theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Theme.shadowColor, radius: 5, x: 0, y: 2)
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
                                value: "\(Int(editedTotal.calories))",
                                unit: "kcal",
                                color: .orange
                            )
                            
                            NutritionCard(
                                title: "Carbs",
                                value: String(format: "%.1f", editedTotal.carbs),
                                unit: "g",
                                color: .blue
                            )
                            
                            NutritionCard(
                                title: "Protein",
                                value: String(format: "%.1f", editedTotal.protein),
                                unit: "g",
                                color: .green
                            )
                            
                            NutritionCard(
                                title: "Fats",
                                value: String(format: "%.1f", editedTotal.fats),
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
                        
                        ForEach($editedIngredients) { $ingredient in
                            EditableIngredientCard(ingredient: $ingredient, isEditing: isEditing)
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
            
            // Action Buttons
            HStack(spacing: 16) {
                if isEditing {
                    Button(action: {
                        print("\(logPrefix) Canceling edits")
                        // Reset to original values
                        editedIngredients = analysisResult.ingredients
                        editedTotal = analysisResult.total
                        editedDishName = analysisResult.dishName
                        isEditing = false
                    }) {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        print("\(logPrefix) Saving edits")
                        // Update total nutrition
                        updateTotalNutrition()
                        isEditing = false
                        showingSaveAlert = true
                    }) {
                        Text("Done")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                } else {
                    Button(action: {
                        print("\(logPrefix) Starting edit mode")
                        isEditing = true
                    }) {
                        Text("Edit")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.primary)
                            .overlay(
                                RoundedRectangle(cornerRadius: 50)
                                    .stroke(Color.primary, lineWidth: 2)
                            )
                            .background(Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 50))
                    }

                    Button(action: {
                        print("\(logPrefix) Saving food log")
                        saveFoodLog()
                    }) {
                        Text("Save")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(colorScheme == .light ? .white : .black)
                            .padding()
                            .background(Color.primary)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 50))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

        }
        .navigationTitle("Analysis Results")
        .navigationBarTitleDisplayMode(.inline)
        .background(Theme.background)
        .alert("Changes Saved", isPresented: $showingSaveAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your changes have been saved successfully.")
        }
        .alert("Log Saved", isPresented: $showingSaveSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your food log has been saved successfully.")
        }
    }
    
    // MARK: - Helper Methods
    private func updateTotalNutrition() {
        let totalCalories = editedIngredients.reduce(0) { $0 + $1.calories }
        let totalCarbs = editedIngredients.reduce(0) { $0 + $1.carbs }
        let totalProtein = editedIngredients.reduce(0) { $0 + $1.protein }
        let totalFats = editedIngredients.reduce(0) { $0 + $1.fats }
        
        editedTotal = NutritionTotal(
            calories: totalCalories,
            carbs: totalCarbs,
            protein: totalProtein,
            fats: totalFats,
            healthScore: editedTotal.healthScore
        )
    }
    
    private func saveFoodLog() {
        let foodLog = FoodLog(
            imagePath: "", // TODO: Save image and get path
            dishName: editedDishName,
            date: Date(),
            ingredients: editedIngredients,
            healthScore: editedTotal.healthScore
        )
        
        foodLogStore.saveLog(foodLog)
        appState.shouldRefreshHomeView = true
        showingSaveSuccess = true
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
                .foregroundStyle(Theme.secondaryText)
            
            Text(value)
                .font(.title3)
                .bold()
                .foregroundStyle(color)
            
            Text(unit)
                .font(.caption)
                .foregroundStyle(Theme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct EditableIngredientCard: View {
    @Binding var ingredient: Ingredient
    let isEditing: Bool
    private let logPrefix = "[EditableIngredientCard]"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isEditing {
                TextField("Ingredient Name", text: $ingredient.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.headline)
            } else {
                Text(ingredient.name)
                    .font(.headline)
                    .foregroundStyle(Theme.primaryText)
                    .lineLimit(1)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    if isEditing {
                        EditableNutritionBadge(
                            label: "Cal",
                            value: $ingredient.calories,
                            color: Theme.accentOrange
                        )
                        EditableNutritionBadge(
                            label: "Carbs",
                            value: $ingredient.carbs,
                            color: Theme.accentBlue
                        )
                        EditableNutritionBadge(
                            label: "Prot",
                            value: $ingredient.protein,
                            color: Theme.accentGreen
                        )
                        EditableNutritionBadge(
                            label: "Fats",
                            value: $ingredient.fats,
                            color: .red
                        )
                    } else {
                        NutritionBadge(
                            label: "Cal",
                            value: "\(Int(ingredient.calories))",
                            color: Theme.accentOrange
                        )
                        NutritionBadge(
                            label: "Carbs",
                            value: String(format: "%.1fg", ingredient.carbs),
                            color: Theme.accentBlue
                        )
                        NutritionBadge(
                            label: "Prot",
                            value: String(format: "%.1fg", ingredient.protein),
                            color: Theme.accentGreen
                        )
                        NutritionBadge(
                            label: "Fats",
                            value: String(format: "%.1fg", ingredient.fats),
                            color: .red
                        )
                    }
                }
            }
        }
        .padding(12)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onAppear {
            print("\(logPrefix) Displaying ingredient: \(ingredient.name)")
        }
    }
}

struct EditableNutritionBadge: View {
    let label: String
    @Binding var value: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            TextField("0", value: $value, format: .number)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 50)
                .multilineTextAlignment(.center)
                .keyboardType(.decimalPad)
        }
        .frame(minWidth: 50)
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
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
        ), foodImage: UIImage(named: "sample_food_image"), appState: AppState())
    }
} 
