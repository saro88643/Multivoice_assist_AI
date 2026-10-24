import React from 'react';
import { View, ActivityIndicator, Text, StyleSheet } from 'react-native';
import { AppColors } from '../utils/theme';

interface LoadingIndicatorProps {
  message?: string;
}

export const LoadingIndicator: React.FC<LoadingIndicatorProps> = ({ message = 'Loading...' }) => {
  return (
    <View style={styles.container}>
      <ActivityIndicator size="large" color={AppColors.purple} />
      {message ? <Text style={styles.text}>{message}</Text> : null}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    padding: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },
  text: {
    color: AppColors.grey,
    marginTop: 10,
    fontSize: 14,
  },
});
