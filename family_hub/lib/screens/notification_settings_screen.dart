import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _eventReminders = true;
  bool _taskUpdates = true;
  bool _shoppingUpdates = true;
  bool _locationAlerts = false;
  bool _sosAlerts = true;
  bool _quietHours = false;

  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Choose which updates you want to receive.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reminders',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Event reminders'),
                    subtitle: const Text('Get a heads-up before scheduled events.'),
                    value: _eventReminders,
                    onChanged: (value) => setState(() => _eventReminders = value),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Task updates'),
                    subtitle: const Text('Chore assignments and completions.'),
                    value: _taskUpdates,
                    onChanged: (value) => setState(() => _taskUpdates = value),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Shopping list changes'),
                    subtitle: const Text('Items added or checked off.'),
                    value: _shoppingUpdates,
                    onChanged: (value) => setState(() => _shoppingUpdates = value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Safety',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Location sharing alerts'),
                    subtitle: const Text('When someone starts or stops sharing.'),
                    value: _locationAlerts,
                    onChanged: (value) => setState(() => _locationAlerts = value),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('SOS alerts'),
                    subtitle: const Text('Urgent alerts from family members.'),
                    value: _sosAlerts,
                    onChanged: (value) => setState(() => _sosAlerts = value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            child: Column(
              children: [
                ListTile(
                  title: const Text('Notification sound'),
                  subtitle: const Text('FamilyHub Tone (notification_tone.wav)'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sound picker placeholder.')),
                    );
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: const Text('Quiet hours'),
                  subtitle: const Text('Mute non-urgent alerts at night.'),
                  value: _quietHours,
                  onChanged: (value) => setState(() => _quietHours = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'SOS alerts are always prioritized for safety.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
