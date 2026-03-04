enum SafetyStatus { safe, away, unknown, sos }
enum InvitationStatus { accepted, pending, declined }
enum TaskType { chore, shopping }
enum TaskStatus { open, pending, accepted, declined, completed }
enum TaskPriority { high, medium, low }
enum NotificationType {
  eventInvitation,
  eventUpdate,
  eventCancelled,
  taskAssigned,
  shoppingShared,
  shoppingItemAssigned,
  shoppingItemCompleted,
  taskCompleted,
  sosAlert,
  sosLocationUpdate,
  sosResolved,
}

class FamilyMember {
  final String id;
  final String name;
  final String avatarUrl; // Placeholder
  final SafetyStatus status;
  final DateTime? lastUpdated;
  final String relationLabel;
  final bool isCloseFamily;
  final String? locationLabel;
  final String? locationAddress;
  final DateTime? sharingUntil;

  FamilyMember({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.status = SafetyStatus.unknown,
    this.lastUpdated,
    this.relationLabel = 'Member',
    this.isCloseFamily = false,
    this.locationLabel,
    this.locationAddress,
    this.sharingUntil,
  });

  FamilyMember copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    SafetyStatus? status,
    DateTime? lastUpdated,
    String? relationLabel,
    bool? isCloseFamily,
    String? locationLabel,
    String? locationAddress,
    DateTime? sharingUntil,
  }) {
    return FamilyMember(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      relationLabel: relationLabel ?? this.relationLabel,
      isCloseFamily: isCloseFamily ?? this.isCloseFamily,
      locationLabel: locationLabel ?? this.locationLabel,
      locationAddress: locationAddress ?? this.locationAddress,
      sharingUntil: sharingUntil ?? this.sharingUntil,
    );
  }
}

class CalendarEvent {
  final String id;
  final String title;
  final DateTime dateTime;
  final int durationMinutes;
  final String? location;
  final String assignedMemberId;
  final String createdById;
  final List<EventInvite> invitedMembers;
  final String? calendarSource;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.dateTime,
    this.durationMinutes = 60,
    this.location,
    required this.assignedMemberId,
    required this.createdById,
    List<EventInvite>? invitedMembers,
    this.calendarSource,
  }) : invitedMembers = invitedMembers ?? const [];

  CalendarEvent copyWith({
    String? title,
    DateTime? dateTime,
    int? durationMinutes,
    String? location,
    String? assignedMemberId,
    String? createdById,
    List<EventInvite>? invitedMembers,
    String? calendarSource,
  }) {
    return CalendarEvent(
      id: id,
      title: title ?? this.title,
      dateTime: dateTime ?? this.dateTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      location: location ?? this.location,
      assignedMemberId: assignedMemberId ?? this.assignedMemberId,
      createdById: createdById ?? this.createdById,
      invitedMembers: invitedMembers ?? this.invitedMembers,
      calendarSource: calendarSource ?? this.calendarSource,
    );
  }
}

class EventInvite {
  final String memberId;
  final InvitationStatus status;

  const EventInvite({
    required this.memberId,
    this.status = InvitationStatus.pending,
  });

  EventInvite copyWith({
    String? memberId,
    InvitationStatus? status,
  }) {
    return EventInvite(
      memberId: memberId ?? this.memberId,
      status: status ?? this.status,
    );
  }
}

class TaskItem {
  final String id;
  final String title;
  final TaskType type;
  final TaskStatus status;
  final TaskPriority priority;
  final String? assignedMemberId;
  final String? createdById;
  final DateTime? dueDate;
  final String? notes;
  final List<ShoppingItem> shoppingItems;

  TaskItem({
    required this.id,
    required this.title,
    this.type = TaskType.chore,
    this.status = TaskStatus.open,
    this.priority = TaskPriority.medium,
    this.assignedMemberId,
    this.createdById,
    this.dueDate,
    this.notes,
    List<ShoppingItem>? shoppingItems,
  }) : shoppingItems = shoppingItems ?? const [];

  bool get isCompleted => status == TaskStatus.completed;

  TaskItem copyWith({
    String? title,
    TaskType? type,
    TaskStatus? status,
    TaskPriority? priority,
    String? assignedMemberId,
    String? createdById,
    DateTime? dueDate,
    String? notes,
    List<ShoppingItem>? shoppingItems,
  }) {
    return TaskItem(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignedMemberId: assignedMemberId ?? this.assignedMemberId,
      createdById: createdById ?? this.createdById,
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
      shoppingItems: shoppingItems ?? this.shoppingItems,
    );
  }
}

class ShoppingItem {
  final String id;
  final String title;
  final bool isChecked;
  final String? assignedMemberId;
  final String? checkedById;

  const ShoppingItem({
    required this.id,
    required this.title,
    this.isChecked = false,
    this.assignedMemberId,
    this.checkedById,
  });

  ShoppingItem copyWith({
    String? title,
    bool? isChecked,
    String? assignedMemberId,
    String? checkedById,
  }) {
    return ShoppingItem(
      id: id,
      title: title ?? this.title,
      isChecked: isChecked ?? this.isChecked,
      assignedMemberId: assignedMemberId ?? this.assignedMemberId,
      checkedById: checkedById ?? this.checkedById,
    );
  }
}

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final String? eventId;
  final String? taskId;
  final bool actionRequired;
  final String? recipientId;
  final String? sourceMemberId;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.eventId,
    this.taskId,
    this.actionRequired = false,
    this.recipientId,
    this.sourceMemberId,
  });
}
