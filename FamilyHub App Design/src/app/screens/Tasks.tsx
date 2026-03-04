import { useState } from "react";
import { Plus, Check, Trash2, User, Calendar as CalendarIcon, ShoppingCart } from "lucide-react";
import { Card } from "@/app/components/ui/card";
import { Button } from "@/app/components/ui/button";
import { Badge } from "@/app/components/ui/badge";
import { Checkbox } from "@/app/components/ui/checkbox";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/app/components/ui/tabs";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
  DialogFooter,
} from "@/app/components/ui/dialog";
import { Input } from "@/app/components/ui/input";
import { Label } from "@/app/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/app/components/ui/select";
import { useAuth } from "@/app/contexts/AuthContext";
import { useNotifications } from "@/app/contexts/NotificationContext";
import { toast } from "sonner";
import ShoppingTab from "@/app/components/ShoppingTab";
import { useSearchParams } from "react-router";

// Mock data
const initialTasks = [
  {
    id: 1,
    title: "Take out bins",
    assignedTo: "Emma Johnson",
    dueDate: "2026-01-27",
    completed: false,
    priority: "high",
    category: "chores" as "chores" | "shopping",
  },
  {
    id: 2,
    title: "Vacuum living room",
    assignedTo: "Mike Johnson",
    dueDate: "2026-01-28",
    completed: false,
    priority: "medium",
    category: "chores" as "chores" | "shopping",
  },
  {
    id: 3,
    title: "Water plants",
    assignedTo: "Sarah Johnson",
    dueDate: "2026-01-27",
    completed: true,
    priority: "low",
    category: "chores" as "chores" | "shopping",
  },
  {
    id: 4,
    title: "Clean kitchen",
    assignedTo: "Emma Johnson",
    dueDate: "2026-01-29",
    completed: false,
    priority: "high",
    category: "chores" as "chores" | "shopping",
  },
  {
    id: 5,
    title: "Milk",
    assignedTo: "Sarah Johnson",
    dueDate: "",
    completed: false,
    priority: "medium",
    category: "shopping" as "chores" | "shopping",
  },
  {
    id: 6,
    title: "Bread",
    assignedTo: "Mike Johnson",
    dueDate: "",
    completed: false,
    priority: "medium",
    category: "shopping" as "chores" | "shopping",
  },
  {
    id: 7,
    title: "Rice",
    assignedTo: "Sarah Johnson",
    dueDate: "",
    completed: false,
    priority: "medium",
    category: "shopping" as "chores" | "shopping",
  },
  {
    id: 8,
    title: "Detergent",
    assignedTo: "Emma Johnson",
    dueDate: "",
    completed: false,
    priority: "medium",
    category: "shopping" as "chores" | "shopping",
  },
  {
    id: 9,
    title: "Apples",
    assignedTo: "Sarah Johnson",
    dueDate: "",
    completed: true,
    priority: "medium",
    category: "shopping" as "chores" | "shopping",
  },
  {
    id: 10,
    title: "Chicken",
    assignedTo: "Mike Johnson",
    dueDate: "",
    completed: false,
    priority: "medium",
    category: "shopping" as "chores" | "shopping",
  },
];

const familyMembers = [
  { id: 1, name: "Sarah Johnson" },
  { id: 2, name: "Mike Johnson" },
  { id: 3, name: "Emma Johnson" },
  { id: 4, name: "Mary Smith" },
];

export default function Tasks() {
  const { user } = useAuth();
  const { addNotification } = useNotifications();
  const [searchParams] = useSearchParams();
  const [tasks, setTasks] = useState(initialTasks);
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  
  // Check if we should show shopping tab from URL params
  const tabFromUrl = searchParams.get("tab");
  const [activeTab, setActiveTab] = useState<"chores" | "shopping">(
    tabFromUrl === "shopping" ? "shopping" : "chores"
  );
  
  const [newTask, setNewTask] = useState({
    title: "",
    assignedTo: "",
    dueDate: "",
    category: "chores" as "chores" | "shopping",
  });

  const toggleTask = (id: number) => {
    setTasks((prev) =>
      prev.map((task) => {
        if (task.id === id) {
          const updated = { ...task, completed: !task.completed };
          toast.success(
            updated.completed
              ? `"${task.title}" marked as complete! 🎉`
              : `"${task.title}" reopened`
          );
          return updated;
        }
        return task;
      })
    );
  };

  const deleteTask = (id: number) => {
    const task = tasks.find((c) => c.id === id);
    setTasks((prev) => prev.filter((c) => c.id !== id));
    toast.success(`"${task?.title}" deleted`);
  };

  const handleAddTask = () => {
    if (newTask.title && newTask.assignedTo) {
      const newId = Date.now();
      setTasks((prev) => [
        ...prev,
        {
          id: newId,
          ...newTask,
          completed: false,
        },
      ]);
      setNewTask({
        title: "",
        assignedTo: "",
        dueDate: "",
        category: "chores" as "chores" | "shopping",
      });
      setIsDialogOpen(false);
      toast.success("Task added successfully!");
    }
  };

  const getPriorityColor = (priority: string) => {
    switch (priority) {
      case "high":
        return "bg-red-100 text-red-700 border-red-200";
      case "medium":
        return "bg-yellow-100 text-yellow-700 border-yellow-200";
      case "low":
        return "bg-green-100 text-green-700 border-green-200";
      default:
        return "bg-gray-100 text-gray-700 border-gray-200";
    }
  };

  const formatDueDate = (dateStr: string) => {
    const date = new Date(dateStr);
    const today = new Date("2026-01-27");
    const tomorrow = new Date("2026-01-28");

    if (date.toDateString() === today.toDateString()) return "Today";
    if (date.toDateString() === tomorrow.toDateString()) return "Tomorrow";
    return date.toLocaleDateString("en-US", { month: "short", day: "numeric" });
  };

  return (
    <div className="h-full flex flex-col bg-gray-50">
      {/* Header */}
      <div className="bg-white border-b border-gray-200 px-6 py-4">
        <h1 className="text-2xl font-semibold text-gray-900 mb-4">Tasks</h1>
      </div>

      {/* Tabs */}
      <Tabs value={activeTab} onValueChange={(v) => setActiveTab(v as "chores" | "shopping")} className="flex-1 flex flex-col">
        <div className="bg-white border-b border-gray-200 px-6">
          <TabsList className="w-full">
            <TabsTrigger value="chores" className="flex-1">
              Chores
            </TabsTrigger>
            <TabsTrigger value="shopping" className="flex-1">
              <ShoppingCart className="w-4 h-4 mr-2" />
              Shopping
            </TabsTrigger>
          </TabsList>
        </div>

        {/* Chores Tab */}
        <TabsContent value="chores" className="flex-1 overflow-auto px-6 py-6 mt-0">
          <div className="flex items-center justify-between mb-4">
            <p className="text-sm text-gray-600">
              {tasks.filter((c) => !c.completed && c.category === "chores").length} pending tasks
            </p>
            <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
              <DialogTrigger asChild>
                <Button size="sm" className="gap-2">
                  <Plus className="w-4 h-4" />
                  Add Chore
                </Button>
              </DialogTrigger>
              <DialogContent className="max-w-sm">
                <DialogHeader>
                  <DialogTitle>New Chore</DialogTitle>
                </DialogHeader>
                <div className="space-y-4 py-4">
                  <div className="space-y-2">
                    <Label htmlFor="chore-title">Task</Label>
                    <Input
                      id="chore-title"
                      placeholder="e.g., Take out bins"
                      value={newTask.title}
                      onChange={(e) => setNewTask({ ...newTask, title: e.target.value })}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="assign">Assign To</Label>
                    <Select
                      value={newTask.assignedTo}
                      onValueChange={(value) =>
                        setNewTask({ ...newTask, assignedTo: value })
                      }
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="Select family member" />
                      </SelectTrigger>
                      <SelectContent>
                        {familyMembers.map((member) => (
                          <SelectItem key={member.id} value={member.name}>
                            {member.name}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="grid grid-cols-2 gap-3">
                    <div className="space-y-2">
                      <Label htmlFor="due-date">Due Date</Label>
                      <Input
                        id="due-date"
                        type="date"
                        value={newTask.dueDate}
                        onChange={(e) =>
                          setNewTask({ ...newTask, dueDate: e.target.value })
                        }
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="priority">Priority</Label>
                      <Select
                        value={newTask.priority}
                        onValueChange={(value) =>
                          setNewTask({ ...newTask, priority: value })
                        }
                      >
                        <SelectTrigger>
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="high">High</SelectItem>
                          <SelectItem value="medium">Medium</SelectItem>
                          <SelectItem value="low">Low</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                  </div>
                </div>
                <DialogFooter>
                  <Button variant="outline" onClick={() => setIsDialogOpen(false)}>
                    Cancel
                  </Button>
                  <Button onClick={handleAddTask}>Add Chore</Button>
                </DialogFooter>
              </DialogContent>
            </Dialog>
          </div>

          <div className="space-y-3">
            {tasks
              .filter((task) => task.category === "chores")
              .map((task) => (
                <Card
                  key={task.id}
                  className={`p-4 transition-all ${
                    task.completed ? "opacity-60 border-gray-200" : "hover:border-gray-300"
                  }`}
                >
                  <div className="flex items-start gap-3">
                    <button
                      onClick={() => toggleTask(task.id)}
                      className={`mt-0.5 w-6 h-6 rounded-md border-2 flex items-center justify-center flex-shrink-0 transition-colors ${
                        task.completed
                          ? "bg-green-600 border-green-600"
                          : "border-gray-300 hover:border-green-600"
                      }`}
                    >
                      {task.completed && <Check className="w-4 h-4 text-white" />}
                    </button>
                    <div className="flex-1 min-w-0">
                      <h3
                        className={`font-medium ${
                          task.completed
                            ? "line-through text-gray-500"
                            : "text-gray-900"
                        }`}
                      >
                        {task.title}
                      </h3>
                      <div className="flex items-center gap-2 mt-2 flex-wrap">
                        <div className="flex items-center gap-1 text-xs text-gray-600">
                          <User className="w-3 h-3" />
                          <span>{task.assignedTo.split(" ")[0]}</span>
                        </div>
                        <div className="flex items-center gap-1 text-xs text-gray-600">
                          <CalendarIcon className="w-3 h-3" />
                          <span>{formatDueDate(task.dueDate)}</span>
                        </div>
                        <Badge
                          variant="outline"
                          className={`text-xs ${getPriorityColor(task.priority)}`}
                        >
                          {task.priority}
                        </Badge>
                      </div>
                    </div>
                    <button
                      onClick={() => deleteTask(task.id)}
                      className="p-1 rounded hover:bg-red-50 transition-colors flex-shrink-0"
                    >
                      <Trash2 className="w-4 h-4 text-red-600" />
                    </button>
                  </div>
                </Card>
              ))}
          </div>
        </TabsContent>

        {/* Shopping Tab */}
        <TabsContent value="shopping" className="flex-1 flex flex-col mt-0">
          <ShoppingTab />
        </TabsContent>
      </Tabs>
    </div>
  );
}