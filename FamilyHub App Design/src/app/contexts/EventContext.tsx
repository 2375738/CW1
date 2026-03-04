import { createContext, useContext, useState, ReactNode } from "react";
import { useAuth } from "./AuthContext";
import { useNotifications } from "./NotificationContext";

export interface EventInvitee {
  memberId: number;
  name: string;
  status: "pending" | "accepted" | "declined";
}

export interface Event {
  id: number;
  title: string;
  date: string;
  time: string;
  duration: number;
  location: string;
  invitedMembers: EventInvitee[];
  createdBy: number;
  calendarSource?: string;
}

// Initial mock events
const initialEvents: Event[] = [
  {
    id: 1,
    title: "Dentist Appointment",
    date: "2026-01-27",
    time: "16:00",
    duration: 60,
    invitedMembers: [
      { memberId: 1, name: "Sarah Johnson", status: "accepted" },
      { memberId: 3, name: "Emma Johnson", status: "pending" },
    ],
    location: "Downtown Dental Clinic",
    createdBy: 1,
  },
  {
    id: 2,
    title: "Soccer Practice",
    date: "2026-01-28",
    time: "15:30",
    duration: 90,
    invitedMembers: [
      { memberId: 3, name: "Emma Johnson", status: "accepted" },
    ],
    location: "City Sports Complex",
    createdBy: 3,
    calendarSource: "Class Charts",
  },
  {
    id: 3,
    title: "Work Meeting",
    date: "2026-01-27",
    time: "14:00",
    duration: 60,
    invitedMembers: [
      { memberId: 2, name: "Mike Johnson", status: "accepted" },
    ],
    location: "Office",
    createdBy: 2,
    calendarSource: "Microsoft Outlook",
  },
  {
    id: 4,
    title: "Family Dinner",
    date: "2026-01-29",
    time: "18:00",
    duration: 120,
    invitedMembers: [
      { memberId: 1, name: "Sarah Johnson", status: "accepted" },
      { memberId: 2, name: "Mike Johnson", status: "accepted" },
      { memberId: 3, name: "Emma Johnson", status: "pending" },
    ],
    location: "Home",
    createdBy: 1,
  },
  {
    id: 5,
    title: "Doctor Visit - Grandma",
    date: "2026-01-30",
    time: "10:30",
    duration: 45,
    invitedMembers: [
      { memberId: 4, name: "Mary Smith", status: "accepted" },
      { memberId: 1, name: "Sarah Johnson", status: "accepted" },
    ],
    location: "General Hospital",
    createdBy: 4,
  },
];

interface EventContextType {
  events: Event[];
  addEvent: (event: Omit<Event, "id">) => void;
  acceptInvitation: (eventId: number) => void;
  declineInvitation: (eventId: number) => void;
  inviteMembers: (eventId: number, memberIds: number[]) => void;
  updateEvent: (eventId: number, updates: Partial<Omit<Event, "id" | "createdBy" | "invitedMembers">>) => void;
  cancelEvent: (eventId: number) => void;
}

const EventContext = createContext<EventContextType | undefined>(undefined);

export function EventProvider({ children }: { children: ReactNode }) {
  const [events, setEvents] = useState<Event[]>(initialEvents);
  const { user } = useAuth();
  const { addNotification } = useNotifications();

  const addEvent = (eventData: Omit<Event, "id">) => {
    const newEvent: Event = {
      ...eventData,
      id: Date.now(),
    };

    setEvents((prev) => [...prev, newEvent]);

    // Get creator name
    const creatorName = getNameByUserId(eventData.createdBy);

    // Create notifications for all invited members (except the creator)
    eventData.invitedMembers.forEach((invitee) => {
      // Create notification for each invited member who is not the creator
      if (invitee.memberId !== eventData.createdBy) {
        addNotification({
          type: "event_invitation",
          title: `Event Invitation: ${eventData.title}`,
          message: `${creatorName} invited you to ${eventData.title}`,
          eventId: newEvent.id,
          eventDetails: {
            title: eventData.title,
            date: eventData.date,
            time: eventData.time,
            duration: eventData.duration,
            location: eventData.location,
            createdBy: creatorName,
          },
          recipientId: invitee.memberId,
        });
      }
    });
  };

  const acceptInvitation = (eventId: number) => {
    if (!user) return;
    
    const userId = getUserIdByEmail(user.email);
    
    setEvents((prev) =>
      prev.map((event) => {
        if (event.id === eventId) {
          return {
            ...event,
            invitedMembers: event.invitedMembers.map((invitee) =>
              invitee.memberId === userId
                ? { ...invitee, status: "accepted" as const }
                : invitee
            ),
          };
        }
        return event;
      })
    );
  };

  const declineInvitation = (eventId: number) => {
    if (!user) return;
    
    const userId = getUserIdByEmail(user.email);
    
    setEvents((prev) =>
      prev.map((event) => {
        if (event.id === eventId) {
          return {
            ...event,
            invitedMembers: event.invitedMembers.map((invitee) =>
              invitee.memberId === userId
                ? { ...invitee, status: "declined" as const }
                : invitee
            ),
          };
        }
        return event;
      })
    );
  };

  const inviteMembers = (eventId: number, memberIds: number[]) => {
    if (!user) return;

    const event = events.find((e) => e.id === eventId);
    if (!event) return;

    const creatorName = getNameByUserId(event.createdBy);

    // Add new members to the event
    setEvents((prev) =>
      prev.map((e) => {
        if (e.id === eventId) {
          const existingMemberIds = e.invitedMembers.map((m) => m.memberId);
          const newMembers = memberIds
            .filter((id) => !existingMemberIds.includes(id))
            .map((id) => ({
              memberId: id,
              name: getNameByUserId(id),
              status: "pending" as const,
            }));

          return {
            ...e,
            invitedMembers: [...e.invitedMembers, ...newMembers],
          };
        }
        return e;
      })
    );

    // Send notifications to newly invited members
    memberIds.forEach((memberId) => {
      addNotification({
        type: "event_invitation",
        title: `Event Invitation: ${event.title}`,
        message: `${creatorName} invited you to ${event.title}`,
        eventId: event.id,
        eventDetails: {
          title: event.title,
          date: event.date,
          time: event.time,
          duration: event.duration,
          location: event.location,
          createdBy: creatorName,
        },
        recipientId: memberId,
      });
    });
  };

  const updateEvent = (
    eventId: number,
    updates: Partial<Omit<Event, "id" | "createdBy" | "invitedMembers">>
  ) => {
    if (!user) return;

    const event = events.find((e) => e.id === eventId);
    if (!event) return;

    const currentUserId = getUserIdByEmail(user.email);
    
    // Only the creator can update the event
    if (event.createdBy !== currentUserId) return;

    const creatorName = getNameByUserId(event.createdBy);
    
    // Store previous details for notification
    const previousDetails = {
      date: event.date,
      time: event.time,
      location: event.location,
    };

    // Update the event and reset all invitees to pending status
    setEvents((prev) =>
      prev.map((e) => {
        if (e.id === eventId) {
          return {
            ...e,
            ...updates,
            invitedMembers: e.invitedMembers.map((invitee) => ({
              ...invitee,
              status: invitee.memberId === currentUserId ? "accepted" as const : "pending" as const,
            })),
          };
        }
        return e;
      })
    );

    // Send notifications to all invited members (except creator)
    event.invitedMembers.forEach((invitee) => {
      if (invitee.memberId !== event.createdBy) {
        const updatedEvent = { ...event, ...updates };
        addNotification({
          type: "event_update",
          title: `Event Updated: ${updatedEvent.title}`,
          message: `${creatorName} updated ${updatedEvent.title}. Please review and accept the changes.`,
          eventId: event.id,
          eventDetails: {
            title: updatedEvent.title,
            date: updatedEvent.date,
            time: updatedEvent.time,
            duration: updatedEvent.duration,
            location: updatedEvent.location,
            createdBy: creatorName,
          },
          previousEventDetails: previousDetails,
          recipientId: invitee.memberId,
        });
      }
    });
  };

  const cancelEvent = (eventId: number) => {
    if (!user) return;

    const event = events.find((e) => e.id === eventId);
    if (!event) return;

    const currentUserId = getUserIdByEmail(user.email);
    
    // Only the creator can cancel the event
    if (event.createdBy !== currentUserId) return;

    const creatorName = getNameByUserId(event.createdBy);

    // Send cancellation notifications to all invited members (except creator)
    event.invitedMembers.forEach((invitee) => {
      if (invitee.memberId !== event.createdBy) {
        addNotification({
          type: "event_cancelled",
          title: `Event Cancelled: ${event.title}`,
          message: `${creatorName} cancelled ${event.title} scheduled for ${event.date} at ${event.time}.`,
          eventId: event.id,
          recipientId: invitee.memberId,
        });
      }
    });

    // Remove the event
    setEvents((prev) => prev.filter((e) => e.id !== eventId));
  };

  return (
    <EventContext.Provider
      value={{
        events,
        addEvent,
        acceptInvitation,
        declineInvitation,
        inviteMembers,
        updateEvent,
        cancelEvent,
      }}
    >
      {children}
    </EventContext.Provider>
  );
}

export function useEvents() {
  const context = useContext(EventContext);
  if (context === undefined) {
    throw new Error("useEvents must be used within an EventProvider");
  }
  return context;
}

// Helper function to map email to user ID
function getUserIdByEmail(email: string): number {
  const userMap: Record<string, number> = {
    "sarah@example.com": 1,
    "mike@example.com": 2,
    "emma@example.com": 3,
    "mary@example.com": 4,
  };
  return userMap[email] || 1;
}

// Helper function to map user ID to name
function getNameByUserId(userId: number): string {
  const nameMap: Record<number, string> = {
    1: "Sarah Johnson",
    2: "Mike Johnson",
    3: "Emma Johnson",
    4: "Mary Smith",
  };
  return nameMap[userId] || "Someone";
}
