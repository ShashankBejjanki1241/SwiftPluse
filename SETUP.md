# SwiftPulse Setup Guide

This guide will help you get SwiftPulse up and running on your development machine.

## Prerequisites

- Xcode 15.0 or later
- iOS 16.0+ deployment target
- macOS 13.0 or later
- Git

## Getting Started

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd SwiftPulse
```

### 2. Configure API Keys

1. Get a free API key from [NewsAPI](https://newsapi.org/)
2. Copy the `Config/SwiftPulse.xcconfig.example` file:
   ```bash
   cp Config/SwiftPulse.xcconfig Config/SwiftPulse.xcconfig
   ```
3. Edit `Config/SwiftPulse.xcconfig` and replace `your_api_key_here` with your actual API key

**⚠️ Important**: Never commit your real API key to source control!

### 3. Open the Project

1. Open `SwiftPulse.xcodeproj` in Xcode
2. Select your development team in the project settings
3. Choose an iOS simulator (iPhone 15 recommended)

### 4. Build and Run

1. Press `Cmd + R` to build and run the project
2. The app should launch in the simulator

## Project Structure

```
SwiftPulse/
├── Sources/                    # Source code
│   ├── App/                   # App entry point
│   ├── Features/              # Feature modules
│   │   ├── Feed/             # News feed
│   │   ├── Detail/           # Article details
│   │   ├── Favorites/        # Saved articles
│   │   └── Settings/         # App settings
│   ├── Data/                  # Data layer
│   │   ├── Networking/       # API client
│   │   ├── Repositories/     # Data orchestration
│   │   └── Persistence/      # SwiftData models
│   └── Shared/               # Common utilities
│       ├── DesignSystem/     # UI components
│       ├── FeatureFlags/     # Feature toggles
│       └── Analytics/        # Event tracking
├── Tests/                     # Unit and UI tests
├── Config/                    # Configuration files
├── .github/                   # CI/CD workflows
└── fastlane/                  # Deployment automation
```

## Architecture Overview

- **MVVM Pattern**: ViewModels manage state and business logic
- **Repository Pattern**: Abstracts data sources and caching
- **SwiftData**: Modern persistence framework for offline support
- **Async/Await**: Modern concurrency for networking
- **Combine**: Reactive programming for search and state management

## Key Features

- 📰 **News Feed**: Latest articles with infinite scroll
- 🔍 **Search**: Debounced search with real-time results
- ❤️ **Favorites**: Save articles for offline reading
- ⚙️ **Settings**: App configuration and preferences
- 📱 **Offline Support**: Cached content when offline
- 🎨 **Modern UI**: SwiftUI with accessibility support

## Testing

### Run Unit Tests
```bash
# In Xcode: Cmd + U
# Or via command line:
xcodebuild test -scheme SwiftPulse -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Run UI Tests
```bash
xcodebuild test -scheme SwiftPulse -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:SwiftPulseUITests
```

## Deployment

### TestFlight (Beta)
```bash
fastlane beta
```

### App Store
```bash
fastlane release
```

## Troubleshooting

### Common Issues

1. **Build Errors**: Ensure you're using Xcode 15+ and iOS 16+ deployment target
2. **API Errors**: Verify your API key is correct and has proper permissions
3. **Simulator Issues**: Try resetting the simulator (Device → Erase All Content and Settings)
4. **SwiftData Errors**: Clean build folder (Product → Clean Build Folder)

### Getting Help

- Check the [README.md](README.md) for project overview
- Review the [GitHub Issues](https://github.com/your-repo/issues) for known problems
- Create a new issue if you encounter a bug

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is for portfolio demonstration purposes.
