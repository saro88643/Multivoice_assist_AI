import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  Alert,
} from 'react-native';
import { useProfile } from '../providers/ProfileContext';
import { AppColors } from '../utils/theme';

export const EditProfileScreen = ({ navigation }: any) => {
  const { userName, userEmail, updateProfile } = useProfile();
  const [name, setName] = useState(userName);
  const [email, setEmail] = useState(userEmail);

  const handleSave = async () => {
    if (!name.trim()) {
      Alert.alert('Validation', 'Please enter your name');
      return;
    }
    if (!email.trim() || !email.includes('@')) {
      Alert.alert('Validation', 'Please enter a valid email');
      return;
    }

    await updateProfile(name, email);
    Alert.alert('Success', 'Profile updated successfully');
    navigation.goBack();
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backBtn}>
          <Text style={styles.backText}>❮ Back</Text>
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Edit Profile</Text>
        <View style={{ width: 40 }} />
      </View>

      <View style={styles.form}>
        <Text style={styles.label}>Full Name</Text>
        <TextInput
          style={styles.input}
          value={name}
          onChangeText={setName}
          placeholder="Enter name"
          placeholderTextColor="rgba(255,255,255,0.38)"
        />

        <Text style={styles.label}>Email Address</Text>
        <TextInput
          style={styles.input}
          value={email}
          onChangeText={setEmail}
          placeholder="Enter email"
          placeholderTextColor="rgba(255,255,255,0.38)"
          keyboardType="email-address"
          autoCapitalize="none"
        />

        <TouchableOpacity style={styles.saveBtn} onPress={handleSave}>
          <Text style={styles.saveBtnText}>Save Changes</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: AppColors.background,
    padding: 20,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 30,
  },
  backBtn: {
    padding: 4,
  },
  backText: {
    color: AppColors.white,
    fontSize: 16,
  },
  headerTitle: {
    color: AppColors.white,
    fontSize: 20,
    fontWeight: 'bold',
  },
  form: {
    width: '100%',
  },
  label: {
    color: 'rgba(255,255,255,0.7)',
    marginBottom: 8,
    fontSize: 14,
  },
  input: {
    backgroundColor: AppColors.surface,
    borderRadius: 15,
    paddingHorizontal: 16,
    paddingVertical: 14,
    color: AppColors.white,
    fontSize: 16,
    marginBottom: 20,
  },
  saveBtn: {
    height: 52,
    backgroundColor: AppColors.primary,
    borderRadius: 15,
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: 10,
  },
  saveBtnText: {
    color: AppColors.white,
    fontSize: 16,
    fontWeight: 'bold',
  },
});
