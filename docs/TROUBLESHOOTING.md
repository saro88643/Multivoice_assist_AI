# MultiVoice Assist — Troubleshooting Guide

## Common Solutions

### 1. `"temp_rn" has not been registered`
- **Cause**: Main component name mismatch in `MainActivity.kt`.
- **Solution**: `index.js` registers both `multivoice_assist_react_native` and `temp_rn`.

### 2. `Java heap space` during Gradle build
- **Cause**: Inadequate JVM memory for Gradle daemon.
- **Solution**: Set `org.gradle.jvmargs=-Xmx4096m` and `android.enableJetifier=false` in `android/gradle.properties`.

### 3. `Unable to resolve module react-native/asset-registry`
- **Cause**: Metro asset resolver resolution path in RN 0.73.
- **Solution**: `metro.config.js` maps `react-native/asset-registry` to `react-native/Libraries/Image/AssetRegistry`.
