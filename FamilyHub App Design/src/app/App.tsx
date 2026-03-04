import { RouterProvider } from "react-router";
import { router } from "@/app/routes";
import { Toaster } from "@/app/components/ui/sonner";
import { AuthProvider } from "@/app/contexts/AuthContext";
import { NotificationProvider } from "@/app/contexts/NotificationContext";
import { EventProvider } from "@/app/contexts/EventContext";
import { RelationshipProvider } from "@/app/contexts/RelationshipContext";
import { ShoppingProvider } from "@/app/contexts/ShoppingContext";

export default function App() {
  return (
    <AuthProvider>
      <NotificationProvider>
        <RelationshipProvider>
          <EventProvider>
            <ShoppingProvider>
              <RouterProvider router={router} />
              <Toaster />
            </ShoppingProvider>
          </EventProvider>
        </RelationshipProvider>
      </NotificationProvider>
    </AuthProvider>
  );
}