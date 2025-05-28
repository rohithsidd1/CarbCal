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
    func analyzeFoodImage(_ image: UIImage, completion: @escaping (Result<AnalysisResponse, APIError>) -> Void) {
        // [ImageCompression] Compress image before upload
        let logPrefix = "[OpenAIService][ImageCompression]"
        let compressionQuality: CGFloat = 0.5 // Adjust as needed
        guard let compressedData = image.jpegData(compressionQuality: compressionQuality) else {
            print("\(logPrefix) Failed to compress image.")
            completion(.failure(.invalidImageData))
            return
        }
        print("\(logPrefix) Original size: \(image.pngData()?.count ?? 0) bytes, Compressed size: \(compressedData.count) bytes, Quality: \(compressionQuality)")
        
        // Convert image to base64
        let base64Image = compressedData.base64EncodedString()
        
        // Prepare request URL with correct Azure OpenAI format
        let urlString = "\(endpoint)/openai/deployments/\(deploymentName)/chat/completions?api-version=\(apiVersion)"
        print("\(logPrefix) Request URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("\(logPrefix) Invalid URL: \(urlString)")
            completion(.failure(.invalidURL))
            return
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
            let data = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = data
            print("\(logPrefix) Request body prepared successfully")
            print("\(logPrefix) Request headers: \(request.allHTTPHeaderFields ?? [:])")
        } catch {
            print("\(logPrefix) Failed to serialize request body: \(error.localizedDescription)")
            completion(.failure(.requestSerializationFailed))
            return
        }
        
        // Make API call using dataTask
        let session = URLSession.shared
        print("\(logPrefix) Making API request to Azure OpenAI (dataTask)")
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("\(logPrefix) Network error: \(error.localizedDescription)")
                completion(.failure(.apiError(statusCode: 500)))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("\(logPrefix) Invalid response type")
                completion(.failure(.invalidResponse))
                return
            }
            guard let data = data else {
                print("\(logPrefix) No data received")
                completion(.failure(.invalidResponse))
                return
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
                completion(.failure(.apiError(statusCode: httpResponse.statusCode)))
                return
            }
            // Parse OpenAI response
            let decoder = JSONDecoder()
            do {
                let apiResponse = try decoder.decode(APIResponse.self, from: data)
                // Print the content before parsing
                if let content = apiResponse.choices.first?.message.content {
                    print("\(logPrefix) Response content before parsing: \(content)")
                }
                // Extract and parse the JSON string from the response
                guard let jsonString = apiResponse.choices.first?.message.content,
                      let jsonData = jsonString.data(using: .utf8) else {
                    print("\(logPrefix) Failed to parse response content")
                    completion(.failure(.parsingFailed))
                    return
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
                completion(.success(analysisResponse))
            } catch {
                print("\(logPrefix) API call failed: \(error.localizedDescription)")
                if let decodingError = error as? DecodingError {
                    print("\(logPrefix) Decoding error details: \(decodingError)")
                }
                completion(.failure(.apiError(statusCode: 500)))
            }
        }
        task.resume()
    }

    // Async/await wrapper for concurrency compatibility
    func analyzeFoodImage(_ image: UIImage) async throws -> AnalysisResponse {
        return try await withCheckedThrowingContinuation { continuation in
            self.analyzeFoodImage(image) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
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
    case invalidImageData
} 
