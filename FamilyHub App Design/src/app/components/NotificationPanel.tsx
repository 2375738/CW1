import { useState } from "react";
import { useNavigate } from "react-router";
import { Bell, Calendar, X, Check, XCircle, ListChecks, CheckCircle, Clock, MapPin, Edit, AlertTriangle, ChevronRight } from "lucide-react";
import { Button } from "@/app/components/ui/button";
import { Badge } from "@/app/components/ui/badge";
import { Card } from "@/app/components/ui/card";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/app/components/ui/dialog";
import { useNotifications, Notification } from "@/app/contexts/NotificationContext";
import { openMapsApp, getMapsAppName } from "@/app/utils/maps";

interface NotificationPanelProps {
  onAcceptInvitation?: (eventId: number) => void;
  onDeclineInvitation?: (eventId: number) => void;
}

export function NotificationPanel({
  onAcceptInvitation,
  onDeclineInvitation,
}: NotificationPanelProps) {
  const { notifications, markAsRead, removeNotification, unreadCount } = useNotifications();
  const [isOpen, setIsOpen] = useState(false);
  const navigate = useNavigate();

  const handleAccept = (eventId: number, notificationId: number) => {
    if (onAcceptInvitation) {
      onAcceptInvitation(eventId);
    }
    removeNotification(notificationId);
  };

  const handleDecline = (eventId: number, notificationId: number) => {
    if (onDeclineInvitation) {
      onDeclineInvitation(eventId);
    }
    removeNotification(notificationId);
  };

  const clearNotification = (id: number) => {
    removeNotification(id);
  };

  const formatDate = (dateStr: string) => {
    const date = new Date(dateStr);
    return date.toLocaleDateString("en-US", { month: "short", day: "numeric" });
  };

  const formatTime = (timeStr: string) => {
    return timeStr;
  };

  const getNotificationIcon = (type: Notification["type"]) => {
    switch (type) {
      case "event_invitation":
      case "event_change":
        return <Calendar className="w-5 h-5 text-blue-600" />;
      case "event_cancelled":
        return <XCircle className="w-5 h-5 text-red-600" />;
      case "task_assigned":
        return <ListChecks className="w-5 h-5 text-green-600" />;
      case "task_completed":
        return <CheckCircle className="w-5 h-5 text-green-600" />;
      default:
        return <Bell className="w-5 h-5 text-gray-600" />;
    }
  };

  return (
    <>
      <button
        onClick={() => setIsOpen(true)}
        className="p-2 rounded-full hover:bg-gray-100 transition-colors relative"
      >
        <Bell className="w-6 h-6 text-gray-700" />
        {unreadCount > 0 && (
          <span className="absolute top-1 right-1 w-5 h-5 bg-red-500 text-white text-xs font-semibold rounded-full flex items-center justify-center">
            {unreadCount}
          </span>
        )}
      </button>

      <Dialog open={isOpen} onOpenChange={setIsOpen}>
        <DialogContent className="max-w-md max-h-[80vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>Notifications</DialogTitle>
          </DialogHeader>

          <div className="space-y-3 py-4">
            {notifications.length === 0 ? (
              <div className="text-center py-8">
                <Bell className="w-12 h-12 mx-auto text-gray-300 mb-3" />
                <p className="text-gray-600">No notifications</p>
                <p className="text-sm text-gray-500 mt-1">
                  You're all caught up!
                </p>
              </div>
            ) : (
              notifications.map((notification) => (
                <Card
                  key={notification.id}
                  className={`p-4 ${
                    notification.read ? "bg-gray-50" : "bg-blue-50 border-blue-200"
                  }`}
                >
                  {notification.type === "event_invitation" && notification.eventDetails ? (
                    <div className="space-y-3">
                      <div className="flex items-start gap-3">
                        <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center flex-shrink-0">
                          <Calendar className="w-5 h-5 text-blue-600" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <h4 className="font-semibold text-gray-900 mb-1">
                            Event Invitation
                          </h4>
                          <p className="text-sm text-gray-700 mb-2">
                            <span className="font-medium">
                              {notification.eventDetails.createdBy}
                            </span>{" "}
                            invited you to{" "}
                            <span className="font-medium">
                              {notification.eventDetails.title}
                            </span>
                          </p>
                        </div>
                      </div>

                      <div className="bg-white rounded-lg p-3 space-y-2 border border-gray-200">
                        <div className="flex items-center gap-2 text-sm text-gray-700">
                          <Calendar className="w-4 h-4 text-gray-500" />
                          <span>
                            {formatDate(notification.eventDetails.date)} at{" "}
                            {formatTime(notification.eventDetails.time)}
                          </span>
                        </div>
                        <div className="flex items-center gap-2 text-sm text-gray-700">
                          <Clock className="w-4 h-4 text-gray-500" />
                          <span>{notification.eventDetails.duration} minutes</span>
                        </div>
                        {notification.eventDetails.location && (
                          <button
                            onClick={() => openMapsApp(notification.eventDetails!.location!)}
                            className="flex items-center gap-2 text-sm text-blue-600 hover:text-blue-700 hover:underline transition-colors"
                            title={`Open in ${getMapsAppName()}`}
                          >
                            <MapPin className="w-4 h-4" />
                            <span>{notification.eventDetails.location}</span>
                          </button>
                        )}
                      </div>

                      <div className="flex gap-2">
                        <Button
                          size="sm"
                          className="flex-1 gap-2"
                          onClick={() =>
                            handleAccept(notification.eventId!, notification.id)
                          }
                        >
                          <Check className="w-4 h-4" />
                          Accept Changes
                        </Button>
                        <Button
                          size="sm"
                          variant="outline"
                          className="flex-1 gap-2"
                          onClick={() =>
                            handleDecline(notification.eventId!, notification.id)
                          }
                        >
                          <X className="w-4 h-4" />
                          Decline
                        </Button>
                      </div>
                    </div>
                  ) : notification.type === "event_update" && notification.eventDetails ? (
                    <div className="space-y-3">
                      <div className="flex items-start gap-3">
                        <div className="w-10 h-10 bg-amber-100 rounded-full flex items-center justify-center flex-shrink-0">
                          <Edit className="w-5 h-5 text-amber-600" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <h4 className="font-semibold text-gray-900 mb-1">
                            Event Updated
                          </h4>
                          <p className="text-sm text-gray-700 mb-2">
                            <span className="font-medium">
                              {notification.eventDetails.createdBy}
                            </span>{" "}
                            updated{" "}
                            <span className="font-medium">
                              {notification.eventDetails.title}
                            </span>
                          </p>
                        </div>
                      </div>

                      {notification.previousEventDetails && (
                        <div className="bg-red-50 rounded-lg p-3 space-y-1 border border-red-200">
                          <p className="text-xs font-semibold text-red-900 mb-1">Previous:</p>
                          <div className="flex items-center gap-2 text-sm text-red-700 line-through">
                            <Calendar className="w-4 h-4" />
                            <span>
                              {formatDate(notification.previousEventDetails.date)} at{" "}
                              {formatTime(notification.previousEventDetails.time)}
                            </span>
                          </div>
                          {notification.previousEventDetails.location && (
                            <div className="flex items-center gap-2 text-sm text-red-700 line-through">
                              <MapPin className="w-4 h-4" />
                              <span>{notification.previousEventDetails.location}</span>
                            </div>
                          )}
                        </div>
                      )}

                      <div className="bg-green-50 rounded-lg p-3 space-y-2 border border-green-200">
                        <p className="text-xs font-semibold text-green-900 mb-1">New:</p>
                        <div className="flex items-center gap-2 text-sm text-green-700">
                          <Calendar className="w-4 h-4" />
                          <span>
                            {formatDate(notification.eventDetails.date)} at{" "}
                            {formatTime(notification.eventDetails.time)}
                          </span>
                        </div>
                        <div className="flex items-center gap-2 text-sm text-green-700">
                          <Clock className="w-4 h-4" />
                          <span>{notification.eventDetails.duration} minutes</span>
                        </div>
                        {notification.eventDetails.location && (
                          <div className="flex items-center gap-2 text-sm text-green-700">
                            <MapPin className="w-4 h-4" />
                            <span>{notification.eventDetails.location}</span>
                          </div>
                        )}
                      </div>

                      <div className="flex gap-2">
                        <Button
                          size="sm"
                          className="flex-1 gap-2"
                          onClick={() =>
                            handleAccept(notification.eventId!, notification.id)
                          }
                        >
                          <Check className="w-4 h-4" />
                          Accept Changes
                        </Button>
                        <Button
                          size="sm"
                          variant="outline"
                          className="flex-1 gap-2"
                          onClick={() =>
                            handleDecline(notification.eventId!, notification.id)
                          }
                        >
                          <X className="w-4 h-4" />
                          Decline
                        </Button>
                      </div>
                    </div>
                  ) : notification.type === "event_cancelled" ? (
                    <div className="space-y-3">
                      <div className="flex items-start gap-3">
                        <div className="w-10 h-10 bg-red-100 rounded-full flex items-center justify-center flex-shrink-0">
                          <AlertTriangle className="w-5 h-5 text-red-600" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <h4 className="font-semibold text-gray-900 mb-1">
                            Event Cancelled
                          </h4>
                          <p className="text-sm text-gray-700">
                            {notification.message}
                          </p>
                        </div>
                        <button
                          onClick={() => removeNotification(notification.id)}
                          className="text-gray-400 hover:text-gray-600"
                        >
                          <X className="w-4 h-4" />
                        </button>
                      </div>
                    </div>
                  ) : notification.type === "task_assigned" ? (
                    <div className="space-y-3">
                      <div className="flex items-start gap-3">
                        <div className="w-10 h-10 bg-green-100 rounded-full flex items-center justify-center flex-shrink-0">
                          <ListChecks className="w-5 h-5 text-green-600" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <h4 className="font-semibold text-gray-900 mb-1">
                            {notification.title}
                          </h4>
                          <p className="text-sm text-gray-700">{notification.message}</p>
                        </div>
                        <button
                          onClick={() => removeNotification(notification.id)}
                          className="text-gray-400 hover:text-gray-600"
                        >
                          <X className="w-4 h-4" />
                        </button>
                      </div>
                      <Button
                        size="sm"
                        className="w-full gap-2"
                        onClick={() => {
                          navigate("/tasks?tab=shopping");
                          setIsOpen(false);
                          markAsRead(notification.id);
                        }}
                      >
                        View Task
                        <ChevronRight className="w-4 h-4" />
                      </Button>
                    </div>
                  ) : (
                    <div className="flex items-start gap-3">
                      <div className="w-10 h-10 bg-gray-100 rounded-full flex items-center justify-center flex-shrink-0">
                        <Bell className="w-5 h-5 text-gray-600" />
                      </div>
                      <div className="flex-1 min-w-0">
                        <h4 className="font-semibold text-gray-900 mb-1">
                          {notification.title}
                        </h4>
                        <p className="text-sm text-gray-700">{notification.message}</p>
                      </div>
                      <button
                        onClick={() => removeNotification(notification.id)}
                        className="text-gray-400 hover:text-gray-600"
                      >
                        <X className="w-4 h-4" />
                      </button>
                    </div>
                  )}
                </Card>
              ))
            )}
          </div>
        </DialogContent>
      </Dialog>
    </>
  );
}