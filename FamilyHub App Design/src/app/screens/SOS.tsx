import { useState, useEffect } from "react";
import { useNavigate } from "react-router";
import { Button } from "@/app/components/ui/button";
import { Card } from "@/app/components/ui/card";
import { Alert, AlertDescription, AlertTitle } from "@/app/components/ui/alert";
import { Progress } from "@/app/components/ui/progress";
import { Badge } from "@/app/components/ui/badge";
import { AlertTriangle, Phone, MapPin, Users, X, CheckCircle, Shield, Loader2 } from "lucide-react";
import { useAuth } from "@/app/contexts/AuthContext";
import { useRelationships } from "@/app/contexts/RelationshipContext";
import { useNotifications } from "@/app/contexts/NotificationContext";
import { toast } from "sonner";

type SOSStatus = "idle" | "activating" | "sending" | "sent" | "failed";

export default function SOS() {
  const { user } = useAuth();
  const { getCloseFamilyMembers } = useRelationships();
  const { addNotification } = useNotifications();
  const [sosStatus, setSOSStatus] = useState<SOSStatus>("idle");
  const [holdProgress, setHoldProgress] = useState(0);
  const [isHolding, setIsHolding] = useState(false);
  const [notifiedMembers, setNotifiedMembers] = useState<number[]>([]);
  const navigate = useNavigate();

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
  const closeFamilyMembers = getCloseFamilyMembers(currentUserId);

  // Hold-to-activate logic
  useEffect(() => {
    let interval: NodeJS.Timeout;

    if (isHolding && sosStatus === "idle") {
      setHoldProgress(0);
      interval = setInterval(() => {
        setHoldProgress((prev) => {
          if (prev >= 100) {
            clearInterval(interval);
            triggerSOS();
            return 100;
          }
          return prev + 2; // 3 seconds to activate (100 / 2 = 50 updates * 60ms)
        });
      }, 60);
    } else if (!isHolding) {
      setHoldProgress(0);
    }

    return () => {
      if (interval) clearInterval(interval);
    };
  }, [isHolding, sosStatus]);

  const triggerSOS = () => {
    setSOSStatus("activating");
    setIsHolding(false);
    
    // Simulate sending process
    setTimeout(() => {
      setSOSStatus("sending");
      
      // Send actual notifications to each close family member
      closeFamilyMembers.forEach((member, index) => {
        setTimeout(() => {
          setNotifiedMembers((prev) => [...prev, member.id]);
          
          // Send actual notification to the notification system
          addNotification({
            type: "emergency",
            title: `🚨 EMERGENCY SOS from ${user?.name || 'Family Member'}`,
            message: `${user?.name || 'A family member'} has activated an emergency SOS alert and needs immediate help!`,
            recipientId: member.id,
            actionRequired: true,
          });
          
          // After last member, mark as sent
          if (index === closeFamilyMembers.length - 1) {
            setTimeout(() => {
              setSOSStatus("sent");
              toast.success(`SOS alert sent to ${closeFamilyMembers.length} close family members`);
            }, 500);
          }
        }, (index + 1) * 800);
      });
    }, 1000);
  };

  const cancelSOS = () => {
    setSOSStatus("idle");
    setNotifiedMembers([]);
    setHoldProgress(0);
    toast.success("SOS alert cancelled");
  };

  const resetSOS = () => {
    setSOSStatus("idle");
    setNotifiedMembers([]);
    setHoldProgress(0);
  };

  return (
    <div className="h-full flex flex-col bg-gray-50">
      {/* Header */}
      <div className="bg-white border-b border-gray-200 px-6 py-4">
        <div className="flex items-center gap-2 mb-2">
          <AlertTriangle className="w-6 h-6 text-red-600" />
          <h1 className="text-2xl font-semibold text-gray-900">Emergency SOS</h1>
        </div>
        <p className="text-sm text-gray-500">
          Send an immediate alert to all family members
        </p>
      </div>

      <div className="flex-1 overflow-auto px-6 py-6 space-y-6">
        {/* Status Display */}
        {sosStatus !== "idle" && (
          <Alert className={`
            ${sosStatus === "sent" ? "border-green-500 bg-green-50" : ""}
            ${sosStatus === "failed" ? "border-red-500 bg-red-50" : ""}
            ${sosStatus === "sending" || sosStatus === "activating" ? "border-blue-500 bg-blue-50" : ""}
          `}>
            <div className="flex items-start gap-3">
              {sosStatus === "sent" && <CheckCircle className="h-5 w-5 text-green-600 flex-shrink-0" />}
              {sosStatus === "failed" && <AlertTriangle className="h-5 w-5 text-red-600 flex-shrink-0" />}
              {(sosStatus === "sending" || sosStatus === "activating") && (
                <Loader2 className="h-5 w-5 text-blue-600 animate-spin flex-shrink-0" />
              )}
              <div className="flex-1">
                <AlertTitle className="text-base">
                  {sosStatus === "activating" && "Activating SOS..."}
                  {sosStatus === "sending" && "Sending Alert..."}
                  {sosStatus === "sent" && "SOS Alert Sent!"}
                  {sosStatus === "failed" && "Failed to Send Alert"}
                </AlertTitle>
                <AlertDescription className="text-sm mt-1">
                  {sosStatus === "activating" && "Preparing to send emergency alert"}
                  {sosStatus === "sending" && `Notifying family members (${notifiedMembers.length}/${closeFamilyMembers.length})`}
                  {sosStatus === "sent" && "All family members have been notified of your emergency"}
                  {sosStatus === "failed" && "Please try again or contact emergency services directly"}
                </AlertDescription>
              </div>
            </div>
          </Alert>
        )}

        {/* SOS Activation Button */}
        {sosStatus === "idle" && (
          <Card className="p-8 text-center border-red-200 bg-gradient-to-br from-red-50 to-white">
            <div className="space-y-6">
              <div className="w-32 h-32 mx-auto rounded-full bg-red-600 flex items-center justify-center relative overflow-hidden">
                {isHolding && holdProgress > 0 && (
                  <div
                    className="absolute inset-0 bg-red-700 transition-all duration-75"
                    style={{
                      clipPath: `inset(${100 - holdProgress}% 0 0 0)`,
                    }}
                  />
                )}
                <AlertTriangle className="w-16 h-16 text-white relative z-10" />
              </div>

              <div>
                <h2 className="text-xl font-semibold text-gray-900 mb-2">
                  Send Emergency Alert
                </h2>
                <p className="text-sm text-gray-600">
                  Hold the button for 3 seconds to send SOS
                </p>
              </div>

              <button
                onMouseDown={() => setIsHolding(true)}
                onMouseUp={() => setIsHolding(false)}
                onMouseLeave={() => setIsHolding(false)}
                onTouchStart={() => setIsHolding(true)}
                onTouchEnd={() => setIsHolding(false)}
                className="w-full py-6 bg-red-600 hover:bg-red-700 active:bg-red-800 text-white font-semibold rounded-xl shadow-lg transition-all relative overflow-hidden"
              >
                {isHolding && holdProgress > 0 && (
                  <div
                    className="absolute inset-0 bg-red-700"
                    style={{
                      width: `${holdProgress}%`,
                      transition: "width 0.06s linear",
                    }}
                  />
                )}
                <span className="relative z-10 flex items-center justify-center gap-2">
                  <AlertTriangle className="w-5 h-5" />
                  {isHolding ? "Hold to Confirm..." : "Press and Hold"}
                </span>
              </button>

              {isHolding && (
                <Progress value={holdProgress} className="h-2" />
              )}

              <p className="text-xs text-gray-500">
                This action will immediately notify all close family members with your
                location and a request for help
              </p>
            </div>
          </Card>
        )}

        {/* Cancel/Reset Button */}
        {sosStatus === "sending" && (
          <Button
            variant="outline"
            onClick={cancelSOS}
            className="w-full"
            size="lg"
          >
            Cancel Alert
          </Button>
        )}

        {sosStatus === "sent" && (
          <Button
            variant="outline"
            onClick={resetSOS}
            className="w-full"
            size="lg"
          >
            Dismiss
          </Button>
        )}

        {/* Family Members List */}
        <section>
          <h2 className="text-lg font-semibold text-gray-900 mb-3 flex items-center gap-2">
            <Users className="w-5 h-5" />
            Will be notified
          </h2>
          <div className="space-y-2">
            {closeFamilyMembers.map((member) => {
              const isNotified = notifiedMembers.includes(member.id);
              const isPending =
                sosStatus === "sending" && !notifiedMembers.includes(member.id);

              return (
                <Card
                  key={member.id}
                  className={`p-4 transition-all ${
                    isNotified ? "border-green-200 bg-green-50" : ""
                  } ${isPending ? "border-blue-200 bg-blue-50" : ""}`}
                >
                  <div className="flex items-center gap-4">
                    <img
                      src={member.avatar}
                      alt={member.name}
                      className="w-12 h-12 rounded-full object-cover"
                    />
                    <div className="flex-1 min-w-0">
                      <h3 className="font-semibold text-gray-900">
                        {member.name}
                      </h3>
                      <div className="flex items-center gap-2 text-sm text-gray-600">
                        <Phone className="w-3 h-3" />
                        <span>{member.phone}</span>
                      </div>
                    </div>
                    {isNotified && (
                      <Badge className="bg-green-600 gap-1">
                        <CheckCircle className="w-3 h-3" />
                        Notified
                      </Badge>
                    )}
                    {isPending && (
                      <Badge variant="secondary" className="gap-1">
                        <Loader2 className="w-3 h-3 animate-spin" />
                        Sending
                      </Badge>
                    )}
                  </div>
                </Card>
              );
            })}
          </div>
        </section>

        {/* SOS Details */}
        <section>
          <h2 className="text-lg font-semibold text-gray-900 mb-3">
            What happens when you activate SOS?
          </h2>
          <Card className="p-4">
            <ul className="space-y-3 text-sm text-gray-700">
              <li className="flex gap-3">
                <div className="flex-shrink-0 w-6 h-6 rounded-full bg-red-100 flex items-center justify-center">
                  <span className="text-xs font-semibold text-red-600">1</span>
                </div>
                <div>
                  <strong className="text-gray-900">Urgent Alert Sent</strong>
                  <p className="text-gray-600 mt-0.5">
                    All family members receive an immediate push notification
                  </p>
                </div>
              </li>
              <li className="flex gap-3">
                <div className="flex-shrink-0 w-6 h-6 rounded-full bg-red-100 flex items-center justify-center">
                  <span className="text-xs font-semibold text-red-600">2</span>
                </div>
                <div>
                  <strong className="text-gray-900">Location Shared</strong>
                  <p className="text-gray-600 mt-0.5">
                    Your current location is included in the alert (if enabled)
                  </p>
                </div>
              </li>
              <li className="flex gap-3">
                <div className="flex-shrink-0 w-6 h-6 rounded-full bg-red-100 flex items-center justify-center">
                  <span className="text-xs font-semibold text-red-600">3</span>
                </div>
                <div>
                  <strong className="text-gray-900">Timestamp Recorded</strong>
                  <p className="text-gray-600 mt-0.5">
                    Alert includes when and where it was triggered
                  </p>
                </div>
              </li>
            </ul>
          </Card>
        </section>

        {/* Emergency Services */}
        <section className="pb-6">
          <Alert className="border-amber-300 bg-amber-50">
            <AlertTriangle className="h-4 w-4 text-amber-600" />
            <AlertTitle>Life-threatening emergency?</AlertTitle>
            <AlertDescription className="mt-2">
              <p className="text-sm mb-3">
                In case of immediate danger, call emergency services directly:
              </p>
              <Button variant="default" className="w-full bg-red-600 hover:bg-red-700 gap-2">
                <Phone className="w-4 h-4" />
                Call 911
              </Button>
            </AlertDescription>
          </Alert>
        </section>

        {/* Add Close Family Relationships */}
        <section>
          <p className="text-sm text-gray-600 mb-4">
            Add close family relationships to enable SOS alerts. Only immediate family members (parents, siblings, spouse, children) will receive SOS alerts.
          </p>
          <Button onClick={() => navigate("/family")} variant="outline" className="gap-2">
            <Users className="w-4 h-4" />
            Manage Family Relationships
          </Button>
        </section>
      </div>
    </div>
  );
}