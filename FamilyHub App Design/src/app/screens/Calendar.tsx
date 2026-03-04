import { useState } from "react";
import { Plus, Clock, User, ChevronLeft, ChevronRight, Calendar as CalendarIcon, Check, X, Sparkles, UserCheck, AlertCircle, UserPlus, Edit, Trash2, MapPin } from "lucide-react";
import { Card } from "@/app/components/ui/card";
import { Button } from "@/app/components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger, DialogFooter } from "@/app/components/ui/dialog";
import { Input } from "@/app/components/ui/input";
import { Label } from "@/app/components/ui/label";
import { Badge } from "@/app/components/ui/badge";
import { TimePicker } from "@/app/components/TimePicker";
import { Checkbox } from "@/app/components/ui/checkbox";
import { useEvents } from "@/app/contexts/EventContext";
import { useAuth } from "@/app/contexts/AuthContext";
import { openMapsApp, getMapsAppName } from "@/app/utils/maps";

// Mock data - family members with their calendars
const familyMembers = [
  { 
    id: 1, 
    name: "Sarah Johnson",
    avatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop",
    calendars: ["Google Calendar", "Work Calendar"],
  },
  { 
    id: 2, 
    name: "Mike Johnson",
    avatar: "https://images.unsplash.com/photo-1622319107576-cca7c8a906f7?w=100&h=100&fit=crop",
    calendars: ["Google Calendar"],
  },
  { 
    id: 3, 
    name: "Emma Johnson",
    avatar: "https://images.unsplash.com/photo-1652217627250-0dd21428e0f3?w=100&h=100&fit=crop",
    calendars: ["School Calendar"],
  },
];

export default function Calendar() {
  const { events, addEvent, inviteMembers, updateEvent, cancelEvent } = useEvents();
  const { user } = useAuth();
  const [selectedDate, setSelectedDate] = useState("2026-01-27");
  const [weekStartDate, setWeekStartDate] = useState("2026-01-27");
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [selectedMembers, setSelectedMembers] = useState<number[]>([]);
  const [showSuggestTime, setShowSuggestTime] = useState(false);
  const [isInviteDialogOpen, setIsInviteDialogOpen] = useState(false);
  const [selectedEventForInvite, setSelectedEventForInvite] = useState<number | null>(null);
  const [membersToInvite, setMembersToInvite] = useState<number[]>([]);
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);
  const [selectedEventForEdit, setSelectedEventForEdit] = useState<number | null>(null);
  const [editEventData, setEditEventData] = useState({
    title: "",
    date: "",
    time: "",
    duration: 60,
    location: "",
  });
  const [newEvent, setNewEvent] = useState({
    title: "",
    date: "2026-01-27",
    time: "12:00",
    duration: 60,
    location: "",
  });

  const formatDate = (dateStr: string) => {
    const date = new Date(dateStr);
    return date.toLocaleDateString("en-US", {
      weekday: "long",
      month: "long",
      day: "numeric",
    });
  };

  const isToday = (dateStr: string) => {
    return dateStr === "2026-01-27"; // Mock today
  };

  const getEventsForDate = (dateStr: string) => {
    return events.filter((e) => e.date === dateStr);
  };

  // Generate week dates starting from weekStartDate
  const generateWeekDates = (startDate: string) => {
    const dates = [];
    const start = new Date(startDate);
    for (let i = 0; i < 7; i++) {
      const date = new Date(start);
      date.setDate(start.getDate() + i);
      dates.push(date.toISOString().split("T")[0]);
    }
    return dates;
  };

  const dates = generateWeekDates(weekStartDate);

  // Navigate to previous week
  const handlePreviousWeek = () => {
    const start = new Date(weekStartDate);
    start.setDate(start.getDate() - 7);
    const newStartDate = start.toISOString().split("T")[0];
    setWeekStartDate(newStartDate);
    setSelectedDate(newStartDate); // Select first day of new week
  };

  // Navigate to next week
  const handleNextWeek = () => {
    const start = new Date(weekStartDate);
    start.setDate(start.getDate() + 7);
    const newStartDate = start.toISOString().split("T")[0];
    setWeekStartDate(newStartDate);
    setSelectedDate(newStartDate); // Select first day of new week
  };

  // Check if a member is available at a specific time
  const isMemberAvailable = (memberId: number, date: string, time: string, duration: number) => {
    const eventTime = parseInt(time.split(":")[0]) * 60 + parseInt(time.split(":")[1]);
    const eventEnd = eventTime + duration;

    const memberEvents = events.filter(e => 
      e.date === date && 
      e.invitedMembers.some(m => m.memberId === memberId && m.status === "accepted")
    );

    for (const event of memberEvents) {
      const existingTime = parseInt(event.time.split(":")[0]) * 60 + parseInt(event.time.split(":")[1]);
      const existingEnd = existingTime + event.duration;

      // Check for time overlap
      if (
        (eventTime >= existingTime && eventTime < existingEnd) ||
        (eventEnd > existingTime && eventEnd <= existingEnd) ||
        (eventTime <= existingTime && eventEnd >= existingEnd)
      ) {
        return false;
      }
    }
    return true;
  };

  // Suggest ideal time based on selected members' availability
  const suggestIdealTime = () => {
    if (selectedMembers.length === 0) return null;

    const timeSlots = [];
    for (let hour = 8; hour < 20; hour++) {
      for (let minute = 0; minute < 60; minute += 30) {
        const time = `${hour.toString().padStart(2, "0")}:${minute.toString().padStart(2, "0")}`;
        const allAvailable = selectedMembers.every(memberId =>
          isMemberAvailable(memberId, newEvent.date, time, newEvent.duration)
        );
        if (allAvailable) {
          timeSlots.push(time);
        }
      }
    }
    return timeSlots.slice(0, 3); // Return top 3 suggestions
  };

  const toggleMemberSelection = (memberId: number) => {
    setSelectedMembers(prev =>
      prev.includes(memberId)
        ? prev.filter(id => id !== memberId)
        : [...prev, memberId]
    );
  };

  const handleAddEvent = () => {
    // Get user ID for the creator
    const getUserId = (email: string): number => {
      const userMap: Record<string, number> = {
        "sarah@example.com": 1,
        "mike@example.com": 2,
        "emma@example.com": 3,
      };
      return userMap[email] || 1;
    };

    const creatorId = user ? getUserId(user.email) : 1;

    // Create event using the context
    addEvent({
      title: newEvent.title,
      date: newEvent.date,
      time: newEvent.time,
      duration: newEvent.duration,
      location: newEvent.location,
      invitedMembers: selectedMembers.map(id => ({
        memberId: id,
        name: familyMembers.find(m => m.id === id)?.name || "",
        status: id === creatorId ? "accepted" as const : "pending" as const, // Creator auto-accepts
      })),
      createdBy: creatorId,
    });
    
    // Reset form and close dialog
    setIsDialogOpen(false);
    setNewEvent({
      title: "",
      date: "2026-01-27",
      time: "12:00",
      duration: 60,
      location: "",
    });
    setSelectedMembers([]);
    setShowSuggestTime(false);
  };

  const suggestedTimes = showSuggestTime ? suggestIdealTime() : null;

  // Get current user ID
  const getCurrentUserId = () => {
    if (!user) return 0;
    const userMap: Record<string, number> = {
      "sarah@example.com": 1,
      "mike@example.com": 2,
      "emma@example.com": 3,
    };
    return userMap[user.email] || 0;
  };

  const currentUserId = getCurrentUserId();

  // Handle opening invite dialog
  const handleOpenInviteDialog = (eventId: number) => {
    setSelectedEventForInvite(eventId);
    setMembersToInvite([]);
    setIsInviteDialogOpen(true);
  };

  // Handle inviting members to an event
  const handleInviteMembers = () => {
    if (selectedEventForInvite && membersToInvite.length > 0) {
      inviteMembers(selectedEventForInvite, membersToInvite);
      setIsInviteDialogOpen(false);
      setSelectedEventForInvite(null);
      setMembersToInvite([]);
    }
  };

  // Get uninvited members for a specific event
  const getUninvitedMembers = (eventId: number) => {
    const event = events.find((e) => e.id === eventId);
    if (!event) return [];
    
    const invitedMemberIds = event.invitedMembers.map((m) => m.memberId);
    return familyMembers.filter((m) => !invitedMemberIds.includes(m.id));
  };

  const toggleInviteMemberSelection = (memberId: number) => {
    setMembersToInvite(prev =>
      prev.includes(memberId)
        ? prev.filter(id => id !== memberId)
        : [...prev, memberId]
    );
  };

  // Handle opening edit dialog
  const handleOpenEditDialog = (eventId: number) => {
    const event = events.find((e) => e.id === eventId);
    if (!event) return;

    setSelectedEventForEdit(eventId);
    setEditEventData({
      title: event.title,
      date: event.date,
      time: event.time,
      duration: event.duration,
      location: event.location,
    });
    setIsEditDialogOpen(true);
  };

  // Handle updating event
  const handleUpdateEvent = () => {
    if (selectedEventForEdit) {
      updateEvent(selectedEventForEdit, editEventData);
      setIsEditDialogOpen(false);
      setSelectedEventForEdit(null);
    }
  };

  // Handle cancelling event
  const handleCancelEvent = (eventId: number) => {
    if (confirm("Are you sure you want to cancel this event? All participants will be notified.")) {
      cancelEvent(eventId);
    }
  };

  return (
    <div className="h-full flex flex-col bg-gray-50">
      {/* Header */}
      <div className="bg-white border-b border-gray-200 px-6 py-4">
        <div className="flex items-center justify-between mb-4">
          <h1 className="text-2xl font-semibold text-gray-900">Calendar</h1>
          <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
            <DialogTrigger asChild>
              <Button size="sm" className="gap-2">
                <Plus className="w-4 h-4" />
                Add Event
              </Button>
            </DialogTrigger>
            <DialogContent className="max-w-sm max-h-[90vh] overflow-y-auto">
              <DialogHeader>
                <DialogTitle>New Event</DialogTitle>
              </DialogHeader>
              <div className="space-y-4 py-4">
                <div className="space-y-2">
                  <Label htmlFor="title">Event Title</Label>
                  <Input
                    id="title"
                    placeholder="e.g., Dentist Appointment"
                    value={newEvent.title}
                    onChange={(e) => setNewEvent({ ...newEvent, title: e.target.value })}
                  />
                </div>
                <div className="grid grid-cols-2 gap-3">
                  <div className="space-y-2">
                    <Label htmlFor="date">Date</Label>
                    <Input
                      id="date"
                      type="date"
                      value={newEvent.date}
                      onChange={(e) => setNewEvent({ ...newEvent, date: e.target.value })}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="time">Time</Label>
                    <TimePicker
                      value={newEvent.time}
                      onChange={(time) => setNewEvent({ ...newEvent, time })}
                    />
                  </div>
                </div>
                <div className="space-y-2">
                  <Label htmlFor="duration">Duration (minutes)</Label>
                  <Input
                    id="duration"
                    type="number"
                    placeholder="60"
                    value={newEvent.duration}
                    onChange={(e) => setNewEvent({ ...newEvent, duration: parseInt(e.target.value) || 60 })}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="location">Location</Label>
                  <Input
                    id="location"
                    placeholder="e.g., Swansea Marina, SA1 3XG"
                    value={newEvent.location}
                    onChange={(e) => setNewEvent({ ...newEvent, location: e.target.value })}
                  />
                </div>
                <div className="space-y-3">
                  <Label>Invite Family Members</Label>
                  <div className="space-y-2">
                    {familyMembers.map((member) => {
                      const isAvailable = isMemberAvailable(
                        member.id,
                        newEvent.date,
                        newEvent.time,
                        newEvent.duration
                      );
                      const isSelected = selectedMembers.includes(member.id);

                      return (
                        <div
                          key={member.id}
                          className={`flex items-center justify-between p-3 rounded-lg border transition-colors ${
                            isSelected
                              ? "border-blue-300 bg-blue-50"
                              : isAvailable
                              ? "border-gray-200 hover:border-gray-300 bg-white"
                              : "border-gray-200 bg-gray-50"
                          }`}
                        >
                          <div className="flex items-center gap-3 flex-1">
                            <Checkbox
                              id={`member-${member.id}`}
                              checked={isSelected}
                              onCheckedChange={() => toggleMemberSelection(member.id)}
                            />
                            <img
                              src={member.avatar}
                              alt={member.name}
                              className="w-8 h-8 rounded-full"
                            />
                            <div className="flex-1">
                              <div className="text-sm font-medium text-gray-900">
                                {member.name}
                              </div>
                              <div className="text-xs text-gray-500">
                                {member.calendars.join(", ")}
                              </div>
                            </div>
                          </div>
                          {isAvailable ? (
                            <Badge variant="secondary" className="bg-green-100 text-green-700 text-xs">
                              Available
                            </Badge>
                          ) : (
                            <Badge variant="secondary" className="bg-red-100 text-red-700 text-xs">
                              Busy
                            </Badge>
                          )}
                        </div>
                      );
                    })}
                  </div>
                  {selectedMembers.length > 0 && (
                    <Button
                      type="button"
                      variant="outline"
                      size="sm"
                      className="w-full gap-2"
                      onClick={() => setShowSuggestTime(!showSuggestTime)}
                    >
                      <Sparkles className="w-4 h-4" />
                      {showSuggestTime ? "Hide" : "Suggest Ideal Time"}
                    </Button>
                  )}
                  {suggestedTimes && suggestedTimes.length > 0 && (
                    <div className="p-3 bg-blue-50 border border-blue-200 rounded-lg space-y-2">
                      <div className="flex items-center gap-2 text-sm font-medium text-blue-900">
                        <Sparkles className="w-4 h-4" />
                        Suggested Times (All Available)
                      </div>
                      <div className="flex flex-wrap gap-2">
                        {suggestedTimes.map((time) => (
                          <button
                            key={time}
                            onClick={() => setNewEvent({ ...newEvent, time })}
                            className="px-3 py-1.5 bg-white border border-blue-300 rounded-md text-sm font-medium text-blue-700 hover:bg-blue-100 transition-colors"
                          >
                            {time}
                          </button>
                        ))}
                      </div>
                    </div>
                  )}
                  {suggestedTimes && suggestedTimes.length === 0 && (
                    <div className="p-3 bg-amber-50 border border-amber-200 rounded-lg">
                      <div className="flex items-center gap-2 text-sm text-amber-900">
                        <AlertCircle className="w-4 h-4" />
                        No common available times found. Invitations will be sent for approval.
                      </div>
                    </div>
                  )}
                  <p className="text-xs text-gray-500">
                    Selected members will receive invitations and need to accept
                  </p>
                </div>
              </div>
              <DialogFooter>
                <Button variant="outline" onClick={() => setIsDialogOpen(false)}>
                  Cancel
                </Button>
                <Button onClick={handleAddEvent}>
                  Send Invitations
                </Button>
              </DialogFooter>
            </DialogContent>
          </Dialog>
        </div>

        {/* Date selector */}
        <div className="flex items-center gap-2">
          <button 
            className="p-2 rounded-lg hover:bg-gray-100 flex-shrink-0 transition-colors"
            onClick={handlePreviousWeek}
            aria-label="Previous week"
          >
            <ChevronLeft className="w-5 h-5 text-gray-600" />
          </button>
          <div className="flex items-center gap-2 overflow-x-auto pb-2 scrollbar-hide flex-1">
            {dates.map((date) => {
              const day = new Date(date).getDate();
              const dayName = new Date(date).toLocaleDateString("en-US", { weekday: "short" });
              const active = date === selectedDate;
              const today = isToday(date);

              return (
                <button
                  key={date}
                  onClick={() => setSelectedDate(date)}
                  className={`flex flex-col items-center gap-1 p-3 rounded-xl min-w-[60px] transition-all ${
                    active
                      ? "bg-blue-600 text-white shadow-md"
                      : today
                      ? "bg-blue-50 text-blue-600 border-2 border-blue-200"
                      : "bg-white text-gray-700 hover:bg-gray-50"
                  }`}
                >
                  <span className="text-xs font-medium">{dayName}</span>
                  <span className="text-lg font-semibold">{day}</span>
                  {getEventsForDate(date).length > 0 && (
                    <div className={`w-1 h-1 rounded-full ${active ? "bg-white" : "bg-blue-600"}`} />
                  )}
                </button>
              );
            })}
          </div>
          <button 
            className="p-2 rounded-lg hover:bg-gray-100 flex-shrink-0 transition-colors"
            onClick={handleNextWeek}
            aria-label="Next week"
          >
            <ChevronRight className="w-5 h-5 text-gray-600" />
          </button>
        </div>
      </div>

      {/* Events List */}
      <div className="flex-1 overflow-auto px-6 py-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">
          {formatDate(selectedDate)}
        </h2>

        {getEventsForDate(selectedDate).length === 0 ? (
          <Card className="p-8 text-center">
            <div className="text-gray-400 mb-2">
              <Clock className="w-12 h-12 mx-auto" />
            </div>
            <p className="text-gray-600">No events scheduled</p>
            <p className="text-sm text-gray-500 mt-1">
              Add an event to get started
            </p>
          </Card>
        ) : (
          <div className="space-y-3">
            {getEventsForDate(selectedDate).map((event) => {
              const isCreator = event.createdBy === currentUserId;
              const uninvitedMembers = getUninvitedMembers(event.id);
              
              return (
                <Card key={event.id} className="p-4 hover:border-gray-300 transition-colors">
                  <div className="flex gap-4">
                    <div className="flex flex-col items-center text-sm text-gray-600 min-w-[60px]">
                      <Clock className="w-4 h-4 mb-1" />
                      <span className="font-medium">{event.time}</span>
                      <span className="text-xs text-gray-400">{event.duration}m</span>
                    </div>
                    <div className="flex-1 min-w-0">
                      <h3 className="font-semibold text-gray-900 mb-1">{event.title}</h3>
                      {event.location && (
                        <button
                          onClick={() => openMapsApp(event.location!)}
                          className="flex items-center gap-1.5 text-sm text-blue-600 hover:text-blue-700 hover:underline mb-2 transition-colors"
                          title={`Open in ${getMapsAppName()}`}
                        >
                          <MapPin className="w-3.5 h-3.5" />
                          {event.location}
                        </button>
                      )}
                      {event.calendarSource && (
                        <div className="flex items-center gap-1 mb-2">
                          <CalendarIcon className="w-3 h-3 text-gray-400" />
                          <span className="text-xs text-gray-500">{event.calendarSource}</span>
                        </div>
                      )}
                      <div className="flex items-center gap-2 flex-wrap mb-3">
                        {event.invitedMembers.map((person, idx) => (
                          <div key={idx} className="flex items-center gap-1">
                            <Badge 
                              variant="secondary" 
                              className={`text-xs flex items-center gap-1 ${
                                person.status === "accepted" 
                                  ? "bg-green-100 text-green-700" 
                                  : "bg-amber-100 text-amber-700"
                              }`}
                            >
                              {person.name.split(" ")[0]}
                              {person.status === "accepted" ? (
                                <Check className="w-3 h-3" />
                              ) : (
                                <Clock className="w-3 h-3" />
                              )}
                            </Badge>
                          </div>
                        ))}
                      </div>
                      {isCreator && (
                        <div className="flex gap-2 flex-wrap">
                          {uninvitedMembers.length > 0 && (
                            <Button
                              size="sm"
                              variant="outline"
                              className="gap-2"
                              onClick={() => handleOpenInviteDialog(event.id)}
                            >
                              <UserPlus className="w-4 h-4" />
                              Invite
                            </Button>
                          )}
                          <Button
                            size="sm"
                            variant="outline"
                            className="gap-2"
                            onClick={() => handleOpenEditDialog(event.id)}
                          >
                            <Edit className="w-4 h-4" />
                            Edit
                          </Button>
                          <Button
                            size="sm"
                            variant="outline"
                            className="gap-2 text-red-600 hover:text-red-700 hover:bg-red-50"
                            onClick={() => handleCancelEvent(event.id)}
                          >
                            <Trash2 className="w-4 h-4" />
                            Cancel
                          </Button>
                        </div>
                      )}
                    </div>
                  </div>
                </Card>
              );
            })}
          </div>
        )}
      </div>

      {/* Invite Members Dialog */}
      <Dialog open={isInviteDialogOpen} onOpenChange={setIsInviteDialogOpen}>
        <DialogContent className="max-w-sm">
          <DialogHeader>
            <DialogTitle>Invite More Members</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-4">
            {selectedEventForInvite && getUninvitedMembers(selectedEventForInvite).length === 0 ? (
              <p className="text-sm text-gray-500 text-center py-4">
                All family members are already invited to this event.
              </p>
            ) : (
              <>
                <p className="text-sm text-gray-600">
                  Select additional family members to invite:
                </p>
                <div className="space-y-2">
                  {selectedEventForInvite &&
                    getUninvitedMembers(selectedEventForInvite).map((member) => (
                      <div
                        key={member.id}
                        className={`flex items-center gap-3 p-3 rounded-lg border transition-colors ${
                          membersToInvite.includes(member.id)
                            ? "border-blue-300 bg-blue-50"
                            : "border-gray-200 hover:border-gray-300 bg-white"
                        }`}
                      >
                        <Checkbox
                          id={`invite-${member.id}`}
                          checked={membersToInvite.includes(member.id)}
                          onCheckedChange={() => toggleInviteMemberSelection(member.id)}
                        />
                        <img
                          src={member.avatar}
                          alt={member.name}
                          className="w-8 h-8 rounded-full"
                        />
                        <div className="flex-1">
                          <div className="text-sm font-medium text-gray-900">
                            {member.name}
                          </div>
                          <div className="text-xs text-gray-500">
                            {member.calendars.join(", ")}
                          </div>
                        </div>
                      </div>
                    ))}
                </div>
              </>
            )}
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setIsInviteDialogOpen(false)}>
              Cancel
            </Button>
            <Button
              onClick={handleInviteMembers}
              disabled={membersToInvite.length === 0}
            >
              Send Invitations
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Edit Event Dialog */}
      <Dialog open={isEditDialogOpen} onOpenChange={setIsEditDialogOpen}>
        <DialogContent className="max-w-sm max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>Edit Event</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label htmlFor="edit-title">Event Title</Label>
              <Input
                id="edit-title"
                placeholder="e.g., Dentist Appointment"
                value={editEventData.title}
                onChange={(e) => setEditEventData({ ...editEventData, title: e.target.value })}
              />
            </div>
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-2">
                <Label htmlFor="edit-date">Date</Label>
                <Input
                  id="edit-date"
                  type="date"
                  value={editEventData.date}
                  onChange={(e) => setEditEventData({ ...editEventData, date: e.target.value })}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="edit-time">Time</Label>
                <TimePicker
                  value={editEventData.time}
                  onChange={(time) => setEditEventData({ ...editEventData, time })}
                />
              </div>
            </div>
            <div className="space-y-2">
              <Label htmlFor="edit-duration">Duration (minutes)</Label>
              <Input
                id="edit-duration"
                type="number"
                placeholder="60"
                value={editEventData.duration}
                onChange={(e) => setEditEventData({ ...editEventData, duration: parseInt(e.target.value) || 60 })}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="edit-location">Location</Label>
              <Input
                id="edit-location"
                placeholder="e.g., Swansea Marina, SA1 3XG"
                value={editEventData.location}
                onChange={(e) => setEditEventData({ ...editEventData, location: e.target.value })}
              />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setIsEditDialogOpen(false)}>
              Cancel
            </Button>
            <Button onClick={handleUpdateEvent}>
              Update Event
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}