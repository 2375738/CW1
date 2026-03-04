import { createContext, useContext, useState, ReactNode } from "react";

export interface ShoppingItem {
  id: number;
  name: string;
  purchased: boolean;
  assignedTo?: string;
  note?: string;
  boughtBy?: string;
}

export interface ShoppingTask {
  id: number;
  title: string;
  assignedTo: string;
  assignedBy: string;
  dueDate: string;
  items: ShoppingItem[];
  completed: boolean;
  accepted: boolean;
}

interface ShoppingContextType {
  tasks: ShoppingTask[];
  acceptTask: (taskId: number) => void;
  toggleItemPurchased: (taskId: number, itemId: number, userName: string) => void;
  reassignItem: (taskId: number, itemId: number, newAssignee: string) => void;
  addTask: (task: Omit<ShoppingTask, "id" | "completed" | "accepted">) => void;
  deleteTask: (taskId: number) => void;
  updateItemNote: (taskId: number, itemId: number, note: string) => void;
  updateTask: (taskId: number, updates: Partial<ShoppingTask>) => void;
}

const ShoppingContext = createContext<ShoppingContextType | undefined>(undefined);

export function ShoppingProvider({ children }: { children: ReactNode }) {
  const [tasks, setTasks] = useState<ShoppingTask[]>([
    {
      id: 1,
      title: "Weekly Groceries",
      assignedTo: "Sarah Johnson",
      assignedBy: "Mike Johnson",
      dueDate: "2026-01-29",
      accepted: false,
      completed: false,
      items: [
        { id: 1, name: "Milk 1L", purchased: false },
        { id: 2, name: "Bread 1 loaf", purchased: false },
        { id: 3, name: "Eggs 12", purchased: false },
        { id: 4, name: "Apples 6", purchased: false },
      ],
    },
    {
      id: 2,
      title: "Weekend BBQ Shopping",
      assignedTo: "Mike Johnson",
      assignedBy: "Sarah Johnson",
      dueDate: "2026-01-30",
      accepted: true,
      completed: false,
      items: [
        { id: 5, name: "Chicken 500g", purchased: false },
        { id: 6, name: "Rice 1kg", purchased: false },
        { id: 7, name: "BBQ Sauce", purchased: false },
      ],
    },
  ]);

  const acceptTask = (taskId: number) => {
    setTasks((prev) =>
      prev.map((task) =>
        task.id === taskId ? { ...task, accepted: true } : task
      )
    );
  };

  const toggleItemPurchased = (taskId: number, itemId: number, userName: string) => {
    setTasks((prev) =>
      prev.map((task) => {
        if (task.id === taskId) {
          const updatedItems = task.items.map((item) =>
            item.id === itemId
              ? {
                  ...item,
                  purchased: !item.purchased,
                  boughtBy: !item.purchased ? userName : undefined,
                }
              : item
          );
          const allPurchased = updatedItems.every((item) => item.purchased);
          return {
            ...task,
            items: updatedItems,
            completed: allPurchased,
          };
        }
        return task;
      })
    );
  };

  const reassignItem = (taskId: number, itemId: number, newAssignee: string) => {
    setTasks((prev) => {
      const currentTask = prev.find((t) => t.id === taskId);
      if (!currentTask) return prev;

      const itemToReassign = currentTask.items.find((i) => i.id === itemId);
      if (!itemToReassign) return prev;

      // Remove item from current task
      const updatedCurrentTask = {
        ...currentTask,
        items: currentTask.items.filter((item) => item.id !== itemId),
      };

      // Find or create task for new assignee
      const existingTaskForAssignee = prev.find(
        (t) =>
          t.assignedTo === newAssignee &&
          !t.completed &&
          t.assignedBy === currentTask.assignedTo
      );

      let updatedTasks = prev.map((t) => (t.id === taskId ? updatedCurrentTask : t));

      if (existingTaskForAssignee) {
        // Add item to existing task
        updatedTasks = updatedTasks.map((t) =>
          t.id === existingTaskForAssignee.id
            ? {
                ...t,
                items: [...t.items, { ...itemToReassign, assignedTo: newAssignee }],
              }
            : t
        );
      } else {
        // Create new task for reassigned item
        const newTask: ShoppingTask = {
          id: Date.now(),
          title: `Reassigned from ${currentTask.title}`,
          assignedTo: newAssignee,
          assignedBy: currentTask.assignedTo,
          dueDate: currentTask.dueDate,
          items: [{ ...itemToReassign, assignedTo: newAssignee }],
          completed: false,
          accepted: false,
        };
        updatedTasks = [...updatedTasks, newTask];
      }

      // Remove current task if it has no items left
      return updatedTasks.filter((t) => t.id !== taskId || t.items.length > 0);
    });
  };

  const addTask = (task: Omit<ShoppingTask, "id" | "completed" | "accepted">) => {
    const newTask: ShoppingTask = {
      ...task,
      id: Date.now(),
      completed: false,
      accepted: false,
    };
    setTasks((prev) => [...prev, newTask]);
  };

  const deleteTask = (taskId: number) => {
    setTasks((prev) => prev.filter((task) => task.id !== taskId));
  };

  const updateItemNote = (taskId: number, itemId: number, note: string) => {
    setTasks((prev) =>
      prev.map((task) => {
        if (task.id === taskId) {
          return {
            ...task,
            items: task.items.map((item) =>
              item.id === itemId ? { ...item, note } : item
            ),
          };
        }
        return task;
      })
    );
  };

  const updateTask = (taskId: number, updates: Partial<ShoppingTask>) => {
    setTasks((prev) =>
      prev.map((task) =>
        task.id === taskId ? { ...task, ...updates } : task
      )
    );
  };

  return (
    <ShoppingContext.Provider
      value={{
        tasks,
        acceptTask,
        toggleItemPurchased,
        reassignItem,
        addTask,
        deleteTask,
        updateItemNote,
        updateTask,
      }}
    >
      {children}
    </ShoppingContext.Provider>
  );
}

export function useShopping() {
  const context = useContext(ShoppingContext);
  if (!context) {
    throw new Error("useShopping must be used within a ShoppingProvider");
  }
  return context;
}