import { createContext, useContext, useState, ReactNode } from "react";
import { useAuth } from "./AuthContext";

export type NotificationType = "event_invitation" | "event_change" | "event_cancelled" | "event_update" | "task_assigned" | "task_completed" | "emergency";

export interface Notification {
  id: number;
  type: NotificationType;
  title: string;
  message: string;
  timestamp: string;
  read: boolean;
  recipientId?: number; // ID of the user who should receive this notification
  eventId?: number;
  taskId?: number;
  taskTitle?: string;
  assignedTo?: string;
  assignedBy?: string;
  actionRequired?: boolean;
  relatedId?: number;
  eventDetails?: {
    title: string;
    date: string;
    time: string;
    duration: number;
    location: string;
    createdBy: string;
  };
  previousEventDetails?: {
    date: string;
    time: string;
    location: string;
  };
}

interface NotificationContextType {
  allNotifications: Notification[]; // All notifications (for system storage)
  notifications: Notification[]; // Filtered notifications for current user
  addNotification: (notification: Omit<Notification, "id" | "timestamp" | "read">) => void;
  markAsRead: (id: number) => void;
  removeNotification: (id: number) => void;
  unreadCount: number;
}

const NotificationContext = createContext<NotificationContextType | undefined>(undefined);

export function NotificationProvider({ children }: { children: ReactNode }) {
  const { user } = useAuth();
  const [allNotifications, setAllNotifications] = useState<Notification[]>([
    {
      id: 1,
      type: "event_invitation",
      title: "Event Invitation: Dentist Appointment",
      message: "Sarah invited you to Dentist Appointment on Jan 27 at 16:00",
      timestamp: new Date().toISOString(),
      read: false,
      recipientId: 3, // Emma
      eventId: 1,
      eventDetails: {
        title: "Dentist Appointment",
        date: "2026-01-27",
        time: "16:00",
        duration: 60,
        location: "Downtown Dental Clinic",
        createdBy: "Sarah Johnson",
      },
    },
    {
      id: 2,
      type: "task_assigned",
      title: "Shopping Task Assigned",
      message: "Mike Johnson assigned you \"Weekly Groceries\" with 4 items for Tomorrow",
      timestamp: new Date().toISOString(),
      read: false,
      recipientId: 1, // Sarah
      actionRequired: true,
      relatedId: 1,
    },
  ]);

  // Get current user ID
  const getCurrentUserId = (): number => {
    if (!user) return 0;
    const userMap: Record<string, number> = {
      "sarah@example.com": 1,
      "mike@example.com": 2,
      "emma@example.com": 3,
      "mary@example.com": 4,
    };
    return userMap[user.email] || 0;
  };

  const currentUserId = getCurrentUserId();

  // Filter notifications for the current user
  const notifications = allNotifications.filter(
    (notif) => !notif.recipientId || notif.recipientId === currentUserId
  );

  const addNotification = (notification: Omit<Notification, "id" | "timestamp" | "read">) => {
    const newNotification: Notification = {
      ...notification,
      id: Date.now(),
      timestamp: new Date().toISOString(),
      read: false,
    };
    setAllNotifications((prev) => [newNotification, ...prev]);
  };

  const markAsRead = (id: number) => {
    setAllNotifications((prev) =>
      prev.map((notif) => (notif.id === id ? { ...notif, read: true } : notif))
    );
  };

  const removeNotification = (id: number) => {
    setAllNotifications((prev) => prev.filter((notif) => notif.id !== id));
  };

  const unreadCount = notifications.filter((n) => !n.read).length;

  return (
    <NotificationContext.Provider
      value={{
        allNotifications,
        notifications,
        addNotification,
        markAsRead,
        removeNotification,
        unreadCount,
      }}
    >
      {children}
    </NotificationContext.Provider>
  );
}

export function useNotifications() {
  const context = useContext(NotificationContext);
  if (context === undefined) {
    throw new Error("useNotifications must be used within a NotificationProvider");
  }
  return context;
}