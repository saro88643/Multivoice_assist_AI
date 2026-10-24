import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  ScrollView,
  Alert,
  ActivityIndicator,
} from 'react-native';
import { authService } from '../services/authService';
import { useProfile } from '../providers/ProfileContext';
import { AppColors } from '../utils/theme';

export const RegisterScreen = ({ navigation }: any) => {
  const profile = useProfile();
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [isRegistering, setIsRegistering] = useState(false);

  const handleRegister = async () => {
    if (!name.trim()) {
      Alert.alert('Validation', 'Please enter your name');
      return;
    }
    if (!email.trim() || !email.includes('@')) {
      Alert.alert('Validation', 'Please enter a valid email');
      return;
    }
    if (!phone.trim()) {
      Alert.alert('Validation', 'Please enter your phone number');
      return;
    }
    if (!password || password.length < 6) {
      Alert.alert('Validation', 'Password must be at least 6 characters');
      return;
    }
    if (password !== confirmPassword) {
      Alert.alert('Validation', 'Passwords do not match');
      return;
    }

    setIsRegistering(true);
    try {
      await authService.register({ name, email, phone, password });
      await profile.loadProfile();
      Alert.alert('Success', 'Registration successful! Please login.');
      navigation.replace('Login');
    } catch (e: any) {
      Alert.alert('Error', e.message || 'Registration failed');
    } finally {
      setIsRegistering(false);
    }
  };

  return (
    <ScrollView contentContainerStyle={styles.scrollContainer}>
      <TouchableOpacity
        style={styles.backBtn}
        onPress={() => navigation.goBack()}
      >
        <Text style={styles.backText}>❮ Back</Text>
      </TouchableOpacity>

      <View style={styles.logoCircle}>
        <Text style={styles.logoIcon}>👤</Text>
      </View>

      <Text style={styles.title}>Create Account</Text>

      <View style={styles.inputContainer}>
        <Text style={styles.label}>Full Name</Text>
        <TextInput
          style={styles.input}
          value={name}
          onChangeText={setName}
          placeholder="Enter your name"
          placeholderTextColor="rgba(255,255,255,0.38)"
        />
      </View>

      <View style={styles.inputContainer}>
        <Text style={styles.label}>Email Address</Text>
        <TextInput
          style={styles.input}
          value={email}
          onChangeText={setEmail}
          placeholder="Enter your email"
          placeholderTextColor="rgba(255,255,255,0.38)"
          keyboardType="email-address"
          autoCapitalize="none"
        />
      </View>

      <View style={styles.inputContainer}>
        <Text style={styles.label}>Phone Number</Text>
        <TextInput
          style={styles.input}
          value={phone}
          onChangeText={setPhone}
          placeholder="Enter your phone"
          placeholderTextColor="rgba(255,255,255,0.38)"
          keyboardType="phone-pad"
        />
      </View>

      <View style={styles.inputContainer}>
        <Text style={styles.label}>Password</Text>
        <TextInput
          style={styles.input}
          value={password}
          onChangeText={setPassword}
          placeholder="Create a password"
          placeholderTextColor="rgba(255,255,255,0.38)"
          secureTextEntry
        />
      </View>

      <View style={styles.inputContainer}>
        <Text style={styles.label}>Confirm Password</Text>
        <TextInput
          style={styles.input}
          value={confirmPassword}
          onChangeText={setConfirmPassword}
          placeholder="Repeat your password"
          placeholderTextColor="rgba(255,255,255,0.38)"
          secureTextEntry
        />
      </View>

      <TouchableOpacity
        style={styles.registerBtn}
        onPress={handleRegister}
        disabled={isRegistering}
      >
        {isRegistering ? (
          <ActivityIndicator color={AppColors.white} />
        ) : (
          <Text style={styles.registerBtnText}>Register Now</Text>
        )}
      </TouchableOpacity>

      <View style={styles.loginRow}>
        <Text style={styles.alreadyText}>Already have an account? </Text>
        <TouchableOpacity onPress={() => navigation.navigate('Login')}>
          <Text style={styles.loginLink}>Login</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  scrollContainer: {
    flexGrow: 1,
    backgroundColor: AppColors.background,
    padding: 24,
    alignItems: 'center',
  },
  backBtn: {
    alignSelf: 'flex-start',
    marginTop: 10,
    marginBottom: 20,
  },
  backText: {
    color: AppColors.white,
    fontSize: 16,
  },
  logoCircle: {
    width: 90,
    height: 90,
    borderRadius: 45,
    backgroundColor: AppColors.primary,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 20,
  },
  logoIcon: {
    fontSize: 45,
  },
  title: {
    color: AppColors.white,
    fontSize: 26,
    fontWeight: 'bold',
    marginBottom: 25,
  },
  inputContainer: {
    width: '100%',
    marginBottom: 16,
  },
  label: {
    color: 'rgba(255,255,255,0.7)',
    marginBottom: 6,
    fontSize: 14,
  },
  input: {
    backgroundColor: AppColors.surface,
    borderRadius: 15,
    paddingHorizontal: 16,
    paddingVertical: 12,
    color: AppColors.white,
    fontSize: 16,
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.12)',
  },
  registerBtn: {
    width: '100%',
    height: 55,
    backgroundColor: AppColors.primary,
    borderRadius: 15,
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: 15,
    marginBottom: 24,
  },
  registerBtnText: {
    color: AppColors.white,
    fontSize: 18,
    fontWeight: 'bold',
  },
  loginRow: {
    flexDirection: 'row',
  },
  alreadyText: {
    color: 'rgba(255,255,255,0.7)',
  },
  loginLink: {
    color: AppColors.primary,
    fontWeight: 'bold',
  },
});
