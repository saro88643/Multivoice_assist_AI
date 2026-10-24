# MultiVoice Assist — Testing Guide

## Test Suite Execution

### 1. TypeScript Validation
```bash
npm run type-check
```

### 2. Unit & RAG Tests
```bash
npm test
```

### 3. Native Android Build & Execution
```bash
npx react-native run-android
```

### 4. Offline Verification
1. Enable Airplane Mode on device/emulator.
2. Launch MultiVoice Assist.
3. Verify status badge: `● Local RAG Ready`.
4. Send a query and observe grounded offline response and source citations.
