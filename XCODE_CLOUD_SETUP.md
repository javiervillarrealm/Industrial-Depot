# Xcode Cloud Setup

## Bundle Identifier
- **Main App**: `mx.com.industrialdepot`
- **Tests**: `mx.com.industrialdepot.tests`
- **UI Tests**: `mx.com.industrialdepot.uitests`

## Signing Configuration
- **Code Signing Style**: Automatic
- **Development Team**: `78DJ2L3G2N`
- **Provisioning Profile**: Empty (automatic signing)

## Export Options
The project includes an `exportOptions.plist` file configured for App Store Connect distribution with automatic signing.

## Xcode Cloud Configuration
1. Ensure the scheme "Industrial Depot" is shared (✅ Already configured)
2. Archive configuration uses Release build (✅ Already configured)
3. Bundle identifier is set to `mx.com.industrialdepot` (✅ Already configured)
4. Automatic signing is enabled (✅ Already configured)

## Build Number
Current build number: 3

## Notes
- Xcode Cloud should use App Store Connect destination with Automatic signing
- No manual provisioning profile configuration required
- All bundle identifiers have been unified to use the `mx.com.industrialdepot` prefix
