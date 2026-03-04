import { useState, useEffect } from "react";
import { Plus, ChevronRight, ArrowLeft, Trash2, UserCircle, Calendar as CalendarIcon, Edit2, MoreVertical } from "lucide-react";
import { Card } from "@/app/components/ui/card";
import { Button } from "@/app/components/ui/button";
import { Badge } from "@/app/components/ui/badge";
import { Checkbox } from "@/app/components/ui/checkbox";
import { Input } from "@/app/components/ui/input";
import { Label } from "@/app/components/ui/label";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/app/components/ui/dialog";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/app/components/ui/select";
import { toast } from "sonner";
import { useAuth } from "@/app/contexts/AuthContext";
import { useNotifications } from "@/app/contexts/NotificationContext";
import { useShopping, type ShoppingItem, type ShoppingTask } from "@/app/contexts/ShoppingContext";

const familyMembers = [
  { id: 1, name: "Sarah Johnson" },
  { id: 2, name: "Mike Johnson" },
  { id: 3, name: "Emma Johnson" },
  { id: 4, name: "Mary Smith" },
];

export default function ShoppingTab() {
  const { user } = useAuth();
  const { addNotification } = useNotifications();
  const { tasks, acceptTask, toggleItemPurchased, reassignItem, addTask, deleteTask, updateItemNote, updateTask } = useShopping();

  const [selectedTask, setSelectedTask] = useState<ShoppingTask | null>(null);
  const [showCreateDialog, setShowCreateDialog] = useState(false);
  const [showEditDialog, setShowEditDialog] = useState(false);
  const [showDeleteDialog, setShowDeleteDialog] = useState(false);
  const [showReassignDialog, setShowReassignDialog] = useState(false);
  const [itemToReassign, setItemToReassign] = useState<ShoppingItem | null>(null);
  const [newTaskTitle, setNewTaskTitle] = useState("");
  const [newTaskAssignee, setNewTaskAssignee] = useState("");
  const [newTaskDate, setNewTaskDate] = useState("2026-01-29");
  const [newTaskItems, setNewTaskItems] = useState<string[]>([]);
  const [newItemInput, setNewItemInput] = useState("");
  const [reassignTo, setReassignTo] = useState("");
  const [editingNoteId, setEditingNoteId] = useState<number | null>(null);
  const [noteText, setNoteText] = useState("");

  // Sync selectedTask with tasks from context
  useEffect(() => {
    if (selectedTask) {
      const updatedTask = tasks.find((t) => t.id === selectedTask.id);
      if (updatedTask) {
        setSelectedTask(updatedTask);
      } else {
        // Task was deleted
        setSelectedTask(null);
      }
    }
  }, [tasks]);

  const formatDate = (dateStr: string) => {
    const date = new Date(dateStr);
    const today = new Date("2026-01-28");
    const tomorrow = new Date("2026-01-29");
    
    if (date.toDateString() === today.toDateString()) return "Today";
    if (date.toDateString() === tomorrow.toDateString()) return "Tomorrow";
    return date.toLocaleDateString("en-US", { month: "short", day: "numeric", weekday: "short" });
  };

  const handleReassignItem = () => {
    if (!itemToReassign || !reassignTo || !selectedTask) return;

    reassignItem(selectedTask.id, itemToReassign.id, reassignTo);

    // Send notification
    if (reassignTo !== user?.name) {
      addNotification({
        type: "task_assigned",
        title: "Shopping Item Reassigned",
        message: `${user?.name} reassigned "${itemToReassign.name}" to you`,
      });
    }

    toast.success(`"${itemToReassign.name}" reassigned to ${reassignTo}. New task created for them.`);
    setShowReassignDialog(false);
    setItemToReassign(null);
    setReassignTo("");
    
    // Close the detail view if no items left
    const updatedTask = tasks.find((t) => t.id === selectedTask.id);
    if (!updatedTask || updatedTask.items.filter((i) => i.id !== itemToReassign.id).length === 0) {
      setSelectedTask(null);
    } else {
      // Update selected task to reflect removal
      setSelectedTask({
        ...selectedTask,
        items: selectedTask.items.filter((item) => item.id !== itemToReassign.id),
      });
    }
  };

  const handleCreateTask = () => {
    if (!newTaskTitle || !newTaskAssignee || newTaskItems.length === 0) {
      toast.error("Please fill in all fields and add at least one item");
      return;
    }

    const newTask = {
      title: newTaskTitle,
      assignedTo: newTaskAssignee,
      assignedBy: user?.name || "You",
      dueDate: newTaskDate,
      items: newTaskItems.map((item, index) => ({
        id: Date.now() + index,
        name: item,
        purchased: false,
      })),
    };

    addTask(newTask);

    // Send notification if assigning to someone else
    if (newTaskAssignee !== user?.name) {
      addNotification({
        type: "task_assigned",
        title: "Shopping Task Assigned",
        message: `${user?.name} assigned you "${newTaskTitle}" with ${newTaskItems.length} items for ${formatDate(newTaskDate)}`,
      });
    }

    toast.success(`Shopping task "${newTaskTitle}" created!`);
    setShowCreateDialog(false);
    setNewTaskTitle("");
    setNewTaskAssignee("");
    setNewTaskDate("2026-01-29");
    setNewTaskItems([]);
  };

  const handleAddItemToNewTask = () => {
    if (newItemInput.trim()) {
      setNewTaskItems((prev) => [...prev, newItemInput.trim()]);
      setNewItemInput("");
    }
  };

  const handleRemoveItemFromNewTask = (index: number) => {
    setNewTaskItems((prev) => prev.filter((_, i) => i !== index));
  };

  const handleAcceptTask = (taskId: number) => {
    acceptTask(taskId);
    toast.success("Shopping task accepted!");
  };

  const handleToggleItem = (taskId: number, itemId: number) => {
    toggleItemPurchased(taskId, itemId, user?.name || "Unknown");
    // The useEffect will automatically update selectedTask
  };

  const handleDeleteTask = () => {
    if (!selectedTask) return;
    deleteTask(selectedTask.id);
    toast.success("Shopping task deleted");
    setShowDeleteDialog(false);
    setSelectedTask(null);
  };

  const handleEditTask = () => {
    if (!selectedTask) return;
    setNewTaskTitle(selectedTask.title);
    setNewTaskAssignee(selectedTask.assignedTo);
    setNewTaskDate(selectedTask.dueDate);
    setNewTaskItems(selectedTask.items.map((item) => item.name));
    setShowEditDialog(true);
  };

  const handleSaveEditTask = () => {
    if (!selectedTask || !newTaskTitle || !newTaskAssignee || newTaskItems.length === 0) {
      toast.error("Please fill in all fields and add at least one item");
      return;
    }

    const updatedTask = {
      title: newTaskTitle,
      assignedTo: newTaskAssignee,
      assignedBy: selectedTask.assignedBy,
      dueDate: newTaskDate,
      items: newTaskItems.map((itemName, index) => {
        const existingItem = selectedTask.items.find((item) => item.name === itemName);
        return existingItem || {
          id: Date.now() + index,
          name: itemName,
          purchased: false,
        };
      }),
    };

    updateTask(selectedTask.id, updatedTask);
    toast.success("Shopping task updated!");
    setShowEditDialog(false);
    setNewTaskTitle("");
    setNewTaskAssignee("");
    setNewTaskDate("2026-01-29");
    setNewTaskItems([]);
  };

  const myTasks = tasks.filter((task) => task.assignedTo === user?.name);
  const otherTasks = tasks.filter((task) => task.assignedTo !== user?.name);

  // If viewing a task
  if (selectedTask) {
    const purchasedCount = selectedTask.items.filter((item) => item.purchased).length;
    const totalCount = selectedTask.items.length;

    return (
      <div className="flex-1 overflow-auto">
        {/* Reassign Dialog */}
        <Dialog open={showReassignDialog} onOpenChange={setShowReassignDialog}>
          <DialogContent className="max-w-sm">
            <DialogHeader>
              <DialogTitle>Reassign Item</DialogTitle>
            </DialogHeader>
            <div className="py-4">
              <p className="text-sm text-gray-600 mb-4">
                Can't buy "{itemToReassign?.name}"? Reassign it to another family member.
              </p>
              <div className="space-y-2">
                <Label>Reassign To</Label>
                <Select value={reassignTo} onValueChange={setReassignTo}>
                  <SelectTrigger>
                    <SelectValue placeholder="Select family member" />
                  </SelectTrigger>
                  <SelectContent>
                    {familyMembers
                      .filter((m) => m.name !== selectedTask.assignedTo)
                      .map((member) => (
                        <SelectItem key={member.id} value={member.name}>
                          {member.name}
                        </SelectItem>
                      ))}
                  </SelectContent>
                </Select>
              </div>
            </div>
            <DialogFooter>
              <Button variant="outline" onClick={() => setShowReassignDialog(false)}>
                Cancel
              </Button>
              <Button onClick={handleReassignItem} disabled={!reassignTo}>
                Reassign
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>

        {/* Edit Task Dialog */}
        <Dialog open={showEditDialog} onOpenChange={setShowEditDialog}>
          <DialogContent className="max-w-md">
            <DialogHeader>
              <DialogTitle>Edit Shopping Task</DialogTitle>
            </DialogHeader>
            <div className="space-y-4 py-4">
              <div className="space-y-2">
                <Label>Task Name</Label>
                <Input
                  placeholder="e.g., Weekend Groceries"
                  value={newTaskTitle}
                  onChange={(e) => setNewTaskTitle(e.target.value)}
                />
              </div>
              <div className="space-y-2">
                <Label>Assign To</Label>
                <Select value={newTaskAssignee} onValueChange={setNewTaskAssignee}>
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
              <div className="space-y-2">
                <Label>Shopping Date</Label>
                <Input
                  type="date"
                  value={newTaskDate}
                  onChange={(e) => setNewTaskDate(e.target.value)}
                />
              </div>
              <div className="space-y-2">
                <Label>Items to Buy</Label>
                <div className="flex gap-2">
                  <Input
                    placeholder="Add item..."
                    value={newItemInput}
                    onChange={(e) => setNewItemInput(e.target.value)}
                    onKeyDown={(e) => e.key === "Enter" && handleAddItemToNewTask()}
                  />
                  <Button onClick={handleAddItemToNewTask} size="sm">
                    <Plus className="w-4 h-4" />
                  </Button>
                </div>
                <div className="space-y-1 max-h-40 overflow-auto">
                  {newTaskItems.map((item, index) => (
                    <div
                      key={index}
                      className="flex items-center justify-between bg-gray-50 rounded px-3 py-2"
                    >
                      <span className="text-sm">{item}</span>
                      <button
                        onClick={() => handleRemoveItemFromNewTask(index)}
                        className="text-red-600 hover:text-red-700"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  ))}
                </div>
                {newTaskItems.length === 0 && (
                  <p className="text-xs text-gray-500">No items added yet</p>
                )}
              </div>
            </div>
            <DialogFooter>
              <Button variant="outline" onClick={() => setShowEditDialog(false)}>
                Cancel
              </Button>
              <Button onClick={handleSaveEditTask}>Save Changes</Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>

        {/* Delete Confirmation Dialog */}
        <Dialog open={showDeleteDialog} onOpenChange={setShowDeleteDialog}>
          <DialogContent className="max-w-sm">
            <DialogHeader>
              <DialogTitle>Delete Shopping Task?</DialogTitle>
            </DialogHeader>
            <p className="text-sm text-gray-600 py-4">
              Are you sure you want to delete "{selectedTask.title}"? This action cannot be undone.
            </p>
            <DialogFooter>
              <Button variant="outline" onClick={() => setShowDeleteDialog(false)}>
                Cancel
              </Button>
              <Button variant="destructive" onClick={handleDeleteTask}>
                Delete Task
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>

        {/* Header */}
        <div className="bg-white border-b border-gray-200 px-6 py-4 sticky top-0 z-10">
          <button
            onClick={() => setSelectedTask(null)}
            className="flex items-center gap-2 text-blue-600 hover:text-blue-700 mb-2"
          >
            <ArrowLeft className="w-4 h-4" />
            <span className="text-sm font-medium">Back to Shopping Tasks</span>
          </button>
          <div className="flex items-center justify-between">
            <h1 className="text-2xl font-semibold text-gray-900">{selectedTask.title}</h1>
            <div className="flex gap-2">
              <Button variant="outline" size="sm" onClick={handleEditTask}>
                <Edit2 className="w-4 h-4 mr-1" />
                Edit
              </Button>
              <Button variant="outline" size="sm" onClick={() => setShowDeleteDialog(true)}>
                <Trash2 className="w-4 h-4 mr-1" />
                Delete
              </Button>
            </div>
          </div>
          <div className="flex items-center gap-3 mt-2 flex-wrap">
            <Badge variant="secondary" className="text-xs">
              <UserCircle className="w-3 h-3 mr-1" />
              {selectedTask.assignedTo}
            </Badge>
            <Badge variant="secondary" className="text-xs">
              <CalendarIcon className="w-3 h-3 mr-1" />
              {formatDate(selectedTask.dueDate)}
            </Badge>
            {selectedTask.completed && (
              <Badge className="bg-green-600 text-xs">Completed</Badge>
            )}
          </div>
        </div>

        {/* Accept Task Banner */}
        {!selectedTask.accepted && selectedTask.assignedTo === user?.name && (
          <div className="mx-6 mt-4">
            <Card className="p-4 bg-gradient-to-r from-amber-50 to-yellow-50 border-amber-200">
              <div className="flex items-center justify-between">
                <div>
                  <h3 className="font-semibold text-gray-900">New Shopping Task</h3>
                  <p className="text-sm text-gray-600 mt-1">
                    {selectedTask.assignedBy} assigned this shopping task to you
                  </p>
                </div>
                <Button
                  onClick={() => handleAcceptTask(selectedTask.id)}
                  className="bg-amber-600 hover:bg-amber-700"
                >
                  Accept
                </Button>
              </div>
            </Card>
          </div>
        )}

        {/* Progress */}
        <div className="px-6 py-4">
          <div className="flex items-center justify-between mb-2">
            <span className="text-sm font-medium text-gray-700">
              Progress: {purchasedCount}/{totalCount}
            </span>
            <span className="text-sm text-gray-500">
              {Math.round((purchasedCount / totalCount) * 100)}%
            </span>
          </div>
          <div className="w-full bg-gray-200 rounded-full h-2">
            <div
              className="bg-green-600 h-2 rounded-full transition-all"
              style={{ width: `${(purchasedCount / totalCount) * 100}%` }}
            />
          </div>
        </div>

        {/* Items List */}
        <div className="px-6 pb-6 space-y-2">
          {selectedTask.items.map((item) => (
            <Card
              key={item.id}
              className={`p-4 ${item.purchased ? "bg-gray-50 opacity-60" : ""}`}
            >
              <div className="space-y-1">
                <div className="flex items-center gap-3">
                  <Checkbox
                    checked={item.purchased}
                    onCheckedChange={() => handleToggleItem(selectedTask.id, item.id)}
                    id={`item-${item.id}`}
                  />
                  <label
                    htmlFor={`item-${item.id}`}
                    className={`flex-1 cursor-pointer ${
                      item.purchased ? "line-through text-gray-500" : "text-gray-900"
                    }`}
                  >
                    {item.name}
                    {item.assignedTo && (
                      <Badge variant="secondary" className="ml-2 text-xs">
                        {item.assignedTo}
                      </Badge>
                    )}
                  </label>
                  {!item.purchased && (
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => {
                        setItemToReassign(item);
                        setShowReassignDialog(true);
                      }}
                    >
                      Reassign
                    </Button>
                  )}
                </div>
                {item.boughtBy && (
                  <div className="pl-9">
                    <p className="text-xs text-gray-500">
                      ✓ Bought by {item.boughtBy}
                    </p>
                  </div>
                )}
              </div>
            </Card>
          ))}
        </div>
      </div>
    );
  }

  // Main list view
  return (
    <div className="flex-1 overflow-auto">
      {/* Create Task Dialog */}
      <Dialog open={showCreateDialog} onOpenChange={setShowCreateDialog}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>Create Shopping Task</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label>Task Name</Label>
              <Input
                placeholder="e.g., Weekend Groceries"
                value={newTaskTitle}
                onChange={(e) => setNewTaskTitle(e.target.value)}
              />
            </div>
            <div className="space-y-2">
              <Label>Assign To</Label>
              <Select value={newTaskAssignee} onValueChange={setNewTaskAssignee}>
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
            <div className="space-y-2">
              <Label>Shopping Date</Label>
              <Input
                type="date"
                value={newTaskDate}
                onChange={(e) => setNewTaskDate(e.target.value)}
              />
            </div>
            <div className="space-y-2">
              <Label>Items to Buy</Label>
              <div className="flex gap-2">
                <Input
                  placeholder="Add item..."
                  value={newItemInput}
                  onChange={(e) => setNewItemInput(e.target.value)}
                  onKeyDown={(e) => e.key === "Enter" && handleAddItemToNewTask()}
                />
                <Button onClick={handleAddItemToNewTask} size="sm">
                  <Plus className="w-4 h-4" />
                </Button>
              </div>
              <div className="space-y-1 max-h-40 overflow-auto">
                {newTaskItems.map((item, index) => (
                  <div
                    key={index}
                    className="flex items-center justify-between bg-gray-50 rounded px-3 py-2"
                  >
                    <span className="text-sm">{item}</span>
                    <button
                      onClick={() => handleRemoveItemFromNewTask(index)}
                      className="text-red-600 hover:text-red-700"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                ))}
              </div>
              {newTaskItems.length === 0 && (
                <p className="text-xs text-gray-500">No items added yet</p>
              )}
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setShowCreateDialog(false)}>
              Cancel
            </Button>
            <Button onClick={handleCreateTask}>Create Task</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Header */}
      <div className="bg-white border-b border-gray-200 px-6 py-4 sticky top-0 z-10">
        <div className="flex items-center justify-between">
          <h1 className="text-2xl font-semibold text-gray-900">Shopping</h1>
          <Button onClick={() => setShowCreateDialog(true)}>
            <Plus className="w-4 h-4 mr-2" />
            New Task
          </Button>
        </div>
      </div>

      <div className="px-6 py-6 space-y-6">
        {/* My Tasks */}
        <section>
          <h2 className="text-lg font-semibold text-gray-900 mb-3">My Shopping Tasks</h2>
          {myTasks.length === 0 ? (
            <Card className="p-8 text-center">
              <p className="text-gray-500">No shopping tasks assigned to you</p>
            </Card>
          ) : (
            <div className="space-y-3">
              {myTasks.map((task) => {
                const purchasedCount = task.items.filter((item) => item.purchased).length;
                const totalCount = task.items.length;
                const needsAcceptance = !task.accepted;
                const progressPercentage = totalCount > 0 ? (purchasedCount / totalCount) * 100 : 0;

                return (
                  <Card
                    key={task.id}
                    className={`p-4 cursor-pointer hover:border-gray-300 transition-colors ${
                      needsAcceptance
                        ? "bg-gradient-to-r from-amber-50 to-yellow-50 border-amber-200"
                        : ""
                    }`}
                    onClick={() => setSelectedTask(task)}
                  >
                    <div className="flex items-center justify-between mb-3">
                      <div className="flex-1">
                        <div className="flex items-center gap-2 mb-1">
                          <h3 className="font-semibold text-gray-900">{task.title}</h3>
                          {needsAcceptance && (
                            <Badge className="bg-amber-600 text-xs">Needs Accept</Badge>
                          )}
                          {task.completed && (
                            <Badge className="bg-green-600 text-xs">Completed</Badge>
                          )}
                        </div>
                        <div className="flex items-center gap-3 text-sm text-gray-600">
                          <span>{formatDate(task.dueDate)}</span>
                          <span>•</span>
                          <span>
                            {purchasedCount}/{totalCount} items
                          </span>
                          {task.assignedBy !== user?.name && (
                            <>
                              <span>•</span>
                              <span>By {task.assignedBy}</span>
                            </>
                          )}
                        </div>
                      </div>
                      <ChevronRight className="w-5 h-5 text-gray-400" />
                    </div>
                    {/* Progress Bar */}
                    <div className="space-y-1">
                      <div className="w-full bg-gray-200 rounded-full h-2">
                        <div
                          className="bg-green-600 h-2 rounded-full transition-all"
                          style={{ width: `${progressPercentage}%` }}
                        />
                      </div>
                    </div>
                  </Card>
                );
              })}
            </div>
          )}
        </section>

        {/* Other Tasks */}
        {otherTasks.length > 0 && (
          <section>
            <h2 className="text-lg font-semibold text-gray-900 mb-3">Family's Tasks</h2>
            <div className="space-y-3">
              {otherTasks.map((task) => {
                const purchasedCount = task.items.filter((item) => item.purchased).length;
                const totalCount = task.items.length;
                const progressPercentage = totalCount > 0 ? (purchasedCount / totalCount) * 100 : 0;

                return (
                  <Card
                    key={task.id}
                    className="p-4 cursor-pointer hover:border-gray-300 transition-colors"
                    onClick={() => setSelectedTask(task)}
                  >
                    <div className="flex items-center justify-between mb-3">
                      <div className="flex-1">
                        <div className="flex items-center gap-2 mb-1">
                          <h3 className="font-semibold text-gray-900">{task.title}</h3>
                          {task.completed && (
                            <Badge className="bg-green-600 text-xs">Completed</Badge>
                          )}
                        </div>
                        <div className="flex items-center gap-3 text-sm text-gray-600">
                          <span>{task.assignedTo}</span>
                          <span>•</span>
                          <span>{formatDate(task.dueDate)}</span>
                          <span>•</span>
                          <span>
                            {purchasedCount}/{totalCount} items
                          </span>
                        </div>
                      </div>
                      <ChevronRight className="w-5 h-5 text-gray-400" />
                    </div>
                    {/* Progress Bar */}
                    <div className="space-y-1">
                      <div className="w-full bg-gray-200 rounded-full h-2">
                        <div
                          className="bg-green-600 h-2 rounded-full transition-all"
                          style={{ width: `${progressPercentage}%` }}
                        />
                      </div>
                    </div>
                  </Card>
                );
              })}
            </div>
          </section>
        )}
      </div>
    </div>
  );
}