import { useState } from "react";
import { useNavigate } from "react-router";
import { ChevronLeft, Eye, EyeOff } from "lucide-react";
import { Card } from "@/app/components/ui/card";
import { Switch } from "@/app/components/ui/switch";
import { Label } from "@/app/components/ui/label";
import { Button } from "@/app/components/ui/button";
import { Input } from "@/app/components/ui/input";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/app/components/ui/dialog";
import { toast } from "sonner";

export default function PrivacySecurity() {
  const navigate = useNavigate();
  const [settings, setSettings] = useState({
    locationSharing: true,
    showOnlineStatus: true,
    shareReadReceipts: true,
    allowTaskAssignments: true,
    twoFactorAuth: false,
    biometricAuth: true,
  });

  const [isChangePasswordOpen, setIsChangePasswordOpen] = useState(false);
  const [showCurrentPassword, setShowCurrentPassword] = useState(false);
  const [showNewPassword, setShowNewPassword] = useState(false);
  const [passwordForm, setPasswordForm] = useState({
    currentPassword: "",
    newPassword: "",
    confirmPassword: "",
  });

  const handleToggle = (key: keyof typeof settings) => {
    setSettings((prev) => ({
      ...prev,
      [key]: !prev[key],
    }));
    toast.success("Privacy settings updated");
  };

  const handleChangePassword = () => {
    if (passwordForm.newPassword !== passwordForm.confirmPassword) {
      toast.error("Passwords don't match");
      return;
    }
    if (passwordForm.newPassword.length < 8) {
      toast.error("Password must be at least 8 characters");
      return;
    }
    // Mock password change
    toast.success("Password changed successfully!");
    setIsChangePasswordOpen(false);
    setPasswordForm({
      currentPassword: "",
      newPassword: "",
      confirmPassword: "",
    });
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
          <h1 className="text-2xl font-semibold text-gray-900">
            Privacy & Security
          </h1>
        </div>
      </div>

      <div className="flex-1 overflow-auto px-6 py-6 space-y-6">
        {/* Privacy Settings */}
        <section>
          <h3 className="text-lg font-semibold text-gray-900 mb-3">
            Privacy Settings
          </h3>
          <Card className="divide-y divide-gray-100">
            <div className="p-4 flex items-center justify-between">
              <div className="flex-1">
                <Label
                  htmlFor="location-sharing"
                  className="text-base font-medium text-gray-900 cursor-pointer"
                >
                  Location Sharing
                </Label>
                <p className="text-sm text-gray-500 mt-1">
                  Allow family members to see your location
                </p>
              </div>
              <Switch
                id="location-sharing"
                checked={settings.locationSharing}
                onCheckedChange={() => handleToggle("locationSharing")}
              />
            </div>

            <div className="p-4 flex items-center justify-between">
              <div className="flex-1">
                <Label
                  htmlFor="online-status"
                  className="text-base font-medium text-gray-900 cursor-pointer"
                >
                  Show Online Status
                </Label>
                <p className="text-sm text-gray-500 mt-1">
                  Let family see when you're active
                </p>
              </div>
              <Switch
                id="online-status"
                checked={settings.showOnlineStatus}
                onCheckedChange={() => handleToggle("showOnlineStatus")}
              />
            </div>

            <div className="p-4 flex items-center justify-between">
              <div className="flex-1">
                <Label
                  htmlFor="read-receipts"
                  className="text-base font-medium text-gray-900 cursor-pointer"
                >
                  Read Receipts
                </Label>
                <p className="text-sm text-gray-500 mt-1">
                  Show when you've seen notifications
                </p>
              </div>
              <Switch
                id="read-receipts"
                checked={settings.shareReadReceipts}
                onCheckedChange={() => handleToggle("shareReadReceipts")}
              />
            </div>

            <div className="p-4 flex items-center justify-between">
              <div className="flex-1">
                <Label
                  htmlFor="task-assignments"
                  className="text-base font-medium text-gray-900 cursor-pointer"
                >
                  Allow Task Assignments
                </Label>
                <p className="text-sm text-gray-500 mt-1">
                  Let family members assign tasks to you
                </p>
              </div>
              <Switch
                id="task-assignments"
                checked={settings.allowTaskAssignments}
                onCheckedChange={() => handleToggle("allowTaskAssignments")}
              />
            </div>
          </Card>
        </section>

        {/* Security Settings */}
        <section>
          <h3 className="text-lg font-semibold text-gray-900 mb-3">
            Security Settings
          </h3>
          <Card className="divide-y divide-gray-100">
            <div className="p-4 flex items-center justify-between">
              <div className="flex-1">
                <Label
                  htmlFor="two-factor"
                  className="text-base font-medium text-gray-900 cursor-pointer"
                >
                  Two-Factor Authentication
                </Label>
                <p className="text-sm text-gray-500 mt-1">
                  Add an extra layer of security
                </p>
              </div>
              <Switch
                id="two-factor"
                checked={settings.twoFactorAuth}
                onCheckedChange={() => handleToggle("twoFactorAuth")}
              />
            </div>

            <div className="p-4 flex items-center justify-between">
              <div className="flex-1">
                <Label
                  htmlFor="biometric"
                  className="text-base font-medium text-gray-900 cursor-pointer"
                >
                  Biometric Authentication
                </Label>
                <p className="text-sm text-gray-500 mt-1">
                  Use fingerprint or face ID to unlock
                </p>
              </div>
              <Switch
                id="biometric"
                checked={settings.biometricAuth}
                onCheckedChange={() => handleToggle("biometricAuth")}
              />
            </div>

            <div className="p-4">
              <Button
                variant="outline"
                className="w-full"
                onClick={() => setIsChangePasswordOpen(true)}
              >
                Change Password
              </Button>
            </div>
          </Card>
        </section>

        {/* Data Management */}
        <section>
          <h3 className="text-lg font-semibold text-gray-900 mb-3">
            Data Management
          </h3>
          <Card className="divide-y divide-gray-100">
            <button className="w-full p-4 text-left hover:bg-gray-50 transition-colors">
              <p className="font-medium text-gray-900">Download My Data</p>
              <p className="text-sm text-gray-500 mt-1">
                Get a copy of your FamilyHub data
              </p>
            </button>

            <button className="w-full p-4 text-left hover:bg-gray-50 transition-colors">
              <p className="font-medium text-red-600">Delete Account</p>
              <p className="text-sm text-gray-500 mt-1">
                Permanently delete your account and data
              </p>
            </button>
          </Card>
        </section>
      </div>

      {/* Change Password Dialog */}
      <Dialog open={isChangePasswordOpen} onOpenChange={setIsChangePasswordOpen}>
        <DialogContent className="max-w-sm">
          <DialogHeader>
            <DialogTitle>Change Password</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label htmlFor="current-password">Current Password</Label>
              <div className="relative">
                <Input
                  id="current-password"
                  type={showCurrentPassword ? "text" : "password"}
                  value={passwordForm.currentPassword}
                  onChange={(e) =>
                    setPasswordForm({ ...passwordForm, currentPassword: e.target.value })
                  }
                  placeholder="Enter current password"
                />
                <button
                  type="button"
                  onClick={() => setShowCurrentPassword(!showCurrentPassword)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                >
                  {showCurrentPassword ? (
                    <EyeOff className="w-4 h-4" />
                  ) : (
                    <Eye className="w-4 h-4" />
                  )}
                </button>
              </div>
            </div>
            <div className="space-y-2">
              <Label htmlFor="new-password">New Password</Label>
              <div className="relative">
                <Input
                  id="new-password"
                  type={showNewPassword ? "text" : "password"}
                  value={passwordForm.newPassword}
                  onChange={(e) =>
                    setPasswordForm({ ...passwordForm, newPassword: e.target.value })
                  }
                  placeholder="Enter new password"
                />
                <button
                  type="button"
                  onClick={() => setShowNewPassword(!showNewPassword)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                >
                  {showNewPassword ? (
                    <EyeOff className="w-4 h-4" />
                  ) : (
                    <Eye className="w-4 h-4" />
                  )}
                </button>
              </div>
            </div>
            <div className="space-y-2">
              <Label htmlFor="confirm-password">Confirm New Password</Label>
              <Input
                id="confirm-password"
                type="password"
                value={passwordForm.confirmPassword}
                onChange={(e) =>
                  setPasswordForm({ ...passwordForm, confirmPassword: e.target.value })
                }
                placeholder="Confirm new password"
              />
            </div>
          </div>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => {
                setIsChangePasswordOpen(false);
                setPasswordForm({
                  currentPassword: "",
                  newPassword: "",
                  confirmPassword: "",
                });
              }}
            >
              Cancel
            </Button>
            <Button onClick={handleChangePassword}>Change Password</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
