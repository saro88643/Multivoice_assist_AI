import React, { createContext, useState, useContext, ReactNode, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { AppConstants } from '../utils/constants';

interface ProfileContextType {
  userName: string;
  userEmail: string;
  profileImagePath: string | null;
  loadProfile: () => Promise<void>;
  updateProfile: (name: string, email: string) => Promise<void>;
  setProfileImagePath: (path: string | null) => Promise<void>;
  removeProfileImage: () => Promise<void>;
}

const ProfileContext = createContext<ProfileContextType | undefined>(undefined);

export const ProfileProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [userName, setUserName] = useState<string>(AppConstants.defaultName);
  const [userEmail, setUserEmail] = useState<string>(AppConstants.defaultEmail);
  const [profileImagePath, setProfileImagePathState] = useState<string | null>(null);

  const loadProfile = async (): Promise<void> => {
    try {
      const storedName = await AsyncStorage.getItem('user_name');
      const storedEmail = await AsyncStorage.getItem('user_email');
      const storedImg = await AsyncStorage.getItem('profile_image_path');

      if (storedName) setUserName(storedName);
      if (storedEmail) setUserEmail(storedEmail);
      if (storedImg) setProfileImagePathState(storedImg);
    } catch (e) {
      console.error('Load profile error:', e);
    }
  };

  const updateProfile = async (name: string, email: string): Promise<void> => {
    const cleanName = name.trim();
    const cleanEmail = email.trim();
    if (!cleanName || !cleanEmail) return;

    await AsyncStorage.setItem('user_name', cleanName);
    await AsyncStorage.setItem('user_email', cleanEmail);
    setUserName(cleanName);
    setUserEmail(cleanEmail);
  };

  const setProfileImagePath = async (path: string | null): Promise<void> => {
    if (path) {
      await AsyncStorage.setItem('profile_image_path', path);
      setProfileImagePathState(path);
    } else {
      await AsyncStorage.removeItem('profile_image_path');
      setProfileImagePathState(null);
    }
  };

  const removeProfileImage = async (): Promise<void> => {
    await setProfileImagePath(null);
  };

  useEffect(() => {
    loadProfile();
  }, []);

  return (
    <ProfileContext.Provider
      value={{
        userName,
        userEmail,
        profileImagePath,
        loadProfile,
        updateProfile,
        setProfileImagePath,
        removeProfileImage,
      }}
    >
      {children}
    </ProfileContext.Provider>
  );
};

export const useProfile = (): ProfileContextType => {
  const context = useContext(ProfileContext);
  if (!context) {
    throw new Error('useProfile must be used within a ProfileProvider');
  }
  return context;
};
