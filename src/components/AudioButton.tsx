import React from 'react';
import { TouchableOpacity, Text, StyleSheet } from 'react-native';
import { AppColors } from '../utils/theme';

interface AudioButtonProps {
  onPress: () => void;
  isPlaying?: boolean;
}

export const AudioButton: React.FC<AudioButtonProps> = ({ onPress, isPlaying }) => {
  return (
    <TouchableOpacity style={styles.button} onPress={onPress}>
      <Text style={styles.icon}>{isPlaying ? '🔊' : '🔉'}</Text>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  button: {
    padding: 6,
  },
  icon: {
    fontSize: 22,
    color: AppColors.primaryPurple,
  },
});
