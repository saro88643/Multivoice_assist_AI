import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Alert,
} from 'react-native';
import { useAuth } from '../providers/AuthContext';
import { useProfile } from '../providers/ProfileContext';
import { ProfileAvatar } from '../components/ProfileAvatar';
import { AppColors } from '../utils/theme';

export const ProfileScreen = ({ navigation }: any) => {
  const { logout } = useAuth();
  const { userName, userEmail, profileImagePath, setProfileImagePath } = useProfile();

  const handleLogout = () => {
    Alert.alert('Logout', 'Are you sure you want to logout?', [
      { text: 'Cancel', style: 'cancel' },
      {
        text: 'Logout',
        style: 'destructive',
        onPress: () => {
          logout();
          navigation.reset({
            index: 0,
            routes: [{ name: 'Login' }],
          });
        },
      },
    ]);
  };

  const handlePickImage = () => {
    Alert.alert(
      'Profile Photo',
      'Choose profile photo option',
      [
        {
          text: 'Set Demo Avatar',
          onPress: () =>
            setProfileImagePath('https://ui-avatars.com/api/?name=' + encodeURIComponent(userName)),
        },
        {
          text: 'Remove Photo',
          style: 'destructive',
          onPress: () => setProfileImagePath(null),
        },
        { text: 'Cancel', style: 'cancel' },
      ]
    );
  };

  const showAbout = () => {
    Alert.alert(
      'About MultiVoice Assist',
      'MultiVoice Assist\nVersion 1.0.0\n\nA multilingual AI chatbot that allows users to communicate using text and voice in different languages completely offline.'
    );
  };

  const showSecurity = () => {
    Alert.alert(
      'Security',
      'Account Security\n\nYour account security features and password management are active.'
    );
  };

  return (
    <ScrollView contentContainerStyle={styles.container}>
      {/* HEADER */}
      <View style={styles.header}>
        <TouchableOpacity onPress={() => navigation.goBack()} style={styles.backBtn}>
          <Text style={styles.backText}>❮ Back</Text>
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Profile</Text>
        <View style={{ width: 40 }} />
      </View>

      {/* AVATAR SECTION */}
      <View style={styles.avatarSection}>
        <TouchableOpacity onPress={handlePickImage} activeOpacity={0.8}>
          <ProfileAvatar imagePath={profileImagePath} radius={50} />
          <View style={styles.cameraIconBadge}>
            <Text style={{ fontSize: 14 }}>📷</Text>
          </View>
        </TouchableOpacity>

        <Text style={styles.userName}>{userName}</Text>
        <Text style={styles.userEmail}>{userEmail}</Text>

        <TouchableOpacity
          style={styles.editBtn}
          onPress={() => navigation.navigate('EditProfile')}
        >
          <Text style={styles.editBtnText}>✏️ Edit Profile</Text>
        </TouchableOpacity>
      </View>

      {/* OPTIONS LIST */}
      <View style={styles.optionsList}>
        <TouchableOpacity
          style={styles.optionItem}
          onPress={() => navigation.navigate('VoiceSettings')}
        >
          <View style={styles.optionIconCircle}>
            <Text style={{ fontSize: 18 }}>🎙️</Text>
          </View>
          <View style={styles.optionTextCol}>
            <Text style={styles.optionTitle}>Voice Settings</Text>
            <Text style={styles.optionSub}>Manage voice and speech settings</Text>
          </View>
          <Text style={styles.arrowIcon}>❯</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.optionItem}
          onPress={() => navigation.navigate('History')}
        >
          <View style={styles.optionIconCircle}>
            <Text style={{ fontSize: 18 }}>📜</Text>
          </View>
          <View style={styles.optionTextCol}>
            <Text style={styles.optionTitle}>Chat History</Text>
            <Text style={styles.optionSub}>View and manage conversations</Text>
          </View>
          <Text style={styles.arrowIcon}>❯</Text>
        </TouchableOpacity>

        <TouchableOpacity style={styles.optionItem} onPress={showSecurity}>
          <View style={styles.optionIconCircle}>
            <Text style={{ fontSize: 18 }}>🛡️</Text>
          </View>
          <View style={styles.optionTextCol}>
            <Text style={styles.optionTitle}>Security</Text>
            <Text style={styles.optionSub}>Manage account security</Text>
          </View>
          <Text style={styles.arrowIcon}>❯</Text>
        </TouchableOpacity>

        <TouchableOpacity style={styles.optionItem} onPress={showAbout}>
          <View style={styles.optionIconCircle}>
            <Text style={{ fontSize: 18 }}>ℹ️</Text>
          </View>
          <View style={styles.optionTextCol}>
            <Text style={styles.optionTitle}>About</Text>
            <Text style={styles.optionSub}>About MultiVoice Assist</Text>
          </View>
          <Text style={styles.arrowIcon}>❯</Text>
        </TouchableOpacity>
      </View>

      {/* LOGOUT BUTTON */}
      <TouchableOpacity style={styles.logoutBtn} onPress={handleLogout}>
        <Text style={styles.logoutBtnText}>🚪 Logout</Text>
      </TouchableOpacity>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flexGrow: 1,
    backgroundColor: AppColors.background,
    padding: 20,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 20,
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
  avatarSection: {
    alignItems: 'center',
    marginBottom: 30,
  },
  cameraIconBadge: {
    position: 'absolute',
    right: 0,
    bottom: 0,
    width: 34,
    height: 34,
    borderRadius: 17,
    backgroundColor: AppColors.primary,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 2,
    borderColor: AppColors.background,
  },
  userName: {
    color: AppColors.white,
    fontSize: 24,
    fontWeight: 'bold',
    marginTop: 15,
  },
  userEmail: {
    color: 'rgba(255,255,255,0.6)',
    fontSize: 15,
    marginTop: 4,
  },
  editBtn: {
    marginTop: 15,
    paddingHorizontal: 20,
    paddingVertical: 8,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: AppColors.primary,
  },
  editBtnText: {
    color: AppColors.primary,
    fontWeight: 'bold',
  },
  optionsList: {
    marginBottom: 25,
  },
  optionItem: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: AppColors.surface,
    borderRadius: 15,
    padding: 14,
    marginBottom: 12,
  },
  optionIconCircle: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: 'rgba(79, 70, 229, 0.15)',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 14,
  },
  optionTextCol: {
    flex: 1,
  },
  optionTitle: {
    color: AppColors.white,
    fontSize: 16,
    fontWeight: 'bold',
  },
  optionSub: {
    color: 'rgba(255,255,255,0.54)',
    fontSize: 13,
    marginTop: 2,
  },
  arrowIcon: {
    color: 'rgba(255,255,255,0.54)',
    fontSize: 16,
  },
  logoutBtn: {
    width: '100%',
    height: 52,
    backgroundColor: AppColors.error,
    borderRadius: 15,
    justifyContent: 'center',
    alignItems: 'center',
  },
  logoutBtnText: {
    color: AppColors.white,
    fontSize: 16,
    fontWeight: 'bold',
  },
});
