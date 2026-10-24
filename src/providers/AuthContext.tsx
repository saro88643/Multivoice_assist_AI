import React, { createContext, useState, useContext, ReactNode } from 'react';
import { authService } from '../services/authService';

interface AuthContextType {
  isLoggedIn: boolean;
  loggedInEmail: string | null;
  login: (email: string, password: string) => Promise<boolean>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [isLoggedIn, setIsLoggedIn] = useState<boolean>(false);
  const [loggedInEmail, setLoggedInEmail] = useState<string | null>(null);

  const login = async (email: string, password: string): Promise<boolean> => {
    const success = await authService.login(email, password);
    if (success) {
      setIsLoggedIn(true);
      setLoggedInEmail(email.trim().toLowerCase());
    }
    return success;
  };

  const logout = () => {
    setIsLoggedIn(false);
    setLoggedInEmail(null);
  };

  return (
    <AuthContext.Provider value={{ isLoggedIn, loggedInEmail, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = (): AuthContextType => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
