import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/family_provider.dart';
import '../models/app_models.dart';
import '../widgets/avatar_view.dart';
import '../utils/external_actions.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final familyData = Provider.of<FamilyProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context, familyData),
              if (familyData.isSosActive)
                _ActiveSosBanner(familyData: familyData),
              const SizedBox(height: 32),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
              ),
              const SizedBox(height: 16),
              _buildQuickActionsGrid(context),
              const SizedBox(height: 32),

              // Family Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Family',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/family'),
                    child: Text(
                      "View All",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              ...familyData.members.map((member) => _buildFamilyMemberCard(context, member)),
              
              const SizedBox(height: 32),

              // Upcoming Events Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                    'Upcoming',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                  ),
                   TextButton(
                    onPressed: () => context.go('/calendar'),
                    child: const Text("View Calendar"),
                  )
                ],
              ),
              const SizedBox(height: 16),
              ...familyData.upcomingEvents.take(2).map((event) => _buildUpcomingCard(context, event, familyData)),

              const SizedBox(height: 32),

              // Pending Tasks Section
              Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    Text(
                      'Pending Tasks',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${familyData.pendingTasks.where((t) => t.type == TaskType.chore && t.status != TaskStatus.completed).length} new',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    )
                ],
              ),
              const SizedBox(height: 16),
              _buildNotificationsPanel(context, familyData),
              const SizedBox(height: 12),
              ...familyData.pendingTasks
                  .where((task) => task.type == TaskType.chore && task.status != TaskStatus.completed)
                  .take(2)
                  .map((task) => _buildTaskCard(context, task, familyData)),


              const SizedBox(height: 32),
              
              // Shopping Tasks Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Shopping Tasks',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/tasks'),
                    child: Text(
                      "View All",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              ...familyData.pendingTasks
                  .where((task) => task.type == TaskType.shopping)
                  .toList()
                  .reversed
                  .take(3)
                  .map((task) => _buildShoppingCard(context, task, familyData)),

              // Bottom spacing
              const SizedBox(height: 80), 
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, FamilyProvider familyData) {
    final user = familyData.currentUser;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FamilyHub',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Welcome back, ${user.name}',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Row(
          children: [
             Stack(
               children: [
                 IconButton(
                   icon: const Icon(Icons.notifications_outlined, size: 28),
                   onPressed: () => _showNotificationsSheet(context, familyData),
                   color: Theme.of(context).colorScheme.onSurface,
                 ),
                 if (_currentUserNotifications(familyData).isNotEmpty)
                   Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: Text(
                          '${_currentUserNotifications(familyData).length}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                   )
               ],
             ),
             const SizedBox(width: 8),
             InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => context.go('/profile'),
              child: AvatarView(
                avatarUrl: user.avatarUrl,
                fallbackInitial: user.name[0],
                radius: 20,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildActionCard(
          context,
          icon: Icons.calendar_today,
          label: 'Add Event',
          color: Colors.blue,
          onTap: () => context.go('/calendar'),
        ),
        _buildActionCard(
          context,
          icon: Icons.playlist_add_check,
          label: 'Add Task',
          color: Colors.green,
          onTap: () => context.go('/tasks'),
        ),
        _buildActionCard(
          context,
          icon: Icons.location_on_outlined,
          label: 'Check Location',
          color: Colors.purple,
          onTap: () => context.go('/map'),
        ),
        _buildActionCard(
          context,
          icon: Icons.add, // Or emergency icon
          label: 'Emergency',
          color: Colors.red,
          isEmergency: true,
          onTap: () => context.go('/sos'),
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, {
    required IconData icon, 
    required String label, 
    required Color color, 
    required VoidCallback onTap,
    bool isEmergency = false,
  }) {
    return _InteractiveActionCard(
      icon: icon,
      label: label,
      color: color,
      onTap: onTap,
    );
  }

  Widget _buildFamilyMemberCard(BuildContext context, FamilyMember member) {
    final role = member.relationLabel.isNotEmpty ? member.relationLabel : "Member";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AvatarView(
                avatarUrl: member.avatarUrl,
                fallbackInitial: member.name[0],
                radius: 28,
                backgroundColor: Colors.grey.shade200,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          member.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            role,
                            style: TextStyle(
                              color: Colors.purple.shade400,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          member.locationLabel ?? 'Location disabled',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                        if (member.locationLabel != null) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.location_on, size: 12, color: Colors.blue),
                          const SizedBox(width: 4),
                          const Text(
                            "Sharing",
                            style: TextStyle(color: Colors.blue, fontSize: 13),
                          ),
                        ]
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Action Buttons
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 12,
            runSpacing: 12,
            children: [
              _InteractiveSocialButton(
                icon: FontAwesomeIcons.phone,
                color: Colors.green.shade600,
                tooltipMessage: 'Call ${member.name.split(' ').first}',
              ),
              _InteractiveSocialButton(
                icon: FontAwesomeIcons.whatsapp,
                color: const Color(0xFF25D366),
                tooltipMessage: 'WhatsApp ${member.name.split(' ').first}',
              ),
              _InteractiveSocialButton(
                icon: FontAwesomeIcons.telegram,
                color: const Color(0xFF229ED9),
                tooltipMessage: 'Telegram ${member.name.split(' ').first}',
              ),
              _InteractiveSocialButton(
                icon: FontAwesomeIcons.facebookMessenger,
                color: const Color(0xFF1877F2),
                tooltipMessage: 'Message ${member.name.split(' ').first}',
              ),
              _InteractiveSocialButton(
                icon: FontAwesomeIcons.instagram,
                color: const Color(0xFFE1306C),
                tooltipMessage: 'Instagram @${member.name.toLowerCase()}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingCard(BuildContext context, CalendarEvent event, FamilyProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                   event.title,
                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                 ),
                 const SizedBox(height: 4),
                 // Mock Today/Tomorrow logic
                 Text(
                   "Today, ${DateFormat.Hm().format(event.dateTime)}",
                   style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                 ),
              ],
            ),
          ),
          // Participant Bubbles
          Row(
            children: [
               CircleAvatar(
                 radius: 12,
                 backgroundColor: Colors.blue,
                 child: Text("Y", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)), // You
               ),
               if (event.assignedMemberId != 'u1') ...[
                 const SizedBox(width: 4),
                 CircleAvatar(
                   radius: 12,
                   backgroundColor: Colors.blue.shade100,
                   child: Text(
                     provider.members.firstWhere((m) => m.id == event.assignedMemberId, orElse: () => provider.currentUser).name[0],
                     style: TextStyle(color: Colors.blue.shade800, fontSize: 10, fontWeight: FontWeight.bold),
                   ),
                 ),
               ]
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, TaskItem task, FamilyProvider provider) {
    // Find assignee name if not current user
    String assigneeName = "You";
    if (task.assignedMemberId != null && task.assignedMemberId != 'u1') {
       final member = provider.members.firstWhere((m) => m.id == task.assignedMemberId, orElse: () => provider.currentUser);
       assigneeName = member.name;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
         children: [
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                 const SizedBox(height: 6),
                 Row(
                   children: [
                     Container(
                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                       decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                       child: Text(assigneeName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                     ),
                     const SizedBox(width: 8),
                     Text("Today", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                   ],
                 )
               ],
             ),
           ),
           Checkbox(
             value: task.status == TaskStatus.completed, 
             onChanged: (val) => provider.toggleTaskCompleted(task.id),
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
             activeColor: Colors.blue,
           )
         ],
      ),
    );
  }

  Widget _buildNotificationsPanel(BuildContext context, FamilyProvider provider) {
    final notifications = _currentUserNotifications(provider);
    if (notifications.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Text('No new notifications'),
      );
    }

    return Column(
      children: notifications.map((notification) {
        final content = Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: _notificationDecoration(notification),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(notification.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    onPressed: () => provider.dismissNotification(notification.id),
                    icon: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(notification.message, style: TextStyle(color: Colors.grey.shade700)),
              const SizedBox(height: 8),
              Text(
                _formatTimestamp(notification.timestamp),
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
              if (notification.type == NotificationType.sosAlert) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final member = _notificationSourceMember(provider, notification);
                          if (member == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No caller details available.')),
                            );
                            return;
                          }
                          await ExternalActions.callMember(context, member);
                        },
                        icon: const Icon(Icons.call, size: 16),
                        label: const Text('Call'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          final member = _notificationSourceMember(provider, notification);
                          if (member == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No location details available.')),
                            );
                            return;
                          }
                          await ExternalActions.navigateToMember(context, member);
                        },
                        icon: const Icon(Icons.navigation_outlined, size: 16),
                        label: const Text('Navigate'),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              if (notification.type == NotificationType.eventInvitation && notification.eventId != null)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => provider.declineInvitation(notification.eventId!, provider.currentUser.id),
                        child: const Text('Decline'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => provider.acceptInvitation(notification.eventId!, provider.currentUser.id),
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              if (notification.type == NotificationType.taskAssigned && notification.taskId != null)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          provider.declineTask(notification.taskId!);
                          provider.dismissNotification(notification.id);
                        },
                        child: const Text('Decline'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          provider.acceptTask(notification.taskId!);
                          provider.dismissNotification(notification.id);
                        },
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              if (!notification.actionRequired)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => provider.dismissNotification(notification.id),
                    child: const Text('Dismiss'),
                  ),
                ),
            ],
          ),
        );
        return _shouldBlinkNotification(notification) ? _BlinkingAlert(child: content) : content;
      }).toList(),
    );
  }

  void _showNotificationsSheet(BuildContext context, FamilyProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Consumer<FamilyProvider>(
        builder: (context, liveProvider, child) {
          final notifications = _currentUserNotifications(liveProvider);
          return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notifications', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                if (notifications.isEmpty)
                  const Text('No new notifications')
                else
                  Expanded(
                    child: ListView(
                      children: notifications.map((notification) {
                          final content = Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: _notificationDecoration(notification),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(notification.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  IconButton(
                                    onPressed: () => liveProvider.dismissNotification(notification.id),
                                    icon: const Icon(Icons.close, size: 18),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(notification.message, style: TextStyle(color: Colors.grey.shade700)),
                              const SizedBox(height: 8),
                              Text(
                                _formatTimestamp(notification.timestamp),
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                              ),
                              if (notification.type == NotificationType.sosAlert) ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () async {
                                          final member = _notificationSourceMember(liveProvider, notification);
                                          if (member == null) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('No caller details available.')),
                                            );
                                            return;
                                          }
                                          await ExternalActions.callMember(context, member);
                                        },
                                        icon: const Icon(Icons.call, size: 16),
                                        label: const Text('Call'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: FilledButton.icon(
                                        onPressed: () async {
                                          final member = _notificationSourceMember(liveProvider, notification);
                                          if (member == null) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('No location details available.')),
                                            );
                                            return;
                                          }
                                          await ExternalActions.navigateToMember(context, member);
                                        },
                                        icon: const Icon(Icons.navigation_outlined, size: 16),
                                        label: const Text('Navigate'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (notification.type == NotificationType.eventInvitation && notification.eventId != null)
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          liveProvider.declineInvitation(notification.eventId!, liveProvider.currentUser.id);
                                          liveProvider.dismissNotification(notification.id);
                                        },
                                        child: const Text('Decline'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: FilledButton(
                                        onPressed: () {
                                          liveProvider.acceptInvitation(notification.eventId!, liveProvider.currentUser.id);
                                          liveProvider.dismissNotification(notification.id);
                                        },
                                        child: const Text('Accept'),
                                      ),
                                    ),
                                  ],
                                ),
                              if (notification.type == NotificationType.taskAssigned && notification.taskId != null)
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          liveProvider.declineTask(notification.taskId!);
                                          liveProvider.dismissNotification(notification.id);
                                        },
                                        child: const Text('Decline'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: FilledButton(
                                        onPressed: () {
                                          liveProvider.acceptTask(notification.taskId!);
                                          liveProvider.dismissNotification(notification.id);
                                        },
                                        child: const Text('Accept'),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        );
                          return _shouldBlinkNotification(notification)
                              ? _BlinkingAlert(child: content)
                              : content;
                      }).toList(),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
        },
      ),
    );
  }

  BoxDecoration _notificationDecoration(NotificationItem notification) {
    switch (notification.type) {
      case NotificationType.eventInvitation:
        return BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.shade100),
        );
      case NotificationType.eventUpdate:
        return BoxDecoration(
          color: Colors.indigo.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.indigo.shade100),
        );
      case NotificationType.taskCompleted:
        return BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade100),
        );
      case NotificationType.shoppingShared:
        return BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.shade100),
        );
      case NotificationType.shoppingItemAssigned:
        return BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.shade100),
        );
      case NotificationType.shoppingItemCompleted:
        return BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade100),
        );
      case NotificationType.sosResolved:
        return BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        );
      case NotificationType.sosAlert:
        return BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade200),
        );
      case NotificationType.sosLocationUpdate:
        return BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.shade100),
        );
      case NotificationType.taskAssigned:
      default:
        return BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.shade100),
        );
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  List<NotificationItem> _currentUserNotifications(FamilyProvider provider) {
    return provider.notifications.where((notification) {
      return notification.recipientId == null ||
          notification.recipientId == provider.currentUser.id;
    }).toList();
  }

  Widget _buildShoppingCard(BuildContext context, TaskItem task, FamilyProvider provider) {
    final creator = provider.members.firstWhere(
      (m) => m.id == task.createdById,
      orElse: () => provider.currentUser,
    );
    final dueDate = task.dueDate != null ? DateFormat('MMM d').format(task.dueDate!) : 'No due date';
    final itemCount = task.shoppingItems.length;
    final isNew = task.status == TaskStatus.pending;
    final canAccept = isNew && task.assignedMemberId == provider.currentUser.id;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Row(
        children: [
           const CircleAvatar(
             backgroundColor: Colors.orange,
             child: Icon(Icons.shopping_cart_outlined, color: Colors.white),
           ),
           const SizedBox(width: 16),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Row(
                   children: [
                     Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                     if (isNew) ...[
                       const SizedBox(width: 8),
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                         decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(4)),
                         child: const Text("New", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                       )
                     ]
                   ],
                 ),
                 const SizedBox(height: 4),
                 Text(
                   'By ${creator.name} • $dueDate • $itemCount items',
                   style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                 ),
               ],
             ),
           ),
            FilledButton(
              onPressed: () {
                if (canAccept) {
                  provider.acceptTask(task.id);
                }
                context.go('/tasks');
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.orange[800], minimumSize: const Size(60, 32), padding: EdgeInsets.symmetric(horizontal: 12)),
              child: Text(canAccept ? "Accept" : "Open", style: const TextStyle(fontSize: 12)),
            )
        ],
      ),
    );
  }

  // Removed _buildSocialButton in favor of _InteractiveSocialButton

  FamilyMember? _notificationSourceMember(FamilyProvider provider, NotificationItem notification) {
    final sourceId = notification.sourceMemberId;
    if (sourceId == null) return null;
    if (sourceId == provider.currentUser.id) return provider.currentUser;
    for (final member in provider.members) {
      if (member.id == sourceId) return member;
    }
    return null;
  }

  bool _shouldBlinkNotification(NotificationItem notification) {
    return notification.type == NotificationType.sosAlert;
  }
}

class _BlinkingAlert extends StatefulWidget {
  final Widget child;

  const _BlinkingAlert({required this.child});

  @override
  State<_BlinkingAlert> createState() => _BlinkingAlertState();
}

class _BlinkingAlertState extends State<_BlinkingAlert> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: widget.child,
    );
  }
}

class _InteractiveSocialButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String tooltipMessage;

  const _InteractiveSocialButton({
    required this.icon,
    required this.color,
    required this.tooltipMessage,
  });

  @override
  State<_InteractiveSocialButton> createState() => _InteractiveSocialButtonState();
}

class _InteractiveSocialButtonState extends State<_InteractiveSocialButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltipMessage,
      verticalOffset: 24,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(color: Colors.white, fontSize: 12),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _isHovered ? widget.color : widget.color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Icon(
            widget.icon,
            color: _isHovered ? Colors.white : widget.color,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _InteractiveActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _InteractiveActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_InteractiveActionCard> createState() => _InteractiveActionCardState();
}

class _InteractiveActionCardState extends State<_InteractiveActionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.identity()..scale(_isHovered ? 1.03 : 1.0),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: _isHovered ? widget.color.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? widget.color.withValues(alpha: 0.3) : Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered 
                    ? widget.color.withValues(alpha: 0.15) 
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: _isHovered ? 15 : 10,
                offset: Offset(0, _isHovered ? 6 : 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon, 
                size: _isHovered ? 34 : 32, 
                color: widget.color,
              ),
              const SizedBox(height: 12),
              Text(
                widget.label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: _isHovered ? widget.color.withGreen(widget.color.green ~/ 1.5) : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveSosBanner extends StatefulWidget {
  final FamilyProvider familyData;
  const _ActiveSosBanner({required this.familyData});

  @override
  State<_ActiveSosBanner> createState() => _ActiveSosBannerState();
}

class _ActiveSosBannerState extends State<_ActiveSosBanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isInitiator = widget.familyData.sosInitiatorId == widget.familyData.currentUser.id;
    
    final initiator = widget.familyData.sosInitiatorId != null 
        ? widget.familyData.members.firstWhere(
            (m) => m.id == widget.familyData.sosInitiatorId, 
            orElse: () => widget.familyData.currentUser)
        : null;
        
    final name = initiator?.name ?? 'A family member';
    
    final titleText = isInitiator ? 'YOUR SOS IS ACTIVE' : 'SOS ACTIVE';
    final subtitleText = isInitiator ? 'Broadcasting your location now' : '$name needs help!';

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(top: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.05 + (_animation.value * 0.1)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.red.withValues(alpha: _animation.value * 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: _animation.value * 0.2),
                blurRadius: 15,
                spreadRadius: 2,
              )
            ]
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titleText, style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
                    Text(subtitleText, style: TextStyle(color: Colors.red.shade900, fontSize: 14)),
                  ],
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                   backgroundColor: Colors.red.shade700,
                   foregroundColor: Colors.white,
                ),
                onPressed: () => context.go(isInitiator ? '/sos' : '/map'),
                child: Text(isInitiator ? 'Manage' : 'View Map'),
              )
            ],
          ),
        );
      },
    );
  }
}
