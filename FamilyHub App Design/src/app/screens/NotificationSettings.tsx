import { useState } from "react";
import { useNavigate } from "react-router";
import { ChevronLeft } from "lucide-react";
import { Card } from "@/app/components/ui/card";
import { Switch } from "@/app/components/ui/switch";
import { Label } from "@/app/components/ui/label";
import { toast } from "sonner";

export default function NotificationSettings() {
  const navigate = useNavigate();
  const [settings, setSettings] = useState({
    eventReminders: true,
    taskAssignments: true,
    shoppingUpdates: true,
    locationAlerts: true,
    sosAlerts: true,
    familyInvites: true,
    pushNotifications: true,
    emailNotifications: false,
    smsNotifications: false,
  });

  const handleToggle = (key: keyof typeof settings) => {
    setSettings((prev) => ({
      ...prev,
      [key]: !prev[key],
    }));
    toast.success("Notification settings updated");
  };

  return (
    <div className="h-full flex flex-col bg-gray-50">
      {/* Header */}
      <div className="bg-white border-b border-gray-200 px-6 py-4">
        <div className="flex items-center gap-3">
          <button
            onClick={() => navigate("/profile")}
            className="p-2 -ml-2 rounded-lg hover:bg-gray-100 transition-colors"
          >
            <ChevronLeft className="w-5 h-5 text-gray-600" />
          </button>
          <h1 className="text-2xl font-semibold text-gray-900">Notifications</h1>
        </div>
      </div>

      <div className="flex-1 overflow-auto px-6 py-6 space-y-6">
        {/* App Notifications */}
        <section>
          <h3 className="text-lg font-semibold text-gray-900 mb-3">
            App Notifications
          </h3>
          <Card className="divide-y divide-gray-100">
            <div className="p-4 flex items-center justify-between">
              <div className="flex-1">
                <Label htmlFor="event-reminders" className="text-base font-medium text-gray-900 cursor-pointer">
                  Event Reminders
                </Label>
                <p className="text-sm text-gray-500 mt-1">
                  Get notified about upcoming events
                </p>
              </div>
              <Switch
                id="event-reminders"
                checked={settings.eventReminders}
                onCheckedChange={() => handleToggle("eventReminders")}
              />
            </div>

            <div className="p-4 flex items-center justify-between">
              <div className="flex-1">
                <Label htmlFor="task-assignments" className="text-base font-medium text-gray-900 cursor-pointer">
                  Task Assignments
                </Label>
                <p className="text-sm text-gray-500 mt-1">
                  Notify when tasks are assigned to you
                </p>
              </div>
              <Switch
                id="task-assignments"
                checked={settings.taskAssignments}
                onCheckedChange={() => handleToggle("taskAssignments")}
              />
            </div>

            <div className="p-4 flex items-center justify-between">
              <div className="flex-1">
                <Label htmlFor="shopping-updates" className="text-base font-medium text-gray-900 cursor-pointer">
                  Shopping Updates
                </Label>
                <p className="text-sm text-gray-500 mt-1">
                  Updates on shopping list changes
                </p>
              </div>
              <Switch
                id="shopping-updates"
                checked={settings.shoppingUpdates}
                onCheckedChange={() => handleToggle("shoppingUpdates")}
              />
            </div>

            <div className="p-4 flex items-center justify-between">
              <div className="flex-1">
                <Label htmlFor="location-alerts" className="text-base font-medium text-gray-900 cursor-pointer">
                  Location Alerts
                </Label>
                <p className="text-sm text-gray-500 mt-1">
                  Alerts when family members arrive/leave
                </p>
              </div>
              <Switch
                id="location-alerts"
                checked={settings.locationAlerts}
                onCheckedChange={() => handleToggle("locationAlerts")}
              />
            </div>

            <div className="p-4 flex items-center justify-between">
              <div className="flex-1">
                <Label htmlFor="sos-alerts" className="text-base font-medium text-gray-900 cursor-pointer">
                  SOS Alerts
                </Label>
                <p className="text-sm text-gray-500 mt-1">
                  Emergency alerts from family members
                </p>
              </div>
              <Switch
                id="sos-alerts"
                checked={settings.sosAlerts}
                onCheckedChange={() => handleToggle("sosAlerts")}
              />
            </div>

            <div className="p-4 flex items-center justify-between">
              <div className="flex-1">
                <Label htmlFor="family-invites" className="text-base font-medium text-gray-900 cursor-pointer">
                  Family Invites
                </Label>
                <p className="text-sm text-gray-500 mt-1">
                  Invitations to join family groups
                </p>
              </div>
              <Switch
                id="family-invites"
                checked={settings.familyInvites}
                onCheckedChange={() => handleToggle("familyInvites")}
              />
            </div>
          </Card>
        </section>

        {/* Notification Methods */}
        <section>
          <h3 className="text-lg font-semibold text-gray-900 mb-3">
            Notification Methods
          </h3>
          <Card className="divide-y divide-gray-100">
            <div className="p-4 flex items-center justify-between">
              <div className="flex-1">
                <Label htmlFor="push-notifications" className="text-base font-medium text-gray-900 cursor-pointer">
                  Push Notifications
                </Label>
                <p className="text-sm text-gray-500 mt-1">
                  Receive notifications on your device
                </p>
              </div>
              <Switch
                id="push-notifications"
                checked={settings.pushNotifications}
                onCheckedChange={() => handleToggle("pushNotifications")}
              />
            </div>

            <div className="p-4 flex items-center justify-between">
              <div className="flex-1">
                <Label htmlFor="email-notifications" className="text-base font-medium text-gray-900 cursor-pointer">
                  Email Notifications
                </Label>
                <p className="text-sm text-gray-500 mt-1">
                  Receive notifications via email
                </p>
              </div>
              <Switch
                id="email-notifications"
                checked={settings.emailNotifications}
                onCheckedChange={() => handleToggle("emailNotifications")}
              />
            </div>

            <div className="p-4 flex items-center justify-between">
              <div className="flex-1">
                <Label htmlFor="sms-notifications" className="text-base font-medium text-gray-900 cursor-pointer">
                  SMS Notifications
                </Label>
                <p className="text-sm text-gray-500 mt-1">
                  Receive notifications via SMS
                </p>
              </div>
              <Switch
                id="sms-notifications"
                checked={settings.smsNotifications}
                onCheckedChange={() => handleToggle("smsNotifications")}
              />
            </div>
          </Card>
        </section>
      </div>
    </div>
  );
}
