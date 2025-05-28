# CarbCal - AI-Powered Food Nutrition Tracker

CarbCal is an iOS application that uses AI to analyze food photos and track nutritional information. Built with SwiftUI and OpenAI's Vision API, it provides an intuitive way to log meals and monitor your nutrition.

## Features

- 📸 Take photos of your food or choose from gallery
- 🤖 AI-powered food analysis using OpenAI Vision API
- 📊 Detailed nutritional breakdown (calories, carbs, protein, fats)
- ✏️ Editable results for accuracy
- 📅 Daily meal history tracking
- 🌙 Dark/Light mode support

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- OpenAI API Key

## Installation

1. Clone the repository:
```bash
git clone https://github.com/rohithsidd1/CarbCal.git
cd CarbCal
```

2. Install dependencies:
```bash
# No external dependencies required
```

3. Configure OpenAI API:
   - Create a `.env` file in the project root
   - Add your OpenAI API key:
   ```
   OPENAI_API_KEY=your_api_key_here
   ```

## Building the Project

1. Open the project in Xcode:
```bash
open CarbCal.xcodeproj
```

2. Configure signing:
   - Select the CarbCal target
   - Go to Signing & Capabilities
   - Select your development team
   - Update the Bundle Identifier if needed

3. Build and Run:
   - Select your target device/simulator
   - Press ⌘R or click the Play button
   - Wait for the build to complete

## Project Structure

```
CarbCal/
├── Views/
│   ├── HomeView.swift       # Main view with camera and history
│   ├── ResultsView.swift    # Analysis results and editing
│   └── CameraView.swift     # Camera and photo picker
├── Models/
│   └── Models.swift         # Data models and storage
├── Services/
│   └── OpenAIService.swift  # OpenAI API integration
└── Resources/
    └── Assets.xcassets      # App icons and images
```

## Usage

1. Launch the app
2. Choose to take a photo or select from gallery
3. Wait for AI analysis
4. Review and edit results if needed
5. Save the meal log
6. View your daily history and nutrition summary

## Troubleshooting

### Common Issues

1. Camera Access Denied
   - Go to Settings > Privacy > Camera
   - Enable access for CarbCal

2. Photo Library Access Denied
   - Go to Settings > Privacy > Photos
   - Enable access for CarbCal

3. OpenAI API Errors
   - Verify your API key in the .env file
   - Check your internet connection
   - Ensure you have sufficient API credits

### Build Errors

1. Signing Issues
   - Verify your Apple Developer account
   - Check provisioning profiles
   - Update bundle identifier

2. Swift Version Mismatch
   - Ensure Xcode 15.0+ is installed
   - Update Swift tools if needed

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- OpenAI for the Vision API
- Apple for SwiftUI framework
- Contributors and maintainers 