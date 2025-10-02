# Industrial Depot iOS App

This is the iOS version of the Industrial Depot app, designed for iPhone 17 Pro and other iOS devices.

## Features

- **Welcome Screen**: Main entry point with category selection
- **Robots Catalogue**: Browse industrial robots with specifications
- **Cobots Catalogue**: Browse collaborative robots with specifications  
- **Laser Calculator**: Calculate laser cutting parameters for different materials
- **Local Data**: All data is stored locally (no Firebase connection)
- **Spanish Translation**: Full Spanish localization for Mexican market

## Project Structure

```
Industrial Depot/
├── Models/
│   ├── RobotModel.swift          # Robot/Cobot data model
│   └── LaserModel.swift          # Laser parameter models
├── Views/
│   ├── WelcomeView.swift         # Main welcome screen
│   ├── RobotsListView.swift      # Industrial robots list
│   ├── CobotsListView.swift      # Collaborative robots list
│   ├── RobotDetailView.swift     # Robot/Cobot detail screen
│   └── LaserCalculatorView.swift # Laser calculator
├── Repositories/
│   ├── RobotsRepository.swift    # Robot data management
│   └── LaserDataRepository.swift # Laser data management
├── Utils/
│   ├── ParameterTranslator.swift # Spanish translations
│   └── LocalImageHelper.swift    # Image asset management
├── Assets/
│   └── Images/                   # Robot, cobot, and laser images
└── Data/                         # CSV data files
```

## Data Sources

- **Robot Images**: Located in `Assets/Images/Robots/` and `Assets/Images/Cobots/`
- **Laser Image**: Located in `Assets/Images/Laser/laser_machine.jpg`
- **CSV Data**: Located in `Data/` folder
  - `robot_specs.csv` - Industrial robot specifications
  - `cobot_specs.csv` - Collaborative robot specifications
  - `laser_cut_params_subset_with_id.csv` - Laser cutting parameters
  - `laser_perforation_params_subset_with_id.csv` - Laser perforation parameters

## Building and Running

1. Open `Industrial Depot.xcodeproj` in Xcode
2. Select iPhone 17 Pro simulator or your target device
3. Build and run the project (⌘+R)

## Key Features

### Welcome Screen
- Displays "Welcome to Industrial Depot, Industrial Machinery Marketplace"
- Three main categories: Cobots, Robots Industriales, Láser
- Each category has representative images

### Robot/Cobot Lists
- Displays robots with images and key specifications
- Translated parameter names (Payload → Carga Útil, etc.)
- Tap to view detailed specifications

### Robot/Cobot Details
- Full specifications with translated parameter names
- Contact information for Axiom Robotics
- "¿Necesita una cotización o asesoría?" section

### Laser Calculator
- Material selection dropdown with Spanish translations
- Thickness input in mm
- Calculates cutting and perforation parameters
- Contact information for Industrial Metal Systems

## Localization

All user-facing text is in Spanish:
- Parameter names are translated (e.g., "Payload" → "Carga Útil")
- Material names are translated (e.g., "Aluminum Alloy" → "Aluminio")
- UI text is in Spanish (e.g., "Cargando robots..." for "Loading robots...")

## Dependencies

- SwiftUI (iOS 17.0+)
- No external dependencies - uses only Apple frameworks

## Notes

- The app uses local CSV files instead of Firebase for data
- Images are stored as local assets in the app bundle
- All functionality matches the Android version
- Optimized for iPhone 17 Pro but compatible with other iOS devices
