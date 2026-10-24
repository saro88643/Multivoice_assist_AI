import React from 'react';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { NavigationContainer } from '@react-navigation/native';
import { AppNavigator } from './navigation/AppNavigator';
import { AuthProvider } from './providers/AuthContext';
import { ChatProvider } from './providers/ChatContext';
import { HistoryProvider } from './providers/HistoryContext';
import { ProfileProvider } from './providers/ProfileContext';
import { SpeechProvider } from './providers/SpeechContext';

const App = () => {
  return (
    <SafeAreaProvider>
      <AuthProvider>
        <ProfileProvider>
          <HistoryProvider>
            <ChatProvider>
              <SpeechProvider>
                <NavigationContainer>
                  <AppNavigator />
                </NavigationContainer>
              </SpeechProvider>
            </ChatProvider>
          </HistoryProvider>
        </ProfileProvider>
      </AuthProvider>
    </SafeAreaProvider>
  );
};

export default App;
