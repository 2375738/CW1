import { Outlet, useLocation, useNavigate, Navigate } from "react-router";
import { Home as HomeIcon, Calendar, ListChecks, MapPin, User } from "lucide-react";
import { useAuth } from "@/app/contexts/AuthContext";

export default function Root() {
  const location = useLocation();
  const navigate = useNavigate();
  const { isAuthenticated } = useAuth();

  // Redirect to login if not authenticated
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  const tabs = [
    { path: "/", icon: HomeIcon, label: "Home" },
    { path: "/calendar", icon: Calendar, label: "Calendar" },
    { path: "/tasks", icon: ListChecks, label: "Tasks" },
    { path: "/map", icon: MapPin, label: "Map" },
    { path: "/profile", icon: User, label: "Profile" },
  ];

  const isActive = (path: string) => {
    if (path === "/") return location.pathname === "/";
    return location.pathname.startsWith(path);
  };

  return (
    <div className="h-screen w-full flex flex-col bg-gray-50 max-w-md mx-auto shadow-2xl overflow-hidden">
      {/* Main Content */}
      <main className="flex-1 overflow-auto">
        <Outlet />
      </main>

      {/* Bottom Tab Navigation */}
      <nav className="bg-white border-t border-gray-200 safe-area-inset-bottom">
        <div className="flex items-center justify-around px-2 py-2">
          {tabs.map((tab) => {
            const Icon = tab.icon;
            const active = isActive(tab.path);
            
            return (
              <button
                key={tab.path}
                onClick={() => navigate(tab.path)}
                className={`flex flex-col items-center justify-center gap-1 py-1 px-3 rounded-lg transition-colors min-w-[60px] ${
                  active
                    ? "text-blue-600"
                    : "text-gray-600 hover:text-gray-900"
                }`}
              >
                <Icon className={`w-6 h-6 ${active ? "fill-blue-100" : ""}`} />
                <span className="text-xs font-medium">{tab.label}</span>
              </button>
            );
          })}
        </div>
      </nav>
    </div>
  );
}