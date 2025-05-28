

# CarbCal iOS App – PRD (Product Requirements Document)

---

## Project Overview

**CarbCal** is an iOS SwiftUI application that enables users to:
- Capture photos of meals.
- Analyze ingredients and estimate nutritional data using the OpenAI Vision API.
- Review and edit auto-generated results.
- Maintain a day-wise history of meals with total calorie count.

The app uses AI-driven multimodal vision analysis to automate food tracking, making calorie logging seamless and intuitive.

---

## Features

1. **Food Capture**
   - User clicks a button to open the camera and take a food photo.
   - Captured image is temporarily stored and passed to the analysis module.

2. **AI Food Analysis**
   - Image is uploaded to the backend (which uses OpenAI's Vision API).
   - The response includes:
     - List of ingredients
     - Calories, Carbs, Protein, Fats per item
     - Total summary of nutrition
     - Dish name

3. **Editable Results View**
   - Users can update the ingredient details and macros if the AI output is incorrect.
   - Each edited log is saved with a timestamp.

4. **Daily History View**
   - Displays a calendar/date-switch UI.
   - Shows total calories for selected date.
   - Lists all food logs for the day.

---

## Requirements for Each Feature

### 1. Food Capture

- Use `AVCaptureSession` or `UIImagePickerController`.
- Save captured image locally (e.g., to `FileManager.default.temporaryDirectory`)
- Variable: `capturedImage: UIImage`

### 2. AI Food Analysis

- API: `POST /analyze-food-image`
- Headers: 
  - `Authorization`: Bearer token
  - `Content-Type`: multipart/form-data
- Body:
  - `image`: binary file
- Response:
```json
{
  "dishName": "Pancakes with blueberries & syrup",
  "ingredients": [
    { "name": "Pancakes", "calories": 595, "carbs": 85, "protein": 9, "fats": 19 },
    { "name": "Blueberries", "calories": 8, "carbs": 2, "protein": 0, "fats": 0 },
    { "name": "Syrup", "calories": 12, "carbs": 6, "protein": 0, "fats": 0 }
  ],
  "total": {
    "calories": 615,
    "carbs": 93,
    "protein": 11,
    "fats": 21,
    "healthScore": 7
  }
}
```

### 3. Editable Results View

- Each ingredient is displayed in a `List`.
- Editable fields: Name, Calories, Carbs, Protein, Fats
- “Fix Results” button to adjust manually
- “Done” button to confirm
- Save to persistent storage

### 4. Daily History View

- Top section: `DatePicker` or horizontal scroll calendar
- Below: 
  - Total calorie display (`Text("Total: \(totalCalories)")`)
  - ScrollView of `FoodLogCard` views
- Core Data or Firebase used for storage

---

## Data Models

```swift
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
```

---

## API Contract

### `POST /analyze-food-image`

- Headers:
  - `Authorization`: Bearer Token
  - `Content-Type`: multipart/form-data
- Body:
  - `image`: binary file
- Response: *See AI Food Analysis section above*

### `POST /food-logs`

- Body:
```json
{
  "dishName": "Salad",
  "date": "2025-05-27",
  "ingredients": [...],
  "healthScore": 8,
  "imagePath": "localPathOrURL"
}
```

### `GET /food-logs?date=YYYY-MM-DD`

- Response:
```json
{
  "date": "2025-05-27",
  "totalCalories": 1270,
  "logs": [
    {
      "dishName": "Salad",
      "imagePath": "...",
      "ingredients": [...],
      "healthScore": 8
    }
  ]
}
```

---

## Dependencies

- **Backend**: FastAPI + OpenAI Vision API
- **Frontend**: SwiftUI
- **Image Handling**: `AVCaptureSession`, `UIImagePickerController`
- **Networking**: `URLSession` or `Alamofire`
- **Storage**: Core Data (or optionally Firebase)
- **State Management**: `@State`, `@ObservedObject`, `@EnvironmentObject`

---

## Build Order (Cursor Sequence)

1. Setup SwiftUI project and routing
2. Implement camera view (feature 1)
3. Create API handler and integrate vision API (feature 2)
4. Build results UI + editable fields (feature 3)
5. Implement Core Data storage + calendar view (feature 4)
6. Final UI polish + error handling