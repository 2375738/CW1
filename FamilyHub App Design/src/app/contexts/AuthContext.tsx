import { createContext, useContext, useState, ReactNode } from "react";

interface User {
  id: number;
  name: string;
  email: string;
  role: string;
  avatar: string;
  phone: string;
  familyId: string;
}

interface AuthContextType {
  user: User | null;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  updateProfile: (updates: Partial<User>) => void;
  isAuthenticated: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

// Mock user data
const mockUsers: Record<string, User> = {
  "sarah@example.com": {
    id: 1,
    name: "Sarah Johnson",
    email: "sarah@example.com",
    role: "Parent",
    avatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=400&fit=crop",
    phone: "+1 (555) 123-4567",
    familyId: "johnson-family",
  },
  "mike@example.com": {
    id: 2,
    name: "Mike Johnson",
    email: "mike@example.com",
    role: "Parent",
    avatar: "https://images.unsplash.com/photo-1622319107576-cca7c8a906f7?w=400&h=400&fit=crop",
    phone: "+1 (555) 234-5678",
    familyId: "johnson-family",
  },
};

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);

  const login = async (email: string, password: string) => {
    // Simulate API call
    await new Promise((resolve) => setTimeout(resolve, 800));
    
    const mockUser = mockUsers[email];
    if (mockUser) {
      setUser(mockUser);
    } else {
      throw new Error("Invalid credentials");
    }
  };

  const logout = () => {
    setUser(null);
  };

  const updateProfile = (updates: Partial<User>) => {
    if (user) {
      setUser({ ...user, ...updates });
    }
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        login,
        logout,
        updateProfile,
        isAuthenticated: !!user,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
}