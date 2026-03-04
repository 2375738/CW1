import { createBrowserRouter, Navigate } from "react-router";
import Root from "@/app/Root";
import Login from "@/app/screens/Login";
import Home from "@/app/screens/Home";
import Calendar from "@/app/screens/Calendar";
import Tasks from "@/app/screens/Tasks";
import Map from "@/app/screens/Map";
import Profile from "@/app/screens/Profile";
import Family from "@/app/screens/Family";
import SOS from "@/app/screens/SOS";
import NotificationSettings from "@/app/screens/NotificationSettings";
import PrivacySecurity from "@/app/screens/PrivacySecurity";

export const router = createBrowserRouter([
  {
    path: "/login",
    Component: Login,
  },
  {
    path: "/",
    Component: Root,
    children: [
      { index: true, Component: Home },
      { path: "calendar", Component: Calendar },
      { path: "tasks", Component: Tasks },
      { path: "map", Component: Map },
      { path: "profile", Component: Profile },
      { path: "family", Component: Family },
      { path: "sos", Component: SOS },
      { path: "notifications", Component: NotificationSettings },
      { path: "privacy", Component: PrivacySecurity },
    ],
  },
]);