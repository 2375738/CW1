import { Plus, Calendar as CalendarIcon, ListChecks, MapPin, Bell, CheckCircle, MessageCircle, Phone } from "lucide-react";
import { useState } from "react";
import { useNavigate } from "react-router";
import { useAuth } from "@/app/contexts/AuthContext";
import { useEvents } from "@/app/contexts/EventContext";
import { useNotifications } from "@/app/contexts/NotificationContext";
import { useRelationships } from "@/app/contexts/RelationshipContext";
import { useShopping } from "@/app/contexts/ShoppingContext";
import { Badge } from "@/app/components/ui/badge";
import { Card } from "@/app/components/ui/card";
import { Button } from "@/app/components/ui/button";
import { NotificationPanel } from "@/app/components/NotificationPanel";
import { toast } from "sonner";

// Mock data
const familyMembers = [
  {
    id: 1,
    name: "Sarah Johnson",
    role: "You",
    avatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=400&fit=crop",
    status: "At home",
    locationSharing: true,
    phone: "+1234567890",
    whatsapp: "+1234567890",
    telegram: "@sarahjohnson",
    instagram: "sarahjohnson",
  },
  {
    id: 2,
    name: "Mike Johnson",
    role: "Parent",
    avatar: "https://images.unsplash.com/photo-1622319107576-cca7c8a906f7?w=400&h=400&fit=crop",
    status: "At work",
    locationSharing: true,
    phone: "+1234567891",
    whatsapp: "+1234567891",
    telegram: "@mikejohnson",
    instagram: "mikejohnson",
  },
  {
    id: 3,
    name: "Emma Johnson",
    role: "Teen",
    avatar: "https://images.unsplash.com/photo-1652217627250-0dd21428e0f3?w=400&h=400&fit=crop",
    status: "At school",
    locationSharing: false,
    phone: "+1234567892",
    whatsapp: "+1234567892",
    telegram: "@emmajohnson",
    instagram: "emmajohnson",
  },
  {
    id: 4,
    name: "Mary Smith",
    role: "Grandma",
    avatar: "https://images.unsplash.com/photo-1547199315-ddabe87428ed?w=400&h=400&fit=crop",
    status: "At home",
    locationSharing: true,
    phone: "+1234567893",
    whatsapp: "+1234567893",
    telegram: "@marysmith",
    instagram: "marysmith",
  },
];

const upcomingEvents = [
  { id: 1, title: "Dentist Appointment", time: "Today, 16:00", assignedTo: ["Emma", "You"] },
  { id: 2, title: "Soccer Practice", time: "Tomorrow, 15:30", assignedTo: ["Emma"] },
];

const pendingTasks = [
  { id: 1, title: "Take out bins", assignedTo: "Emma", dueDate: "Today" },
  { id: 2, title: "Pick up groceries", assignedTo: "You", dueDate: "Today" },
];

const pendingShoppingTasks = [
  { 
    id: 1, 
    title: "Weekly Groceries", 
    assignedTo: "You", 
    assignedBy: "Mike Johnson", 
    dueDate: "Tomorrow", 
    itemCount: 4,
    purchasedCount: 0,
    accepted: false,
  },
];

export default function Home() {
  const navigate = useNavigate();
  const { user } = useAuth();
  const { events, acceptInvitation, declineInvitation } = useEvents();
  const { notifications } = useNotifications();
  const { getFamilyMembers, getRelationshipWith } = useRelationships();
  const { tasks: shoppingTasks, acceptTask } = useShopping();

  // Get current user ID
  const getUserIdByEmail = (email: string): number => {
    const userMap: Record<string, number> = {
      "sarah@example.com": 1,
      "mike@example.com": 2,
      "emma@example.com": 3,
      "mary@example.com": 4,
    };
    return userMap[email] || 1;
  };

  const currentUserId = user ? getUserIdByEmail(user.email) : 0;

  // Filter pending task notifications
  const pendingTaskNotifications = notifications.filter(
    (n) => !n.read && (n.type === "task_assigned" || n.type === "task_completed")
  );

  // Get current user's family member data
  const currentUserData = familyMembers.find(m => m.id === currentUserId);

  // Get user's assigned shopping tasks from the shopping context
  const myShoppingTasks = shoppingTasks
    .filter((task) => task.assignedTo === user?.name)
    .map((task) => ({
      id: task.id,
      title: task.title,
      assignedTo: task.assignedTo,
      assignedBy: task.assignedBy,
      dueDate: task.dueDate === "2026-01-29" ? "Tomorrow" : "Today",
      itemCount: task.items.length,
      purchasedCount: task.items.filter((item) => item.purchased).length,
      accepted: task.accepted,
    }));

  // Get relationship for a member by their ID
  const getRelationshipForMember = (memberId: number) => {
    if (!currentUserId) return null;
    const relationship = getRelationshipWith(currentUserId, memberId);
    return relationship?.relationType;
  };

  // State to track accepted shopping items
  const [acceptedShoppingItems, setAcceptedShoppingItems] = useState<number[]>([]);

  // Function to handle accepting a shopping item
  const handleAcceptShoppingItem = (itemId: number) => {
    acceptTask(itemId);
    const task = myShoppingTasks.find((t) => t.id === itemId);
    toast.success(`✓ Accepted: "${task?.title}" shopping task!`);
    // Navigate to shopping tab
    navigate("/tasks?tab=shopping");
  };

  // Contact functions
  const handlePhoneCall = (member: typeof familyMembers[0]) => {
    window.location.href = `tel:${member.phone}`;
    toast.success(`Calling ${member.name}...`);
  };

  const handleWhatsApp = (member: typeof familyMembers[0]) => {
    // Use WhatsApp deep link to open native app
    window.location.href = `whatsapp://send?phone=${member.whatsapp.replace(/[^0-9]/g, '')}`;
    toast.success(`Opening WhatsApp with ${member.name}`);
  };

  const handleTelegram = (member: typeof familyMembers[0]) => {
    // Use Telegram deep link to open native app
    window.location.href = `tg://resolve?domain=${member.telegram.replace('@', '')}`;
    toast.success(`Opening Telegram with ${member.name}`);
  };

  const handleInstagram = (member: typeof familyMembers[0]) => {
    // Use Instagram deep link to open native app
    window.location.href = `instagram://user?username=${member.instagram}`;
    toast.success(`Opening Instagram with ${member.name}`);
  };

  return (
    <div className="h-full bg-gray-50">
      {/* Header */}
      <div className="bg-white border-b border-gray-200 px-6 py-4">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-semibold text-gray-900">FamilyHub</h1>
            <p className="text-sm text-gray-500">Welcome back, {user?.name.split(" ")[0]}</p>
          </div>
          <div className="flex items-center gap-3">
            <NotificationPanel
              onAcceptInvitation={acceptInvitation}
              onDeclineInvitation={declineInvitation}
            />
            <button
              onClick={() => navigate("/profile")}
              className="w-10 h-10 rounded-full overflow-hidden border-2 border-gray-200 hover:border-blue-400 transition-colors flex-shrink-0"
              title="View Profile"
            >
              <img
                src={currentUserData?.avatar}
                alt={user?.name}
                className="w-full h-full object-cover"
              />
            </button>
          </div>
        </div>
      </div>

      <div className="px-6 py-6 space-y-6">
        {/* Quick Actions */}
        <section>
          <h2 className="text-lg font-semibold text-gray-900 mb-3">Quick Actions</h2>
          <div className="grid grid-cols-2 gap-3">
            <button
              onClick={() => navigate("/calendar")}
              className="flex flex-col items-center justify-center gap-2 p-4 bg-white rounded-xl border border-gray-200 hover:border-blue-300 hover:bg-blue-50 transition-all"
            >
              <CalendarIcon className="w-6 h-6 text-blue-600" />
              <span className="text-sm font-medium text-gray-900">Add Event</span>
            </button>
            <button
              onClick={() => navigate("/tasks")}
              className="flex flex-col items-center justify-center gap-2 p-4 bg-white rounded-xl border border-gray-200 hover:border-green-300 hover:bg-green-50 transition-all"
            >
              <ListChecks className="w-6 h-6 text-green-600" />
              <span className="text-sm font-medium text-gray-900">Add Task</span>
            </button>
            <button
              onClick={() => navigate("/map")}
              className="flex flex-col items-center justify-center gap-2 p-4 bg-white rounded-xl border border-gray-200 hover:border-purple-300 hover:bg-purple-50 transition-all"
            >
              <MapPin className="w-6 h-6 text-purple-600" />
              <span className="text-sm font-medium text-gray-900">Check Location</span>
            </button>
            <button
              onClick={() => navigate("/sos")}
              className="flex flex-col items-center justify-center gap-2 p-4 bg-white rounded-xl border border-gray-200 hover:border-red-300 hover:bg-red-50 transition-all"
            >
              <Plus className="w-6 h-6 text-red-600" />
              <span className="text-sm font-medium text-gray-900">Emergency</span>
            </button>
          </div>
        </section>

        {/* Family Members */}
        <section>
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-lg font-semibold text-gray-900">Family</h2>
            <button className="text-sm text-blue-600 hover:text-blue-700 font-medium">
              View All
            </button>
          </div>
          <div className="space-y-3">
            {familyMembers
              .filter(member => member.id !== currentUserId) // Hide current user from family list
              .map((member) => {
              const relationship = getRelationshipForMember(member.id);
              
              return (
                <Card key={member.id} className="p-4 hover:border-gray-300 transition-colors">
                  <div className="flex items-start gap-4">
                    <img
                      src={member.avatar}
                      alt={member.name}
                      className="w-12 h-12 rounded-full object-cover flex-shrink-0"
                    />
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 flex-wrap mb-1">
                        <h3 className="font-semibold text-gray-900 truncate">{member.name}</h3>
                        {relationship && (
                          <Badge 
                            variant="secondary" 
                            className="text-xs bg-purple-100 text-purple-700 hover:bg-purple-100"
                          >
                            {relationship.charAt(0).toUpperCase() + relationship.slice(1)}
                          </Badge>
                        )}
                      </div>
                      <div className="flex items-center gap-2 mb-2">
                        <p className="text-sm text-gray-500">{member.status}</p>
                        {member.locationSharing && (
                          <>
                            <span className="text-gray-300">•</span>
                            <div className="flex items-center gap-1">
                              <MapPin className="w-3 h-3 text-blue-600" />
                              <span className="text-xs text-blue-600">Sharing</span>
                            </div>
                          </>
                        )}
                      </div>
                      
                      {/* Quick Contact Buttons */}
                      <div className="flex items-center gap-2 mt-3">
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            handlePhoneCall(member);
                          }}
                          className="flex items-center justify-center w-9 h-9 rounded-full bg-green-100 hover:bg-green-200 transition-colors"
                          title={`Call ${member.name}`}
                        >
                          <Phone className="w-4 h-4 text-green-700" />
                        </button>
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            handleWhatsApp(member);
                          }}
                          className="flex items-center justify-center w-9 h-9 rounded-full bg-green-100 hover:bg-green-200 transition-colors"
                          title={`WhatsApp ${member.name}`}
                        >
                          <MessageCircle className="w-4 h-4 text-green-700" />
                        </button>
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            handleTelegram(member);
                          }}
                          className="flex items-center justify-center w-9 h-9 rounded-full bg-blue-100 hover:bg-blue-200 transition-colors"
                          title={`Telegram ${member.name}`}
                        >
                          <svg className="w-4 h-4 text-blue-700" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm4.64 6.8c-.15 1.58-.8 5.42-1.13 7.19-.14.75-.42 1-.68 1.03-.58.05-1.02-.38-1.58-.75-.88-.58-1.38-.94-2.23-1.5-.99-.65-.35-1.01.22-1.59.15-.15 2.71-2.48 2.76-2.69a.2.2 0 00-.05-.18c-.06-.05-.14-.03-.21-.02-.09.02-1.49.95-4.22 2.79-.4.27-.76.41-1.08.4-.36-.01-1.04-.2-1.55-.37-.63-.2-1.12-.31-1.08-.66.02-.18.27-.36.74-.55 2.92-1.27 4.86-2.11 5.83-2.51 2.78-1.16 3.35-1.36 3.73-1.36.08 0 .27.02.39.12.1.08.13.19.14.27-.01.06.01.24 0 .38z"/>
                          </svg>
                        </button>
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            handleInstagram(member);
                          }}
                          className="flex items-center justify-center w-9 h-9 rounded-full bg-pink-100 hover:bg-pink-200 transition-colors"
                          title={`Instagram ${member.name}`}
                        >
                          <svg className="w-4 h-4 text-pink-700" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z"/>
                          </svg>
                        </button>
                      </div>
                    </div>
                  </div>
                </Card>
              );
            })}
          </div>
        </section>

        {/* Upcoming Events */}
        <section>
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-lg font-semibold text-gray-900">Upcoming</h2>
            <button
              onClick={() => navigate("/calendar")}
              className="text-sm text-blue-600 hover:text-blue-700 font-medium"
            >
              View Calendar
            </button>
          </div>
          <div className="space-y-2">
            {upcomingEvents.map((event) => (
              <Card key={event.id} className="p-4 hover:border-gray-300 transition-colors cursor-pointer">
                <div className="flex items-start justify-between">
                  <div>
                    <h3 className="font-medium text-gray-900">{event.title}</h3>
                    <p className="text-sm text-gray-500 mt-1">{event.time}</p>
                  </div>
                  <div className="flex -space-x-2">
                    {event.assignedTo.map((person, idx) => (
                      <div
                        key={idx}
                        className="w-6 h-6 rounded-full bg-gradient-to-br from-blue-400 to-blue-600 border-2 border-white flex items-center justify-center"
                      >
                        <span className="text-xs text-white font-medium">
                          {person[0]}
                        </span>
                      </div>
                    ))}
                  </div>
                </div>
              </Card>
            ))}
          </div>
        </section>

        {/* Pending Tasks */}
        <section>
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-lg font-semibold text-gray-900">Pending Tasks</h2>
            {pendingTaskNotifications.length > 0 && (
              <Badge variant="default" className="bg-red-600">
                {pendingTaskNotifications.length} new
              </Badge>
            )}
          </div>
          {pendingTaskNotifications.length > 0 ? (
            <div className="space-y-2 mb-4">
              {pendingTaskNotifications.map((notification) => (
                <Card key={notification.id} className="p-4 bg-blue-50 border-blue-200">
                  <div className="flex items-start gap-3">
                    <div className="w-8 h-8 bg-blue-600 rounded-full flex items-center justify-center flex-shrink-0">
                      {notification.type === "task_completed" ? (
                        <CheckCircle className="w-4 h-4 text-white" />
                      ) : (
                        <ListChecks className="w-4 h-4 text-white" />
                      )}
                    </div>
                    <div className="flex-1">
                      <h3 className="font-semibold text-gray-900 text-sm">
                        {notification.title}
                      </h3>
                      <p className="text-sm text-gray-600 mt-1">
                        {notification.message}
                      </p>
                    </div>
                  </div>
                </Card>
              ))}
            </div>
          ) : null}
          <div className="space-y-2">
            {pendingTasks.map((task) => (
              <Card key={task.id} className="p-4">
                <div className="flex items-center justify-between">
                  <div>
                    <h3 className="font-medium text-gray-900">{task.title}</h3>
                    <div className="flex items-center gap-2 mt-1">
                      <Badge variant="secondary" className="text-xs">
                        {task.assignedTo}
                      </Badge>
                      <span className="text-xs text-gray-500">{task.dueDate}</span>
                    </div>
                  </div>
                  <button className="w-6 h-6 rounded border-2 border-gray-300 hover:border-blue-600 hover:bg-blue-50 transition-colors" />
                </div>
              </Card>
            ))}
          </div>
        </section>

        {/* Shopping List */}
        {myShoppingTasks.length > 0 && (
          <section>
            <div className="flex items-center justify-between mb-3">
              <h2 className="text-lg font-semibold text-gray-900">Shopping Tasks</h2>
              <button 
                onClick={() => navigate("/tasks")}
                className="text-sm text-blue-600 hover:text-blue-700 font-medium"
              >
                View All
              </button>
            </div>
            <div className="space-y-2">
              {myShoppingTasks.map((task) => {
                const needsAcceptance = task.assignedBy !== user?.name && !task.accepted;
                
                return (
                  <Card 
                    key={task.id} 
                    className={`p-4 cursor-pointer hover:border-gray-300 transition-colors ${
                      needsAcceptance 
                        ? "bg-gradient-to-r from-amber-50 to-yellow-50 border-amber-200" 
                        : "bg-gradient-to-r from-green-50 to-emerald-50 border-green-200"
                    }`}
                    onClick={() => navigate("/tasks?tab=shopping")}
                  >
                    <div className="flex items-start gap-3">
                      <div className={`w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 ${
                        needsAcceptance ? "bg-amber-600" : "bg-green-600"
                      }`}>
                        <ListChecks className="w-4 h-4 text-white" />
                      </div>
                      <div className="flex-1">
                        <div className="flex items-start justify-between gap-2">
                          <div className="flex-1">
                            <div className="flex items-center gap-2 mb-1">
                              <h3 className="font-medium text-gray-900">{task.title}</h3>
                              {needsAcceptance && (
                                <Badge className="bg-amber-600 text-xs">New</Badge>
                              )}
                            </div>
                            <div className="flex items-center gap-2 flex-wrap text-sm text-gray-600">
                              {task.assignedBy !== user?.name && (
                                <>
                                  <span className="text-xs">By {task.assignedBy}</span>
                                  <span>•</span>
                                </>
                              )}
                              <span className="text-xs">{task.dueDate}</span>
                              <span>•</span>
                              <span className="text-xs">{task.itemCount} items</span>
                            </div>
                          </div>
                          {needsAcceptance && (
                            <Button 
                              size="sm" 
                              className="bg-amber-600 hover:bg-amber-700 h-8 text-xs"
                              onClick={(e) => {
                                e.stopPropagation();
                                handleAcceptShoppingItem(task.id);
                              }}
                            >
                              Accept
                            </Button>
                          )}
                        </div>
                      </div>
                    </div>
                  </Card>
                );
              })}
            </div>
          </section>
        )}
      </div>
    </div>
  );
}