
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/family_provider.dart';
import '../models/app_models.dart';
import '../widgets/avatar_view.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  late DateTime _weekStartDay;

  @override
  void initState() {
    super.initState();
    _weekStartDay = _startOfWeek(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final familyData = Provider.of<FamilyProvider>(context);

    final selectedEvents = familyData.upcomingEvents.where((event) {
      return event.dateTime.year == _selectedDay.year &&
          event.dateTime.month == _selectedDay.month &&
          event.dateTime.day == _selectedDay.day;
    }).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Calendar', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: FilledButton.icon(
              onPressed: () => _showAddEventDialog(context, familyData),
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Add Event", style: TextStyle(fontWeight: FontWeight.bold)),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: const StadiumBorder(),
              ),
            ),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDayStrip(familyData),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              DateFormat('EEEE, MMMM d').format(_selectedDay),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: selectedEvents.isEmpty
                ? Center(
                    child: Text(
                      "No events scheduled",
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: selectedEvents.length,
                    itemBuilder: (context, index) {
                      return _buildTimelineEventCard(context, familyData, selectedEvents[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  DateTime _startOfWeek(DateTime date) {
    final weekday = date.weekday;
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: weekday - 1));
  }

  Widget _buildDayStrip(FamilyProvider provider) {
    final days = List.generate(7, (index) => _weekStartDay.add(Duration(days: index)));

    return SizedBox(
      height: 110,
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _weekStartDay = _weekStartDay.subtract(const Duration(days: 7));
                _selectedDay = _weekStartDay;
              });
            },
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              separatorBuilder: (_, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final date = days[index];
                final isSelected = _isSameDay(date, _selectedDay);
                final hasEvents = provider.upcomingEvents.any((event) => _isSameDay(event.dateTime, date));

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDay = date;
                    });
                  },
                  child: Container(
                    width: 60,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.shade600 : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected ? null : Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E').format(date),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        if (hasEvents)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: CircleAvatar(
                              radius: 2,
                              backgroundColor: isSelected ? Colors.white : Colors.blue.shade600,
                            ),
                          )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _weekStartDay = _weekStartDay.add(const Duration(days: 7));
                _selectedDay = _weekStartDay;
              });
            },
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildTimelineEventCard(BuildContext context, FamilyProvider provider, CalendarEvent event) {
    final isCreator = event.createdById == provider.currentUser.id;
    final uninvited = _getUninvitedMembers(provider, event);
    final currentInvite = event.invitedMembers.firstWhere(
      (invite) => invite.memberId == provider.currentUser.id,
      orElse: () => const EventInvite(memberId: ''),
    );
    final isInvitee = currentInvite.memberId.isNotEmpty;
    final isPendingInvite = isInvitee && currentInvite.status == InvitationStatus.pending;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('HH:mm').format(event.dateTime),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                "${event.durationMinutes}m",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Container(
            width: 4,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),
                if (event.location != null && event.location!.isNotEmpty)
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Open maps placeholder.')),
                      );
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          event.location!,
                          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                if (event.calendarSource != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 6),
                        Text(
                          event.calendarSource!,
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: event.invitedMembers.isEmpty
                      ? [
                          _buildAttendeeChip(provider.currentUser.name, InvitationStatus.accepted),
                        ]
                      : event.invitedMembers.map((invite) {
                          final name = _memberName(provider, invite.memberId);
                          return _buildAttendeeChip(name, invite.status);
                        }).toList(),
                ),
                const SizedBox(height: 12),
                if (isPendingInvite)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => provider.declineInvitation(event.id, provider.currentUser.id),
                          child: const Text('Decline'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => provider.acceptInvitation(event.id, provider.currentUser.id),
                          child: const Text('Accept'),
                        ),
                      ),
                    ],
                  ),
                if (isPendingInvite) const SizedBox(height: 12),
                if (isCreator)
                  Row(
                    children: [
                      if (uninvited.isNotEmpty)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showInviteDialog(context, provider, event),
                            icon: const Icon(Icons.person_add, size: 16),
                            label: const Text("Invite"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      if (uninvited.isNotEmpty) const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showEditEventDialog(context, provider, event),
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text("Edit"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _confirmCancelEvent(context, provider, event.id),
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: const Text("Delete"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            side: BorderSide(color: Colors.red.shade200),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendeeChip(String name, InvitationStatus status) {
    final isAccepted = status == InvitationStatus.accepted;
    final color = isAccepted ? Colors.green.shade700 : Colors.orange.shade700;
    final background = isAccepted ? Colors.green.shade50 : Colors.orange.shade50;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name.split(' ').first,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(width: 4),
          Icon(isAccepted ? Icons.check : Icons.access_time, size: 12, color: color),
        ],
      ),
    );
  }

  List<FamilyMember> _getAllMembers(FamilyProvider provider) {
    final members = [provider.currentUser, ...provider.members];
    final seen = <String>{};
    return members.where((member) => seen.add(member.id)).toList();
  }

  String _memberName(FamilyProvider provider, String memberId) {
    final all = _getAllMembers(provider);
    final found = all.firstWhere((m) => m.id == memberId, orElse: () => provider.currentUser);
    return found.name;
  }

  bool _isMemberAvailable(
    FamilyProvider provider,
    String memberId,
    DateTime date,
    TimeOfDay time,
    int durationMinutes,
  ) {
    final start = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    final end = start.add(Duration(minutes: durationMinutes));

    final events = provider.upcomingEvents.where((event) {
      if (!_isSameDay(event.dateTime, date)) return false;
      return event.invitedMembers.any(
        (invite) => invite.memberId == memberId && invite.status == InvitationStatus.accepted,
      );
    });

    for (final event in events) {
      final eventEnd = event.dateTime.add(Duration(minutes: event.durationMinutes));
      final overlaps = start.isBefore(eventEnd) && end.isAfter(event.dateTime);
      if (overlaps) return false;
    }
    return true;
  }

  List<String> _suggestTimes(
    FamilyProvider provider,
    List<String> memberIds,
    DateTime date,
    int durationMinutes,
  ) {
    final suggestions = <String>[];
    for (int hour = 8; hour < 20; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        final time = TimeOfDay(hour: hour, minute: minute);
        final allAvailable = memberIds.every(
          (id) => _isMemberAvailable(provider, id, date, time, durationMinutes),
        );
        if (allAvailable) {
          suggestions.add(time.format(context));
          if (suggestions.length >= 3) return suggestions;
        }
      }
    }
    return suggestions;
  }
  void _showAddEventDialog(BuildContext context, FamilyProvider provider) {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    DateTime selectedDate = _selectedDay;
    TimeOfDay selectedTime = TimeOfDay.now();
    int durationMinutes = 60;
    final selectedMembers = <String>{};
    bool showSuggestions = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final allMembers = _getAllMembers(provider);
          final selectedMemberIds = selectedMembers.toList();
          final suggestedTimes = showSuggestions
              ? _suggestTimes(provider, selectedMemberIds, selectedDate, durationMinutes)
              : <String>[];

          return AlertDialog(
            title: const Text('New Event'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Event Title'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setModalState(() => selectedDate = picked);
                            }
                          },
                          icon: const Icon(Icons.calendar_today_outlined, size: 16),
                          label: Text(DateFormat('MMM d').format(selectedDate)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (picked != null) {
                              setModalState(() => selectedTime = picked);
                            }
                          },
                          icon: const Icon(Icons.schedule, size: 16),
                          label: Text(selectedTime.format(context)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: durationMinutes,
                    decoration: const InputDecoration(labelText: 'Duration'),
                    items: const [
                      DropdownMenuItem(value: 30, child: Text('30 minutes')),
                      DropdownMenuItem(value: 60, child: Text('60 minutes')),
                      DropdownMenuItem(value: 90, child: Text('90 minutes')),
                      DropdownMenuItem(value: 120, child: Text('120 minutes')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() => durationMinutes = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(labelText: 'Location (Optional)'),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Invite Family Members',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: allMembers.map((member) {
                      final isAvailable = _isMemberAvailable(
                        provider,
                        member.id,
                        selectedDate,
                        selectedTime,
                        durationMinutes,
                      );
                      final isSelected = selectedMembers.contains(member.id);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.blue.shade300 : Colors.grey.shade200,
                          ),
                          color: isSelected ? Colors.blue.shade50 : Colors.white,
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: isSelected,
                              onChanged: (_) {
                                setModalState(() {
                                  if (isSelected) {
                                    selectedMembers.remove(member.id);
                                  } else {
                                    selectedMembers.add(member.id);
                                  }
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            AvatarView(
                              avatarUrl: member.avatarUrl,
                              fallbackInitial: member.name[0],
                              radius: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(member.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isAvailable ? Colors.green.shade50 : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isAvailable ? 'Available' : 'Busy',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isAvailable ? Colors.green.shade700 : Colors.red.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  if (selectedMembers.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: OutlinedButton.icon(
                        onPressed: () => setModalState(() => showSuggestions = !showSuggestions),
                        icon: const Icon(Icons.auto_awesome, size: 16),
                        label: Text(showSuggestions ? 'Hide Suggested Times' : 'Suggest Ideal Time'),
                      ),
                    ),
                  if (showSuggestions)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: suggestedTimes.isEmpty
                          ? Row(
                              children: const [
                                Icon(Icons.info_outline, size: 16, color: Colors.orange),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'No common times found. Invitations will be sent for approval.',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            )
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: suggestedTimes
                                  .map((time) => OutlinedButton(
                                        onPressed: () {
                                          final parsed = _parseTimeOfDay(time);
                                          if (parsed != null) {
                                            setModalState(() => selectedTime = parsed);
                                          }
                                        },
                                        child: Text(time),
                                      ))
                                  .toList(),
                            ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              FilledButton(
                onPressed: () {
                  if (titleController.text.trim().isEmpty) return;
                  final dateTime = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );
                  final creatorId = provider.currentUser.id;
                  final invitees = <EventInvite>[
                    EventInvite(memberId: creatorId, status: InvitationStatus.accepted),
                    ...selectedMembers
                        .where((id) => id != creatorId)
                        .map((id) => EventInvite(memberId: id, status: InvitationStatus.pending)),
                  ];
                  provider.addEvent(
                    CalendarEvent(
                      id: DateTime.now().toString(),
                      title: titleController.text.trim(),
                      dateTime: dateTime,
                      durationMinutes: durationMinutes,
                      location: locationController.text.trim().isEmpty ? null : locationController.text.trim(),
                      assignedMemberId: creatorId,
                      createdById: creatorId,
                      invitedMembers: invitees,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Send Invitations'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showInviteDialog(BuildContext context, FamilyProvider provider, CalendarEvent event) {
    final uninvited = _getUninvitedMembers(provider, event);
    final selected = <String>{};

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: const Text('Invite More Members'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: uninvited.isEmpty
                    ? [
                        const Text('All family members are already invited.'),
                      ]
                    : uninvited.map((member) {
                        final isSelected = selected.contains(member.id);
                        return CheckboxListTile(
                          value: isSelected,
                          title: Text(member.name),
                          onChanged: (_) {
                            setModalState(() {
                              if (isSelected) {
                                selected.remove(member.id);
                              } else {
                                selected.add(member.id);
                              }
                            });
                          },
                        );
                      }).toList(),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              FilledButton(
                onPressed: selected.isEmpty
                    ? null
                    : () {
                        provider.inviteMembers(event.id, selected.toList());
                        Navigator.pop(context);
                      },
                child: const Text('Send Invitations'),
              ),
            ],
          );
        },
      ),
    );
  }
  void _showEditEventDialog(BuildContext context, FamilyProvider provider, CalendarEvent event) {
    final titleController = TextEditingController(text: event.title);
    final locationController = TextEditingController(text: event.location ?? '');
    DateTime selectedDate = event.dateTime;
    TimeOfDay selectedTime = TimeOfDay(hour: event.dateTime.hour, minute: event.dateTime.minute);
    int durationMinutes = event.durationMinutes;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: const Text('Edit Event'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Event Title'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setModalState(() => selectedDate = picked);
                            }
                          },
                          icon: const Icon(Icons.calendar_today_outlined, size: 16),
                          label: Text(DateFormat('MMM d').format(selectedDate)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (picked != null) {
                              setModalState(() => selectedTime = picked);
                            }
                          },
                          icon: const Icon(Icons.schedule, size: 16),
                          label: Text(selectedTime.format(context)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: durationMinutes,
                    decoration: const InputDecoration(labelText: 'Duration'),
                    items: const [
                      DropdownMenuItem(value: 30, child: Text('30 minutes')),
                      DropdownMenuItem(value: 60, child: Text('60 minutes')),
                      DropdownMenuItem(value: 90, child: Text('90 minutes')),
                      DropdownMenuItem(value: 120, child: Text('120 minutes')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setModalState(() => durationMinutes = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(labelText: 'Location (Optional)'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Updating the event will reset pending invites.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              FilledButton(
                onPressed: () {
                  if (titleController.text.trim().isEmpty) return;
                  final dateTime = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );
                  final resetInvites = event.invitedMembers.map((invite) {
                    if (invite.memberId == event.createdById) {
                      return invite.copyWith(status: InvitationStatus.accepted);
                    }
                    return invite.copyWith(status: InvitationStatus.pending);
                  }).toList();
                  provider.updateEvent(
                    event.id,
                    event.copyWith(
                      title: titleController.text.trim(),
                      dateTime: dateTime,
                      durationMinutes: durationMinutes,
                      location: locationController.text.trim().isEmpty ? null : locationController.text.trim(),
                      invitedMembers: resetInvites,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Update Event'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmCancelEvent(BuildContext context, FamilyProvider provider, String eventId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Event'),
        content: const Text('Are you sure you want to cancel this event? Everyone will be notified.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Keep')),
          FilledButton(
            onPressed: () {
              provider.cancelEvent(eventId);
              Navigator.pop(context);
            },
            child: const Text('Cancel Event'),
          ),
        ],
      ),
    );
  }

  List<FamilyMember> _getUninvitedMembers(FamilyProvider provider, CalendarEvent event) {
    final invitedIds = event.invitedMembers.map((invite) => invite.memberId).toSet();
    return _getAllMembers(provider).where((member) => !invitedIds.contains(member.id)).toList();
  }

  TimeOfDay? _parseTimeOfDay(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1].split(' ').first);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }
}
