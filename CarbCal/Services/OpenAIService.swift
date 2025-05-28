import Foundation
import UIKit

// MARK: - OpenAI Service
class OpenAIService {
    // Debug log prefix
    private let logPrefix = "[OpenAI]"
    
    // Azure OpenAI Configuration
    private let apiKey = ""
    private let endpoint = "https://sweden-openai89099.openai.azure.com"
    private let deploymentName = "gpt-4o-mini"
    private let apiVersion = "2024-08-01-preview"
    
    // MARK: - DTOs for API Response
    private struct APIResponse: Codable {
        let choices: [Choice]
        
        struct Choice: Codable {
            let message: Message
        }
        
        struct Message: Codable {
            let content: String
        }
    }
    
    private struct APIIngredient: Codable {
        let name: String
        let calories: Double
        let carbs: Double
        let protein: Double
        let fats: Double
    }
    
    private struct APINutritionTotal: Codable {
        let calories: Double
        let carbs: Double
        let protein: Double
        let fats: Double
        let healthScore: Int
    }
    
    private struct APIAnalysisResponse: Codable {
        let dishName: String
        let ingredients: [APIIngredient]
        let total: APINutritionTotal
    }
    
    init() {
        print("\(logPrefix) Initializing Azure OpenAI service")
    }
    
    // MARK: - API Methods
    func analyzeFoodImage(_ image: UIImage) async throws -> AnalysisResponse {
        print("\(logPrefix) Starting image analysis")
        
        // Convert image to base64
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("\(logPrefix) Failed to convert image to data")
            throw APIError.imageConversionFailed
        }
        let base64Image = imageData.base64EncodedString()
        
        // Prepare request URL with correct Azure OpenAI format
        let urlString = "\(endpoint)/openai/deployments/\(deploymentName)/chat/completions?api-version=\(apiVersion)"
        print("\(logPrefix) Request URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("\(logPrefix) Invalid URL: \(urlString)")
            throw APIError.invalidURL
        }
        
        // Prepare request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("\(apiKey)", forHTTPHeaderField: "api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Prepare request body
        let requestBody: [String: Any] = [
            "messages": [
                [
                    "role": "system",
                    "content": "You are a helpful assistant that analyzes food images and returns nutritional information in a specific JSON format. You must return ONLY the JSON object with no additional text or explanation. Use decimal numbers for precise nutritional values."
                ],
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": "Analyze this food image and provide detailed nutritional information. Include: 1) Dish name, 2) List of ingredients with calories, carbs, protein, and fats for each, 3) Total nutritional values, 4) Health score (1-10). Format the response as JSON matching this structure: { dishName: string, ingredients: [{ name: string, calories: number, carbs: number, protein: number, fats: number }], total: { calories: number, carbs: number, protein: number, fats: number, healthScore: number } }"
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64Image)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 4000,
            "temperature": 0.7
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            print("\(logPrefix) Request body prepared successfully")
            
            // Debug: Print request headers
            print("\(logPrefix) Request headers: \(request.allHTTPHeaderFields ?? [:])")
        } catch {
            print("\(logPrefix) Failed to serialize request body: \(error.localizedDescription)")
            throw APIError.requestSerializationFailed
        }
        
        // Make API call
        do {
            print("\(logPrefix) Making API request to Azure OpenAI")
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("\(logPrefix) Invalid response type")
                throw APIError.invalidResponse
            }
            
            // Print raw response data for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("\(logPrefix) Raw API Response: \(responseString)")
            }
            
            if httpResponse.statusCode != 200 {
                print("\(logPrefix) API error: \(httpResponse.statusCode)")
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("\(logPrefix) Error details: \(errorJson)")
                }
                throw APIError.apiError(statusCode: httpResponse.statusCode)
            }
            
            // Parse OpenAI response
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(APIResponse.self, from: data)
            
            // Print the content before parsing
            if let content = apiResponse.choices.first?.message.content {
                print("\(logPrefix) Response content before parsing: \(content)")
            }
            
            // Extract and parse the JSON string from the response
            guard let jsonString = apiResponse.choices.first?.message.content,
                  let jsonData = jsonString.data(using: .utf8) else {
                print("\(logPrefix) Failed to parse response content")
                throw APIError.parsingFailed
            }
            
            // Parse the analysis response
            let apiAnalysisResponse = try decoder.decode(APIAnalysisResponse.self, from: jsonData)
            
            // Convert API response to app models
            let ingredients = apiAnalysisResponse.ingredients.map { apiIngredient in
                Ingredient(
                    name: apiIngredient.name,
                    calories: apiIngredient.calories,
                    carbs: apiIngredient.carbs,
                    protein: apiIngredient.protein,
                    fats: apiIngredient.fats
                )
            }
            
            let total = NutritionTotal(
                calories: apiAnalysisResponse.total.calories,
                carbs: apiAnalysisResponse.total.carbs,
                protein: apiAnalysisResponse.total.protein,
                fats: apiAnalysisResponse.total.fats,
                healthScore: apiAnalysisResponse.total.healthScore
            )
            
            let analysisResponse = AnalysisResponse(
                dishName: apiAnalysisResponse.dishName,
                ingredients: ingredients,
                total: total
            )
            
            print("\(logPrefix) Analysis completed successfully")
            return analysisResponse
        } catch {
            print("\(logPrefix) API call failed: \(error.localizedDescription)")
            if let decodingError = error as? DecodingError {
                print("\(logPrefix) Decoding error details: \(decodingError)")
            }
            throw error
        }
    }
}

// MARK: - Supporting Types
enum APIError: Error {
    case imageConversionFailed
    case invalidResponse
    case apiError(statusCode: Int)
    case parsingFailed
    case requestSerializationFailed
    case invalidURL
} 