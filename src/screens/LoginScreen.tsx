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
import { useAuth } from '../providers/AuthContext';
import { useProfile } from '../providers/ProfileContext';
import { AppColors } from '../utils/theme';
import { AppConstants } from '../utils/constants';

export const LoginScreen = ({ navigation }: any) => {
  const { login } = useAuth();
  const profile = useProfile();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [hidePassword, setHidePassword] = useState(true);
  const [rememberMe, setRememberMe] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  const handleLogin = async () => {
    if (!email.trim()) {
      Alert.alert('Validation', 'Please enter your email.');
      return;
    }
    if (!password) {
      Alert.alert('Validation', 'Please enter your password.');
      return;
    }

    setIsLoading(true);
    const success = await login(email, password);
    if (success) {
      await profile.loadProfile();
      setIsLoading(false);
      navigation.reset({
        index: 0,
        routes: [{ name: 'Home' }],
      });
    } else {
      setIsLoading(false);
      Alert.alert('Login Failed', 'Invalid email or password.');
    }
  };

  return (
    <ScrollView contentContainerStyle={styles.scrollContainer}>
      <View style={styles.logoCircle}>
        <Text style={styles.logoIcon}>🌐</Text>
      </View>

      <Text style={styles.appName}>{AppConstants.appName}</Text>
      <Text style={styles.subtitle}>Welcome Back!</Text>

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
        <Text style={styles.label}>Password</Text>
        <View style={styles.passwordWrapper}>
          <TextInput
            style={[styles.input, { flex: 1 }]}
            value={password}
            onChangeText={setPassword}
            placeholder="Enter your password"
            placeholderTextColor="rgba(255,255,255,0.38)"
            secureTextEntry={hidePassword}
          />
          <TouchableOpacity
            onPress={() => setHidePassword(!hidePassword)}
            style={styles.eyeBtn}
          >
            <Text style={{ fontSize: 18 }}>{hidePassword ? '👁️' : '🙈'}</Text>
          </TouchableOpacity>
        </View>
      </View>

      <TouchableOpacity
        style={styles.rememberRow}
        onPress={() => setRememberMe(!rememberMe)}
      >
        <Text style={styles.checkbox}>{rememberMe ? '☑️' : '⬜'}</Text>
        <Text style={styles.rememberText}>Remember Me</Text>
      </TouchableOpacity>

      <TouchableOpacity
        style={styles.loginBtn}
        onPress={handleLogin}
        disabled={isLoading}
      >
        {isLoading ? (
          <ActivityIndicator color={AppColors.white} />
        ) : (
          <Text style={styles.loginBtnText}>Login ➔</Text>
        )}
      </TouchableOpacity>

      <View style={styles.registerRow}>
        <Text style={styles.noAccountText}>Don't have an account? </Text>
        <TouchableOpacity onPress={() => navigation.navigate('Register')}>
          <Text style={styles.registerLink}>Register</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.footer}>
        <Text style={styles.footerApp}>{AppConstants.appName}</Text>
        <Text style={styles.footerVer}>Version {AppConstants.version}</Text>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  scrollContainer: {
    flexGrow: 1,
    backgroundColor: AppColors.background,
    padding: 25,
    alignItems: 'center',
    justifyContent: 'center',
  },
  logoCircle: {
    width: 120,
    height: 120,
    borderRadius: 60,
    backgroundColor: AppColors.primary,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 25,
  },
  logoIcon: {
    fontSize: 65,
  },
  appName: {
    color: AppColors.white,
    fontSize: 32,
    fontWeight: 'bold',
    marginBottom: 10,
  },
  subtitle: {
    color: AppColors.grey,
    fontSize: 18,
    marginBottom: 35,
  },
  inputContainer: {
    width: '100%',
    marginBottom: 20,
  },
  label: {
    color: 'rgba(255,255,255,0.7)',
    marginBottom: 8,
    fontSize: 14,
  },
  input: {
    backgroundColor: AppColors.surface,
    borderRadius: 18,
    paddingHorizontal: 20,
    paddingVertical: 14,
    color: AppColors.white,
    fontSize: 16,
  },
  passwordWrapper: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  eyeBtn: {
    position: 'absolute',
    right: 15,
  },
  rememberRow: {
    flexDirection: 'row',
    alignItems: 'center',
    alignSelf: 'flex-start',
    marginBottom: 25,
  },
  checkbox: {
    fontSize: 18,
    marginRight: 8,
  },
  rememberText: {
    color: 'rgba(255,255,255,0.7)',
    fontSize: 15,
  },
  loginBtn: {
    width: '100%',
    height: 58,
    backgroundColor: AppColors.primary,
    borderRadius: 18,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 30,
    elevation: 8,
  },
  loginBtnText: {
    color: AppColors.white,
    fontSize: 18,
    fontWeight: 'bold',
  },
  registerRow: {
    flexDirection: 'row',
    marginBottom: 30,
  },
  noAccountText: {
    color: 'rgba(255,255,255,0.7)',
  },
  registerLink: {
    color: AppColors.primary,
    fontWeight: 'bold',
  },
  footer: {
    alignItems: 'center',
    borderTopWidth: 1,
    borderTopColor: 'rgba(255,255,255,0.12)',
    width: '100%',
    paddingTop: 15,
  },
  footerApp: {
    color: 'rgba(255,255,255,0.54)',
    fontSize: 16,
    fontWeight: 'bold',
  },
  footerVer: {
    color: 'rgba(255,255,255,0.38)',
    fontSize: 13,
  },
});
