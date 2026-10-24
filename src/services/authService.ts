import AsyncStorage from '@react-native-async-storage/async-storage';
import { AppConstants } from '../utils/constants';

const USER_EMAIL_KEY = 'user_email';
const USER_PASSWORD_KEY = 'user_password';
const USER_NAME_KEY = 'user_name';
const USER_PHONE_KEY = 'user_phone';
const IS_REGISTERED_KEY = 'is_registered';

export class AuthService {
  public async login(email: string, password: string): Promise<boolean> {
    const enteredEmail = email.trim().toLowerCase();

    const storedEmail = await AsyncStorage.getItem(USER_EMAIL_KEY);
    const storedPassword = await AsyncStorage.getItem(USER_PASSWORD_KEY);

    let isCorrect = false;

    if (storedEmail && storedPassword) {
      if (enteredEmail === storedEmail.toLowerCase() && password === storedPassword) {
        isCorrect = true;
      }
    }

    if (!isCorrect) {
      if (
        enteredEmail === AppConstants.defaultEmail.toLowerCase() &&
        password === AppConstants.defaultPassword
      ) {
        isCorrect = true;
      }
    }

    if (isCorrect) {
      await AsyncStorage.setItem(USER_EMAIL_KEY, enteredEmail);
      const storedName = await AsyncStorage.getItem(USER_NAME_KEY);
      if (!storedName || (storedEmail && enteredEmail !== storedEmail.toLowerCase())) {
        const namePrefix = enteredEmail.split('@')[0];
        const formattedName = namePrefix.charAt(0).toUpperCase() + namePrefix.slice(1);
        await AsyncStorage.setItem(USER_NAME_KEY, formattedName);
      }
    }

    return isCorrect;
  }

  public async register(params: {
    name: string;
    email: string;
    phone: string;
    password: string;
  }): Promise<boolean> {
    await AsyncStorage.setItem(USER_NAME_KEY, params.name.trim());
    await AsyncStorage.setItem(USER_EMAIL_KEY, params.email.trim().toLowerCase());
    await AsyncStorage.setItem(USER_PHONE_KEY, params.phone.trim());
    await AsyncStorage.setItem(USER_PASSWORD_KEY, params.password);
    await AsyncStorage.setItem(IS_REGISTERED_KEY, 'true');
    return true;
  }
}

export const authService = new AuthService();
