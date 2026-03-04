import { createContext, useContext, useState, ReactNode } from "react";
import { useAuth } from "./AuthContext";

export type RelationType =
  | "mother"
  | "father"
  | "daughter"
  | "son"
  | "sister"
  | "brother"
  | "wife"
  | "husband"
  | "grandmother"
  | "grandfather"
  | "granddaughter"
  | "grandson"
  | "aunt"
  | "uncle"
  | "niece"
  | "nephew"
  | "cousin"
  | "friend";

export interface Relationship {
  userId: number;
  relatedUserId: number;
  relationType: RelationType;
}

export interface FamilyMember {
  id: number;
  name: string;
  email: string;
  avatar: string;
}

// All family members
export const allFamilyMembers: FamilyMember[] = [
  {
    id: 1,
    name: "Sarah Johnson",
    email: "sarah@example.com",
    avatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=400&fit=crop",
  },
  {
    id: 2,
    name: "Mike Johnson",
    email: "mike@example.com",
    avatar: "https://images.unsplash.com/photo-1622319107576-cca7c8a906f7?w=400&h=400&fit=crop",
  },
  {
    id: 3,
    name: "Emma Johnson",
    email: "emma@example.com",
    avatar: "https://images.unsplash.com/photo-1652217627250-0dd21428e0f3?w=400&h=400&fit=crop",
  },
  {
    id: 4,
    name: "Mary Smith",
    email: "mary@example.com",
    avatar: "https://images.unsplash.com/photo-1547199315-ddabe87428ed?w=400&h=400&fit=crop",
  },
];

// Initial relationships (mock data)
const initialRelationships: Relationship[] = [
  // Sarah's relationships
  { userId: 1, relatedUserId: 2, relationType: "husband" },
  { userId: 1, relatedUserId: 3, relationType: "daughter" },
  { userId: 1, relatedUserId: 4, relationType: "friend" },
  
  // Mike's relationships
  { userId: 2, relatedUserId: 1, relationType: "wife" },
  { userId: 2, relatedUserId: 3, relationType: "daughter" },
  { userId: 2, relatedUserId: 4, relationType: "friend" },
  
  // Emma's relationships
  { userId: 3, relatedUserId: 1, relationType: "mother" },
  { userId: 3, relatedUserId: 2, relationType: "father" },
  { userId: 3, relatedUserId: 4, relationType: "grandmother" },
  
  // Mary's relationships
  { userId: 4, relatedUserId: 1, relationType: "friend" },
  { userId: 4, relatedUserId: 2, relationType: "friend" },
  { userId: 4, relatedUserId: 3, relationType: "granddaughter" },
];

interface RelationshipContextType {
  relationships: Relationship[];
  addRelationship: (relatedUserId: number, relationType: RelationType) => void;
  updateRelationship: (relatedUserId: number, relationType: RelationType) => void;
  removeRelationship: (relatedUserId: number) => void;
  getRelationshipsForUser: (userId: number) => Relationship[];
  getRelationshipWith: (userId: number, relatedUserId: number) => Relationship | undefined;
  isCloseFamily: (userId: number, relatedUserId: number) => boolean;
  getFamilyMembers: (userId: number) => Array<FamilyMember & { relation: RelationType }>;
  getCloseFamilyMembers: (userId: number) => Array<FamilyMember & { relation: RelationType }>;
}

const RelationshipContext = createContext<RelationshipContextType | undefined>(undefined);

// Close family types (for SOS alerts)
const CLOSE_FAMILY_TYPES: RelationType[] = [
  "mother",
  "father",
  "daughter",
  "son",
  "sister",
  "brother",
  "wife",
  "husband",
];

export function RelationshipProvider({ children }: { children: ReactNode }) {
  const [relationships, setRelationships] = useState<Relationship[]>(initialRelationships);
  const { user } = useAuth();

  const getUserIdByEmail = (email: string): number => {
    const userMap: Record<string, number> = {
      "sarah@example.com": 1,
      "mike@example.com": 2,
      "emma@example.com": 3,
      "mary@example.com": 4,
    };
    return userMap[email] || 1;
  };

  const getCurrentUserId = () => {
    if (!user) return 0;
    return getUserIdByEmail(user.email);
  };

  const addRelationship = (relatedUserId: number, relationType: RelationType) => {
    const currentUserId = getCurrentUserId();
    if (!currentUserId) return;

    // Remove existing relationship if any
    setRelationships((prev) =>
      prev.filter(
        (r) => !(r.userId === currentUserId && r.relatedUserId === relatedUserId)
      )
    );

    // Add new relationship
    setRelationships((prev) => [
      ...prev,
      { userId: currentUserId, relatedUserId, relationType },
    ]);
  };

  const updateRelationship = (relatedUserId: number, relationType: RelationType) => {
    const currentUserId = getCurrentUserId();
    if (!currentUserId) return;

    setRelationships((prev) =>
      prev.map((r) =>
        r.userId === currentUserId && r.relatedUserId === relatedUserId
          ? { ...r, relationType }
          : r
      )
    );
  };

  const removeRelationship = (relatedUserId: number) => {
    const currentUserId = getCurrentUserId();
    if (!currentUserId) return;

    setRelationships((prev) =>
      prev.filter(
        (r) => !(r.userId === currentUserId && r.relatedUserId === relatedUserId)
      )
    );
  };

  const getRelationshipsForUser = (userId: number) => {
    return relationships.filter((r) => r.userId === userId);
  };

  const getRelationshipWith = (userId: number, relatedUserId: number) => {
    return relationships.find(
      (r) => r.userId === userId && r.relatedUserId === relatedUserId
    );
  };

  const isCloseFamily = (userId: number, relatedUserId: number) => {
    const relationship = getRelationshipWith(userId, relatedUserId);
    if (!relationship) return false;
    return CLOSE_FAMILY_TYPES.includes(relationship.relationType);
  };

  const getFamilyMembers = (userId: number) => {
    const userRelationships = getRelationshipsForUser(userId);
    return userRelationships.map((rel) => {
      const member = allFamilyMembers.find((m) => m.id === rel.relatedUserId);
      return {
        ...member!,
        relation: rel.relationType,
      };
    });
  };

  const getCloseFamilyMembers = (userId: number) => {
    return getFamilyMembers(userId).filter((member) =>
      CLOSE_FAMILY_TYPES.includes(member.relation)
    );
  };

  return (
    <RelationshipContext.Provider
      value={{
        relationships,
        addRelationship,
        updateRelationship,
        removeRelationship,
        getRelationshipsForUser,
        getRelationshipWith,
        isCloseFamily,
        getFamilyMembers,
        getCloseFamilyMembers,
      }}
    >
      {children}
    </RelationshipContext.Provider>
  );
}

export function useRelationships() {
  const context = useContext(RelationshipContext);
  if (context === undefined) {
    throw new Error("useRelationships must be used within a RelationshipProvider");
  }
  return context;
}