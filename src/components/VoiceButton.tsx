import React from 'react';
import { TouchableOpacity, Text, StyleSheet, View } from 'react-native';
import { AppColors } from '../utils/theme';

interface VoiceButtonProps {
  isListening: boolean;
  onPressIn: () => void;
  onPressOut: () => void;
}

export const VoiceButton: React.FC<VoiceButtonProps> = ({
  isListening,
  onPressIn,
  onPressOut,
}) => {
  return (
    <TouchableOpacity
      activeOpacity={0.8}
      onPressIn={onPressIn}
      onPressOut={onPressOut}
      style={[
        styles.button,
        isListening ? styles.listeningBtn : styles.normalBtn,
      ]}
    >
      <Text style={styles.icon}>{isListening ? '🎙️' : '🎙️'}</Text>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  button: {
    width: 90,
    height: 90,
    borderRadius: 45,
    justifyContent: 'center',
    alignItems: 'center',
    elevation: 8,
    shadowColor: AppColors.primary,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.35,
    shadowRadius: 10,
  },
  normalBtn: {
    backgroundColor: AppColors.blue,
  },
  listeningBtn: {
    backgroundColor: AppColors.error,
  },
  icon: {
    fontSize: 42,
  },
});
