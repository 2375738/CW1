import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/family_provider.dart';
import '../models/app_models.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tasks & Shopping'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Shopping List'),
              Tab(text: 'Chores'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ShoppingListView(),
            ChoresListView(),
          ],
        ),
      ),
    );
  }
}

class ShoppingListView extends StatelessWidget {
  const ShoppingListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shopping Tasks',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              FilledButton.icon(
                onPressed: () => _showAddShoppingTaskDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New', style: TextStyle(fontWeight: FontWeight.bold)),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: const StadiumBorder(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Consumer<FamilyProvider>(
            builder: (context, provider, child) {
              final shoppingTasks = provider.pendingTasks
                  .where((t) => t.type == TaskType.shopping)
                  .toList();

              if (shoppingTasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_basket_outlined, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text('Your shopping list is empty.'),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: shoppingTasks.length,
                itemBuilder: (context, index) {
                  final task = shoppingTasks[index];
                  return _ShoppingTaskCard(task: task);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  void _showAddShoppingTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    DateTime? dueDate;
    TaskPriority priority = TaskPriority.medium;
    final notesController = TextEditingController();
    final itemController = TextEditingController();
    String? assigneeId;
    final availableItems = <String>[
      'Milk',
      'Rice',
      'Detergent',
      'Eggs',
      'Bread',
      'Apples',
      'Chicken',
    ];
    final selectedItems = <String>{};

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final provider = Provider.of<FamilyProvider>(context, listen: false);
          final members = [provider.currentUser, ...provider.members];
          assigneeId ??= provider.currentUser.id;
          return AlertDialog(
            title: const Text('New Shopping Task'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Task Title'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: assigneeId,
                    decoration: const InputDecoration(labelText: 'Assign to'),
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('Shared'),
                      ),
                      ...members
                          .map((member) => DropdownMenuItem(
                                value: member.id,
                                child: Text(member.name),
                              )),
                    ],
                    onChanged: (value) => setModalState(() => assigneeId = value?.isEmpty == true ? null : value),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Items to Buy',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: itemController,
                          decoration: const InputDecoration(
                            hintText: 'Add item...',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: () {
                          final value = itemController.text.trim();
                          if (value.isEmpty) return;
                          setModalState(() {
                            availableItems.add(value);
                            selectedItems.add(value);
                            itemController.clear();
                          });
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (availableItems.isEmpty)
                    const Text('No items added yet')
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableItems.map((item) {
                        final isSelected = selectedItems.contains(item);
                        return FilterChip(
                          label: Text(item),
                          selected: isSelected,
                          onSelected: (value) {
                            setModalState(() {
                              if (value) {
                                selectedItems.add(item);
                              } else {
                                selectedItems.remove(item);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<TaskPriority>(
                    initialValue: priority,
                    decoration: const InputDecoration(labelText: 'Priority'),
                    items: TaskPriority.values
                        .map((value) => DropdownMenuItem(
                              value: value,
                              child: Text(_priorityLabel(value)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() => priority = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now().subtract(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setModalState(() => dueDate = picked);
                      }
                    },
                    icon: const Icon(Icons.calendar_today_outlined, size: 16),
                    label: Text(dueDate == null ? 'Add due date' : DateFormat('MMM d').format(dueDate!)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: 'Notes (optional)'),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              FilledButton(
                onPressed: () {
                  final title = titleController.text.trim();
                  if (title.isEmpty) return;
                  final items = selectedItems
                      .toList(growable: false)
                      .asMap()
                      .entries
                      .map((entry) => ShoppingItem(
                            id: '${DateTime.now().microsecondsSinceEpoch}-${entry.key}',
                            title: entry.value,
                            assignedMemberId: assigneeId,
                          ))
                      .toList();

                  Provider.of<FamilyProvider>(context, listen: false).addTask(
                    title,
                    type: TaskType.shopping,
                    priority: priority,
                    assignedMemberId: assigneeId,
                    dueDate: dueDate,
                    notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                    shoppingItems: items,
                  );
                  Navigator.pop(context);
                },
                child: const Text('Create'),
              ),
            ],
          );
        },
      ),
    );
  }
}


class ChoresListView extends StatelessWidget {
  const ChoresListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddChoreDialog(context);
        },
        label: const Text('Add Chore', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add_task),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        shape: const StadiumBorder(),
      ),
      body: Consumer<FamilyProvider>(
        builder: (context, provider, child) {
          final chores = provider.pendingTasks
              .where((t) => t.type == TaskType.chore)
              .toList();

          if (chores.isEmpty) {
            return const Center(child: Text('No chores! House is spotless.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chores.length,
            itemBuilder: (context, index) {
              final chore = chores[index];
              return _ChoreTaskCard(task: chore);
            },
          );
        },
      ),
    );
  }

  void _showAddChoreDialog(BuildContext context) {
    final titleController = TextEditingController();
    DateTime? dueDate;
    String? assigneeId;
    TaskPriority priority = TaskPriority.medium;
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final provider = Provider.of<FamilyProvider>(context, listen: false);
          final members = [provider.currentUser, ...provider.members];

          return AlertDialog(
            title: const Text('New Chore'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Chore Name'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: assigneeId,
                    decoration: const InputDecoration(labelText: 'Assign to'),
                    items: members
                        .map((member) => DropdownMenuItem(
                              value: member.id,
                              child: Text(member.name),
                            ))
                        .toList(),
                    onChanged: (value) => setModalState(() => assigneeId = value),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<TaskPriority>(
                    initialValue: priority,
                    decoration: const InputDecoration(labelText: 'Priority'),
                    items: TaskPriority.values
                        .map((value) => DropdownMenuItem(
                              value: value,
                              child: Text(_priorityLabel(value)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() => priority = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now().subtract(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setModalState(() => dueDate = picked);
                      }
                    },
                    icon: const Icon(Icons.calendar_today_outlined, size: 16),
                    label: Text(dueDate == null ? 'Add due date' : DateFormat('MMM d').format(dueDate!)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: 'Notes (optional)'),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              FilledButton(
                onPressed: () {
                  if (titleController.text.trim().isEmpty) return;
                  provider.addTask(
                    titleController.text.trim(),
                    type: TaskType.chore,
                    priority: priority,
                    assignedMemberId: assigneeId ?? provider.currentUser.id,
                    dueDate: dueDate,
                    notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Assign Chore'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ShoppingTaskCard extends StatelessWidget {
  final TaskItem task;

  const _ShoppingTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FamilyProvider>(context, listen: false);
    final itemCount = task.shoppingItems.length;
    final checkedCount = task.shoppingItems.where((item) => item.isChecked).length;
    final progress = itemCount == 0 ? 0.0 : checkedCount / itemCount;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showShoppingDetails(context, provider, task),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  _StatusChip(status: task.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _PriorityChip(priority: task.priority),
                  const SizedBox(width: 8),
                  Text(
                    'Assigned to ${_assigneeName(provider, task.assignedMemberId)}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '$checkedCount/$itemCount items checked',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 6),
              Text(
                _formatDueDate(task.dueDate),
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade400),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showShoppingDetails(BuildContext context, FamilyProvider provider, TaskItem task) {
    final itemController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final current = provider.pendingTasks.firstWhere((t) => t.id == task.id, orElse: () => task);
          final items = current.shoppingItems;
          final canAccept = current.assignedMemberId == provider.currentUser.id && current.status == TaskStatus.pending;
          final members = [provider.currentUser, ...provider.members];

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        current.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    _StatusChip(status: current.status),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _PriorityChip(priority: current.priority),
                    const SizedBox(width: 8),
                    Text(
                      'Assigned to ${_assigneeName(provider, current.assignedMemberId)}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(_formatDueDate(current.dueDate), style: TextStyle(color: Colors.grey.shade600)),
                if (current.notes != null) ...[
                  const SizedBox(height: 8),
                  Text(current.notes!, style: TextStyle(color: Colors.grey.shade700)),
                ],
                const SizedBox(height: 16),
                Text('Items', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (items.isEmpty)
                  const Text('No items yet. Add a few essentials.'),
                ...items.map((item) => _buildShoppingItemRow(
                      context,
                      provider,
                      current,
                      item,
                      members,
                      setModalState,
                    )),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: itemController,
                        decoration: const InputDecoration(
                          hintText: 'Add item',
                          isDense: true,
                        ),
                        onSubmitted: (_) => _addItem(provider, current.id, itemController, setModalState),
                      ),
                    ),
                    IconButton.filled(
                      onPressed: () => _addItem(provider, current.id, itemController, setModalState),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (canAccept) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            provider.declineTask(current.id);
                            Navigator.pop(context);
                          },
                          child: const Text('Decline'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            provider.acceptTask(current.id);
                            Navigator.pop(context);
                          },
                          child: const Text('Accept'),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        provider.removeTask(current.id);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _addItem(
    FamilyProvider provider,
    String taskId,
    TextEditingController controller,
    StateSetter setModalState,
  ) {
    final value = controller.text.trim();
    if (value.isEmpty) return;
    provider.addShoppingItemToTask(taskId, value);
    controller.clear();
    setModalState(() {});
  }

  Widget _buildShoppingItemRow(
    BuildContext context,
    FamilyProvider provider,
    TaskItem task,
    ShoppingItem item,
    List<FamilyMember> members,
    StateSetter setModalState,
  ) {
    final assigneeLabel = item.assignedMemberId == null
        ? (task.assignedMemberId == null ? 'Shared' : _assigneeName(provider, task.assignedMemberId))
        : _assigneeName(provider, item.assignedMemberId);
    final checkedByLabel = item.checkedById == null ? null : _assigneeName(provider, item.checkedById);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Checkbox(
            value: item.isChecked,
            onChanged: (_) {
              provider.toggleShoppingItem(task.id, item.id);
              setModalState(() {});
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  'Assigned to $assigneeLabel',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                if (item.isChecked && checkedByLabel != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Bought by $checkedByLabel',
                    style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Reassign item',
            onSelected: (value) {
              final memberId = value.isEmpty ? null : value;
              provider.reassignShoppingItem(task.id, item.id, memberId);
              setModalState(() {});
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: '', child: Text('Shared')),
              ...members.map((member) => PopupMenuItem(
                    value: member.id,
                    child: Text(member.name),
                  )),
            ],
            child: Row(
              children: const [
                Icon(Icons.swap_horiz, size: 18),
                SizedBox(width: 4),
                Text('Reassign', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoreTaskCard extends StatelessWidget {
  final TaskItem task;

  const _ChoreTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FamilyProvider>(context, listen: false);
    final assigneeName = _assigneeName(provider, task.assignedMemberId);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showChoreDetails(context, provider, task),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  _StatusChip(status: task.status),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text('Assigned to: $assigneeName', style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(width: 8),
                  _PriorityChip(priority: task.priority),
                ],
              ),
              const SizedBox(height: 6),
              Text(_formatDueDate(task.dueDate), style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  void _showChoreDetails(BuildContext context, FamilyProvider provider, TaskItem task) {
    String? reassignedId = task.assignedMemberId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final current = provider.pendingTasks.firstWhere((t) => t.id == task.id, orElse: () => task);
          final isAssignedToCurrent = current.assignedMemberId == provider.currentUser.id;
          final canAccept = isAssignedToCurrent && current.status == TaskStatus.pending;
          final members = [provider.currentUser, ...provider.members];
          TaskPriority priority = current.priority;

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        current.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    _StatusChip(status: current.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Assigned to: ${_assigneeName(provider, current.assignedMemberId)}'),
                const SizedBox(height: 6),
                Text(_formatDueDate(current.dueDate), style: TextStyle(color: Colors.grey.shade600)),
                if (current.notes != null) ...[
                  const SizedBox(height: 8),
                  Text(current.notes!, style: TextStyle(color: Colors.grey.shade700)),
                ],
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: reassignedId,
                  decoration: const InputDecoration(labelText: 'Reassign to'),
                  items: members
                      .map((member) => DropdownMenuItem(
                            value: member.id,
                            child: Text(member.name),
                          ))
                      .toList(),
                  onChanged: (value) => setModalState(() => reassignedId = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TaskPriority>(
                  initialValue: priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: TaskPriority.values
                      .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text(_priorityLabel(value)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setModalState(() => priority = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: current.status == TaskStatus.completed
                            ? null
                            : () {
                                provider.toggleTaskCompleted(current.id);
                                Navigator.pop(context);
                              },
                        child: Text(current.status == TaskStatus.completed ? 'Completed' : 'Mark Done'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          if (reassignedId != null && reassignedId != current.assignedMemberId) {
                            provider.reassignTask(current.id, reassignedId!);
                          }
                          if (priority != current.priority) {
                            provider.updateTask(current.id, current.copyWith(priority: priority));
                          }
                          Navigator.pop(context);
                        },
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      provider.removeTask(current.id);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text('Delete Task', style: TextStyle(color: Colors.red)),
                  ),
                ),
                if (canAccept) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            provider.declineTask(current.id);
                            Navigator.pop(context);
                          },
                          child: const Text('Decline'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            provider.acceptTask(current.id);
                            Navigator.pop(context);
                          },
                          child: const Text('Accept'),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final TaskStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color background;
    Color foreground;
    String label;

    switch (status) {
      case TaskStatus.pending:
        background = Colors.orange.shade50;
        foreground = Colors.orange.shade700;
        label = 'Pending';
        break;
      case TaskStatus.accepted:
        background = Colors.green.shade50;
        foreground = Colors.green.shade700;
        label = 'Accepted';
        break;
      case TaskStatus.declined:
        background = Colors.red.shade50;
        foreground = Colors.red.shade700;
        label = 'Declined';
        break;
      case TaskStatus.completed:
        background = Colors.blue.shade50;
        foreground = Colors.blue.shade700;
        label = 'Done';
        break;
      case TaskStatus.open:
        background = Colors.grey.shade200;
        foreground = Colors.grey.shade700;
        label = 'Open';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(color: foreground, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final TaskPriority priority;

  const _PriorityChip({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color background;
    Color foreground;
    String label;

    switch (priority) {
      case TaskPriority.high:
        background = Colors.red.shade50;
        foreground = Colors.red.shade700;
        label = 'High';
        break;
      case TaskPriority.low:
        background = Colors.green.shade50;
        foreground = Colors.green.shade700;
        label = 'Low';
        break;
      case TaskPriority.medium:
        background = Colors.orange.shade50;
        foreground = Colors.orange.shade700;
        label = 'Medium';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label, style: TextStyle(color: foreground, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

String _priorityLabel(TaskPriority priority) {
  switch (priority) {
    case TaskPriority.high:
      return 'High';
    case TaskPriority.low:
      return 'Low';
    case TaskPriority.medium:
      return 'Medium';
  }
}

String _assigneeName(FamilyProvider provider, String? memberId) {
  if (memberId == null) return 'Shared';
  if (memberId == provider.currentUser.id) return 'You';
  final member = provider.members.firstWhere((m) => m.id == memberId, orElse: () => provider.currentUser);
  return member.name;
}

String _formatDueDate(DateTime? date) {
  if (date == null) return 'No due date';
  return 'Due ${DateFormat('MMM d').format(date)}';
}

class _QuickAddInput extends StatefulWidget {
  final bool isShopping;
  const _QuickAddInput({required this.isShopping});

  @override
  State<_QuickAddInput> createState() => _QuickAddInputState();
}

class _QuickAddInputState extends State<_QuickAddInput> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: widget.isShopping ? 'Add item (e.g., Milk)...' : 'Add chore...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: _submit,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_controller.text.trim().isEmpty) return;
    final provider = Provider.of<FamilyProvider>(context, listen: false);
    if (widget.isShopping) {
      provider.addShoppingItem(_controller.text.trim());
    } else {
      provider.addTask(_controller.text.trim(), type: TaskType.chore, assignedMemberId: provider.currentUser.id);
    }
    _controller.clear();
  }
}
