import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/app_models.dart';
import '../data/local_database.dart';

class FamilyProvider extends ChangeNotifier {
  FamilyProvider() {
    unawaited(_initialize());
  }

  bool isInitialized = false;
  bool _isHydrating = false;

  bool isSosActive = false;
  String? sosInitiatorId;
  DateTime? sosActivatedAt;
  Timer? _sosLocationUpdateTimer;

  bool isLoggedIn = false;

  void signIn() {
    isLoggedIn = true;
    notifyListeners();
  }

  void signOut() {
    isLoggedIn = false;
    notifyListeners();
  }
  // Mock Current User
  FamilyMember currentUser = FamilyMember(
    id: 'u1',
    name: 'Dad',
    avatarUrl:
        'https://images.unsplash.com/photo-1599566150163-29194dcaad36?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=128&q=80',
    status: SafetyStatus.safe,
    relationLabel: 'You',
    isCloseFamily: true,
    locationLabel: 'Home',
    locationAddress: '15 Wind Street, Swansea SA1 1DP',
  );

  // Mock Family Members
  final List<FamilyMember> members = [
    FamilyMember(
      id: 'u2',
      name: 'Mom',
      avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=128&q=80',
      status: SafetyStatus.away,
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 15)),
      relationLabel: 'Mother',
      isCloseFamily: true,
      locationLabel: 'Office',
      locationAddress: 'Swansea University Bay Campus, Fabian Way',
      sharingUntil: null,
    ),
    FamilyMember(
      id: 'u3',
      name: 'Alex',
      avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=128&q=80',
      status: SafetyStatus.safe,
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 5)),
      relationLabel: 'Son',
      isCloseFamily: true,
      locationLabel: 'Home',
      locationAddress: '23 Marina Way, Swansea SA1 3XG',
      sharingUntil: DateTime.now().add(const Duration(hours: 2)),
    ),
    FamilyMember(
      id: 'u4',
      name: 'Sarah',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=128&q=80',
      status: SafetyStatus.unknown,
      relationLabel: 'Friend',
      isCloseFamily: false,
      locationLabel: null,
      locationAddress: null,
      sharingUntil: null,
    ),
  ];

  void signInAsEmail(String email) {
    String? targetId;
    if (email == 'mike@example.com') targetId = 'u1';
    if (email == 'dad@example.com') targetId = 'u1';
    if (email == 'sarah@example.com') targetId = 'u4';
    if (email == 'emma@example.com') targetId = 'u3';
    if (email == 'mary@example.com') targetId = 'u2';
    if (email == 'mom@example.com') targetId = 'u2';

    if (targetId == null) {
      signIn();
      return;
    }

    final all = [currentUser, ...members];
    final nextUser = all.firstWhere((m) => m.id == targetId, orElse: () => currentUser);
    if (nextUser.id == currentUser.id) {
      signIn();
      return;
    }

    members.removeWhere((m) => m.id == nextUser.id);
    if (!members.any((m) => m.id == currentUser.id)) {
      members.add(currentUser);
    }
    currentUser = nextUser;
    signIn();
    notifyListeners();
  }

  String userEmail = 'you@example.com';
  String userPhone = '+44 7700 900077';

  void updateProfile(String name, String email, String phone) {
    currentUser = currentUser.copyWith(name: name);
    userEmail = email;
    userPhone = phone;
    notifyListeners();
  }

  // Mock Events
  final List<CalendarEvent> upcomingEvents = [
    CalendarEvent(
      id: 'e1',
      title: 'Soccer Practice',
      dateTime: DateTime.now().add(const Duration(hours: 2)),
      durationMinutes: 90,
      location: 'Central Park',
      assignedMemberId: 'u3',
      createdById: 'u1',
      invitedMembers: const [
        EventInvite(memberId: 'u1', status: InvitationStatus.accepted),
        EventInvite(memberId: 'u3', status: InvitationStatus.accepted),
        EventInvite(memberId: 'u2', status: InvitationStatus.pending),
      ],
      calendarSource: 'School Calendar',
    ),
    CalendarEvent(
      id: 'e2',
      title: 'Grocery Run',
      dateTime: DateTime.now().add(const Duration(hours: 5)),
      durationMinutes: 60,
      assignedMemberId: 'u1',
      createdById: 'u1',
      invitedMembers: const [
        EventInvite(memberId: 'u1', status: InvitationStatus.accepted),
      ],
      calendarSource: 'Google Calendar',
    ),
  ];

  // Mock Tasks
  final List<TaskItem> pendingTasks = [
    TaskItem(
      id: 't1',
      title: 'Weekly Groceries',
      type: TaskType.shopping,
      status: TaskStatus.accepted,
      priority: TaskPriority.medium,
      createdById: 'u2',
      assignedMemberId: null,
      dueDate: DateTime.now().add(const Duration(days: 1)),
      notes: 'Focus on breakfast items and detergents.',
      shoppingItems: const [
        ShoppingItem(id: 's1', title: 'Milk'),
        ShoppingItem(id: 's2', title: 'Rice'),
        ShoppingItem(id: 's3', title: 'Detergent'),
        ShoppingItem(id: 's4', title: 'Eggs'),
      ],
    ),
    TaskItem(
      id: 't2',
      title: 'Take out bins',
      type: TaskType.chore,
      status: TaskStatus.pending,
      priority: TaskPriority.high,
      assignedMemberId: 'u3',
      createdById: 'u1',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      notes: 'Bins go out by 8 PM.',
    ),
    TaskItem(
      id: 't3',
      title: 'Fix sink',
      type: TaskType.chore,
      status: TaskStatus.accepted,
      priority: TaskPriority.medium,
      assignedMemberId: 'u1',
      createdById: 'u2',
      dueDate: DateTime.now().add(const Duration(days: 2)),
    ),
  ];

  // Mock Notifications
  final List<NotificationItem> notifications = [
    NotificationItem(
      id: 'n1',
      type: NotificationType.eventInvitation,
      title: 'Event Invitation: Dentist',
      message: 'Mom invited you to Dentist at 16:00.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      eventId: 'e1',
      actionRequired: true,
      recipientId: 'u1',
    ),
    NotificationItem(
      id: 'n1b',
      type: NotificationType.eventUpdate,
      title: 'Event Updated: Soccer Practice',
      message: 'Time changed to 17:30. Check details.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
      eventId: 'e1',
      actionRequired: false,
      recipientId: 'u1',
    ),
    NotificationItem(
      id: 'n2',
      type: NotificationType.taskAssigned,
      title: 'Chore Assigned',
      message: 'Dad assigned you “Take out bins”.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      taskId: 't2',
      actionRequired: true,
      recipientId: 'u3',
    ),
    NotificationItem(
      id: 'n3',
      type: NotificationType.taskCompleted,
      title: 'Task Completed',
      message: 'Alex completed “Take out bins”.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      taskId: 't2',
      actionRequired: false,
      recipientId: 'u1',
    ),
  ];

  bool _sharedShoppingNotified = false;

  Future<void> _initialize() async {
    try {
      final savedState = await LocalDatabase.instance.readState();
      if (savedState == null) {
        _seedSharedShoppingNotifications();
        await _persistState();
      } else {
        _isHydrating = true;
        _restoreFromMap(savedState);
        _isHydrating = false;
      }
      _restartSosLocationTimerIfNeeded();
    } catch (_) {
      // If persistence fails, app continues with in-memory defaults.
    } finally {
      isInitialized = true;
      super.notifyListeners();
    }
  }

  Future<void> _persistState() async {
    final payload = _toMap();
    await LocalDatabase.instance.writeState(payload);
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    if (!_isHydrating) {
      unawaited(_persistState());
    }
  }

  void _seedSharedShoppingNotifications() {
    if (_sharedShoppingNotified) return;
    final sharedTask = pendingTasks.firstWhere(
      (task) => task.type == TaskType.shopping && task.assignedMemberId == null,
      orElse: () => TaskItem(
        id: '',
        title: '',
        type: TaskType.shopping,
        status: TaskStatus.accepted,
        priority: TaskPriority.medium,
        createdById: '',
      ),
    );
    if (sharedTask.id.isEmpty) return;
    _notifyCloseFamily(
      title: 'Shared Shopping List',
      message: 'A shared shopping task "${sharedTask.title}" is available.',
      type: NotificationType.shoppingShared,
    );
    _sharedShoppingNotified = true;
  }

  void _notifyCloseFamily({
    required String title,
    required String message,
    required NotificationType type,
  }) {
    final recipients = [currentUser, ...members]
        .where((member) => member.isCloseFamily && member.id != currentUser.id)
        .toList();
    for (final member in recipients) {
      notifications.insert(
        0,
        NotificationItem(
          id: 'n-${DateTime.now().microsecondsSinceEpoch}-${member.id}',
          type: type,
          title: title,
          message: message,
          timestamp: DateTime.now(),
          recipientId: member.id,
        ),
      );
    }
  }

  void _notifyAllFamily({
    required String title,
    required String message,
    required NotificationType type,
  }) {
    final recipients = [currentUser, ...members];
    for (final member in recipients) {
      notifications.insert(
        0,
        NotificationItem(
          id: 'n-${DateTime.now().microsecondsSinceEpoch}-${member.id}',
          type: type,
          title: title,
          message: message,
          timestamp: DateTime.now(),
          recipientId: member.id,
        ),
      );
    }
  }
  
  int get shoppingCount => pendingTasks.length;
  int get choreCount => 2; // Hardcoded specific

  void addEvent(CalendarEvent event) {
    upcomingEvents.add(event);
    notifyListeners();
  }

  void updateEvent(String eventId, CalendarEvent updatedEvent) {
    final index = upcomingEvents.indexWhere((e) => e.id == eventId);
    if (index == -1) return;
    upcomingEvents[index] = updatedEvent;
    notifyListeners();
  }

  void inviteMembers(String eventId, List<String> memberIds) {
    final index = upcomingEvents.indexWhere((e) => e.id == eventId);
    if (index == -1) return;
    final event = upcomingEvents[index];
    final existingIds = event.invitedMembers.map((invite) => invite.memberId).toSet();
    final newInvites = memberIds
        .where((id) => !existingIds.contains(id))
        .map((id) => EventInvite(memberId: id, status: InvitationStatus.pending))
        .toList();
    if (newInvites.isEmpty) return;
    upcomingEvents[index] = event.copyWith(
      invitedMembers: [...event.invitedMembers, ...newInvites],
    );
    notifyListeners();
  }

  void cancelEvent(String eventId) {
    upcomingEvents.removeWhere((e) => e.id == eventId);
    notifyListeners();
  }

  void acceptInvitation(String eventId, String memberId) {
    final index = upcomingEvents.indexWhere((e) => e.id == eventId);
    if (index == -1) return;
    final event = upcomingEvents[index];
    final updatedInvites = event.invitedMembers.map((invite) {
      if (invite.memberId == memberId) {
        return invite.copyWith(status: InvitationStatus.accepted);
      }
      return invite;
    }).toList();
    upcomingEvents[index] = event.copyWith(invitedMembers: updatedInvites);
    notifications.removeWhere((n) => n.eventId == eventId && n.type == NotificationType.eventInvitation);
    notifyListeners();
  }

  void declineInvitation(String eventId, String memberId) {
    final index = upcomingEvents.indexWhere((e) => e.id == eventId);
    if (index == -1) return;
    final event = upcomingEvents[index];
    final updatedInvites = event.invitedMembers.map((invite) {
      if (invite.memberId == memberId) {
        return invite.copyWith(status: InvitationStatus.declined);
      }
      return invite;
    }).toList();
    upcomingEvents[index] = event.copyWith(invitedMembers: updatedInvites);
    notifications.removeWhere((n) => n.eventId == eventId && n.type == NotificationType.eventInvitation);
    notifyListeners();
  }

  void dismissNotification(String notificationId) {
    notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  void addTask(
    String title, {
    TaskType type = TaskType.chore,
    TaskPriority priority = TaskPriority.medium,
    String? assignedMemberId,
    DateTime? dueDate,
    String? notes,
    List<ShoppingItem>? shoppingItems,
  }) {
    final creatorId = currentUser.id;
    final isAssignedToCurrent = assignedMemberId == null || assignedMemberId == creatorId;
    final initialStatus = type == TaskType.shopping
        ? (isAssignedToCurrent ? TaskStatus.accepted : TaskStatus.pending)
        : TaskStatus.pending;
    pendingTasks.add(TaskItem(
      id: DateTime.now().toString(),
      title: title,
      type: type,
      status: initialStatus,
      priority: priority,
      assignedMemberId: assignedMemberId,
      createdById: creatorId,
      dueDate: dueDate,
      notes: notes,
      shoppingItems: shoppingItems,
    ));
    if (type == TaskType.shopping && assignedMemberId == null) {
      _notifyAllFamily(
        title: 'Shared Shopping List',
        message: 'A shared shopping task "$title" was created.',
        type: NotificationType.shoppingShared,
      );
    } else if (assignedMemberId != null) {
      final assignee = assignedMemberId == creatorId
          ? currentUser
          : members.firstWhere((m) => m.id == assignedMemberId, orElse: () => currentUser);
      if (assignedMemberId == creatorId) {
        notifications.add(
          NotificationItem(
            id: 'n-${DateTime.now().microsecondsSinceEpoch}',
            type: NotificationType.taskAssigned,
            title: 'Shopping Task Assigned',
            message: 'You were assigned "$title".',
            timestamp: DateTime.now(),
            taskId: pendingTasks.last.id,
            actionRequired: true,
            recipientId: creatorId,
          ),
        );
      } else {
        notifications.add(
          NotificationItem(
            id: 'n-${DateTime.now().microsecondsSinceEpoch}',
            type: NotificationType.taskAssigned,
            title: 'Shopping Task Assigned',
            message: 'Assigned to ${assignee.name}.',
            timestamp: DateTime.now(),
            taskId: pendingTasks.last.id,
            actionRequired: false,
            recipientId: assignedMemberId,
          ),
        );
      }
    }
    notifyListeners();
  }

  void updateTask(String taskId, TaskItem updated) {
    final index = pendingTasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;
    pendingTasks[index] = updated;
    notifyListeners();
  }

  void removeTask(String taskId) {
    pendingTasks.removeWhere((task) => task.id == taskId);
    notifyListeners();
  }

  void toggleTaskCompleted(String id) {
    final index = pendingTasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final task = pendingTasks[index];
    final nextStatus = task.status == TaskStatus.completed ? TaskStatus.accepted : TaskStatus.completed;
    pendingTasks[index] = task.copyWith(status: nextStatus);
    notifyListeners();
  }

  void acceptTask(String id) {
    final index = pendingTasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    pendingTasks[index] = pendingTasks[index].copyWith(status: TaskStatus.accepted);
    notifyListeners();
  }

  void declineTask(String id) {
    final index = pendingTasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    pendingTasks[index] = pendingTasks[index].copyWith(status: TaskStatus.declined);
    notifyListeners();
  }

  void reassignTask(String id, String memberId) {
    final index = pendingTasks.indexWhere((t) => t.id == id);
    if (index == -1) return;
    pendingTasks[index] = pendingTasks[index].copyWith(
      assignedMemberId: memberId,
      status: TaskStatus.pending,
    );
    final assignee = memberId == currentUser.id
        ? currentUser
        : members.firstWhere((m) => m.id == memberId, orElse: () => currentUser);
    notifications.add(
      NotificationItem(
        id: 'n-${DateTime.now().microsecondsSinceEpoch}',
        type: NotificationType.taskAssigned,
        title: 'Task Reassigned',
        message: memberId == currentUser.id
            ? 'A task was reassigned to you.'
            : 'Reassigned to ${assignee.name}.',
        timestamp: DateTime.now(),
        taskId: id,
        actionRequired: memberId == currentUser.id,
        recipientId: memberId,
      ),
    );
    notifyListeners();
  }

  TaskItem? _findShoppingTask() {
    try {
      return pendingTasks.firstWhere((t) => t.type == TaskType.shopping);
    } catch (_) {
      return null;
    }
  }

  void addShoppingItem(String title) {
    final existing = _findShoppingTask();
    if (existing == null) {
      addTask(
        'Shared Shopping List',
        type: TaskType.shopping,
        shoppingItems: [
          ShoppingItem(
            id: DateTime.now().toString(),
            title: title,
            assignedMemberId: existing?.assignedMemberId,
          ),
        ],
      );
      return;
    }

    final items = [
      ...existing.shoppingItems,
      ShoppingItem(
        id: DateTime.now().toString(),
        title: title,
        assignedMemberId: existing.assignedMemberId,
      ),
    ];
    updateTask(existing.id, existing.copyWith(shoppingItems: items));
  }

  void addShoppingItemToTask(String taskId, String title) {
    final index = pendingTasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;
    final task = pendingTasks[index];
    final items = [
      ...task.shoppingItems,
      ShoppingItem(
        id: '${DateTime.now().microsecondsSinceEpoch}-${task.shoppingItems.length}',
        title: title,
        assignedMemberId: task.assignedMemberId,
      ),
    ];
    pendingTasks[index] = task.copyWith(
      shoppingItems: items,
      status: task.status == TaskStatus.completed ? TaskStatus.accepted : task.status,
    );
    notifyListeners();
  }

  void reassignShoppingItem(String taskId, String itemId, String? memberId) {
    final index = pendingTasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;
    final task = pendingTasks[index];
    final item = task.shoppingItems.firstWhere(
      (element) => element.id == itemId,
      orElse: () => const ShoppingItem(id: '-', title: 'item'),
    );

    if (memberId == null) {
      final updatedItems = task.shoppingItems.map((existing) {
        if (existing.id != itemId) return existing;
        return existing.copyWith(assignedMemberId: null);
      }).toList();
      pendingTasks[index] = task.copyWith(shoppingItems: updatedItems);
      notifyListeners();
      return;
    }

    final remainingItems = task.shoppingItems.where((existing) => existing.id != itemId).toList();
    pendingTasks[index] = task.copyWith(shoppingItems: remainingItems);
    if (remainingItems.isEmpty && task.type == TaskType.shopping) {
      pendingTasks.removeAt(index);
    }

    addTask(
      'Shopping: ${item.title}',
      type: TaskType.shopping,
      priority: task.priority,
      assignedMemberId: memberId,
      dueDate: task.dueDate,
      notes: 'Reassigned from ${task.title}.',
      shoppingItems: [
        item.copyWith(
          assignedMemberId: memberId,
          isChecked: false,
        ),
      ],
    );
  }

  String _shoppingItemTitle(TaskItem task, String itemId) {
    for (final item in task.shoppingItems) {
      if (item.id == itemId) return item.title;
    }
    return 'item';
  }

  FamilyMember? _memberById(String? id) {
    if (id == null) return null;
    if (currentUser.id == id) return currentUser;
    for (final member in members) {
      if (member.id == id) return member;
    }
    return null;
  }

  List<FamilyMember> _sosRecipients({
    required String sourceMemberId,
    bool includeInitiator = false,
  }) {
    final allMembers = [currentUser, ...members];
    final recipients = allMembers.where((m) => m.isCloseFamily).toList();
    if (includeInitiator) {
      return recipients;
    }
    return recipients.where((m) => m.id != sourceMemberId).toList();
  }

  void sendSosAlert({
    required String triggeredBy,
    required String sourceMemberId,
  }) {
    final recipients = _sosRecipients(sourceMemberId: sourceMemberId);
    for (final member in recipients) {
      notifications.insert(
        0,
        NotificationItem(
          id: 'n-${DateTime.now().microsecondsSinceEpoch}-${member.id}',
          type: NotificationType.sosAlert,
          title: 'Emergency SOS',
          message: '$triggeredBy triggered an SOS alert.',
          timestamp: DateTime.now(),
          recipientId: member.id,
          actionRequired: true,
          sourceMemberId: sourceMemberId,
        ),
      );
    }
    notifyListeners();
  }

  void sendSosLocationUpdate({
    required String triggeredBy,
    required String sourceMemberId,
  }) {
    final recipients = _sosRecipients(sourceMemberId: sourceMemberId);
    for (final member in recipients) {
      notifications.insert(
        0,
        NotificationItem(
          id: 'n-${DateTime.now().microsecondsSinceEpoch}-${member.id}',
          type: NotificationType.sosLocationUpdate,
          title: 'Location Update',
          message: 'Updated location from $triggeredBy.',
          timestamp: DateTime.now(),
          recipientId: member.id,
          actionRequired: false,
          sourceMemberId: sourceMemberId,
        ),
      );
    }
    notifyListeners();
  }

  void resolveSosAlert({
    required String triggeredBy,
    required String sourceMemberId,
  }) {
    final recipients = _sosRecipients(sourceMemberId: sourceMemberId);
    for (final member in recipients) {
      notifications.insert(
        0,
        NotificationItem(
          id: 'n-${DateTime.now().microsecondsSinceEpoch}-${member.id}',
          type: NotificationType.sosResolved,
          title: 'SOS Cancelled',
          message: '$triggeredBy cancelled the SOS alert.',
          timestamp: DateTime.now(),
          recipientId: member.id,
          actionRequired: false,
          sourceMemberId: sourceMemberId,
        ),
      );
    }
    notifyListeners();
  }

  bool _wasLocationSharingAutoEnabledForSos = false;

  void startSosAlert() {
    if (isSosActive) return;
    final initiatorId = currentUser.id;
    final initiatorName = currentUser.name;
    isSosActive = true;
    sosInitiatorId = initiatorId;
    sosActivatedAt = DateTime.now();

    if (!isSharingLocation) {
      _wasLocationSharingAutoEnabledForSos = true;
      startLocationSharing(null, 'SOS Emergency Tracking');
    } else {
      _wasLocationSharingAutoEnabledForSos = false;
    }

    sendSosAlert(triggeredBy: initiatorName, sourceMemberId: initiatorId);
    sendSosLocationUpdate(triggeredBy: initiatorName, sourceMemberId: initiatorId);
    _sosLocationUpdateTimer?.cancel();
    _sosLocationUpdateTimer = Timer.periodic(
      const Duration(minutes: 3),
      (_) => sendSosLocationUpdate(
        triggeredBy: initiatorName,
        sourceMemberId: initiatorId,
      ),
    );
    notifyListeners();
  }

  void stopSosAlert({bool sendResolution = true}) {
    if (!isSosActive) return;
    _sosLocationUpdateTimer?.cancel();
    _sosLocationUpdateTimer = null;
    if (sendResolution) {
      final initiator = _memberById(sosInitiatorId) ?? currentUser;
      resolveSosAlert(
        triggeredBy: initiator.name,
        sourceMemberId: initiator.id,
      );
    }
    isSosActive = false;
    sosInitiatorId = null;
    sosActivatedAt = null;

    if (_wasLocationSharingAutoEnabledForSos) {
      toggleLocationSharing(false);
      _wasLocationSharingAutoEnabledForSos = false;
    }

    notifyListeners();
  }

  void toggleShoppingItem(String taskId, String itemId) {
    final index = pendingTasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;
    final task = pendingTasks[index];
    bool markedChecked = false;
    final updatedItems = task.shoppingItems.map((item) {
      if (item.id != itemId) return item;
      final nextChecked = !item.isChecked;
      if (!item.isChecked && nextChecked) {
        markedChecked = true;
      }
      return item.copyWith(
        isChecked: nextChecked,
        checkedById: nextChecked ? currentUser.id : null,
      );
    }).toList();
    final allChecked = updatedItems.isNotEmpty && updatedItems.every((item) => item.isChecked);
    final nextStatus = allChecked
        ? TaskStatus.completed
        : (task.status == TaskStatus.completed ? TaskStatus.accepted : task.status);
    pendingTasks[index] = task.copyWith(
      shoppingItems: updatedItems,
      status: nextStatus,
    );
    if (markedChecked && task.assignedMemberId == null) {
      final itemTitle = _shoppingItemTitle(task, itemId);
      _notifyAllFamily(
        title: 'Item Purchased',
        message: '"$itemTitle" was marked as bought by ${currentUser.name}.',
        type: NotificationType.shoppingItemCompleted,
      );
    }
    notifyListeners();
  }
  bool isSharingLocation = false;
  String sharingDurationLabel = 'Off';
  DateTime? sharingEndsAt;

  void toggleLocationSharing(bool value) {
    if (!value) {
      isSharingLocation = false;
      sharingDurationLabel = 'Off';
      sharingEndsAt = null;
    }
    notifyListeners();
  }

  void startLocationSharing(Duration? duration, String label) {
    isSharingLocation = true;
    sharingDurationLabel = label;
    sharingEndsAt = duration == null ? null : DateTime.now().add(duration);
    notifyListeners();
  }

  void addFamilyMember(FamilyMember member) {
    members.add(member);
    notifyListeners();
  }

  void removeFamilyMember(String memberId) {
    members.removeWhere((member) => member.id == memberId);
    notifyListeners();
  }

  void updateRelationship(String memberId, String relationLabel, bool isCloseFamily) {
    final index = members.indexWhere((member) => member.id == memberId);
    if (index == -1) return;
    final member = members[index];
    members[index] = FamilyMember(
      id: member.id,
      name: member.name,
      avatarUrl: member.avatarUrl,
      status: member.status,
      lastUpdated: member.lastUpdated,
      relationLabel: relationLabel,
      isCloseFamily: isCloseFamily,
    );
    notifyListeners();
  }

  void _restartSosLocationTimerIfNeeded() {
    _sosLocationUpdateTimer?.cancel();
    _sosLocationUpdateTimer = null;
    if (!isSosActive || sosInitiatorId == null) return;
    final initiator = _memberById(sosInitiatorId);
    if (initiator == null) {
      isSosActive = false;
      sosInitiatorId = null;
      sosActivatedAt = null;
      return;
    }
    _sosLocationUpdateTimer = Timer.periodic(
      const Duration(minutes: 3),
      (_) => sendSosLocationUpdate(
        triggeredBy: initiator.name,
        sourceMemberId: initiator.id,
      ),
    );
  }

  Map<String, dynamic> _toMap() {
    return <String, dynamic>{
      'version': 1,
      'isLoggedIn': isLoggedIn,
      'isSosActive': isSosActive,
      'sosInitiatorId': sosInitiatorId,
      'sosActivatedAt': sosActivatedAt?.toIso8601String(),
      'isSharingLocation': isSharingLocation,
      'sharingDurationLabel': sharingDurationLabel,
      'sharingEndsAt': sharingEndsAt?.toIso8601String(),
      'sharedShoppingNotified': _sharedShoppingNotified,
      'currentUser': _familyMemberToMap(currentUser),
      'members': members.map(_familyMemberToMap).toList(),
      'upcomingEvents': upcomingEvents.map(_calendarEventToMap).toList(),
      'pendingTasks': pendingTasks.map(_taskToMap).toList(),
      'notifications': notifications.map(_notificationToMap).toList(),
    };
  }

  void _restoreFromMap(Map<String, dynamic> data) {
    isLoggedIn = data['isLoggedIn'] == true;
    isSosActive = data['isSosActive'] == true;
    sosInitiatorId = data['sosInitiatorId'] as String?;
    sosActivatedAt = _parseDate(data['sosActivatedAt']);
    isSharingLocation = data['isSharingLocation'] == true;
    sharingDurationLabel = (data['sharingDurationLabel'] as String?) ?? 'Off';
    sharingEndsAt = _parseDate(data['sharingEndsAt']);
    _sharedShoppingNotified = data['sharedShoppingNotified'] == true;

    final loadedCurrentUser = _familyMemberFromMap(data['currentUser']);
    if (loadedCurrentUser != null) {
      currentUser = loadedCurrentUser;
    }

    if (data.containsKey('members')) {
      final loadedMembers = _familyMemberListFromAny(data['members']);
      members
        ..clear()
        ..addAll(loadedMembers);
    }

    if (data.containsKey('upcomingEvents')) {
      final loadedEvents = _eventListFromAny(data['upcomingEvents']);
      upcomingEvents
        ..clear()
        ..addAll(loadedEvents);
    }

    if (data.containsKey('pendingTasks')) {
      final loadedTasks = _taskListFromAny(data['pendingTasks']);
      pendingTasks
        ..clear()
        ..addAll(loadedTasks);
    }

    if (data.containsKey('notifications')) {
      final loadedNotifications = _notificationListFromAny(data['notifications']);
      notifications
        ..clear()
        ..addAll(loadedNotifications);
    }
  }

  DateTime? _parseDate(dynamic value) {
    if (value is! String) return null;
    return DateTime.tryParse(value);
  }

  List<FamilyMember> _familyMemberListFromAny(dynamic raw) {
    if (raw is! List) return const <FamilyMember>[];
    final list = <FamilyMember>[];
    for (final item in raw) {
      final member = _familyMemberFromMap(item);
      if (member != null) list.add(member);
    }
    return list;
  }

  FamilyMember? _familyMemberFromMap(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final id = map['id'] as String?;
    final name = map['name'] as String?;
    final avatarUrl = map['avatarUrl'] as String?;
    if (id == null || name == null || avatarUrl == null) return null;
    return FamilyMember(
      id: id,
      name: name,
      avatarUrl: avatarUrl,
      status: _safetyStatusFromName(map['status'] as String?),
      lastUpdated: _parseDate(map['lastUpdated']),
      relationLabel: (map['relationLabel'] as String?) ?? 'Member',
      isCloseFamily: map['isCloseFamily'] == true,
      locationLabel: map['locationLabel'] as String?,
      locationAddress: map['locationAddress'] as String?,
      sharingUntil: _parseDate(map['sharingUntil']),
    );
  }

  Map<String, dynamic> _familyMemberToMap(FamilyMember member) {
    return <String, dynamic>{
      'id': member.id,
      'name': member.name,
      'avatarUrl': member.avatarUrl,
      'status': member.status.name,
      'lastUpdated': member.lastUpdated?.toIso8601String(),
      'relationLabel': member.relationLabel,
      'isCloseFamily': member.isCloseFamily,
      'locationLabel': member.locationLabel,
      'locationAddress': member.locationAddress,
      'sharingUntil': member.sharingUntil?.toIso8601String(),
    };
  }

  List<CalendarEvent> _eventListFromAny(dynamic raw) {
    if (raw is! List) return const <CalendarEvent>[];
    final list = <CalendarEvent>[];
    for (final item in raw) {
      final event = _eventFromMap(item);
      if (event != null) list.add(event);
    }
    return list;
  }

  CalendarEvent? _eventFromMap(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final id = map['id'] as String?;
    final title = map['title'] as String?;
    final dateTime = _parseDate(map['dateTime']);
    final assignedMemberId = map['assignedMemberId'] as String?;
    final createdById = map['createdById'] as String?;
    if (id == null || title == null || dateTime == null || assignedMemberId == null || createdById == null) {
      return null;
    }

    final rawInvites = map['invitedMembers'];
    final invites = <EventInvite>[];
    if (rawInvites is List) {
      for (final inviteRaw in rawInvites) {
        if (inviteRaw is! Map) continue;
        final inviteMap = Map<String, dynamic>.from(inviteRaw);
        final memberId = inviteMap['memberId'] as String?;
        if (memberId == null) continue;
        invites.add(
          EventInvite(
            memberId: memberId,
            status: _invitationStatusFromName(inviteMap['status'] as String?),
          ),
        );
      }
    }

    return CalendarEvent(
      id: id,
      title: title,
      dateTime: dateTime,
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 60,
      location: map['location'] as String?,
      assignedMemberId: assignedMemberId,
      createdById: createdById,
      invitedMembers: invites,
      calendarSource: map['calendarSource'] as String?,
    );
  }

  Map<String, dynamic> _calendarEventToMap(CalendarEvent event) {
    return <String, dynamic>{
      'id': event.id,
      'title': event.title,
      'dateTime': event.dateTime.toIso8601String(),
      'durationMinutes': event.durationMinutes,
      'location': event.location,
      'assignedMemberId': event.assignedMemberId,
      'createdById': event.createdById,
      'calendarSource': event.calendarSource,
      'invitedMembers': event.invitedMembers
          .map((invite) => <String, dynamic>{
                'memberId': invite.memberId,
                'status': invite.status.name,
              })
          .toList(),
    };
  }

  List<TaskItem> _taskListFromAny(dynamic raw) {
    if (raw is! List) return const <TaskItem>[];
    final list = <TaskItem>[];
    for (final item in raw) {
      final task = _taskFromMap(item);
      if (task != null) list.add(task);
    }
    return list;
  }

  TaskItem? _taskFromMap(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final id = map['id'] as String?;
    final title = map['title'] as String?;
    if (id == null || title == null) return null;
    final rawItems = map['shoppingItems'];
    final items = <ShoppingItem>[];
    if (rawItems is List) {
      for (final rawItem in rawItems) {
        final item = _shoppingItemFromMap(rawItem);
        if (item != null) items.add(item);
      }
    }
    return TaskItem(
      id: id,
      title: title,
      type: _taskTypeFromName(map['type'] as String?),
      status: _taskStatusFromName(map['status'] as String?),
      priority: _taskPriorityFromName(map['priority'] as String?),
      assignedMemberId: map['assignedMemberId'] as String?,
      createdById: map['createdById'] as String?,
      dueDate: _parseDate(map['dueDate']),
      notes: map['notes'] as String?,
      shoppingItems: items,
    );
  }

  Map<String, dynamic> _taskToMap(TaskItem task) {
    return <String, dynamic>{
      'id': task.id,
      'title': task.title,
      'type': task.type.name,
      'status': task.status.name,
      'priority': task.priority.name,
      'assignedMemberId': task.assignedMemberId,
      'createdById': task.createdById,
      'dueDate': task.dueDate?.toIso8601String(),
      'notes': task.notes,
      'shoppingItems': task.shoppingItems.map(_shoppingItemToMap).toList(),
    };
  }

  ShoppingItem? _shoppingItemFromMap(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final id = map['id'] as String?;
    final title = map['title'] as String?;
    if (id == null || title == null) return null;
    return ShoppingItem(
      id: id,
      title: title,
      isChecked: map['isChecked'] == true,
      assignedMemberId: map['assignedMemberId'] as String?,
      checkedById: map['checkedById'] as String?,
    );
  }

  Map<String, dynamic> _shoppingItemToMap(ShoppingItem item) {
    return <String, dynamic>{
      'id': item.id,
      'title': item.title,
      'isChecked': item.isChecked,
      'assignedMemberId': item.assignedMemberId,
      'checkedById': item.checkedById,
    };
  }

  List<NotificationItem> _notificationListFromAny(dynamic raw) {
    if (raw is! List) return const <NotificationItem>[];
    final list = <NotificationItem>[];
    for (final item in raw) {
      final notification = _notificationFromMap(item);
      if (notification != null) list.add(notification);
    }
    return list;
  }

  NotificationItem? _notificationFromMap(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final id = map['id'] as String?;
    final title = map['title'] as String?;
    final message = map['message'] as String?;
    final timestamp = _parseDate(map['timestamp']);
    if (id == null || title == null || message == null || timestamp == null) return null;
    return NotificationItem(
      id: id,
      type: _notificationTypeFromName(map['type'] as String?),
      title: title,
      message: message,
      timestamp: timestamp,
      eventId: map['eventId'] as String?,
      taskId: map['taskId'] as String?,
      actionRequired: map['actionRequired'] == true,
      recipientId: map['recipientId'] as String?,
      sourceMemberId: map['sourceMemberId'] as String?,
    );
  }

  Map<String, dynamic> _notificationToMap(NotificationItem notification) {
    return <String, dynamic>{
      'id': notification.id,
      'type': notification.type.name,
      'title': notification.title,
      'message': notification.message,
      'timestamp': notification.timestamp.toIso8601String(),
      'eventId': notification.eventId,
      'taskId': notification.taskId,
      'actionRequired': notification.actionRequired,
      'recipientId': notification.recipientId,
      'sourceMemberId': notification.sourceMemberId,
    };
  }

  SafetyStatus _safetyStatusFromName(String? name) {
    for (final value in SafetyStatus.values) {
      if (value.name == name) return value;
    }
    return SafetyStatus.unknown;
  }

  InvitationStatus _invitationStatusFromName(String? name) {
    for (final value in InvitationStatus.values) {
      if (value.name == name) return value;
    }
    return InvitationStatus.pending;
  }

  TaskType _taskTypeFromName(String? name) {
    for (final value in TaskType.values) {
      if (value.name == name) return value;
    }
    return TaskType.chore;
  }

  TaskStatus _taskStatusFromName(String? name) {
    for (final value in TaskStatus.values) {
      if (value.name == name) return value;
    }
    return TaskStatus.open;
  }

  TaskPriority _taskPriorityFromName(String? name) {
    for (final value in TaskPriority.values) {
      if (value.name == name) return value;
    }
    return TaskPriority.medium;
  }

  NotificationType _notificationTypeFromName(String? name) {
    for (final value in NotificationType.values) {
      if (value.name == name) return value;
    }
    return NotificationType.taskAssigned;
  }

  @override
  void dispose() {
    _sosLocationUpdateTimer?.cancel();
    super.dispose();
  }
}
