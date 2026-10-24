import React, { useEffect } from 'react';
import { View, Text, StyleSheet, ActivityIndicator } from 'react-native';
import { AppColors } from '../utils/theme';
import { AppConstants } from '../utils/constants';

export const SplashScreen = ({ navigation }: any) => {
  useEffect(() => {
    const timer = setTimeout(() => {
      navigation.replace('Login');
    }, 3000);
    return () => clearTimeout(timer);
  }, [navigation]);

  return (
    <View style={styles.container}>
      <View style={styles.iconCircle}>
        <Text style={styles.iconText}>🌐</Text>
      </View>

      <Text style={styles.appName}>{AppConstants.appName}</Text>
      <Text style={styles.tagline}>{AppConstants.tagline}</Text>
      <Text style={styles.badge}>150+ Languages Supported</Text>

      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color={AppColors.white} />
        <Text style={styles.loadingText}>Loading...</Text>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: AppColors.background,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 25,
  },
  iconCircle: {
    width: 120,
    height: 120,
    borderRadius: 60,
    backgroundColor: 'rgba(255, 255, 255, 0.12)',
    borderWidth: 2,
    borderColor: 'rgba(255, 255, 255, 0.24)',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 35,
  },
  iconText: {
    fontSize: 60,
  },
  appName: {
    color: AppColors.white,
    fontSize: 34,
    fontWeight: 'bold',
    letterSpacing: 1,
    marginBottom: 15,
  },
  tagline: {
    color: 'rgba(255, 255, 255, 0.7)',
    fontSize: 18,
    textAlign: 'center',
    marginBottom: 20,
    paddingHorizontal: 15,
  },
  badge: {
    color: 'rgba(255, 255, 255, 0.6)',
    fontSize: 15,
    marginBottom: 50,
  },
  loadingContainer: {
    alignItems: 'center',
  },
  loadingText: {
    color: 'rgba(255, 255, 255, 0.7)',
    fontSize: 16,
    marginTop: 15,
  },
});
