import { useState } from "react";
import { MapPin, Clock, Eye, EyeOff, Navigation, Info } from "lucide-react";
import { Card } from "@/app/components/ui/card";
import { Button } from "@/app/components/ui/button";
import { Switch } from "@/app/components/ui/switch";
import { Badge } from "@/app/components/ui/badge";
import { Alert, AlertDescription } from "@/app/components/ui/alert";
import { toast } from "sonner";
import { openMapsApp, getMapsAppName } from "@/app/utils/maps";
import { LeafletMap } from "@/app/components/LeafletMap";

// Mock data - Swansea locations
const initialFamilyLocations = [
  {
    id: 1,
    name: "Sarah Johnson",
    role: "You",
    avatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=400&fit=crop",
    location: "Home",
    address: "23 Marina Way, Swansea SA1 3XG",
    lastUpdated: "Just now",
    sharing: true,
    sharingUntil: null,
    coordinates: { lat: 51.6214, lng: -3.9436 },
  },
  {
    id: 2,
    name: "Mike Johnson",
    role: "Parent",
    avatar: "https://images.unsplash.com/photo-1622319107576-cca7c8a906f7?w=400&h=400&fit=crop",
    location: "Office",
    address: "Swansea University Bay Campus, Fabian Way, Swansea SA1 8EN",
    lastUpdated: "2 min ago",
    sharing: true,
    sharingUntil: "18:00",
    coordinates: { lat: 51.6097, lng: -3.8771 },
  },
  {
    id: 3,
    name: "Emma Johnson",
    role: "Teen",
    avatar: "https://images.unsplash.com/photo-1652217627250-0dd21428e0f3?w=400&h=400&fit=crop",
    location: null,
    address: null,
    lastUpdated: null,
    sharing: false,
    sharingUntil: null,
    coordinates: null,
  },
  {
    id: 4,
    name: "Mary Smith",
    role: "Grandma",
    avatar: "https://images.unsplash.com/photo-1547199315-ddabe87428ed?w=400&h=400&fit=crop",
    location: "Home",
    address: "15 Mumbles Road, Swansea SA3 4AA",
    lastUpdated: "5 min ago",
    sharing: true,
    sharingUntil: null,
    coordinates: { lat: 51.5723, lng: -3.9812 },
  },
];

export default function Map() {
  const [familyLocations, setFamilyLocations] = useState(initialFamilyLocations);
  const [yourSharing, setYourSharing] = useState(true);
  const [sharingDuration, setSharingDuration] = useState<string | null>(null);

  const toggleLocationSharing = (enabled: boolean) => {
    setYourSharing(enabled);
    setFamilyLocations((prev) =>
      prev.map((member) =>
        member.id === 1 ? { ...member, sharing: enabled } : member
      )
    );
    
    if (enabled) {
      toast.success("Location sharing enabled");
    } else {
      toast.success("Location sharing disabled");
      setSharingDuration(null);
    }
  };

  const setSharingTime = (duration: string) => {
    setSharingDuration(duration);
    toast.success(`Sharing location for ${duration}`);
  };

  const handleNavigate = (member: typeof initialFamilyLocations[0]) => {
    if (member.address) {
      openMapsApp(member.address);
      toast.success(`Opening ${getMapsAppName()} to navigate to ${member.name}`);
    }
  };

  const activeSharing = familyLocations.filter((m) => m.sharing).length;

  return (
    <div className="h-full flex flex-col bg-gray-50">
      {/* Header */}
      <div className="bg-white border-b border-gray-200 px-6 py-4">
        <div className="flex items-center justify-between mb-2">
          <h1 className="text-2xl font-semibold text-gray-900">Location</h1>
          <Badge variant="secondary" className="gap-1">
            <MapPin className="w-3 h-3" />
            {activeSharing} sharing
          </Badge>
        </div>
        <p className="text-sm text-gray-500">
          See where your family members are in real-time
        </p>
      </div>

      <div className="flex-1 overflow-auto">
        {/* Real Interactive Map */}
        <div className="h-80 border-b border-gray-200">
          <LeafletMap locations={familyLocations} />
        </div>

        <div className="px-6 py-6 space-y-6">
          {/* Your Location Sharing */}
          <section>
            <Card className="p-4">
              <div className="flex items-start justify-between gap-4">
                <div className="flex-1">
                  <div className="flex items-center gap-2 mb-2">
                    <h3 className="font-semibold text-gray-900">Your Location</h3>
                    {yourSharing ? (
                      <Badge variant="default" className="bg-green-600 text-xs">
                        <Eye className="w-3 h-3 mr-1" />
                        Sharing
                      </Badge>
                    ) : (
                      <Badge variant="secondary" className="text-xs">
                        <EyeOff className="w-3 h-3 mr-1" />
                        Private
                      </Badge>
                    )}
                  </div>
                  <p className="text-sm text-gray-600 mb-3">
                    {yourSharing
                      ? "Your family can see your location"
                      : "Turn on to share your location"}
                  </p>
                  {yourSharing && !sharingDuration && (
                    <div className="flex gap-2 flex-wrap">
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => setSharingTime("1 hour")}
                        className="text-xs"
                      >
                        <Clock className="w-3 h-3 mr-1" />
                        1 hour
                      </Button>
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => setSharingTime("4 hours")}
                        className="text-xs"
                      >
                        <Clock className="w-3 h-3 mr-1" />
                        4 hours
                      </Button>
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => setSharingTime("Until end of day")}
                        className="text-xs"
                      >
                        <Clock className="w-3 h-3 mr-1" />
                        All day
                      </Button>
                    </div>
                  )}
                  {sharingDuration && (
                    <p className="text-xs text-gray-500">
                      Sharing for: {sharingDuration}
                    </p>
                  )}
                </div>
                <Switch
                  checked={yourSharing}
                  onCheckedChange={toggleLocationSharing}
                />
              </div>
            </Card>
          </section>

          {/* Privacy Notice */}
          <Alert>
            <Info className="h-4 w-4" />
            <AlertDescription className="text-sm">
              <strong>Privacy first:</strong> Location sharing is optional and
              time-limited. You control when and how long you share.
            </AlertDescription>
          </Alert>

          {/* Family Locations */}
          <section>
            <h2 className="text-lg font-semibold text-gray-900 mb-3">
              Family Members
            </h2>
            <div className="space-y-3">
              {familyLocations.map((member) => (
                <Card
                  key={member.id}
                  className={`p-4 ${
                    member.sharing
                      ? "border-blue-200 bg-blue-50/30"
                      : "border-gray-200"
                  }`}
                >
                  <div className="flex items-start gap-4">
                    <div className="relative">
                      <img
                        src={member.avatar}
                        alt={member.name}
                        className="w-12 h-12 rounded-full object-cover"
                      />
                      {member.sharing && (
                        <div className="absolute -bottom-1 -right-1 w-5 h-5 bg-green-500 rounded-full border-2 border-white flex items-center justify-center">
                          <MapPin className="w-3 h-3 text-white" />
                        </div>
                      )}
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 mb-1">
                        <h3 className="font-semibold text-gray-900">
                          {member.name}
                        </h3>
                        {member.role === "You" && (
                          <Badge variant="secondary" className="text-xs">
                            You
                          </Badge>
                        )}
                      </div>

                      {member.sharing ? (
                        <>
                          <div className="flex items-center gap-2 text-sm text-gray-700 mb-1">
                            <Navigation className="w-4 h-4 text-blue-600" />
                            <span className="font-medium">{member.location}</span>
                          </div>
                          <p className="text-xs text-gray-500 mb-2">
                            {member.address}
                          </p>
                          <div className="flex items-center gap-4 text-xs text-gray-500">
                            <span>Updated: {member.lastUpdated}</span>
                            {member.sharingUntil && (
                              <span>Until: {member.sharingUntil}</span>
                            )}
                          </div>
                        </>
                      ) : (
                        <div className="flex items-center gap-2 text-sm text-gray-500">
                          <EyeOff className="w-4 h-4" />
                          <span>Location sharing disabled</span>
                        </div>
                      )}
                    </div>
                    {member.sharing && member.id !== 1 && (
                      <Button
                        size="sm"
                        variant="outline"
                        className="flex-shrink-0"
                        onClick={() => handleNavigate(member)}
                      >
                        <Navigation className="w-4 h-4 mr-1" />
                        Navigate
                      </Button>
                    )}
                  </div>
                </Card>
              ))}
            </div>
          </section>

          {/* Location Permissions Info */}
          <section className="pb-6">
            <Card className="p-4 bg-gray-50 border-gray-200">
              <h3 className="font-medium text-gray-900 mb-2">
                About Location Sharing
              </h3>
              <ul className="space-y-1 text-sm text-gray-600">
                <li className="flex gap-2">
                  <span className="text-gray-400">•</span>
                  <span>Sharing is always optional and consent-based</span>
                </li>
                <li className="flex gap-2">
                  <span className="text-gray-400">•</span>
                  <span>Set time limits to auto-disable sharing</span>
                </li>
                <li className="flex gap-2">
                  <span className="text-gray-400">•</span>
                  <span>Turn off anytime from your settings</span>
                </li>
                <li className="flex gap-2">
                  <span className="text-gray-400">•</span>
                  <span>Location data is only visible to family members</span>
                </li>
              </ul>
            </Card>
          </section>
        </div>
      </div>
    </div>
  );
}